
tabPanel("Analysis",
         sidebarPanel(
           h5("Choose Settings"),
           tags$hr(),
           "DoRothEA:",
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
           "PROGENy: ",
           tags$br(),
           tags$br(),
           "CARNIVAL"
           
         ),
         
         mainPanel(
           textOutput("test_select")
         )
         
)


