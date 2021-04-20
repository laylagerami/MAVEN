# Disable buttons if data not available
observe({
  if(values$gex_uploaded == F){
    disable("run_dorothea")
    disable("download_dorothea")
    # disable others too
  }
  else{
    enable("run_dorothea")
  }
})

# Run DoRoThEA
observeEvent(input$run_dorothea, {
  # Enable download of files once dorothea is run
  enable("download_dorothea")

  # Prepare data
  data(dorothea_hs,package="dorothea")
  gex_data = values$datadf
  rownames(gex_data) = gex_data[,1]
  gex_data[,1] = NULL
  regulons = dorothea_hs %>%
    dplyr::filter(confidence %in% input$dorothea_conf)

  # Run
  tf_activities = dorothea::run_viper(gex_data,regulons,
                                        options=list(minsize=5,eset.filter=F,
                                                     cores=1,verbose=F,nes=T))
  
  # get top n for table/plot
  observeEvent(input$no_tfs,{
    # Format for CARNIVAL 
    values$tf_activities_carnival = generateTFList(tf_activities,
                                                   top=as.numeric(input$no_tfs),
                                                   access_idx=1)
    
    tf_activities_topn = tf_activities %>%
      as.data.frame() %>% 
      rownames_to_column(var = "GeneID") %>%
      {colnames(.)[2]="NES"; .} %>%
      dplyr::top_n(as.numeric(input$no_tfs), wt = abs(NES)) %>%
      dplyr::arrange(abs(NES)) %>% 
      dplyr::mutate(GeneID = factor(GeneID))
    
    # Save var for later
    values$tf_activities_topn = tf_activities_topn
    
    # convert to uniprot, keep only the first, convert to url
    conversion = AnnotationDbi::select(org.Hs.eg.db,
                                       as.character(tf_activities_topn$GeneID),
                                       columns=c("SYMBOL","UNIPROT"),
                                       keytype="SYMBOL")
    conversion_dedup = conversion %>% distinct(SYMBOL,.keep_all=TRUE)
    conversion_dedup$url <- paste0("https://www.uniprot.org/uniprot/",conversion_dedup$UNIPROT)
    conversion_dedup$url <- paste0("<a href='",conversion_dedup$url,"' target='_blank'>",conversion_dedup$SYMBOL,"</a>")
    
    # merge and na handler
    tf_uniprot_merge = merge(tf_activities_topn,conversion_dedup,by.x="GeneID",by.y="SYMBOL",all=T)
    tf_uniprot_merge$TF= ifelse(is.na(tf_uniprot_merge$UNIPROT)==T,as.character(tf_uniprot_merge$GeneID),tf_uniprot_merge$url)
    
    # change table names and render
    tf_activities_render = tf_uniprot_merge[,c(5,2)]
    tf_activities_render$NES = as.numeric(as.character(tf_activities_render$NES))
    tf_activities_render = tf_activities_render%>%
      dplyr::arrange(desc(abs(NES)))
    colnames(tf_activities_render) = c("TF (HGNC)","Normalised Enrichment Score (NES)")
    output$tf_df = renderDT({
      datatable(tf_activities_render,options = list("pageLength" = 5),escape=1)
    })
    
    # plot tf 
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
})

# download
observeEvent(input$download_dorothea, {
  withProgress(message="Saving DoRothEA results to output folder...",value=1, {
    Sys.sleep(2)
    # Get current time
    time_now = gsub(" ","_",Sys.time())
    time_now = gsub(":","-",time_now)
    
    # Get comp name
    datadf = values$datadf
    cname = colnames(datadf)[2]
    
    # Isolate reactive vals
    conf_level = isolate(input$dorothea_conf)
    n_tfs = isolate(input$no_tfs)
    tf_activities_topn = isolate(values$tf_activities_topn)
    
    # Get dir
    fdir = paste0("output/dorothea_results_",cname,"_",time_now)
    dir.create(fdir)
    
    plotfname = paste0(fdir,"/tf_barplot.png")
    ggsave(plotfname,width=10,height=7)
    
    tablefname = paste0(fdir,"/tf_table.csv")
    write.csv(tf_activities_topn,tablefname,quote=F,row.names = F)
    
    logfname = paste0(fdir,"/settings.txt")
    conf = paste(conf_level,collapse = ", ")
    logdf = data.frame(c(conf,n_tfs))
    rownames(logdf) = c("Confidence Levels","No. Top TFs")
    colnames(logdf) = NULL
    write.table(logdf,logfname,quote = F,col.names = F,row.names = T,sep = ": ")
  })
})

# run PROGEny
#   
#   # Progeny
#   observeEvent(input$no_genes_progeny, {
#     # run
#     rownames(datadf) = datadf[,1]
#     datadf[,1] = NULL
#     datadf = as.matrix(datadf)
#     PathwayActivity_counts <<- progeny(datadf, scale=TRUE, 
#                                        organism="Human", perm=10000, z_scores=F,
#                                        top = as.numeric(input$no_genes_progeny))
#     PA_render <<- PathwayActivity_counts %>%
#       t() %>%
#       as.data.frame() %>%
#       tibble::rownames_to_column(var="Pathway")
#     
#     # get progeny scores for carnival
#     load(file=system.file("progenyMembers.RData",package="CARNIVAL"))
#     PathwayActivity_carnival <- data.frame(PA_render, stringsAsFactors = F)
#     rownames(PathwayActivity_carnival) <- PathwayActivity_carnival$Pathway
#     PathwayActivity_carnival$Pathway <- NULL
#     progenylist <<- assignPROGENyScores(progeny = t(PathwayActivity_carnival), 
#                                         progenyMembers = progenyMembers, 
#                                         id = "gene", 
#                                         access_idx = 1)
#     # output df
#     output$progeny_df <- renderDT({
#       colnames(PA_render)[2] <- "score"
#       PA_render$score = as.numeric(as.character(PA_render$score))
#       PA_render %>%
#         arrange(desc(abs(score)))
#       datatable(PA_render,options=list("pageLength"=14))
#     })
#     
#     # output plot
#     output$progeny_plot <- renderPlot({
#       PA_render <- PathwayActivity_counts %>%
#         t() %>%
#         as.data.frame() %>%
#         tibble::rownames_to_column(var="Pathway")
#       colnames(PA_render)[2] <- "score"
#       ggplot(PA_render,aes(x = reorder(Pathway, score), y = score)) + 
#         geom_bar(aes(fill = score), stat = "identity") +
#         scale_fill_gradient2(low = "darkblue", high = "indianred", 
#                              mid = "whitesmoke", midpoint = 0) + 
#         theme_minimal() +
#         theme(axis.title = element_text(face = "bold", size = 12),
#               axis.text.x = 
#                 element_text(angle = 45, hjust = 1, size =10, face= "bold"),
#               axis.text.y = element_text(size =10, face= "bold"),
#               panel.grid.major = element_blank(), 
#               panel.grid.minor = element_blank()) +
#         xlab("Pathways")
#     })
#   })
#   
#   # CARNIVAL run
#   started <- reactiveVal(Sys.time()[NA])
#   observeEvent(input$run_carnival, {
#     started(Sys.time())
#     # cplex
#     #  volumes <- getVolumes()()
#     #  shinyDirChoose(input, 'ibmfolder', roots=volumes, filetypes=c(),allowDirCreate=T)
#     #  observe({
#     #    ibmfolder <<- input$ibmfolder
#     #    ibmdir <<- paste(unlist(unname(ibmfolder[1])),collapse="/")
#     #  })
#     
#     ibmdir = "../../ibm/"
#     targetdf = data.frame(t(target_in_net))
#     colnames(targetdf) = targetdf[1,]
#     targetdf[1,] = rep(1,ncol(targetdf))
#     # withProgress(message="Running CARNIVAL...",value=1, {
#     #  carnival_result <<- runCARNIVAL(inputObj=targetdf,
#     #                                measObj = tf_activities_carnival[[1]],
#     #                                netObj = networkdf,
#     #                                weightObj = progenylist[[1]],
#     #                                solverPath = paste0(ibmdir,"ILOG/CPLEX_Studio1210/cplex/bin/x86-64_linux/cplex"),
#     #                                solver="cplex",
#     #                                timelimit=as.numeric(input$carnival_time_limit),
#     #                                mipGAP=0,
#     #                                poolrelGAP=0,
#     #                                threads=as.numeric(input$carnival_ncores))
#     #})
#   })
#   
#   # Check if CARNIVAL has finished
#   observe({
#     req(started())
#     if(exists("carnival_result")){
#       output$carnivaldone <- renderText({
#         paste0("CARNIVAL run completed. Please move onto Visualisation tab.")
#       })
#     }
#   })


