library(shiny)
library(shinyjs)
library(igraph)
library(DT)
library(miniUI)
library(chemdoodle)
library(rhandsontable)
library(shinysky)

ui <- shinyUI(
  actionButton("launch_app", "Launch sketcher to SMILES app")
)

server <- function(input, output) {
  observeEvent(input$launch_app, {
    rstudioapi::jobRunScript(path = "./gadget_script.R")
  })
}

shinyApp(ui, server)