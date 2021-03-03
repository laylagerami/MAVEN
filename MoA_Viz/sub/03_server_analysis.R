
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



