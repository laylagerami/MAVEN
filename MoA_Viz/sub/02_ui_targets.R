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
                column(12,
                       h5("Data Input"),
                       tags$hr(),
                       fileInput(inputId = "smiles_file",
                                 label = h5("Upload SMILES (.txt)",
                                            tags$style(type = "text/css", "#q3 {vertical-align: top;}"),
                                            bsButton("q3", label = "", icon = icon("question"), style = "info", size = "extra-small")
                                 ),multiple=F),
                       bsPopover(id = "q3", title = "Upload SMILES",
                                 content = paste0("Tab-separated file in the format SMILES, Name. No header."),
                                 placement = "right", 
                                 trigger = "click", 
                                 options = list(container = "body")),
                       tags$br(),
                       tags$head(
                         tags$style(HTML('#launch_app{background-color:#95a5a6}'))),
                       "No SMILES? Use the sketcher applet to retrieve compound SMILES.",
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
                       h5("Run Options for PIDGIN target prediction"),
                       tags$hr(),
                       "Please specify PIDGIN parameters or leave as default",
                       
                       radioButtons("ba", label=h5("Bioactivity Threshold (uM)",
                                                         tags$style(type = "text/css", "#q4 {vertical-align: top;}")),
                                       
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
                       actionButton("button", "Run PIDGIN"),
                       # Running PIDGIN message w/ js
                       tags$br(),
                       textOutput("pidginparams"),
                       HTML('<script type="text/javascript">
                                $(document).ready(function() {
                                  $("#button").click(function() {
                                    $("#pidginparams").text("Running PIDGIN...");
                                  });
                                });
                              </script>'),
                       textOutput("pidgindone"),
                       tags$br(),
                       tags$br()
                                                
                )
                
              )
     ),
     tabPanel("Results",
              fluidRow(
                column(12,
                       DTOutput("testtable"),
                       tags$br()
                )
              )
     )
   )
   
 )
)

