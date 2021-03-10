# init null output_name
output_name_pidgin <<- "Null"

# Run chemical sketcher
observeEvent(input$launch_app, {
  rstudioapi::jobRunScript(path = "gadget_script.R")
})

# Observe input
observeEvent(input$smiles_file, {
  smi_file <<- input$smiles_file
  ext <- tools::file_ext(smi_file$datapath)
  req(file)
  validate(need(ext == "txt", "Please upload a txt file")) # if no .txt throws error
})

# Check if SMILES uploaded
output$smiles_uploaded_checker <- renderText({
  if(!is.null(input$smiles_file)){
    "Data upload complete. Please move onto Run Options."
  }else{
    "Please upload the required information before moving on to target prediction, or move to the Analysis tab to skip target prediction."
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
})

# Run PIDGIN
started <- reactiveVal(Sys.time()[NA])
observeEvent(input$button, {
  withProgress(message="Running PIDGIN...",value=1, {
    started(Sys.time())
    bin_bash <- "#!/bin/bash"
    conda_activate <- "source activate pidgin3_env"
    output_name <- paste0("output/","PIDGIN_",pidginBa,"_",pidginAd,"_",pidginCores,"_",gsub(" ","_",Sys.time()))
    output_name_pidgin <<- paste0(output_name,"_out_predictions.txt")
    args <- paste0("-f ",smi_file$datapath, " -d '\t' --organism 'Homo' -b ",pidginBa, " --ad ",pidginAd," -n ",pidginCores," -o ",output_name)
    runline <- paste0("python ",predictpy," ",args)
    bash_file <- data.frame(c(bin_bash,conda_activate,runline))
    write.table(bash_file,"./run_pidgin.sh",quote=F,row.names=F,col.names=F)
    system("bash -i run_pidgin.sh")
  })
})

# Check if PIDGIN has finished running
observe({
  req(started())
  
  if(file.exists(output_name_pidgin)){
    preds <<- read.csv(output_name_pidgin,sep="\t",header=T)
    output$pidgindone <- renderText({
      paste0("PIDGIN run completed. Please move onto Results tab.")
    })
  }
})

# Take top n targets and then place them in editable table
output$targettable <- renderDT({
  preds = preds[order(-preds[,17]),]
  colnames(preds)[17] = "Probability"
  preds = preds[,c(3,2,4,17)]
  conversion = AnnotationDbi::select(org.Hs.eg.db,
                                     as.character(preds$Gene_ID),
                                     columns=c("ENTREZID","SYMBOL"),
                                     ketype="ENTREZID")
  preds$Gene_ID <- conversion$SYMBOL
  preds_converted <<- preds
  datatable(preds_converted,options = list("pageLength" = 5))
})

output$selected_targets <- renderText({
  selected = input$targettable_rows_selected
  if (length(selected)){
    targets <<- as.character(preds_converted[selected,]$Gene_ID)
    paste0("Selected Targets: ",paste(targets,collapse=", "),". When you have finished, please move to the Analysis tab.")
  }
})
