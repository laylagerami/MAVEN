observeEvent(input$launch_app, {
  rstudioapi::jobRunScript(path = "gadget_script.R")
})

observeEvent(input$smiles_file, {
  smi_file <<- input$smiles_file
  ext <- tools::file_ext(smi_file$datapath)
  req(file)
  validate(need(ext == "txt", "Please upload a txt file")) # if no .txt throws error
})

output$smiles_uploaded_checker <- renderText({
  if(!is.null(input$smiles_file)){
    "Data upload complete. Please move onto Run Options."
  }else{
    "Please upload the required information before moving on to target prediction, or move to the Analysis tab to skip target prediction."
  }
})

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
observeEvent(input$no_targets, {
  pidginN <<- input$no_targets
})
observeEvent(input$ncores, {
  pidginCores <<- input$ncores
})

# Dirs
volumes <- getVolumes()()
shinyDirChoose(input, 'pidginfolder', roots=volumes, filetypes=c('', 'py'),allowDirCreate=T)
observe({
  pidginfolder <<- input$pidginfolder
  pidgindir <<- paste(unlist(unname(pidginfolder[1])),collapse="/")
  predictpy <<- paste0(pidgindir,"/predict.py")
})


output$pidginparams <- eventReactive(input$button, {
  bin_bash <- "#!/bin/bash"
  conda_activate <- "source activate pidgin3_env"
  output_name <- paste0("./output/","PIDGIN_",pidginBa,"_",pidginAd,"_",pidginCores,"_",gsub(" ","_",Sys.time()),".txt")
  args <- paste0("-f ",smi_file$datapath, " -d '\t' --organism 'Homo' -b ",pidginBa, " --ad ",pidginAd," -n ",pidginCores," -o ",output_name)
  runline <- paste0("python ",predictpy," ",args)
  bash_file <- data.frame(c(bin_bash,conda_activate,runline))
  write.table(bash_file,"./run_pidgin.sh",quote=F,row.names=F,col.names=F)
  system("bash -i run_pidgin.sh")
})

#output$pidginparams <- renderText({
#  eventReactive(input$button, {
#    print(paste0("Running PIDGIN at a Bioactivity threshold of: ",pidginBa, " uM, AD filter of: ",pidginAd, ", Keeping: ",pidginN, " targets, and using: ",pidginCores, " cores...."))
#  })
#})


