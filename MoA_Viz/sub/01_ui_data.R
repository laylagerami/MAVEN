
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
        
)


             