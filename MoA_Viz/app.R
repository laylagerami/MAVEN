# TO DO:
# Fix PIDGIN params and then add helpers
# Integrate w Calculon
# Editable target table in final tab
library(shiny)
library(shinyjs)
library(igraph)
library(DT)
library(miniUI)
library(chemdoodle)
library(rhandsontable)
library(shinysky)
library(shinyBS)
library(shinythemes)

ui <- shinyUI(navbarPage("MAVEN", theme=shinytheme("flatly"),
       ### DATA TAB - STATUS:DONE
        tabPanel("Data",
            
                 sidebarPanel(
                   "Step 1. Data Input",
                   fileInput(inputId = "network",
                             label = h5("Upload network (.sif)",
                                        tags$style(type = "text/css", "#q1 {vertical-align: top;}"),
                                        bsButton("q1", label = "", icon = icon("question"), style = "info", size = "extra-small")
                             ),
                             multiple=F),
                   bsPopover(id = "q1", title = "Upload network",
                             content = paste0("Tab-separated file with three headers; Source, Interaction, Target."),
                             placement = "right", 
                             trigger = "click", 
                             options = list(container = "body")
                   ),
                   tags$hr(),
                   fileInput(inputId = "gex",
                             label = h5("Upload gene expression data",
                                        tags$style(type = "text/css", "#q2 {vertical-align: top;}"),
                                        bsButton("q2", label = "", icon = icon("question"), style = "info", size = "extra-small")
                             ),
                             multiple=F),
                   
                   bsPopover(id = "q2", title = "Upload gene expression data",
                             content = paste0("Tab-separated file with genes as rows and compounds as columns. Column header will be used as compound name. First column must be HGNC Symbol."),
                             placement = "right", 
                             trigger = "click", 
                             options = list(container = "body")
                   )
                   ),
                 
                 mainPanel(
                   tags$style(type="text/css",
                              ".shiny-output-error { visibility: hidden; }",
                              ".shiny-output-error:before { visibility: hidden; }"),
                   
                   DTOutput("networkrender"),
                   tags$br(),
                   textOutput("networkstats"),
                   tags$br(),
                   DTOutput("gextable"),
                   tags$br(),
                   textOutput("gexdata"),
                   tags$br(),
                   textOutput("nextstep1"),
                   tags$br()
                 )
                 
                 ),
        
        ### TARGETS TAB - STATUS: IN PROGRESS
        tabPanel("Targets",
                 sidebarPanel(width=4,
                   "Step 2. Define Targets",
                   tags$br(),
                   tags$br(),
                   "Upload your SMILES and run target prediction in the Target Prediction tab, view and edit results (and add user-defined targets) in Results",
                   tags$br(),
                   tags$br(),
                   "If you do not require any targets, please continue to the Analysis tab."
                 
                 ),
                 
                 mainPanel(
                   
                   tabsetPanel(
                     
                     tabPanel("Upload SMILES",
                              
                              fluidRow(
                                
                                column(8,
                                       h5("Data Input"),
                                       tags$hr(),
                                       fileInput(inputId = "smiles_file",
                                                 label = h5("Upload SMILES (.txt)",
                                                            tags$style(type = "text/css", "#q3 {vertical-align: top;}"),
                                                            bsButton("q3", label = "", icon = icon("question"), style = "info", size = "extra-small")
                                                 ),multiple=F),
                                       bsPopover(id = "q3", title = "Upload SMILES",
                                                 content = paste0("Tab-separated file in the format SMILES, Name"),
                                                 placement = "right", 
                                                 trigger = "click", 
                                                 options = list(container = "body")),
                                       tags$br(),
                                       DTOutput("uploadedsmiles"),
                                       tags$br(),
                                       tags$head(
                                         tags$style(HTML('#launch_app{background-color:#95a5a6}'))),
                                       "No SMILES? Use the sketcher applet to retrieve compound SMILES.",
                                       tags$br(),
                                       actionButton("launch_app", "Launch Sketcher"),
                                       tags$br(),
                                       textOutput("smiles_uploaded_checker")
                            
                                                                                )
                                                                )
                                                  ),
                   
                   
                     
                     tabPanel("Run Options",
                              fluidRow(
                                column(8,
                                       h5("Run Options"),
                                       tags$hr(),
                                       "Please specify PIDGIN parameters or leave as default",
                                       textInput("prob", "Probability threshold (0-1)", value = "0.75", width = NULL, placeholder = NULL),
                                       textInput("ad", "AD filter (0-1)", value = "0.8", width = NULL, placeholder = NULL),
                                       textInput("no_targets","Top number of targets to include",value="5"),
                                       textInput("ncores","Number of cores",value="10"),
                                       
                                       tags$br(),
                                       
                                       actionButton("button", "Run PIDGIN"),
                                       tags$br(),
                                       textOutput("pidginparams")
                              )
                     
                          )
                          ),
                     tabPanel("Results",
                              fluidRow(
                                column(5,
                                       rHandsontableOutput("smilestable"),
                                       tags$br()
                                      )
                                      )
                              )
                     )
                   )
                 )
        )
)

server <- function(input, output) {
 
### DATA
  
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
  
### TARGETS
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
  

  
}
shinyApp(ui, server)