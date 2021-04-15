# Run chemical sketcher on launch
observeEvent(input$launch_app, {
  rstudioapi::jobRunScript(path = "gadget_script.R")
})

# Example SMILES?
observe({
  if (input$example_smiles){ # Example toggled ON
    values$smi_error=F
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
          values$smile_error = T
        })
      }else{
        values$smi_string <- read.csv(values$smi_file$datapath, header = F,sep="\t")[1,1] # read the SMILES 
        
        # Check they're ok
        smicheck = try(chemdoodle_viewer(values$smi_string))
        if(inherits(smicheck,"try-error")){
          values$smile_error = T # USE THIS FLAG TO GREY OUT THE PREDICTION BUTTON
          output$smiles_uploaded_checker <- renderText({
            "There seems to be an issue with your SMILES string. Please check your file and re-upload."
          })
        }else{
          values$smile_error = F
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
      if(is.null(values$smile_error)){
        output$smiles_uploaded_checker <- renderText({
          "Please upload the required information before moving on to target prediction, or move to the Analysis tab to skip target prediction."
        })
      }
    })
  }
})



# Get pidgin parameters
observeEvent(input$ba, {
  pidginBa <<- input$ba
})
observeEvent(input$ad, {
  pidginAd <<- input$ad
})
observeEvent(input$ncores, {
  pidginCores <<- input$ncores
})

# Select PIDGINv4 dir
volumes <- getVolumes()()
shinyDirChoose(input, 'pidginfolder', roots=volumes, filetypes=c('', 'py'),allowDirCreate=T)
observe({
  pidginfolder <<- input$pidginfolder
  pidgindir <<- paste(unlist(unname(pidginfolder[1])),collapse="/")
  predictpy <<- paste0(pidgindir,"/predict.py")
  sim2train <<- paste0(pidgindir,"/sim_to_train.py")
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
    output_name <- paste0("output/","PIDGIN_",pidginBa,"_",pidginAd,"_",pidginCores,"_",time_now)
    output_name_pidgin <<- paste0(output_name,"_out_predictions.txt")
    args <- paste0("-f ",values$smi_file$datapath, " -d '\t' --organism 'Homo' -b ",pidginBa, " --ad ",pidginAd," -n ",pidginCores," -o ",output_name_pidgin)
    runline <- paste0("python ",predictpy," ",args) # command line input
    # define sim to train - doesnt work currently
    output_name2 <<- paste0("output/","PIDGIN_",pidginBa,"_",pidginAd,"_",pidginCores,"_",time_now)
    args2 <- paste0("-f",values$smi_file$datapath, " --organism 'Homo' -b ",pidginBa, " -n ",pidginCores," -o ",output_name2)
    runline2 <- paste0("python ",sim2train," ",args2)
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
  if(file.exists(output_name2)){
    preds <<- read.csv(output_name_pidgin,sep="\t",header=T)
    simtrain <<- read.csv(output_name2,sep="\t",header=T)
    output$pidgindone <- renderText({
      paste0("PIDGIN run completed. Full results saved to 'output' folder. Please move onto Results tab to view the results.")
    })
  }
})

# Render table with link to uniprotdb
output$targettable <- renderDT({
  preds = preds[order(-preds[,17]),]
  colnames(preds)[17] = "Probability"
  conversion = AnnotationDbi::select(org.Hs.eg.db,
                                     as.character(preds$Gene_ID),
                                     columns=c("ENTREZID","SYMBOL"),
                                     ketype="ENTREZID")
  preds$Gene_ID <- conversion$SYMBOL
  preds_converted <<- preds
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
output$selected_targets <- renderText({
  selected = input$targettable_rows_selected
  if (length(selected)){
    targets <<- as.character(preds_converted[selected,]$Gene_ID)
    paste(targets,collapse=", ")
  }
})

# Check if targets are in network
output$target_check <-renderText({
  selected = input$targettable_rows_selected
  if (length(selected)){
    targets <<- as.character(preds_converted[selected,]$Gene_ID)
    all_nodes = unique(c(as.character(networkdf$source),as.character(networkdf$target)))
    target_not_in_net = setdiff(targets,all_nodes)
    target_in_net <<- intersect(targets,all_nodes)
    if(length(target_not_in_net)>0){
      target_not_in_net_flat = paste(target_not_in_net,collapse=", ")
      paste0("WARNING: your target(s): ",target_not_in_net_flat," are not in your input network. These will not be used in the MoA analysis pipeline. Alternatively, go back and upload a different network (target results will be saved).")
    }
  }
})

# User-defined
output$testudtargets <- renderText({
  testthetargets <<- unlist(strsplit(input$udtargets,"\n"))
  unlist(strsplit(input$udtargets,"\n"))
})