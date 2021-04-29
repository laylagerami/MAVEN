# Disable buttons if data not available
shinyjs::hide("sortable") # hide target sorter by default

observe({
  if(values$gex_uploaded == F){
    disable("run_dorothea")
    disable("download_dorothea")
    disable("run_progeny")
    disable("download_progeny")
    # disable others too
  }
  else{
    enable("run_dorothea")
    enable("run_progeny")
  }
})

# CARNIVAL can only run if we have a network and the dorothea+progeny scores
observe({
  if(values$gex_uploaded == F | values$network_uploaded == F | is.null(values$tf_activities_carnival) | is.null(values$progenylist)){
    disable("run_carnival")
  }
  else{
    enable("run_carnival")
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
observeEvent(input$run_progeny, {
  enable("download_progeny") # allow download button after running
  observeEvent(input$no_genes_progeny, {
    datadf = values$datadf
    rownames(datadf) = datadf[,1]
    datadf[,1] = NULL
    datadf = as.matrix(datadf)
    PathwayActivity_counts <- progeny(datadf, scale=TRUE, 
                                            organism="Human", perm=10000, z_scores=F,
                                            top = as.numeric(input$no_genes_progeny))
    
    PA_render <- PathwayActivity_counts %>%
             t() %>%
             as.data.frame() %>%
             tibble::rownames_to_column(var="Pathway")
    
    # get progeny scores for carnival
    load(file=system.file("progenyMembers.RData",package="CARNIVAL"))
    PathwayActivity_carnival <- data.frame(PA_render, stringsAsFactors = F)
    rownames(PathwayActivity_carnival) <- PathwayActivity_carnival$Pathway
    PathwayActivity_carnival$Pathway <- NULL
    values$progenylist <- assignPROGENyScores(progeny = t(PathwayActivity_carnival), 
                                             progenyMembers = progenyMembers, 
                                             id = "gene", 
                                             access_idx = 1)
    
    # output df
    PA_df = PA_render
    colnames(PA_df)[2] <- "score"
    PA_df$score = as.numeric(as.character(PA_df$score))
    PA_df = PA_df %>%
      dplyr::arrange(desc(abs(score)))
    values$progenydf = PA_df
    output$progeny_df <- renderDT({
       datatable(PA_df,options=list("pageLength"=14))
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
})

# download
observeEvent(input$download_progeny, {
  withProgress(message="Saving PROGENy results to output folder...",value=1, {
    Sys.sleep(2)
    # Get current time
    time_now = gsub(" ","_",Sys.time())
    time_now = gsub(":","-",time_now)
    
    # Get comp name
    datadf = values$datadf
    cname = colnames(datadf)[2]
    
    # Isolate reactive vals
    responsivegenes = isolate(input$no_genes_progeny)
    progenydf <- isolate(values$progenydf)
    
    # Get dir
    fdir = paste0("output/progeny_results_",cname,"_",time_now)
    dir.create(fdir)
    
    plotfname = paste0(fdir,"/progeny_barplot.png")
    ggsave(plotfname,width=10,height=7)
    
    tablefname = paste0(fdir,"/progeny_table.csv")
    write.csv(progenydf,tablefname,quote=F,row.names = F)
    
    logfname = paste0(fdir,"/settings.txt")
    logdf = data.frame(responsivegenes)
    rownames(logdf) = c("No. Responsive Genes")
    colnames(logdf) = NULL
    write.table(logdf,logfname,quote = F,col.names = F,row.names = T,sep = ": ")
  })
})

# Check for targets
observe({
  if(length(input$carnival_targets)>0 & values$network_uploaded == T){
    shinyjs::show("sortable") # show target sorter
    
    # Get targets
    targets_to_use = input$carnival_targets
    
    # Overlap
    network = values$networkdf
    all_net_nodes = unique(c(network[,1],network[,2]))
    in_net = intersect(all_net_nodes,targets_to_use)
    not_in_net = setdiff(targets_to_use,all_net_nodes)
    not_in_net_flat = paste(not_in_net,collapse=", ")
    
    # The targets we eventually use
    values$carnival_targets = in_net
    
    # Warning messages
    if(length(not_in_net)>0 & length(not_in_net)<length(targets_to_use)){
      output$carnival_check = renderText({
        paste0("WARNING: Your target(s) ",not_in_net_flat," are not present in your network and will not be used as input for CARNIVAL. You can go back to Targets and choose additional targets if required.")
      })
    }else if(length(not_in_net)==length(targets_to_use)){
      hinyjs::hide("sortable") # hide target sorter
      output$carnival_check = renderText({
        paste0("WARNING: None of your targets are present in your network. No targets will be used as input for CARNIVAL. You can go back to Targets to choose additional targets, or upload a different network.")
      })
    }else if(length(not_in_net)==0){
      targets_to_use_flat = paste(targets_to_use,sep=", ")
      output$carnival_check = renderText({
        paste0(paste(targets_to_use,collapse=", ")," will be used as input targets in CARNIVAL.")
      })
    }
  }else if(length(input$carnival_targets)==0 & values$network_uploaded==T){
    shinyjs::hide("sortable") # hide target sorter
    output$carnival_check = renderText({
      paste0("CARNIVAL will be run with no input targets.")
    })
  }
})

# Targets activated or inhibited? (render bucket list)
output$sortable <- renderUI({
  bucket_list(
    header = "Choose whether to treat your targets as activated or inhibited",
    group_name = "bucket_list_group",
    orientation = "horizontal",
    add_rank_list(
      text = "Inhibited",
      labels = values$carnival_targets,
      input_id = "rank_list_inhibited"
    ),
    add_rank_list(
      text = "Activated",
      labels = NULL,
      input_id = "rank_list_activated"
    )
  )
})

# Retrieve results from bucket list
observe({
  values$inh_targets <- input$rank_list_inhibited
  values$act_targets <- input$rank_list_activated  
})


# Get solver name
observe({
  solver = input$solver
  values$solver = solver
  if(solver=="cplex"){
    enable("interactive_solver")
    output$choose_solver = renderText({"Please use the 'Select Solver' button to select the interactive IBM ILOG CPLEX solver before running CARNIVAL (usually in ibm/ILOG/CPLEX_StudioXXXX/cplex/bin/XXXX)"})
  }
  if(solver=="cbc"){
    enable("interactive_solver")
    output$choose_solver = renderText({"Please use the 'Select Solver' button to select the interactive cbc solver before running CARNIVAL (usually in usr/bin)"})
  }
  if(solver=="lpSolve"){
    disable("interactive_solver")
    output$choose_solver = renderText({"[WARNING: lpSolve should only be used for small/toy examples, and will generally not be useful for real-life studies. Please consider installing the freely available cbc solver, or the free for academic use IBM CPLEX solver.] Using lpSolve R package to run CARNIVAL, no interactive solver required."})
  }
})

# Get solver path
volumes <- getVolumes()()
shinyFileChoose(input, 'interactive_solver', roots=volumes)
observe({
  values$solver_file = input$interactive_solver
})

# CARNIVAL run (include checker)
started_carnival <- reactiveVal(Sys.time()[NA])
observeEvent(input$run_carnival, {
  started_carnival(Sys.time())
  
  # Create target df
  if(length(values$carnival_targets)>0 | !is.null(values$carnival_targets)){
    #shinyjs::show("sortable",asis=T)
    # activated
    act_targets_df = data.frame(t(values$act_targets))
    colnames(act_targets_df) = act_targets_df[1,]
    act_targets_df[1,] = rep(1,ncol(act_targets_df)) 
    # inhibited
    inh_targets_df = data.frame(t(values$inh_targets))
    colnames(inh_targets_df) = inh_targets_df[1,]
    inh_targets_df[1,] = rep(-1,ncol(inh_targets_df))
    # put together
    targets_df <- cbind(act_targets_df,inh_targets_df)
    values$carnival_targets_df = targets_df
    message <- "Running CARNIVAL with input targets...you can check progress in your R console"
  }else{
   # shinyjs::hide("sortable",asis=T) # hide target sortable
    targets_df <- NULL
    message <- "Running CARNIVAL with no input targets (Inverse CARNIVAL)...you can check progress in your R console"
  }
  
  # Check solver
  if(values$solver=="cplex"){
    if(paste(unlist(unname(values$solver_file[1])),collapse="/")==0){
      solver_check=F
    }else{
      solver_check=T
      solver_path = paste(unlist(unname(values$solver_file[1])),collapse="/")
    }
  }else if(values$solver=="cbc"){
    if(paste(unlist(unname(values$solver_file[1])),collapse="/")==0){
      solver_check=F
    }else{
      solver_check=T
      solver_path = paste(unlist(unname(values$solver_file[1])),collapse="/")
    }
  }else if(values$solver=="lpSolve"){
    solver_check=T
    solver_path=NULL
  }
  
  if(solver_check==T){
    withProgress(message=message,value=1, {
      values$carnival_result <- runCARNIVAL(inputObj=targets_df,
                                            netObj = values$networkdf,
                                            measObj = values$tf_activities_carnival[[1]],
                                            weightObj = values$progenylist[[1]],
                                            solverPath = solver_path,
                                            solver=values$solver,
                                            timelimit=as.numeric(input$carnival_time_limit),
                                            threads=as.numeric(input$carnival_ncores))
    })
  }else{
    output$carnival_warning = renderText({"ERROR: No interactive solver path chosen. Please use the Select Solver button, or change option to lpSolve. CARNIVAL terminating..."})
  }
})

   
# Check if CARNIVAL has finished and save results/params
observe({
 req(started_carnival())
 if(!is.null(values$carnival_result)){ # and include condition that it hasnt yet been uploaded
   # Create log file
   # CARNIVAL LOG
   if(!is.null(values$carnival_targets_df)){
     carnival_targets_df = values$carnival_targets_df
     up_targets_cols = (carnival_targets_df[1,] == 1)
     down_targets_cols = (carnival_targets_df[1,] == -1)
     up_targets = paste0("up_targets = ",paste(colnames(carnival_targets_df)[up_targets_cols],collapse=", "))
     down_targets = paste0("down_targets = ",paste(colnames(carnival_targets_df)[down_targets_cols],collapse=", "))
   }else{
     up_targets = paste0("up_targets = None")
     down_targets = paste0("down_targets = None")
   }
   solver = paste0("solver = ",values$solver)
   timelimit = paste0("timelimit = ",input$carnival_time_limit)
   solverPath = paste0("solverPath = ",paste(unlist(unname(values$solver_file[1])),collapse="/"))
   threads = paste0("threads = ",input$carnival_ncores)
   # default settings in case these change btwn versions
   mipGAP = "mipGAP = 0.05"
   poolrelGAP = "poolrelGAP = 0.0001"
   limitPop = "limitPop = 500"
   poolCap = "poolCap = 100"
   poolIntensity = "poolIntensity = 4"
   poolReplace = "poolReplace = 2"
   alphaWeight = "alphaWeight = 1"
   betaWeight = "betaWeight = 0.2"
   
   # DOROTHEA LOG
   top = paste0("top = ",input$no_tfs)
   conf = paste0("confidence levels = ",paste(input$dorothea_conf,sep=", "))
   minsize = "minsize = 5"
   esetfilter = "eset.filter = F"
   nes = "nes = T"
   
   # PROGENY LOG
   scale = "scale = T"
   perm = "perm = 10000"
   z_scores = "z_scores = F"
   top = paste0("top = ",input$no_genes_progeny)
   get_nulldist = "get_nulldist = F"
   
   # Put into file!
  
   # Save log file, RDS and .sif
   
   output$carnivaldone <- renderText({
     paste0("CARNIVAL run completed! Output and log file saved to xxx, Please move onto Visualisation tab.")
   })
 }
})


