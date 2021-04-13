tabPanel("Targets",
         sidebarPanel(width=4,
        "Step 2. Define Targets",
        tags$br(),
        tags$br(),
        "Upload your SMILES and run target prediction, view results, upload previous results, and optionally add user-defined targets (with or without running target prediction)",
        tags$br(),
        tags$br(),
        "If you do not require any targets, please continue to the Analysis tab."
        ),
 
 mainPanel(
   
   tabsetPanel(
     
     tabPanel("Upload SMILES",
              
              fluidRow(
                column(12,
                       strong("SMILES Input for Target Prediction"),
                       tags$br(),
                       "Please note that only the first compound SMILES will be used, and any additional SMILES will be discarded. For batch upload, please see the 'Batch Upload' tab",
                       tags$br(),
                       fileInput(inputId = "smiles_file",
                                 label = h5("Upload SMILES (.txt)",
                                            tags$style(type = "text/css", "#q3 {vertical-align: top;}"),
                                            bsButton("q3", label = "", icon = icon("question"), style = "info", size = "extra-small")
                                 ),multiple=F, accept=c(".txt")),
                       bsPopover(id = "q3", title = "Upload SMILES",
                                 content = paste0("Tab-separated file in the format SMILES, Name/ID (Optional). No header."),
                                 placement = "right", 
                                 trigger = "click", 
                                 options = list(container = "body")),
                       tags$br(),
                       "No SMILES? Use the sketcher applet to draw your compound and retrieve the corresponding SMILES. You can then copy them to a file and upload them above.",
                       tags$br(),
                       tags$br(),
                       actionButton("launch_app", "Launch Sketcher"),
                       tags$br(),
                       tags$br(),
                       textOutput("smiles_uploaded_checker"),
                       tags$br()
                       
                       
                       
                )
              )
     ),
     
     
     
     tabPanel("Run Options",
              fluidRow(
                column(12,
                       tags$head(tags$style(HTML("
                                .btn {
                                color:rgb(255,255,255);
                                text-align: left;
                                #border-color:rgb(0,144,197);
                                background-color:rgb(0,144,197);}

                                # #button:active {
                                # background-color:rgb(51,255,153);
                                # }"))),
                       
                       h5("Run Options for PIDGIN target prediction"),
                       tags$hr(),
                       "Please specify PIDGIN parameters or leave as default",
                       
                       radioButtons("ba", label=h5("Bioactivity Threshold (uM)",
                                                         tags$style(type = "text/css", "#q4 {vertical-align: top;}"),
                                                   bsButton("q4", label = "", icon = icon("question"), style = "info", size = "extra-small")
                       ),
                                        choices= list("0.1","1","10","100"),
                                        selected="10",
                                        inline = T
                       ),
                       
        
                       bsPopover(id = "q4", title = "Bioactivity Threshold (uM)",
                                 content = paste0("Concentration at which activity is to be predicted, in uM."),
                                 placement = "right", 
                                 trigger = "click", 
                                 options = list(container = "body")
                       ),
                       
                       textInput("ad", label = h5("AD filter (0-100)",
                                                  tags$style(type = "text/css", "#q5 {vertical-align: top;}"),
                                                  bsButton("q5", label = "", icon = icon("question"), style = "info", size = "extra-small")
                       ), value = "75", width = NULL, placeholder = NULL),
                       bsPopover(id = "q5", title = "AD filter (0-100)",
                                 content = paste0("Applicability Domain filter (0-100) which computes if your prediction is within the applicability domain of the model, based on the Reliability Density Neighbourhood methodology."),
                                 placement = "right", 
                                 trigger = "click", 
                                 options = list(container = "body")
                       ),
                       
                       textInput("ncores", label = h5("Number of cores",
                                                      tags$style(type = "text/css", "#q6 {vertical-align: top;}"),
                                                      bsButton("q6", label = "", icon = icon("question"), style = "info", size = "extra-small")
                       ), value = "10", width = NULL, placeholder = NULL),
                       bsPopover(id = "q6", title = "Number of cores",
                                 content = paste0("Number of cores required for performing target prediction. Positive integer."),
                                 placement = "right", 
                                 trigger = "click", 
                                 options = list(container = "body")
                       ),
                       
                       tags$br(),
                       tags$br(),
                       shinyDirButton('pidginfolder', 'Select PIDGIN folder', 'Please select the folder containing PIDGIN predict.py file', FALSE),
                       shiny::actionButton("button", "Run PIDGIN"),
                       tags$br(),
                       "You can check the progress of your PIDGIN run by keeping an eye on your R Console.",
                       tags$br(),
                       tags$br(),
                       textOutput("pidgindone"),
                       tags$br(),
                       tags$br()
                                                
                )
                
              )
     ),
     tabPanel("Results",
              fluidRow(
                column(12,
                       h5("Select targets for Causal Reasoning - click to view UniProt link"),
                       tags$hr(),
                       DTOutput("targettable"),
                       tags$br(),
                       tags$br(),
                       strong("Selected targets: "),
                       textOutput("selected_targets"),
                       tags$br(),
                       textOutput("target_check"),
                       tags$br(),
                       "When you have finished selecting targets, please move to the Analysis tab. You can also add additional targets in the Additional Targets tab.",
                       tags$br(),
                       tags$br()
                )
              )
     ),
     tabPanel("Additional Targets",
              fluidRow(
                      column(12,
                h5("Add user-defined targets if required, line-separated (HGNC)"),
                textAreaInput("udtargets", "Input targets", rows = 5),
                textOutput("testudtargets")
                             
                      )
                      
              )
     )
   )
   
 )
)

