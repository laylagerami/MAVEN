library(shiny)
library(miniUI)
library(chemdoodle)


# THIS SCRIPT IS WRITTEN BY GITHUB@ZACHCP 

server <- function(input, output,session) {
  
  session$onSessionEnded(function() {
    stopApp()
  })
  
  #set a dummy reactive variable
  mol <- reactiveValues(moleculedata = NULL,smiles=NULL,molname=NULL,df=NULL)
  
  #function to update the value based on changes on the shiny side
  observeEvent(input$moleculedata, {
    moljson <- input$moleculedata
    mol$moleculedata <- processChemDoodleJson(moljson)
    
  })
  
  # output function renders SMILES
  output$smiles_out <- renderText({
    if (is.null(mol$moleculedata)){
      return("Draw a molecule and click Done to retrieve SMILES file")
    } else {
      mol$smiles <- toSmiles(mol$moleculedata)
      return(paste("Smiles:", mol$smiles))
    }
  })
  
  # Render table
  output$smiles_table <- renderTable({
    if(!is.null(mol$moleculedata)){
      if(input$comp_name==""){
        mol$molname = "Compound"
        df = t(data.frame(c(mol$smiles,"Compound 1")))
        row.names(df) = NULL
        colnames(df) = c("SMILES","Compound Name")
        mol$df = df
      }else{
        mol$molname = input$comp_name
        df = t(data.frame(c(mol$smiles,input$comp_name)))
        row.names(df) = NULL
        colnames(df) = c("SMILES","Compound Name")
        mol$df = df
      }
      df
    }
  })
  
  output$download <- renderUI({
    if(!is.null(mol$smiles)){
      downloadButton("downloadSmiles", "Download .smi file")
    }
  })
    
  # Downloader
  output$downloadSmiles <- downloadHandler(
    filename = function() {
      paste0(mol$molname, ".smi")
    },
    content = function(con) {
      write.table(mol$df, con, row.names = FALSE, col.names=FALSE,sep="\t",quote=F)
    }
  )
}

ui <- miniPage(
  
  mainPanel(h3(textOutput("smiles_out"))),
  textInput("comp_name", "Compound ID (Optional)"),
  miniContentPanel(chemdoodle_sketcher(mol=NULL)),
  
  gadgetTitleBar("Draw A Molecule", right = miniTitleBarButton("done", "Done", primary = TRUE)),
  
  tags$script('
              document.getElementById("done").onclick = function() {
              var mol = sketcher.getMolecule();
              var jsonmol = new ChemDoodle.io.JSONInterpreter().molTo(mol);
              Shiny.onInputChange("moleculedata", jsonmol);};'
  ),
  
  # Render table
  tableOutput("smiles_table"),
  
  # Download
  uiOutput("download")
  
  )

shinyApp(ui = ui, server = server)

# save each SMLE in a DF and allow to download for input into app
