# get uploaded result
observe({
  infilecarnival <- input$upload_carnival
  if(!is.null(infilecarnival)){
    values$carnival_result = readRDS(input$upload_carnival$datapath)
  }
})


# Network rendering function
generateNetwork = function(carnival_result){
  #transoform to data.frame
  carnival_result$weightedSIF <- data.frame(carnival_result$weightedSIF, stringsAsFactors = F)
  carnival_result$weightedSIF$Sign <- as.numeric(carnival_result$weightedSIF$Sign)
  carnival_result$weightedSIF$Weight <- as.numeric(carnival_result$weightedSIF$Weight)
  carnival_result$nodesAttributes <- data.frame(carnival_result$nodesAttributes, stringsAsFactors = F)
  carnival_result$nodesAttributes$ZeroAct <- as.numeric(carnival_result$nodesAttributes$ZeroAct)
  carnival_result$nodesAttributes$UpAct <- as.numeric(carnival_result$nodesAttributes$UpAct)
  carnival_result$nodesAttributes$DownAct <- as.numeric(carnival_result$nodesAttributes$DownAct)
  carnival_result$nodesAttributes$AvgAct <- as.numeric(carnival_result$nodesAttributes$AvgAct)
  carnival_visNet(evis = carnival_result$weightedSIF,
                  nvis = carnival_result$nodesAttributes)[1]
}

# Render if result is present
observe({
  if(!is.null(values$carnival_result)){
    output$carnival_network <- renderVisNetwork(generateNetwork(values$carnival_result))
  }
})

# Enrichment
# Load pathways

enrich_results <- eventReactive(input$run_enrich, {
  values$enrichment_result=T
  carnival_result = values$carnival_result
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
  if(input$msigdb=="All"){
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
  pathways = gmt_to_csv(gmt_set)
  values$pathways = pathways
  
  # Extract nodes and bg
  values$nodes_carnival = extractCARNIVALnodes(carnival_result)
  nodes_carnival = values$nodes_carnival$sucesses
  nodes_carnival_bg = values$nodes_carnival$bg
  
  if(input$include_tfs==F){
    nodesAttributes = data.frame(carnival_result$nodesAttributes)
    tfs = subset(nodesAttributes,NodeType=="T")$Node
    nodes_carnival = nodes_carnival[!nodes_carnival %in% tfs]
    nodes_carnival_bg = nodes_carnival_bg[!nodes_carnival_bg %in% tfs]
  }
  
  # GSA
  withProgress(message="Running Enrichment...",value=1, {
    sig_pathways = runGSAhyper(genes=nodes_carnival,
                               universe = nodes_carnival_bg,
                               gsc = loadGSC(pathways))
  })
  
  sig_pathways_df = as.data.frame(sig_pathways$resTab) %>%
    tibble::rownames_to_column(var="pathway")
  values$sig_pathways_df_full = sig_pathways_df
  sig_pathways_df = sig_pathways_df[,c(1,3)]
  sig_pathways_df[,2] = as.numeric(as.character(sig_pathways_df[,2]))
  sig_pathways_df = sig_pathways_df[order(sig_pathways_df[,2]),]
  values$sig_pathways_df = sig_pathways_df
  sig_pathways_df$url = paste0("https://www.gsea-msigdb.org/gsea/msigdb/cards/",sig_pathways_df$pathway)
  if(input$msigdb!="Custom"){ # create link
    sig_pathways_df$pathway <- paste0("<a href='",sig_pathways_df$url,"' target='_blank'>",sig_pathways_df$pathway,"</a>")
  }
  sig_pathways_df$url = NULL
  colnames(sig_pathways_df) = c("Pathway ID","Adjusted p-Value")
  datatable(sig_pathways_df[order(sig_pathways_df[,2]),],selection="single",escape=1)  %>% 
    formatSignif(columns = c(2), digits = 3)
})

output$download_pathway <- downloadHandler(
  filename = function() {
    paste0('pathwayRes_', input$msigdb, '.csv')
  },
  content = function(con) {
    write.csv(values$sig_pathways_df_full, con,quote=F,row.names=F)
  }
)

observe({
  if(values$enrichment_result==T){
    enable("download_pathway")
  }else{
    disable("download_pathway")
  }
})

output$pwayres = renderDT({
  enrich_results()
})

observe({
  if(values$enrichment_result==T){
    selected = input$pwayres_rows_selected
    if(length(selected)>0){
      pathways <- values$pathways
      nodes_carnival = values$nodes_carnival
      
      carnival_result = values$carnival_result
      carnival_result$weightedSIF <- data.frame(carnival_result$weightedSIF, stringsAsFactors = F)
      carnival_result$weightedSIF$Sign <- as.numeric(carnival_result$weightedSIF$Sign)
      carnival_result$weightedSIF$Weight <- as.numeric(carnival_result$weightedSIF$Weight)
      carnival_result$nodesAttributes <- data.frame(carnival_result$nodesAttributes, stringsAsFactors = F)
      carnival_result$nodesAttributes$ZeroAct <- as.numeric(carnival_result$nodesAttributes$ZeroAct)
      carnival_result$nodesAttributes$UpAct <- as.numeric(carnival_result$nodesAttributes$UpAct)
      carnival_result$nodesAttributes$DownAct <- as.numeric(carnival_result$nodesAttributes$DownAct)
      carnival_result$nodesAttributes$AvgAct <- as.numeric(carnival_result$nodesAttributes$AvgAct)
      
      # Get original colours to populate new df for visUpdate
      get_colours <- carnival_visNet(evis = carnival_result$weightedSIF,
                                     nvis = carnival_result$nodesAttributes)
      get_colours_df <- data.frame(cbind(get_colours$id,get_colours$color))
      colnames(get_colours_df) = c("id","color")
      all_node_ids = get_colours_df$id
      
      # Pathway selector, get nodes
      sig_pathways_df = values$sig_pathways_df
      selectedPathway <- sig_pathways_df[input$pwayres_rows_selected,]$pathway
      subsetGMT <- subset(pathways,term==selectedPathway)$gene
      overlap_nodes <- intersect(subsetGMT,all_node_ids)
      non_overlap_nodes = setdiff(all_node_ids,overlap_nodes)
      overlap_nodes_df <- data.frame(id=overlap_nodes,color=rep("#00FF00",length(overlap_nodes)))
      
      # Set colour for non-overlapping nodes
      non_overlap_nodes_df = subset(get_colours_df,id%in%non_overlap_nodes)
      
      # Lighten them
      non_overlap_nodes_df$color = lighten(non_overlap_nodes_df$color,amount=0.8)
      
      # Get final colour df
      all_nodes_df <- rbind(overlap_nodes_df,non_overlap_nodes_df)
      row.names(all_nodes_df) = NULL
      
      visNetworkProxy("carnival_network") %>%
        visUpdateNodes(nodes=all_nodes_df)
      
      # Print nodes
      output$pway_nodes = renderText(paste0(overlap_nodes,collapse=", "))
    }else if(length(selected)==0){ # deselect
      output$carnival_network <- renderVisNetwork(generateNetwork(values$carnival_result))
      output$pway_nodes = renderText("")
    }
  }
})