# NETWORK
observe({
  if (input$example_network){ # Example toggled ON
    values$network_uploaded=TRUE
    shinyjs::disable(id = "network") # Disable file upload
    values$networkdf=read.csv("Example_Data/omnipath_full_carnival.sif",sep="\t")
    # render
    output$networkrender <- renderDT({
      datatable(values$networkdf,options=list("pageLength" = 5))
    })
    # stats
    output$networkstats <- renderText({
      g = igraph::graph_from_data_frame(values$networkdf)
      nodecount = igraph::gorder(g)
      edgecount = igraph::gsize(g)
      
      paste0("Example network upload complete. ",
             "Number of Nodes: ",round(nodecount,0),'  |  ',
             "Number of Edges: ",round(edgecount,0))
    })
  }else{ # Otherwise upload as normal...
    shinyjs::enable(id = "network")
    observeEvent({
      # Check network has been uploaded
      input$network},{
        netfile=input$network
        ext <- tools::file_ext(netfile$datapath)
        req(netfile)
        values$networkdf=read.csv(netfile$datapath,sep="\t")
        
        # Render the table for user-side sanity check
        output$networkrender <- renderDT({
          datatable(values$networkdf,options=list("pageLength" = 5))
        })
        
        # Output network stats, also functions as a checker
        output$networkstats <- renderText({
          # Check 3 cols
          if(ncol(values$networkdf)!=3){
            paste0("ERROR: It appears that your network is not in the correct format. Please check the documentation or the help button, and make sure your file is correctly formatted.")
          } else {
            # Filter interaction col for only -1 and 1 vals
            correct_vals = values$networkdf %>% filter_at(vars(2), any_vars(. %in% c('1', '-1')))
            if(nrow(correct_vals)!= nrow(values$networkdf)){
              paste0("ERROR: It appears that your network is not in the correct format. Please check the documentation or the help button, and make sure your file is correctly formatted.")
            }else{
              # If correct, we continue and check the nodes
              # Here, it gets converted to an igraph form, so if it doesnt work despite the checks we can throw up an error
              g = try(igraph::graph_from_data_frame(values$networkdf))
              
              # Check gene symbols
              # Get nodes
              all_nodes = unique(c(as.character(values$networkdf[,1]),as.character(values$networkdf[,3])))
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
              
              # If error with conversion, throw an error
              if(inherits(g,"try-error")){
                paste0("Error with network upload. Please check the documentation or the help button, and make sure your file is correctly formatted.")
              }else{ # Otherwise print network stats
                nodecount = igraph::gorder(g)
                edgecount = igraph::gsize(g)
                
                # Flag that this has been successful
                values$network_uploaded=TRUE
                
                paste0("Network upload complete. ",
                       "Number of Nodes: ",round(nodecount,0),'  |  ',
                       "Number of Edges: ",round(edgecount,0))
              }
            }
          }
        })
      })
  }
})

observe({
  if (input$example_data){ # Example toggled ON
    shinyjs::disable(id = "gex")
    output$gexdata <- renderText({
      paste0("Example data loaded successfully")
    })
    values$datadf <- read.csv("Example_Data/T2.txt",header=T,sep="\t")
    output$gextable <- renderDT({
      datatable(values$datadf,options=list("pageLength"=5))
    })
    values$gex_uploaded=TRUE
  }else{
    shinyjs::enable(id = "gex")
    observeEvent({
      # Check gex has been uploaded
      input$gex},{
        gexfile = input$gex
        ext <- tools::file_ext(gexfile$datapath)
        req(gexfile)
        datadf1 <- read.csv(gexfile$datapath, header = T,sep="\t") # read the chosen file 
        
        # Check the data is correct

          if (ncol(datadf1)<2){
            output$gexdata <- renderText({
              paste0("ERROR: It appears that your gene expression data is not in the correct format. Please check the documentation or help button, and make sure that your file is correctly formatted.")
            })
          }else if (ncol(datadf1)>=2 & is.numeric(datadf1[,2])==F){
            output$gexdata <- renderText({
              paste0("ERROR: It appears that your gene expression data is not in the correct format. Please check the documentation or help button, and make sure that your file is correctly formatted.")
            })
          }else{ # When it works!
            output$gexdata <- renderText({
              paste0("Gene expression upload completed successfully.")
            })
            values$gex_uploaded=TRUE
            values$datadf <<- datadf1[,c(1,2)] # only keep first two cols
            output$gextable <- renderDT({
              datatable(values$datadf,options=list("pageLength"=5))
            })
            
            # Shiny alert for incorrect symbols
            all_genes = as.character(values$datadf[,1])
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
          }
      })
  }
})

# Let the user know if they have uploaded all of the required data
observe({
  if(values$gex_uploaded & values$network_uploaded){
    output$nextstep1 <- renderText({
      "Data upload complete. Please ensure that you have uploaded the correct data by checking the tables, then move onto Targets!"
    })
  }else{
    output$nextstep1 <- renderText({
      "Please upload the required information before moving on."
    })
  }
})
  


