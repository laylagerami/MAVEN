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

output$no_smiles_uploaded <- renderText({
  if(!is.null(input$smiles_file)){
    smiledf = input$smiles_file
    smiledffile <- tools::file_ext(smiledf$datapath)
    req(file)
    validate(need(smiledffile == "txt", "Please upload a txt file")) # if no .txt throws error
    datadf = read.csv(smiledf$datapath, header=T,sep="\t") # read the chosen file 
    n = nrow(datadf)
    print(paste0("Number of compounds uploaded: ",n))
  }
})