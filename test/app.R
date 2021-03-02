

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
    
    # Application title
    titlePanel("Test"),
    
    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            sliderInput("bins",
                        "Number of bins:",
                        min = 1,
                        max = 50,
                        value = 30)
        ),
        
        # Show a plot of the generated distribution
        mainPanel(
            tags$head(tags$style(HTML("
                                .btn {
                                color:rgb(255,255,255);
                                text-align: left;
                                #border-color:rgb(0,144,197);
                                background-color:rgb(0,144,197);}

                                # #button:active {
                                # background-color:rgb(51,255,153);
                                # }"))),
            shiny::actionButton("button", "Run PIDGIN"), # RUN MODELS
            tags$br(),
            textOutput("pidgindone"), # OUTPUT DONE MESSAGE         
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
    
    # init null output_name
    output_name = "Null"
    
    observeEvent(input$button, {
        # REATE .SH FILE AND RUN DUMMY SCRIPT - WORKING (params previously defined)
        bin_bash <- "#!/bin/bash"
        set <- 'set -m'
        conda <- "source activate pidgin3_env"
        output_name <<- "test_out.txt"
        runline <- paste0("python script_shiny.py")
        bash_file <- data.frame(c(bin_bash,set,conda,runline))
        write.table(bash_file,"./run_pidgin.sh",quote=F,row.names=F,col.names=F)
        system("bash -i run_pidgin.sh")
    })
    
    # Check output
    reactivePoll(1000,session,
                 checkFunc = function(){
                     if (file.exists(output_name)==T){
                         assign(x="preds",value=read.csv(output_name,
                                                         header=T,sep="\t"),
                                envir=.GlobalEnv)
                         output$pidgindone <- renderText({
                             paste0("Done, please move onto Results tab.")
                         })
                     }
                 })
    
    
}

# Run the application 
shinyApp(ui = ui, server = server)
