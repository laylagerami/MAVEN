tabPanel("1. Data",
         # SIDEBAR
         sidebarPanel(
                 # Enables warnings
                 useShinyalert(),
                 
                 # Text
                 strong("Step 1: Data Input"),
                 
                 # Upload Network
                 fileInput(inputId = "network", 
                           label = h5("Upload network (.sif or .txt)",
                               tags$style(type = "text/css", "#q1 {vertical-align: top;}"),
                               bsButton("q1", label = "", icon = icon("question"), style = "info", size = "extra-small")),
                           multiple=F,
                           accept = c(".sif",".txt")),
                  bsPopover(id = "q1", title = "Upload network",
                    content = paste0("Tab-separated file with three headers; source, interaction, target."),
                    placement = "right", 
                    trigger = "click", 
                    options = list(container = "body")),
                 # Example network
                 materialSwitch(
                         inputId = "example_network",
                         label = "Load example network",
                 ),
                 p("(Example network taken from",
                   a("Omnipath DB)",
                     href = "https://omnipathdb.org/",
                     target="_blank")),
                 
                 
                 tags$hr(),
                 
                 # Upload GEX
                 fileInput(inputId = "gex",
                            label = h5("Upload gene expression data (.txt)",
                               tags$style(type = "text/css", "#q2 {vertical-align: top;}"),
                               bsButton("q2", label = "", icon = icon("question"), style = "info", size = "extra-small")),
                           multiple=F,
                           accept = c(".txt")),
                 bsPopover(id = "q2", title = "Upload gene expression data",
                    content = paste0("Tab-separated file with genes as rows and sample data as 2nd column. First column must be HGNC Symbol. Second column header will be used as compound name, and used as input data (additional columns will be discarded). As input, you can use any gene-level statistic such as log2FC, or t-values."),
                    placement = "right", 
                    trigger = "click", 
                    options = list(container = "body")),
                 # Example data
                 materialSwitch(
                         inputId = "example_data",
                         label = "Load example data",
                 ),
                 p("(Example data taken from",
                   a("GSE129254 [Sun B, et al. Inhibition of the transcriptional kinase CDK7 overcomes therapeutic resistance in HER2-positive breast cancers. Oncogene 2020 Jan;39(1):50-63.])",
                     href = "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE129254",
                     target="_blank")),
        ),
        
        # MAIN PANEL
        mainPanel(
          tags$style(type="text/css",
                     ".shiny-output-error { visibility: hidden; }",
                     ".shiny-output-error:before { visibility: hidden; }"),
          
          "Uploaded gene expression and network data will be used in ",strong("3. Analysis")," for DoRothEA TF inference, PROGENy pathway inference, and CARNIVAL network analysis.",
          tags$br(),
          tags$br(),
          # Network info plus any warnings or errors
          strong("Uploaded Network:"),
          DTOutput("networkrender"),
          tags$br(),
          textOutput("networkstats"),
          
          tags$br(),
          
          # Gex info plus any warnings or errors
          strong("Uploaded Gene Expression Data:"),
          tags$br(),
          DTOutput("gextable"),
          tags$br(),
          textOutput("gexdata"),
          
          # "Upload data" or "please continue" depending 
          tags$br(),
          textOutput("nextstep1"),
          tags$br()
        )
)