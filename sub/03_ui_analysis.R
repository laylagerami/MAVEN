tabPanel("3. Analysis",
  # Sidebar
  sidebarPanel(width=4,
  strong("Step 3: Carry out Analysis"),
  tags$br(),
  tags$br(),
  "Perform TF enrichment, pathway inference and causal reasoning.",
  tags$br(),
  tags$br(),
  # Dorothea options
  "DoRothEA Options:",
  # Conf level
  checkboxGroupInput("dorothea_conf", label=h5("Confidence levels:",
     tags$style(type="text/css","#q7 {vertical-align: top}"),
     bsButton("q7", label = "", icon = icon("question"), style = "info", size = "extra-small")
      ),
    c("A"="A",
      "B"="B",
      "C"="C",
      "D"="D",
      "E"="E"),
    selected=c("A","B","C"),
    inline=T),
    bsPopover(id = "q7", title = "Confidence Levels",
              content = paste0("TF-gene interaction confidence levels to use for TF enrichment of gene expression data."),
              placement = "right", 
              trigger = "click", 
              options = list(container = "body")
    ),
  # No TFS
    sliderInput("no_tfs", label = h5("Number of TFs to include",
                                          tags$style(type = "text/css", "#q8 {vertical-align: top;}"),
                                          bsButton("q8", label = "", icon = icon("question"), style = "info", size = "extra-small")
                                        ),
              min = 5, max = 100,
              value = 10),
    bsPopover(id = "q8", title = "Number of TFs to include",
              content = paste0("Number of top enriched TFs to include as input to CARNIVAL. This number can be increased to increase coverage, but increasing too much may introduce noise. We recommend to check the output NES scores before deciding on the final number of TFs to you."),
              placement = "right", 
              trigger = "click", 
              options = list(container = "body")
    ),
  tags$br(),
  "PROGENy Options:",
  # no. genes
  sliderInput("no_genes_progeny", label = h5("Number of top responsive genes to include",
                                   tags$style(type = "text/css", "#q9 {vertical-align: top;}"),
                                   bsButton("q9", label = "", icon = icon("question"), style = "info", size = "extra-small")
                                  ),
      min = 100, max = 500,
      value = 100),
  bsPopover(id = "q9", title = "Number of top responsive genes to include.",
            content = paste0("Number of pathway-responsive genes for pathway analysis. This number can be increased depending on the coverage of your experiments. For instance, the number of quantified genes for single-cell RNA-seq is smaller than for Bulk RNA-seq or microarray. In those cases, we suggest to increase the number of responsive genes to 200-500."),
            placement = "right", 
            trigger = "click", 
            options = list(container = "body")
  ),
  tags$br(),
  "CARNIVAL Options:",
  # Use targets
  pickerInput(inputId="carnival_targets",
              label =h5("Selected targets for CARNIVAL",
                        tags$style(type="text/css","#q10 {vertical-align: top;}"),
                         bsButton("q10",label="",icon=icon("question"),style="info",size="extra-small")
                        ),choices=c(),multiple = T,options = list(`actions-box` = TRUE) ),
  bsPopover(id="q10",title="Selected targets for CARNIVAL input",
            content=paste0("Targets (as defined in Targets tab) to use in CARNIVAL analysis. In the case of no selected targets, a proxy input node will be generated and Inverse CARNIVAL will be run."),
            placement="right",
            trigger="click",
            options=list(container="body")
            ),
  # Time limit
  textInput("carnival_time_limit", label = h5("Time limit for CARNIVAL run",
                                           tags$style(type = "text/css", "#q11 {vertical-align: top;}"),
                                           bsButton("q11", label = "", icon = icon("question"), style = "info", size = "extra-small")
  ), value = "300", width = NULL, placeholder = NULL),
  bsPopover(id = "q11", title = "Time limit for CARNIVAL run.",
            content = paste0("Time limit (in seconds) for CARNIVAL run. We recommend to increase this value if no/few solutions are found."),
            placement = "right", 
            trigger = "click", 
            options = list(container = "body")
  ),
  # Cores
  textInput("carnival_ncores", label = h5("Number of cores",
                                              tags$style(type = "text/css", "#q12 {vertical-align: top;}"),
                                              bsButton("q12", label = "", icon = icon("question"), style = "info", size = "extra-small")
  ), value = "20", width = NULL, placeholder = NULL),
  bsPopover(id = "q12", title = "Number of cores.",
            content = paste0("Number of cores for ILP solver to use"),
            placement = "right", 
            trigger = "click", 
            options = list(container = "body")
  ),
  radioButtons("solver", label=h5("Solver",
                                      tags$style(type="text/css","#q13 {vertical-align: top;}"),
                                      bsButton("q13",label="",icon=icon("question"),style="info",size="extra-small")
                                  ), c("IBM ILOG CPLEX"="cplex",
                                       "Cbc" = "cbc",
                                       "lpSolve" = "lpSolve"),inline=T),
  bsPopover(id = "q13", title = "Solver",
            content = paste0("Solver to use for CARNIVAL. Please see https://github.com/saezlab/CARNIVAL for more information."),
            placement = "right", 
            trigger = "click", 
            options = list(container = "body")
  )
  
  
    ),
    # Main panel has tabs inside
    mainPanel(
      tabsetPanel(
        # DoRoThEA
        tabPanel("(a) DoRothEA",
          fluidRow(column(10,
              tags$br(),
              strong("DoRothEA Transcription Factor Enrichment"),
              tags$br(),
              actionButton("run_dorothea","Run DoRothEA"),
              tags$br(),
              "You can also use the slider to change the number of top TFs considered after running DoRothEA.\nTIP: Increasing the included confidence levels may enable more TFs to be enriched.",
              tags$br(),
              tags$br(),
              strong("Plot of enriched TFs:"),
              plotOutput("tf_plot"),
              tags$br(),
              tags$br(),
              strong("Table of enriched TFs:"),
              DTOutput("tf_df"),
              tags$br(),
              tags$br(),
              actionButton("download_dorothea", "Download DoRothEA results"),
              tags$br(),
              strong("When you are satisfied with the TFs to be used as input for CARNIVAL, please continue to the PROGENy tab"),
              tags$br(),
              tags$br()
                        )
                 )
        ),
        tabPanel("(b) PROGENy",
                 fluidRow(column(10,
                 tags$br(),
                 strong("PROGENy pathway association scores"),
                 tags$br(),
                 actionButton("run_progeny","Run PROGENy"),
                 tags$br(),
                 "Changing the number of responsive genes will also re-run PROGENy and update the output.",
                 tags$br(),
                 tags$br(),
                 strong("Plot of pathway scores:"),
                 plotOutput("progeny_plot"),
                 tags$br(),
                 tags$br(),
                 strong("Table of pathway scores:"),
                 DTOutput("progeny_df"),
                 tags$br(),
                 tags$br(),
                 actionButton("download_progeny", "Download PROGENy results"),
                 tags$br(),
                 strong("When you are satisfied with the pathway weights to be used as input for CARNIVAL, please continue to the CARNIVAL tab"),
                 tags$br(),
                 tags$br()
                  
                    )
                 )
                 ),
        tabPanel("(c) CARNIVAL",
                 fluidRow(
                   column(10,
                          tags$br(),
                          strong("CARNIVAL network optimisation"),
                          tags$br(),
                          textOutput("carnival_check"),
                          uiOutput("sortable"),
                          tags$br(),
                          textOutput("choose_solver"),
                          shinyFilesButton('interactive_solver', 'Select solver', 'Please select the correct solver file', FALSE),
                          actionButton("run_carnival","Run CARNIVAL"),
                          tags$br(),
                          tags$br(),
                          textOutput("carnival_warning"),
                          tags$br(),
                          tags$br(),
                          textOutput("carnivaldone"),
                          tags$br(),
                          tags$br()
                          )
                 )
            )
      )
    )
  
  )



