
# Run DoRoTHEA
observeEvent(input$run_dorothea, {
  data(dorothea_hs,package="dorothea")
  rownames(datadf) = datadf[,1]
  datadf[,1] = NULL
  regulons <- dorothea_hs%>%
    dplyr::filter(confidence %in% input$dorothea_conf)
  tf_activities <<- dorothea::run_viper(datadf,regulons,
                                            options=list(minsize=5,eset.filter=F,
                                                         cores=1,verbose=F,nes=T))
  
  # dorothea for carnival
  tf_activities_carnival <<- generateTFList(tf_activities,top=50,access_idx=1)
  
  tf_activities_topn <<- tf_activities %>%
    as.data.frame() %>% 
    rownames_to_column(var = "GeneID") %>%
    {colnames(.)[2]="NES"; .} %>%
    dplyr::top_n(as.numeric(input$no_tfs), wt = abs(NES)) %>%
    dplyr::arrange(NES) %>% 
    dplyr::mutate(GeneID = factor(GeneID))
  
  
  output$tf_df = renderDT({
    datatable(tf_activities_topn,options = list("pageLength" = 5))
  })
  output$tf_plot = renderPlot({
    ggplot(tf_activities_topn,aes(x = reorder(GeneID, NES), y = NES)) + 
      geom_bar(aes(fill = NES), stat = "identity") +
      scale_fill_gradient2(low = "darkblue", high = "indianred", 
                           mid = "whitesmoke", midpoint = 0) + 
      theme_minimal() +
      theme(axis.title = element_text(face = "bold", size = 12),
            axis.text.x = 
              element_text(angle = 45, hjust = 1, size =10, face= "bold"),
            axis.text.y = element_text(size =10, face= "bold"),
            panel.grid.major = element_blank(), 
            panel.grid.minor = element_blank()) +
      xlab("Transcription Factors")
  })
})

# Progeny
observeEvent(input$run_progeny, {
  rownames(datadf) = datadf[,1]
  datadf[,1] = NULL
  datadf = as.matrix(datadf)
  PathwayActivity_counts <<- progeny(datadf, scale=TRUE, 
          organism="Human", perm=10000, z_scores=F,
          top = as.numeric(input$no_genes_progeny))
  PA_render <<- PathwayActivity_counts %>%
    t() %>%
    as.data.frame() %>%
    tibble::rownames_to_column(var="Pathway")

  # progeny
  load(file=system.file("progenyMembers.RData",package="CARNIVAL"))
  PathwayActivity_carnival <- data.frame(PA_render, stringsAsFactors = F)
  rownames(PathwayActivity_carnival) <- PathwayActivity_carnival$Pathway
  PathwayActivity_carnival$Pathway <- NULL
  progenylist <<- assignPROGENyScores(progeny = t(PathwayActivity_carnival), 
                                      progenyMembers = progenyMembers, 
                                      id = "gene", 
                                      access_idx = 1)
  
  output$progeny_df <- renderDT({
    colnames(PA_render)[2] <- "score"
    PA_render$score = as.numeric(as.character(PA_render$score))
    PA_render %>%
      arrange(desc(abs(score)))
    datatable(PA_render,options=list("pageLength"=5))
  })
  
  output$progeny_plot <- renderPlot({
    PA_render <- PathwayActivity_counts %>%
      t() %>%
      as.data.frame() %>%
      tibble::rownames_to_column(var="Pathway")
    colnames(PA_render)[2] <- "score"
    ggplot(PA_render,aes(x = reorder(Pathway, score), y = score)) + 
      geom_bar(aes(fill = score), stat = "identity") +
      scale_fill_gradient2(low = "darkblue", high = "indianred", 
                           mid = "whitesmoke", midpoint = 0) + 
      theme_minimal() +
      theme(axis.title = element_text(face = "bold", size = 12),
            axis.text.x = 
              element_text(angle = 45, hjust = 1, size =10, face= "bold"),
            axis.text.y = element_text(size =10, face= "bold"),
            panel.grid.major = element_blank(), 
            panel.grid.minor = element_blank()) +
      xlab("Pathways")
  })
})

# CARNIVAL
# check CARNIVAL
output$carnival_check = renderText({
  if(input$target_bool==T){
    all_nodes = unique(c(as.character(networkdf$source),as.character(networkdf$target)))
    target_not_in_net = setdiff(targets,all_nodes)
    target_in_net <<- intersect(targets,all_nodes)
    if(length(target_not_in_net)==length(targets)){
      out = paste0("None of targets are in input network. Please select a network with larger coverage, or select different targets")
    }
    if(length(target_not_in_net)>0&length(target_in_net)>0){
      target_not_in_net_flat = paste(target_not_in_net,collapse=", ")
      out = paste0("WARNING: your target(s): ",target_not_in_net_flat," are not in your input network. Continuing without these targets.")
    }
}else{
    out = paste0("No targets will be used as input for CARNIVAL analysis")
}
  out
})

started <- reactiveVal(Sys.time()[NA])
observeEvent(input$run_carnival, {
  started(Sys.time())
# cplex
#  volumes <- getVolumes()()
#  shinyDirChoose(input, 'ibmfolder', roots=volumes, filetypes=c(),allowDirCreate=T)
#  observe({
#    ibmfolder <<- input$ibmfolder
#    ibmdir <<- paste(unlist(unname(ibmfolder[1])),collapse="/")
#  })
  
  ibmdir = "../../ibm/"
  targetdf = data.frame(t(target_in_net))
  colnames(targetdf) = targetdf[1,]
  targetdf[1,] = rep(1,ncol(targetdf))
  withProgress(message="Running CARNIVAL...",value=1, {
    carnival_result <<- runCARNIVAL(inputObj=targetdf,
                                  measObj = tf_activities_carnival[[1]],
                                  netObj = networkdf,
                                  weightObj = progenylist[[1]],
                                  solverPath = paste0(ibmdir,"ILOG/CPLEX_Studio1210/cplex/bin/x86-64_linux/cplex"),
                                  solver="cplex",
                                  timelimit=as.numeric(input$carnival_time_limit),
                                  mipGAP=0,
                                  poolrelGAP=0,
                                  threads=as.numeric(input$carnival_ncores))
  })
})
   
observe({
  req(started())
  if(exists(carnival_res)){
    output$carnivaldone <- renderText({
      paste0("CARNIVAL run completed. Please move onto Visualisation tab.")
    })
  }
})
