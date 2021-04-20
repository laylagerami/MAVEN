# Run chemical sketcher on launch
observeEvent(input$launch_app, {
  rstudioapi::jobRunScript(path = "gadget_script.R")
})

# Example SMILES?
observe({
  if (input$example_smiles){ # Example toggled ON
    values$smiles_error=F
    shinyjs::disable(id = "smiles_file") # Disable file upload
    values$smiles_file = "Example_Data/DCLK1IN1.txt"
    values$smi_string <- read.csv(values$smiles_file, header = F,sep="\t")[1,1] # read the SMILES 
    output$smiles_uploaded_checker <- renderText({
      "SMILES uploaded successfully. Please continue to the Run Options tab."
    })
    output$chemdoodle = renderChemdoodle(
      chemdoodle_viewer(values$smi_string,width=200,height=200)
    )
  }else{
    values$smi_string=NULL # remove smiles if toggled off
    values$smiles_error=NULL
    values$smiles_file =NULL
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
        
        # Check they're ok
        smicheck = try(chemdoodle_viewer(values$smi_string))
        if(inherits(smicheck,"try-error")){
          values$smiles_error = T # USE THIS FLAG TO GREY OUT THE PREDICTION BUTTON
          output$smiles_uploaded_checker <- renderText({
            "There seems to be an issue with your SMILES string. Please check your file and re-upload."
          })
        }else{
          values$smiles_error = F
          output$chemdoodle = renderChemdoodle(
            chemdoodle_viewer(values$smi_string,width=200,height=200)
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
  else{
    enable("button")
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

# Select PIDGINv4 dir
volumes <- getVolumes()()
shinyDirChoose(input, 'pidginfolder', roots=volumes, filetypes=c('', 'py'),allowDirCreate=T)
observe({
  values$pidginfolder = input$pidginfolder
  values$pidgindir = paste(unlist(unname(values$pidginfolder[1])),collapse="/")
  values$predictpy = paste0(values$pidgindir,"/predict.py")
  values$sim2train = paste0(values$pidgindir,"/sim_to_train.py")
})

# Run PIDGIN
started <- reactiveVal(Sys.time()[NA])
observeEvent(input$button, {
  withProgress(message="Running PIDGIN...settings saved to logs folder...",value=1, {
    started(Sys.time())
    time_now = gsub(" ","_",Sys.time())
    time_now = gsub(":","-",time_now)
    bin_bash <- "#!/bin/bash"
    conda_activate <- "source activate pidgin3_env" # activate conda
    # define output name and args
    output_name <- paste0("output/","PIDGIN_",values$pidginBa,"_",values$pidginAd,"_",values$pidginCores,"_",time_now)
    values$output_name_pidgin <- paste0(output_name,"_out_predictions.txt")
    args <- paste0("-f ",values$smi_file$datapath, " -d '\t' --organism 'Homo' -b ",values$pidginBa, " --ad ",values$pidginAd," -n ",values$pidginCores," -o ",values$output_name_pidgin)
    runline <- paste0("python ",values$predictpy," ",args) # command line input
    # define sim to train - doesnt work currently
    values$output_name2 = paste0("output/","PIDGIN_",values$pidginBa,"_",values$pidginAd,"_",values$pidginCores,"_",time_now)
    args2 <- paste0("-f",values$smi_file$datapath, " --organism 'Homo' -b ",values$pidginBa, " -n ",values$pidginCores," -o ",values$output_name2)
    runline2 <- paste0("python ",values$sim2train," ",args2)
    bash_file <- data.frame(c(bin_bash,conda_activate,runline,runline2))
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
    output$pidgindone <- renderText({
      paste0("PIDGIN run completed. Full results saved to 'output' folder. Please move onto Results tab to view the results.")
    })
  }
})

# Render table with link to uniprotdb
output$targettable <- renderDT({
  if(!is.null(input$pidgin_file)){
    preds = read.csv(input$pidgin_file$datapath, header = T,sep="\t")
  }else{
    preds = values$preds
  }
  preds = preds[order(-preds[,17]),]
  colnames(preds)[17] = "Probability"
  conversion = AnnotationDbi::select(org.Hs.eg.db,
                                     as.character(preds$Gene_ID),
                                     columns=c("ENTREZID","SYMBOL"),
                                     ketype="ENTREZID")
  preds$Gene_ID <- conversion$SYMBOL
  values$preds_converted = preds
  preds$url <- paste0("https://www.uniprot.org/uniprot/",preds$Uniprot)
  preds$Gene_ID <- paste0("<a href='",preds$url,"' target='_blank'>",preds$Gene_ID,"</a>")
  preds = preds[,c(3,2,4,17)]
  datatable(preds,options=list("pageLength"=5),escape=1)

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
  if (length(selected)){
    values$targets = as.character(values$preds_converted[selected,]$Gene_ID)
    output$selected_targets <- renderText({
      paste(values$targets,collapse=", ")
    })
  }
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



