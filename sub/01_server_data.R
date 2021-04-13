# Render datatable of network
output$networkrender <- renderDT({
    netfile=input$network
    ext <- tools::file_ext(netfile$datapath)
    networkdf<<-read.csv(netfile$datapath,sep="\t")
    datatable(networkdf,options = list("pageLength" = 5))
})

# get number of nodes and edges, also function as a file checker
output$networkstats <- renderText({
    netfile=input$network
    ext <- tools::file_ext(netfile$datapath)
    networkdf<-read.csv(netfile$datapath,sep="\t",header=T)
    
    # Check 3 cols
    if(ncol(networkdf)!=3){
      paste0("ERROR: It appears that your network is not in the correct format. Please check the documentation or the help button, and make sure your file is correctly formatted.")
    } else {
      # Filter interaction col for only -1 and 1 vals
      correct_vals = networkdf %>% filter_at(vars(2), any_vars(. %in% c('1', '-1')))
      if(nrow(correct_vals)!= nrow(networkdf)){
        paste0("ERROR: It appears that your network is not in the correct format. Please check the documentation or the help button, and make sure your file is correctly formatted.")
      }else{
        # If correct, we continue
        # Here, it gets converted to an igraph form, so if it doesnt work despite the checks we can throw up an error
        g = try(igraph::graph_from_data_frame(networkdf))
        if(inherits(g,"try-error")){
          paste0("Error with network upload. Please check the documentation or the help button, and make sure your file is correctly formatted.")
        }else{
          nodecount = igraph::gorder(g)
          edgecount = igraph::gsize(g)
          
          paste0("Network upload complete. ",
                 "Number of Nodes: ",round(nodecount,0),'  |  ',
                 "Number of Edges: ",round(edgecount,0))
        }
      }
    }
})

# Check if network has gene symbols or not?
observeEvent(input$network, {
  netfile=input$network
  ext <- tools::file_ext(netfile$datapath)
  validate(need(ext == "sif", "Please upload a .sif network file"))
  networkdf<-read.csv(netfile$datapath,sep="\t")
  
  # Get nodes
  all_nodes = unique(c(as.character(networkdf[,1]),as.character(networkdf[,3])))
  
  # Check
  check = checkGeneSymbols(all_nodes, unmapped.as.na=TRUE)
  
  # Get unmapped
  na_symbols = subset(check,is.na(Suggested.Symbol))$x
  
  # Write log file
  time_now = gsub(" ","_",Sys.time())
  time_now = gsub(":","-",time_now)
  write.csv(na_symbols,paste0("logs/network_error_HGNC_",time_now,".csv"))
  
  # Alert
  na_symbols_flat = paste(na_symbols,collapse=", ")
  if(length(na_symbols)>0){
    #Sys.sleep(1) # pause
    shinyalert(
      title = "Warning",
      text = paste0("Some of the genes in your network (",na_symbols_flat,") are not valid HGNC symbols. This may disrupt downstream analysis. Writing erroneous symbols to logs folder..."),
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
    #Sys.sleep(1) # pause
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

# Render datatable of GEX
output$gextable <- renderDT({
  gexfile = input$gex
  ext <- tools::file_ext(gexfile$datapath)
  req(file)
  validate(need(ext == "txt", "Please upload a txt file")) # if no .txt throws error
  datadf <- read.csv(gexfile$datapath, header = T,sep="\t") # read the chosen file 
  datadf <<- datadf[,c(1,2)] # only keep first two cols
  datatable(datadf,options = list("pageLength" = 5))
})

# Check GEX data - NEED TO FIX!!!
output$gexdata <- renderText({
  gexfile = input$gex
  ext <- tools::file_ext(gexfile$datapath)
  datadf <- read.csv(gexfile$datapath, header = T,sep="\t") # read the chosen file 
  if(ncol(datadf)>2){
    paste0("WARNING: It seems as though you have more than 2 columns. Please note that only the first set of measurements will be used, and any additional columns will be discarded. For batch upload, please see the 'Batch Upload' tab.")
  }else if (ncol(datadf)<2){
    paste0("ERROR: It appears that your gene expression data is not in the correct format. Please check the documentation or help button, and make sure that your file is correctly formatted.")
  }else if (ncol(datadf)>=2 & nchar(gsub("\\d+(\\.\\d+)?", "", datadf[,2]) != 0)){
    paste0("ERROR: It appears that your gene expression data is not in the correct format. Please check the documentation or help button, and make sure that your file is correctly formatted.")
  }else{
    paste0("Gene expression upload completed successfully.")
  }
  
})
  
# Check if gene symbol?
observeEvent(input$gex, {
  gexfile = input$gex
  ext <- tools::file_ext(gexfile$datapath)
  datadf <- read.csv(gexfile$datapath, header = T,sep="\t") # read the chosen file 

  # Check if gene symbols
  all_genes = as.character(datadf[,1])
  check = checkGeneSymbols(all_genes, unmapped.as.na=TRUE)
  na_symbols = subset(check,is.na(Suggested.Symbol))$x
  time_now = gsub(" ","_",Sys.time())
  time_now = gsub(":","-",time_now)
  write.csv(na_symbols,paste0("logs/gex_data_error_HGNC_",time_now,".csv"))
  na_symbols_flat = paste(na_symbols,collapse=", ")
  if(length(na_symbols)>0){
    #Sys.sleep(1) # pause
    shinyalert(
      title = "Warning",
      text = paste0("Some of the genes in your data (",na_symbols_flat,") are not valid HGNC symbols. This may disrupt downstream analysis. Writing erroneous symbols to logs folder..."),
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
  if(length(na_symbols)==length(all_genes)){
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

# Let the user know if they have uploaded all of the required data
output$nextstep1 <- renderText({
   if(!is.null(input$network) & !is.null(input$gex)){
    "Data upload complete. Please ensure that you have uploaded the correct data by checking the tables, then move onto Targets!"
  }else{
    "Please upload the required information before moving on."
  }
})