tabPanel("Data",
         # SIDEBAR
         sidebarPanel(
                 useShinyalert(),
                 
                 # Text
                 strong("Step 1. Data Input"),
                 
                 # Upload Network
                 fileInput(inputId = "network", 
                           label = h5("Upload network (.sif or .txt)",
                               tags$style(type = "text/css", "#q1 {vertical-align: top;}"),
                               bsButton("q1", label = "", icon = icon("question"), style = "info", size = "extra-small")),
                           multiple=F,
                           accept = c(".sif",".txt")),
                  bsPopover(id = "q1", title = "Upload network",
                    content = paste0("Tab-separated file with three headers; Source, Interaction, Target."),
                    placement = "right", 
                    trigger = "click", 
                    options = list(container = "body")),
                 
                 tags$hr(),
                 
                 # Upload GEX
                 fileInput(inputId = "gex",
                            label = h5("Upload gene expression data (.txt)",
                               tags$style(type = "text/css", "#q2 {vertical-align: top;}"),
                               bsButton("q2", label = "", icon = icon("question"), style = "info", size = "extra-small")),
                           multiple=F,
                           accept = c(".txt")),
                 bsPopover(id = "q2", title = "Upload gene expression data",
                    content = paste0("Tab-separated file with genes as rows. Second column header will be used as compound name. First column must be HGNC Symbol. As input, you can use any gene-level statistic such as log2FC, or t-values."),
                    placement = "right", 
                    trigger = "click", 
                    options = list(container = "body")
          )
        ),
        
        # MAIN PANEL
        mainPanel(
          tags$style(type="text/css",
                     ".shiny-output-error { visibility: hidden; }",
                     ".shiny-output-error:before { visibility: hidden; }"),
          
          # Network info
          strong("Uploaded Network:"),
          DTOutput("networkrender"),
          tags$br(),
          textOutput("networkstats"),
          
          tags$br(),
          
          # Gex info
          strong("Uploaded Gene Expression Data:"),
          tags$br(),
          DTOutput("gextable"),
          tags$br(),
          textOutput("gexdata"),
          
          # "Upload data" or "please continue"
          tags$br(),
          textOutput("nextstep1"),
          tags$br()
        )
)