ui <- shinyUI(navbarPage("MoA Viz",
       ### DATA TAB
        tabPanel("Data Input",
                 
                 sidebarPanel(
                   fileInput("smiles_or_target","Upload SMILES or list of targets",
                             multiple=F),
      
                   radioButtons("targettype", "File type",
                                choices = c(SMILES="smiles",
                                            Targets="targetlist"),
                                selected="smiles"),
                   tags$hr(),
                   
                   fileInput("network","Upload network (.sif)",
                             multiple=F),
                   
                   tags$hr(),
                   
                   fileInput("gex","Upload gene expression data (.txt)",
                             multiple=F)
                 ),
                 
                 mainPanel(
                   tags$style(type="text/css",
                              ".shiny-output-error { visibility: hidden; }",
                              ".shiny-output-error:before { visibility: hidden; }"),
                   tableOutput("target"),
                   tableOutput("networkrender"),
                   textOutput("networkstats"),
                   tableOutput("gexdata"),
                   textOutput("nextstep1")
                 )
                 
                 ),
        
        
        
        
        
        ### ANALYSIS TAB
        tabPanel("Targets",
                 sidebarPanel(
                   "Step 1. Target prediction with PIDGINv4"
                   ,
                   "Please specify parameters or leave as default",
                   
                   textInput("prob", "Probability threshold (0-1)", value = "0.75", width = NULL, placeholder = NULL),
                   textInput("ad", "AD filter (0-1)", value = "0.8", width = NULL, placeholder = NULL),
                   textInput("no_targets","Top number of targets to include",value="5"),
                   textInput("ncores","Number of cores",value="10")
                  
                 ),
                 mainPanel(
                   textOutput("test")
                 )
                 )
        )
  )

server <- function(input, output) {
  
  output$target <- renderTable({
    file = input$smiles_or_target
    ext <- tools::file_ext(file$datapath)
    req(file)
    validate(need(ext == "txt", "Please upload a txt file")) # if no .txt throws error
    read.csv(file$datapath, header = F,sep="\t") # read the chosen file and display it in renderTable
  })
 
  # get network, as above
 
  output$networkrender <- renderTable({
    
    netfile=input$network
    
    ext <- tools::file_ext(netfile$datapath)
    
    req(file)
    
    validate(need(ext == "sif", "Please upload a .sif network file"))
    
    networkdf=read.csv(netfile$datapath,sep="\t")
    
    head(networkdf)
  })
  
  # get number of nodes and edges
  output$networkstats <- renderText({
    
    netfile=input$network
    
    ext <- tools::file_ext(netfile$datapath)
    
    req(file)
    
    networkdf=read.csv(netfile$datapath,sep="\t")
    
    g = igraph::graph_from_data_frame(networkdf)
    
    nodecount = igraph::gorder(g)
    edgecount = igraph::gsize(g)
    
    paste0("Number of Nodes: ",round(nodecount,0),'  |  ',
           "Number of Edges: ",round(edgecount,0))

    
    
  })
  
  output$gexdata <- renderTable({
    gexfile = input$gex
    ext <- tools::file_ext(gexfile$datapath)
    req(file)
    validate(need(ext == "txt", "Please upload a txt file")) # if no .txt throws error
    head(read.csv(gexfile$datapath, header = T,sep="\t")) # read the chosen file and display it in renderTable
  })
  
  output$nextstep1 <- renderText({
    if(!is.null(input$smiles_or_target) & !is.null(input$network) & !is.null(input$gex)){
      "Data upload complete. Please move onto Targets!"
    }
  })
  
  output$test <- renderText({
    t = input$ncores
    "DO COMMAND LINE RUN AND VIS/DOWNLOAD AND OPTION TO SKIP PREDICTION"
  })
  
}

shinyApp(ui, server)