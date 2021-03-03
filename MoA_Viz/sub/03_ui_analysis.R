tabPanel("Analysis",
  # Sidebar
  sidebarPanel(width=4,
  "Step 3: Carry out Analysis",
  tags$br(),
  tags$br(),
  "Perform TF enrichment, pathway inference and causal reasoning.",
  tags$br(),
  tags$br(),
  # Dorothea options
  "DoRoThEA Options:",
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
    textInput("no_tfs", label = h5("Number of TFs to include",
     tags$style(type = "text/css", "#q8 {vertical-align: top;}"),
     bsButton("q8", label = "", icon = icon("question"), style = "info", size = "extra-small")
      ), value = "20", width = NULL, placeholder = NULL),
    bsPopover(id = "q8", title = "Number of TFs to include",
              content = paste0("Number of top enriched TFs to include as input to CARNIVAL."),
              placement = "right", 
              trigger = "click", 
              options = list(container = "body")
    ),
  tags$br(),
  tags$br(),
  "PROGENy Options:",
  # no. genes
  textInput("no_genes_progeny", label = h5("Number of top responsive genes to include",
                                 tags$style(type = "text/css", "#q8 {vertical-align: top;}"),
                                 bsButton("q9", label = "", icon = icon("question"), style = "info", size = "extra-small")
  ), value = "100", width = NULL, placeholder = NULL),
  bsPopover(id = "q9", title = "Number of top responsive genes to include.",
            content = paste0("Number of top differentially regulated genes to use for pathway analysis. This number can be increased depending on the coverage of your experiments. For instance, the number of quantified genes for single-cell RNA-seq is smaller than for Bulk RNA-seq or microarray. In those cases, we suggest to increase the number of responsive genes to 200-500."),
            placement = "right", 
            trigger = "click", 
            options = list(container = "body")
  )
    ),
    # Main panel has tabs inside
    mainPanel(
      tabsetPanel(
        # DoRoThEA
        tabPanel("DoRoThEA",
          fluidRow(column(12,
              h5("Run DoRoThEA and view plot"),
              tags$hr(),
              actionButton("run_dorothea","Run DoRoThEA"),
              tags$br(),
              tags$br(),
              "Table of enriched TFs:",
              DTOutput("tf_df"),
              tags$br(),
              tags$br(),
              "Plot of enriched TFs:",
              plotOutput("tf_plot")
              
                        )
                 )
        ),
        tabPanel("Progeny",
                 fluidRow(
                   column(12,
                  h5("Progeny"),
                  tags$hr(),
                  actionButton("run_progeny","Run PROGENy"),
                  tags$br(),
                  tags$br(),
                  "Table of pathway scores:",
                  DTOutput("progeny_df"),
                  tags$br(),
                  tags$br(),
                  "Plot of pathway scores:",
                  plotOutput("progeny_plot")
                  
                          )
                 )
                 ),
        tabPanel("CARNIVAL",
                 fluidRow(
                   column(12,
                          h5("CARNIVAL")
                          )
                 )
            )
      )
    )
  
  )



