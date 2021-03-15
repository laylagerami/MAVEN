# Network rendering
generateNetwork = function(){
  #transoform to data.frame
  carnival_result$weightedSIF <- data.frame(carnival_result$weightedSIF, stringsAsFactors = F)
  carnival_result$weightedSIF$Sign <- as.numeric(carnival_result$weightedSIF$Sign)
  carnival_result$weightedSIF$Weight <- as.numeric(carnival_result$weightedSIF$Weight)
  carnival_result$nodesAttributes <- data.frame(carnival_result$nodesAttributes, stringsAsFactors = F)
  carnival_result$nodesAttributes$ZeroAct <- as.numeric(carnival_result$nodesAttributes$ZeroAct)
  carnival_result$nodesAttributes$UpAct <- as.numeric(carnival_result$nodesAttributes$UpAct)
  carnival_result$nodesAttributes$DownAct <- as.numeric(carnival_result$nodesAttributes$DownAct)
  carnival_result$nodesAttributes$AvgAct <- as.numeric(carnival_result$nodesAttributes$AvgAct)
  carnival_result <<- carnival_result
  carnival_visNet(evis = carnival_result$weightedSIF,
                  nvis = carnival_result$nodesAttributes)[1]
}
output$carnival_network <- renderVisNetwork(generateNetwork())




# Enrichment
# Load pathways

enrich_results <- eventReactive(input$run_enrich, {
  if(input$msigdb=="Hallmark"){
    gmt_set = "msigdb/h.all.v7.2.symbols.gmt"
  }
  if(input$msigdb=="Biocarta"){
    gmt_set = "msigdb/c2.cp.biocarta.v7.2.symbols.gmt"
  }
  if(input$msigdb=="KEGG"){
    gmt_set = "msigdb/c2.cp.kegg.v7.2.symbols.gmt"
  }
  if(input$msigdb=="PID"){
    gmt_set="msigdb/c2.cp.pid.v7.2.symbols.gmt"
  }
  if(input$msigdb=="Reactome"){
    gmt_set="msigdb/c2.cp.reactome.v7.2.symbols.gmt"
  }
  if(input$msigdb=="Wikipathways"){
    gmt_set="msigdb/c2.cp.wikipathways.v7.2.symbols.gmt"
  }
  if(input$msigdb=="All Curated"){
    gmt_set="msigdb/c2.all.v7.2.symbols.gmt"
  }
  if(input$msigdb=="CP"){
    gmt_set="msigdb/c2.cp.v7.2.symbols .gmt"
  }
  if(input$msigdb=="GO_BP"){
    gmt_set="msigdb/c5.go.bp.v7.2.symbols.gmt"
  }
  if(input$msigdb=="GO_MF"){
    gmt_set="msigdb/c5.go.mf.v7.2.symbols.gmt"
  }
  if(input$msigdb=="GO_CC"){
    gmt_set="msigdb/c5.go.cc.v7.2.symbols.gmt"
  }
  if(input$msigdb=="Custom"){
    file <- input$custom_msigdb
    ext <- tools::file_ext(file$datapath)
    req(file)
    validate(need(ext == "gmt", "Please upload a .gmt file"))
    gmt_set = file$datapath
  }
  pathways <<- gmt_to_csv(gmt_set)
  # Extract nodes and bg
  nodes_carnival <<- extractCARNIVALnodes(carnival_result)
  
  # GSA
  withProgress(message="Running Enrichment...",value=1, {
  sig_pathways = runGSAhyper(genes=nodes_carnival$sucesses,
                             universe = nodes_carnival$bg,
                             gsc = loadGSC(pathways))
  })
  
  sig_pathways_df = as.data.frame(sig_pathways$resTab) %>%
    tibble::rownames_to_column(var="pathway")
  
  sig_pathways_df = sig_pathways_df[,c(1,3)]
  sig_pathways_df[,2] = as.numeric(as.character(sig_pathways_df[,2]))
  sig_pathways_df <<- sig_pathways_df[order(sig_pathways_df[,2]),]
  datatable(sig_pathways_df[order(sig_pathways_df[,2]),],selection="single")
})

output$pwayres = renderDT({
  enrich_results()
})

observeEvent(input$pwayres_rows_selected,{
  # Get original colours to populate new df for visUpdate
  get_colours <- carnival_visNet(evis = carnival_result$weightedSIF,
                         nvis = carnival_result$nodesAttributes)
  get_colours_df <- data.frame(cbind(get_colours$id,get_colours$color))
  colnames(get_colours_df) = c("id","color")
   
  # Pathway selector, get nodes
  selectedPathway = sig_pathways_df[input$pwayres_rows_selected,]$pathway
  #selectedPathway = sig_pathways_df[1,]$pathway
  subsetGMT = subset(pathways,term==selectedPathway)$gene
  overlap_nodes = intersect(subsetGMT,nodes_carnival$sucesses)
  non_overlap_nodes = setdiff(nodes_carnival$sucesses,overlap_nodes)
  overlap_nodes_df <<- data.frame(id=overlap_nodes,color=rep("green",length(overlap_nodes)))
  
  # Set colour for non-overlapping nodes
  non_overlap_nodes_df = subset(get_colours_df,id%in%non_overlap_nodes)
  
  # Get final colour df
  all_nodes_df = rbind(overlap_nodes_df,non_overlap_nodes_df)
  
  visNetworkProxy("carnival_network") %>%
    visUpdateNodes(nodes=all_nodes_df)
  
  # Print nodes
  output$pway_nodes = renderText(paste0(overlap_nodes,collapse=", "))
})



