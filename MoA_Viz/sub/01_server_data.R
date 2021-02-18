
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
    networkdf=read.csv(netfile$datapath,sep="\t")
    
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
  })
  
  
  output$nextstep1 <- renderText({
    if(!is.null(input$network) & !is.null(input$gex)){
      "Data upload complete. Please move onto Targets!"
    }else{
      "Please upload the required information before moving on."
    }
  })
