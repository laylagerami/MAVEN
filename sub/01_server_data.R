# Render datatable of network
  output$networkrender <- renderDT({
    netfile=input$network
    ext <- tools::file_ext(netfile$datapath)
    req(file)
    validate(need(ext == "sif", "Please upload a .sif network file"))
    networkdf<<-read.csv(netfile$datapath,sep="\t")
    datatable(networkdf,options = list("pageLength" = 5))
  })
  
  # get number of nodes and edges
  output$networkstats <- renderText({
    netfile=input$network
    ext <- tools::file_ext(netfile$datapath)
    req(file)
    validate(need(ext == "sif", "Please upload a .sif network file"))
    networkdf<-read.csv(netfile$datapath,sep="\t")
    
    g = try(igraph::graph_from_data_frame(networkdf))
    if(inherits(g,"try-error")){
      paste0("Error with network upload. Please check the documentation and make sure your file is correctly formatted.")
    }else{
      nodecount = igraph::gorder(g)
      edgecount = igraph::gsize(g)
      
      paste0("Network upload complete. ",
             "Number of Nodes: ",round(nodecount,0),'  |  ',
             "Number of Edges: ",round(edgecount,0))
    }
    
    # Check if gene symbols
    all_nodes = unique(c(as.character(networkdf[,1]),as.character(networkdf[,3])))
    check = checkGeneSymbols(all_nodes, unmapped.as.na=TRUE)
    na_symbols = subset(check,is.na(Suggested.Symbol))$x
    na_symbols_flat = paste(na_symbols,collapse=", ")
    if(length(na_symbols)>0){
      Sys.sleep(1) # pause
      shinyalert(
        title = "Warning",
        text = paste0("Some of the genes in your network (",na_symbols_flat,") are not valid HGNC symbols. This may disrupt downstream analysis."), ,
        size = "s",
        closeOnEsc = TRUE,
        closeOnClickOutside = T,
        html = FALSE,
        type = "warning",
        showConfirmButton = TRUE,
        showCancelButton = FALSE,
        confirmButtonText = "OK",
        confirmButtonCol = "#AEDEF4",
        timer = 0,
        imageUrl = "",
        animation = TRUE
      )
    }
    if(length(na_symbols)==length(all_nodes)){
      Sys.sleep(1) # pause
      shinyalert(
        title = "Warning",
        text = paste0("None of the genes in your network are HGNC symbols. Please convert your symbols to HGNC and reupload."),
        size = "s", 
        closeOnEsc = TRUE,
        closeOnClickOutside = T,
        html = FALSE,
        type = "warning",
        showConfirmButton = TRUE,
        showCancelButton = FALSE,
        confirmButtonText = "OK",
        confirmButtonCol = "#AEDEF4",
        timer = 0,
        imageUrl = "",
        animation = TRUE
      )
    }
  })

  
  output$gextable <- renderDT({
    gexfile = input$gex
    ext <- tools::file_ext(gexfile$datapath)
    req(file)
    validate(need(ext == "txt", "Please upload a txt file")) # if no .txt throws error
    datadf <<- read.csv(gexfile$datapath, header = T,sep="\t") # read the chosen file 
    datatable(datadf,options = list("pageLength" = 5))
  })
  
  output$gexdata <- renderText({
    gexfile = input$gex
    ext <- tools::file_ext(gexfile$datapath)
    req(file)
    validate(need(ext == "txt", "Please upload a txt file")) # if no .txt throws error
    datadf <<- read.csv(gexfile$datapath, header = T,sep="\t") # read the chosen file 
    paste0("Gene expression upload complete, for a total of ",nrow(datadf)," genes and ",ncol(datadf)-1, " compounds.")
    
    # Check if gene symbols
    all_genes = as.character(datadf[,1])
    check = checkGeneSymbols(all_genes, unmapped.as.na=TRUE)
    na_symbols = subset(check,is.na(Suggested.Symbol))$x
    na_symbols_flat = paste(na_symbols,collapse=", ")
    if(length(na_symbols)>0){
      Sys.sleep(1) # pause
      shinyalert(
        title = "Warning",
        text = paste0("Some of the genes in your data (",na_symbols_flat,") are not valid HGNC symbols. This may disrupt downstream analysis."),
        size = "s",
        closeOnEsc = TRUE,
        closeOnClickOutside = T,
        html = FALSE,
        type = "warning",
        showConfirmButton = TRUE,
        showCancelButton = FALSE,
        confirmButtonText = "OK",
        confirmButtonCol = "#AEDEF4",
        timer = 0,
        imageUrl = "",
        animation = TRUE
      )
    }
    if(length(na_symbols)==length(all_nodes)){
      Sys.sleep(1) # pause
      shinyalert(
        title = "Warning",
        text = paste0("None of the genes in your data are HGNC symbols. Please convert your symbols to HGNC and reupload."),
        size = "s", 
        closeOnEsc = TRUE,
        closeOnClickOutside = T,
        html = FALSE,
        type = "warning",
        showConfirmButton = TRUE,
        showCancelButton = FALSE,
        confirmButtonText = "OK",
        confirmButtonCol = "#AEDEF4",
        timer = 0,
        imageUrl = "",
        animation = TRUE
      )
    }
  })
  
  
  output$nextstep1 <- renderText({
    if(!is.null(input$network) & !is.null(input$gex)){
      "Data upload complete. Please move onto Targets!"
    }else{
      "Please upload the required information before moving on."
    }
  })
