observeEvent(input$launch_app, {
  rstudioapi::jobRunScript(path = "./gadget_script.R")
})

output$uploadedsmiles <- renderDT({
  smi_file = input$smiles_file
  ext <- tools::file_ext(smi_file$datapath)
  req(file)
  validate(need(ext == "txt", "Please upload a txt file")) # if no .txt throws error
  smidatadf <<- read.csv(smi_file$datapath, header = F,sep="\t") # read the chosen file 
  datatable(smidatadf,options = list("pageLength" = 5))
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
observeEvent(input$prob, {
  pidginProb <<- input$prob
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

output$pidginparams <- eventReactive(input$button, {
  paste0("Running PIDGIN with probability threshold of: ",pidginProb, ", AD filter of: ",pidginAd, ", Keeping: ",pidginN, " targets, and using: ",pidginCores, " cores....")
})
