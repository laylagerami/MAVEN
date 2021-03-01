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

# For later
X <- ""
Y <- ""
x = data.frame(X,Y)
colnames(x) = c("SMILES","Name")

output$smilestable <- renderRHandsontable({
  rhandsontable(x) 
})

observe(
  if(!is.null(input$smilestable)){
    asdf = data.frame(hot_to_r(input$smilestable))
    smiles = asdf$SMILES
    compounds_n = nrow(asdf)
    name = asdf$Name
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
#runPidgin_alert <- observeEvent(input$button, {
#  paste0("Running PIDGIN...")
#})
#output$pidginrunning <- renderText({
#  runPidgin_alert()
#})

observeEvent(input$button, {
  output$pidginrunning <- renderText({
    paste0("Running PIDGIN...")
  })
  bin_bash <- "#!/bin/bash"
  conda_activate <- "source activate pidgin3_env"
  output_name <<- paste0("./output/","PIDGIN_",pidginBa,"_",pidginAd,"_",pidginCores,"_",gsub(" ","_",Sys.time()),".txt")
  args <- paste0("-f ",smi_file$datapath, " -d '\t' --organism 'Homo' -b ",pidginBa, " --ad ",pidginAd," -n ",pidginCores," -o ",output_name)
  runline <- paste0("python ",predictpy," ",args)
  bash_file <- data.frame(c(bin_bash,conda_activate,runline))
  write.table(bash_file,"./run_pidgin.sh",quote=F,row.names=F,col.names=F)
  system("bash -i run_pidgin.sh")
})


checkOutput <- eventReactive(input$button, {
  reactivePoll(1000, session, checkFunc = function() {
    if (file.exists(output_name))
      assign(x = "preds", # Read it in if so
      value = read.csv(output_name,header=T,sep="\t"),
      envir = .GlobalEnv)
      paste0("Done. Please move onto the Results tab.")
    })
})
output$pidgindone <- renderText({
  checkOutput()
})
    

        
    # If file successfully read in
   # if(nrow(preds)>0){
    #  output$pidgindone <- renderText ({
     #   paste0("DONE")
    #  })
    #}
#})


# Check if output file exists, if it does then read it in
#output_name <<- "output/PIDGIN_10_75_10_2021-02-25_10:53:09.txt_out_predictions_20210225-110610.txt"



# Take top n targets and then place them in editable table
#output$testtable <- renderDT({
#  preds = preds[order(-preds[,17]),]
#  colnames(preds)[17] = "Probability"
#  preds = preds[,c(3,2,4,17)]
#  datatable(preds,options = list("pageLength" = 5))
#})

