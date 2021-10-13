# Chemical sketcher
#set a dummy reactive variable
mol <- reactiveValues(moleculedata = NULL,smiles=NULL,molname=NULL,df=NULL)

#function to update the value based on changes on the shiny side
observeEvent(input$moleculedata, {
  moljson <- input$moleculedata
  mol$moleculedata <- processChemDoodleJson(moljson)
  
})

# output function renders SMILES
output$smiles_out <- renderText({
  if (is.null(mol$moleculedata)){
    return("No SMILES? Draw a molecule and click Done to retrieve SMILES file")
  } else {
    mol$smiles <- toSmiles(mol$moleculedata)
    return(paste("Smiles:", mol$smiles))
  }
})

# Render table
output$smiles_table <- renderTable({
  if(!is.null(mol$moleculedata)){
    if(input$comp_name==""){
      mol$molname = "Compound"
      df = t(data.frame(c(mol$smiles,"Compound 1")))
      row.names(df) = NULL
      colnames(df) = c("SMILES","Compound Name")
      mol$df = df
    }else{
      mol$molname = input$comp_name
      df = t(data.frame(c(mol$smiles,input$comp_name)))
      row.names(df) = NULL
      colnames(df) = c("SMILES","Compound Name")
      mol$df = df
    }
    df
  }
})

output$downloadsmi <- renderUI({
  if(!is.null(mol$smiles)){
    downloadButton("downloadSmiles", "Download .smi file")
  }
})

# Downloader
output$downloadSmiles <- downloadHandler(
  filename = function() {
    paste0(mol$molname, ".smi")
  },
  content = function(con) {
    write.table(mol$df, con, row.names = FALSE, col.names=FALSE,sep="\t",quote=F)
  }
)

# Example SMILES?
observe({
  if (input$example_smiles){ # Example toggled ON
    values$smiles_error=F
    shinyjs::disable(id = "smiles_file") # Disable file upload
    values$smi_file$datapath <- "Example_Data/lapatinib/lapatinib.txt"
    values$smi_string <- read.csv(values$smi_file$datapath, header = F,sep="\t")[1,1] # read the SMILES 
    output$smiles_uploaded_checker <- renderText({
      "SMILES uploaded successfully. Please continue to the Run Options tab."
    })
    output$chemdoodle = renderChemdoodle(
      chemdoodle_viewer(values$smi_string,width=200,height=200)
    )
  }else{
    values$smiles_error=NULL
    shinyjs::enable(id = "smiles_file") # Enable file upload
    # Get smiles, check they're OK and render image
    observeEvent(input$smiles_file, {
      values$smi_file <- input$smiles_file
      ext <- tools::file_ext(values$smi_file$datapath)
      req(values$smi_file)
      
      # check file
      filecheck <- try(read.csv(values$smi_file$datapath,header=F,sep="\t")[1,1])
      if(inherits(filecheck,"try-error")){
        output$smiles_uploaded_checker <- renderText({
          "There seems to be an issue with your file. Please check the help button or documentation to ensure that it is formatted correctly."
          values$smiles_error = T
        })
      }else{
        values$smi_string <- read.csv(values$smi_file$datapath, header = F,sep="\t")[1,1] # read the SMILES 
        smi_string <- as.character(values$smi_string)
        #Check they're ok
        smicheck = tryCatch(chemdoodle_viewer(smi_string), error=function(e) e, warning=function(w) w)
        if(is(smicheck,"warning")){
          values$smiles_error = T # USE THIS FLAG TO GREY OUT THE PREDICTION BUTTON
          output$smiles_uploaded_checker <- renderText({
            "There seems to be an issue with your SMILES string. Please check your file and re-upload."
          })
        }else{
          values$smiles_error = F
          output$chemdoodle = renderChemdoodle(
            chemdoodle_viewer(smi_string,width=200,height=200)
          )
          output$smiles_uploaded_checker <- renderText({
            "SMILES uploaded successfully. Please continue to the Run Options tab."
          })
        }
      }
    })
    
    
    # If nothing uploaded, display "please upload"
    observe({
      if(is.null(values$smiles_error)){
        output$smiles_uploaded_checker <- renderText({
          "Please upload the required information before moving on to target prediction, or move to the Analysis tab to skip target prediction."
        })
      }
    })
  }
})

# Only enable PIDGIN button if SMILES are ok
observe({
  if(is.null(values$smiles_error) || values$smiles_error == T){
    disable("button")
  }
})

# Get pidgin parameters
observeEvent(input$ba, {
  values$pidginBa <- input$ba
})
observeEvent(input$ad, {
  values$pidginAd <- input$ad
})
observeEvent(input$ncores, {
  values$pidginCores <- input$ncores
})

# Select PIDGINv4 dir and get .py scripts
volumes <- getVolumes()()
shinyDirChoose(input, 'pidginfolder', roots=volumes, filetypes=c('', 'py'),allowDirCreate=T)
observe({
  values$pidginfolder = input$pidginfolder
  skksks <<- values$pidginfolder
  
  values$pidgindir = paste(unlist(unname(values$pidginfolder[1])),collapse="/")
 
  #Check they have selected the (correct) folder
  if(paste(unlist(unname(values$pidginfolder[1])),collapse="/")==0){
    disable("button")
    output$pidgin_folder_warning = renderText({"Please select the PIDGINv4 directory, which should contain the model .py files"})
  }else{
    if(!file.exists(paste0(values$pidgindir,"/predict.py"))){
      output$pidgin_folder_warning = renderText({"The directory you selected does not contain the 'predict.py' script required to run PIDGIN. Please ensure you have selected the root directory, and have not modified any file or folder names."})
      disable("button")
    }else{
      enable("button")
      output$pidgin_folder_warning = renderText({""})
    }
  }
  values$predictpy = paste0(values$pidgindir,"/predict.py")
  values$sim2train = paste0(values$pidgindir,"/sim_to_train.py")
})

# Run PIDGIN
started <- reactiveVal(Sys.time()[NA])
observeEvent(input$button, {
  withProgress(message="Running PIDGIN...you can check progress in your R console",value=1, {
    values$output_name2 = NULL # remove previous results
    values$output_name_pidgin = NULL
    
    started(Sys.time())
    time_now = gsub(" ","_",Sys.time())
    time_now = gsub(":","-",time_now)
    values$pidgin_time_now = time_now
    bin_bash <- "#!/bin/bash"
    conda_activate <- "source activate pidgin4_env" # activate conda
    conda_deactivate <- "source deactivate" # deactivate conda
    # define output name and args
    output_name <- paste0("output/","PIDGIN_",values$pidginBa,"_",values$pidginAd,"_",values$pidginCores,"_",time_now)
    values$output_name_pidgin <- paste0(output_name,"_out_predictions.txt")
    args <- paste0("-f ",values$smi_file$datapath, " -d '\t' --organism 'Homo sapiens' -b ",values$pidginBa, " --ad ",values$pidginAd," -n ",values$pidginCores," -o ",values$output_name_pidgin)
    runline <- paste0("python ",values$predictpy," ",args) # command line input
    # define sim to train 
    output_name2 = paste0("output/","PIDGIN_",values$pidginBa,"_",values$pidginAd,"_",values$pidginCores,"_",time_now)
    args2 <- paste0("-f",values$smi_file$datapath, " --organism 'Homo sapiens' -b ",values$pidginBa, " -n ",values$pidginCores," -o ",output_name2)
    values$output_name2 = paste0(output_name2,"_similarity_details.txt")
    values$output_namemat = paste0(output_name2,"_similarity_matrix.txt")
    runline2 <- paste0("python ",values$sim2train," ",args2)
    bash_file <- data.frame(c(bin_bash,conda_activate,runline,runline2,conda_deactivate))
    write.table(bash_file,"./run_pidgin.sh",quote=F,row.names=F,col.names=F)
    write.table(bash_file,paste0("logs/pidgin_command_",time_now,".sh"),quote=F,row.names=F,col.names=F)
    system("bash -i run_pidgin.sh")
    file.remove("./run_pidgin.sh") # remove after
  })
})

# Check if PIDGIN has finished running
observe({
  req(started())
  if(file.exists(values$output_name2)){
    values$preds = read.csv(values$output_name_pidgin,sep="\t",header=T)
    values$simtrain = read.csv(values$output_name2,sep="\t",header=T)
    
    # move output files + command to a folder, remove similarity matrix
    output_pidgin_dir = paste0("output/pidgin_",values$pidgin_time_now)
    dir.create(output_pidgin_dir)
    file.rename(from = values$output_name_pidgin, to=paste0(output_pidgin_dir,"/",gsub("output/","",values$output_name_pidgin)))
    file.rename(from = values$output_name2, to=paste0(output_pidgin_dir,"/",gsub("output/","",values$output_name2)))
    file.remove(values$output_namemat)
    file.copy(from = paste0("logs/pidgin_command_",values$pidgin_time_now,".sh"), to=paste0(output_pidgin_dir,"/pidgin_command_",values$pidgin_time_now))
    
    output$pidgindone <- renderText({
      paste0("Target prediction complete. Predictions, training data similarity details and command-line entry saved to ",output_pidgin_dir,". Please move onto Results tab to view the results.")
    })
  }
})



# Render table with link to uniprotdb
output$targettable <- renderDT({
  if(!is.null(input$pidgin_file)){
    f1 = read.csv(input$pidgin_file[[1,'datapath']],sep="\t")
    f2 = read.csv(input$pidgin_file[[2, 'datapath']],sep="\t")
    if(c("NN_activity") %in% colnames(f1) & c("Activity_Threshold") %in% colnames(f2)){
      preds = f2
      sims = f1
      output$pidgin_input_error = renderText({""})
    }else if(c("NN_activity") %in% colnames(f2) & c("Activity_Threshold") %in% colnames(f1)){
      preds = f1
      sims = f2
      output$pidgin_input_error = renderText({""})
    }else{
      output$pidgin_input_error = renderText({"Please ensure you upload the correct files!"})
    }
  }else{
    preds <- values$preds
    sims <- values$simtrain
  }
  preds_and_sims = merge(preds,sims,by="Uniprot")
  preds_and_sims = preds_and_sims[order(-preds_and_sims[,17]),]
  colnames(preds_and_sims)[17] = "Probability"
  preds_and_sims$Probability = signif(preds_and_sims$Probability,digits=3)
  preds_and_sims$Similarity = signif(preds_and_sims$Similarity,digits=3)
  
  conversion = AnnotationDbi::select(org.Hs.eg.db,
                                     as.character(preds_and_sims$Gene_ID),
                                     columns=c("ENTREZID","SYMBOL"),
                                     ketype="ENTREZID")
  preds_and_sims$Gene_ID <- conversion$SYMBOL
  values$preds_converted = preds_and_sims
  preds_and_sims$url <- paste0("https://www.uniprot.org/uniprot/",preds_and_sims$Uniprot)
  preds_and_sims$Gene_ID <- paste0("<a href='",preds_and_sims$url,"' target='_blank'>",preds_and_sims$Gene_ID,"</a>")
  preds_and_sims = preds_and_sims[,c(3,2,17,22,29,26)]
  preds_and_sims$chembl_url <- paste0("https://www.ebi.ac.uk/chembl/compound_report_card/",preds_and_sims$Near_Neighbor_ChEMBLID)
  preds_and_sims$Near_Neighbor_ChEMBLID <- paste0("<a href='",preds_and_sims$chembl_url,"' target='_blank'>",preds_and_sims$Near_Neighbor_ChEMBLID,"</a>")
  preds_and_sims$chembl_url = NULL
  colnames(preds_and_sims) = c("Gene ID","Name","Predicted Probability","Nearest Neighbour","NN Tanimoto Sim","NN pChEMBL")
  datatable(preds_and_sims,options=list("pageLength"=10),escape=1)

  ### OLD- ADD CHEMBL LINK TO DF
  #url_df = readRDS("sub/hgnc_chembl_url.rds")
  #preds_and_url = merge(preds_converted,url_df,by.x="Gene_ID",by.y="hgncs")
  #preds_and_url$Gene_ID <- paste0("<a href='",preds_and_url$url,"' target='_blank'>",preds_and_url$Gene_ID,"</a>")
  #preds_and_url$Gene_ID = ifelse(preds_and_url$chembl_ids=="NaN",preds_converted$Gene_ID,preds_and_url$Gene_ID)
  #preds_and_url = preds_and_url[order(-preds_and_url[,4]),]
  ##preds_and_url = preds_and_url[,c(1,2,3,4)]
  #datatable(preds_and_url,options = list("pageLength" = 5),escape=1)
})

# List selected targets for user-friendliness
observe({
  selected = input$targettable_rows_selected
  if(length(selected)>0){
    values$targets = as.character(values$preds_converted[selected,]$Gene_ID)
  }else{
    values$targets = NULL
  }
  output$selected_targets <- renderText({
    paste(values$targets,collapse=", ")
  })
})

# User-defined
output$all_targets <- renderText({
  if(input$udtargets==""){
    prev_targets <- paste(values$targets,collapse=", ")
    values$all_targets = values$targets
    updatePickerInput(session, "carnival_targets",
                      choices = values$all_targets,
                      selected=values$all_targets)
    paste0("Selected targets (predicted and user-defined): ",prev_targets)
  }else if(input$udtargets!="" & is.null(values$targets)){
    user_targets <- unlist(strsplit(input$udtargets,"\n"))
    values$all_targets <- user_targets
    updatePickerInput(session, "carnival_targets",
                      choices = values$all_targets,
                      selected=values$all_targets)
    paste0("Selected targets (predicted and user-defined): ",paste(user_targets,collapse=", "))
  }else if(input$udtargets!="" & !is.null(values$targets)){
    user_targets <- unlist(strsplit(input$udtargets,"\n"))
    union_targets <- unique(c(user_targets,values$targets))
    values$all_targets = union_targets
    updatePickerInput(session, "carnival_targets",
                      choices = values$all_targets,
                      selected= values$all_targets)
    paste0("Selected targets (predicted and user-defined): ",paste(union_targets,collapse=", "))
  }
})



