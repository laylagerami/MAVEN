tabPanel("Index",
         sidebarPanel(
           h3("Documentation and Help"),
           p("For FAQ/Troubleshooting and tutorials, please check out our documentation",
              a('here',
                     href = 'https://laylagerami.github.io/MAVEN/',
                     target='_blank')," or contact lh605[at]cam[dot]ac[dot]uk with any queries."),
           p("We also include help buttons throughout the app, represented by a [?] symbol, which detail data formats, explanations for different parameters, and more.")
           
         ),

         mainPanel(
           h2("Welcome"),
           "MAVEN, or ",strong("M"),"echanism of ",strong("A"),"ction ",strong("V"),"isualisation and ",
           strong("EN"),"richment, is a tool which enables GUI-based integrated chemical structure-based target prediction
           with gene expression-based causal reasoning.",
           tags$br(),
           tags$br(),
           img(src='workflow-1.jpeg', align = "centre", height="100%", width="100%"),
           tags$br(),
           tags$br(),
           "The first step in the MAVEN workflow is uploading your data. You will need to provide a prior knowledge network (PKN) (or use the default network) and gene expression measurements.",
           tags$br(),
           tags$br(),
           "Next, you will (optionally) define targets of your compound, either manually or by performing compound structure-based target prediction with PIDGINv4. If you do not wish to define targets, then the pipeline can still be run without.",
           tags$br(),
           tags$br(),
           "The next step is to carry out the data analysis. First, the gene expression data will be used to infer transcription factor (TF) activities using DoRothEA. Then, you will run PROGENy to infer pathway activity from your input gene expression data. Finally, the TFs, pathway activities, and optionally targets will be input along with your PKN to CARNIVAL to infer a signalling network capturing dysregulated proteins induced by your compound.",
           tags$br(),
           tags$br(),
           "The final step is the visualisation of the network, as well as pathway enrichment which can be carried out with the MSigDB gene sets included with the package OR any custom .gmt file. To aid in the interpretation of the pathway enrichment results, involved proteins can be highlighted on the netowrk.",
           tags$br(),
           tags$br(),
           "MAVEN is aimed at researchers looking to generate hypotheses for compound mechanism of action, with little to no coding experience required. If you have not used the tools mentioned here before, we recommend you check out our tutorial.",
           tags$br(),
           tags$br()
    
         )
         
)