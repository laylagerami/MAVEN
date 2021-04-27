tabPanel("Visualisation",
         sidebarPanel(
           "Choose MSigDB set or upload your own:",
           selectInput(
             inputId = "msigdb",
             label= h5("Choose MSigDB set",
                       tags$style(type = "text/css", "#q14 {vertical-align: top;}"),
                       bsButton("q14", label = "", icon = icon("question"), style = "info", size = "extra-small")
             ),
             choices = c("Hallmark" = "Hallmark",
                         "Biocarta" = "Biocarta",
                         "KEGG" = "KEGG",
                         "PID" = "PID",
                         "Reactome" = "Reactome",
                         "Wikipathways" = "Wikipathways",
                         "All Curated"="All",
                         "Canonical Pathways" = "CP",
                         "GO BP"="GO_BP",
                         "GO CC"="GO_CC",
                         "GO MF"="GO_MF",
                         "Custom"="Custom"),
             selected = "Hallmark"
           ),
           bsPopover(id = "q13", title = "Choose MSigDB set",
                     content = paste0("Gene set for network enrichment. See https://www.gsea-msigdb.org/gsea/msigdb/collections.jsp"),
                     placement = "right", 
                     trigger = "click", 
                     options = list(container = "body")
           ),
           fileInput("custom_msigdb","Upload custom .gmt file"),
           actionButton("run_enrich","Run enrichment analysis")
           
         ),
         
         mainPanel(
           "CARNIVAL network will be displayed below (you can pan and zoom). Following enrichment you can select pathways of interest.",
           tags$br(),
           tags$br(),
           fileInput("upload_carnival","Upload previous CARNIVAL .RDS file"),
           tags$hr(),
           visNetwork::visNetworkOutput("carnival_network",width = "700px", height = "500px"),
           downloadButton("download_carnival","Download network as a .sif file"),
           tags$hr(),
           "Network nodes in selected pathway: ",
           textOutput("pway_nodes"),
           DTOutput("pwayres"),
           downloadButton("download_pathway", label = "Download enrichment results as as a .csv file")
           
         )
         
)


