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
                       
                       
                       textInput("prob", label = h5("Probability Threshold (0-1)",
                                                    tags$style(type = "text/css", "#q4 {vertical-align: top;}"),
                                                    bsButton("q4", label = "", icon = icon("question"), style = "info", size = "extra-small")
                       ), value = "0.5", width = NULL, placeholder = NULL),
                       bsPopover(id = "q4", title = "Probability Threshold (0-1)",
                                 content = paste0("RF probability threshold for defining activity, from 0 to 1."),
                                 placement = "right", 
                                 trigger = "click", 
                                 options = list(container = "body")
                       ),
                       
                       textInput("ad", label = h5("AD filter (0-1)",
                                                  tags$style(type = "text/css", "#q5 {vertical-align: top;}"),
                                                  bsButton("q5", label = "", icon = icon("question"), style = "info", size = "extra-small")
                       ), value = "0.75", width = NULL, placeholder = NULL),
                       bsPopover(id = "q5", title = "AD filter (0-1)",
                                 content = paste0("Applicability Domain filter (0-1)"),
                                 placement = "right", 
                                 trigger = "click", 
                                 options = list(container = "body")
                       ),
                       
                       textInput("no_targets", label = h5("Top number of targets to include",
                                                          tags$style(type = "text/css", "#q6 {vertical-align: top;}"),
                                                          bsButton("q6", label = "", icon = icon("question"), style = "info", size = "extra-small")
                       ), value = "5", width = NULL, placeholder = NULL),
                       bsPopover(id = "q6", title = "Top number of targets to include",
                                 content = paste0("Number of top (highest probability) targets to include in Causal Reasoning analysis. Positive integer."),
                                 placement = "right", 
                                 trigger = "click", 
                                 options = list(container = "body")
                       ),
                       
                       textInput("ncores", label = h5("Number of cores",
                                                      tags$style(type = "text/css", "#q6 {vertical-align: top;}"),
                                                      bsButton("q7", label = "", icon = icon("question"), style = "info", size = "extra-small")
                       ), value = "10", width = NULL, placeholder = NULL),
                       bsPopover(id = "q7", title = "Number of cores",
                                 content = paste0("Number of cores required for performing target prediction. Positive integer."),
                                 placement = "right", 
                                 trigger = "click", 
                                 options = list(container = "body")
                       ),
                       
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

