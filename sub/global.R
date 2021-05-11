# libraries
library(shiny)
library(shinyjs)
library(igraph)
library(DT)
library(miniUI)
library(chemdoodle)
library(rhandsontable)
library(shinysky)
library(shinyBS)
library(shinythemes)
library(shinyFiles)
library(org.Hs.eg.db)
library(dorothea)
library(dplyr)
library(tibble)
library(ggplot2)
library(progeny)
library(CARNIVAL)
library(visNetwork)
library(piano)
library(HGNChelper)
library(shinyalert)
library(shinyWidgets)
library(lpSolve)
library(sortable)
library(colorspace)

# define global vars
values <- reactiveValues(
  gex_uploaded=F,
  network_uploaded=F,
  networkdf=NULL,
  datadf=NULL,
  output_name_pidgin=NULL,
  smi_string=NULL,
  smi_file=NULL,
  smiles_error=NULL,
  pidginBa = NULL,
  pidginAd = NULL,
  pidginCores = NULL,
  pidginfolder =NULL,
  pidgindir= NULL,
  predictpy = NULL,
  sim2train =NULL,
  output_name_pidgin=NULL,
  output_name_2=NULL,
  preds=NULL,
  simtrain=NULL,
  preds_converted=NULL,
  targets=NULL,
  targets_in_net=NULL,
  all_targets=NULL,
  tf_activities_carnival=NULL,
  tf_activities_topn = NULL,
  progenylist = NULL,
  progenydf = NULL,
  carnival_targets = NULL,
  carnival_result = NULL,
  carnival_done=F,
  enrichment_result=F,
  sig_pathways_df_full=NULL,
  sig_values_df=NULL,
  pathway=NULL,
  solver_file=NULL,
  solver=NULL,
  carnival_result=NULL,
  inh_targets=NULL,
  act_targets=NULL,
  pidgin_time_now=NULL,
  output_namemat = NULL,
  carnival_targets_df = NULL,
  carnival_time_now=NULL,
  all_nodes=NULL,
  carnival_result_format = NULL
)

# set seed 
set.seed(42)

# functions
generateTFList <- function (df = df, top = 50, access_idx = 1) 
{
  if (top == "all") {
    top <- nrow(df)
  }
  if (top > nrow(df)) {
    warning("Number of to TF's inserted exceeds the number of actual TF's in the\n            data frame. All the TF's will be considered.")
    top <- nrow(df)
  }
  ctrl <- intersect(x = access_idx, y = 1:ncol(df))
  if (length(ctrl) == 0) {
    stop("The indeces you inserted do not correspond to \n              the number of columns/samples")
  }
  returnList <- list()
  for (ii in 1:length(ctrl)) {
    tfThresh <- sort(x = abs(df[, ctrl[ii]]), decreasing = TRUE)[top]
    temp <- which(abs(df[, ctrl[ii]]) >= tfThresh)
    currDF <- matrix(data = , nrow = 1, ncol = top)
    colnames(currDF) <- rownames(df)[temp[1:top]]
    currDF[1, ] <- df[temp[1:top], ctrl[ii]]
    currDF <- as.data.frame(currDF)
    returnList[[length(returnList) + 1]] <- currDF
  }
  names(returnList) <- colnames(df)[ctrl]
  return(returnList)
}

assignPROGENyScores <- function (progeny = progeny, progenyMembers = progenyMembers, 
                                 id = "gene", access_idx = 1) 
{
  if (id == "uniprot") {
    idx <- which(names(progenyMembers) == "uniprot")
    progenyMembers <- progenyMembers[[idx]]
  }
  else {
    idx <- which(names(progenyMembers) == "gene")
    progenyMembers <- progenyMembers[[idx]]
  }
  members <- matrix(data = , nrow = 1, ncol = 2)
  pathways <- colnames(progeny)
  ctrl <- intersect(x = access_idx, y = 1:nrow(progeny))
  if (length(ctrl) == 0) {
    stop("The indeces you inserted do not correspond to \n              the number of rows/samples")
  }
  for (ii in 1:length(pathways)) {
    mm <- progenyMembers[[which(names(progenyMembers) == 
                                  pathways[ii])]]
    for (jj in 1:length(mm)) {
      members <- rbind(members, c(pathways[ii], mm[jj]))
    }
  }
  members <- members[-1, ]
  scores <- matrix(data = , nrow = nrow(progeny), ncol = nrow(members))
  colnames(scores) <- members[, 2]
  rownames(scores) <- rownames(progeny)
  members <- unique(members)
  for (i in 1:ncol(scores)) {
    for (j in 1:nrow(scores)) {
      scores[j, i] <- as.numeric(progeny[j, members[which(members[, 
                                                                  2] == colnames(scores)[i]), 1]])
    }
  }
  pxList <- list()
  for (ii in 1:length(access_idx)) {
    pxList[[length(pxList) + 1]] <- as.data.frame(t(as.matrix(scores[access_idx[ii], 
    ])))
  }
  names(pxList) <- rownames(progeny)[ctrl]
  return(pxList)
}

carnival_visNet <- function(evis, nvis, mapIDs=NULL){
  
  # color node scale red to blue
  
  rb_scale = c("#F20404", "#EE0507", "#EA070B", "#E6090F", "#E20B12", "#DF0D16", "#DB0F1A",
               "#D7101E", "#D31221", "#D01425", "#CC1629", "#C8182D", "#C41A30", "#C11B34",
               "#BD1D38", "#B91F3C", "#B5213F", "#B22343", "#AE2547", "#AA264B", "#A6284E",
               "#A32A52", "#9F2C56", "#9B2E5A", "#97305D", "#933261", "#903365", "#8C3569",
               "#88376C", "#843970", "#813B74", "#7D3D78", "#793E7B", "#75407F", "#724283",
               "#6E4487", "#6A468A", "#66488E", "#634992", "#5F4B96", "#5B4D99", "#574F9D",
               "#5451A1", "#5053A5", "#4C55A8", "#4856AC", "#4458B0", "#415AB4", "#3D5CB7",
               "#395EBB", "#3560BF", "#3261C3", "#2E63C6", "#2A65CA", "#2667CE", "#2369D2",
               "#1F6BD5", "#1B6CD9", "#176EDD", "#1470E1", "#1072E4", "#0C74E8", "#0876EC", "#0578F0")
  
  binned = cbind.data.frame(value=-100:100,bin = cut(-100:100, breaks = length(rb_scale), labels = as.character(1:64)))
  
  # formating for visNetwork
  
  ## edges
  colnames(evis) = c('from', "color", "to", "value")
  evis$color[evis$color == 1] = '#0578F0' #blue
  evis$color[evis$color == -1] = "#F20404" #red
  evis$color[evis$color == 0] = '#777777' #gray
  
  ## legend for edges
  
  ledges <- data.frame(color = c("#233f5c", "#f20404"),
                       label = c("activation", "inhibition"), 
                       arrows = c("to", "to"),
                       font.align = "top")
  
  ## nodes
  nvis = nvis[which(nvis$ZeroAct!=100),]
  nvis$ZeroAct = NULL
  nvis = nvis[which(nvis$Node%in%union(evis$from, evis$to)),]
  
  if(!is.null(mapIDs)){
    nvis = merge.data.frame(nvis, mapIDs[,c("uniprot_id", "hgnc_symbol")], by.x = "Node", by.y = "uniprot_id")
  }else{
    nvis$label = nvis$Node
  }
  
  colnames(nvis) = c("id", "UpAct", "DownAct", "color", "group", "label")
  
  nvis$group = replace(nvis$group, nvis$group=='T', 'TFs')
  nvis$group = replace(nvis$group, nvis$group=='S', 'Perturbed')
  nvis$group = replace(nvis$group, nvis$group=='', 'Protein')
  
  nvis$color = sapply(nvis$color, function(x,b,rb){rb[as.integer(as.character(b$bin[b$value==as.integer(x)]))]}, binned, rb_scale)
  
  nvis$title = paste0("<p><b>", nvis$label,"</b><br>Up activity: ",nvis$UpAct,"</b><br>Down activity: ",nvis$DownAct,"</p>")
  
  #nvis = rbind.data.frame(nvis, df)
  
  nvis$level = rep(3, nrow(nvis))
  aux = unique(evis$to[which(evis$from%in%unique(nvis$id[which(nvis$group=="Perturbed")]))])
  nvis$level[which(nvis$id%in%aux)] = 2
  aux = unique(evis$from[which(evis$to%in%unique(nvis$id[which(nvis$group=="TFs")]))])
  nvis$level[which(nvis$id%in%aux)] = 4
  nvis$level[which(nvis$group=="Perturbed")] = 1
  nvis$level[which(nvis$group=="TFs")] = 5
  nvis$level[which(nvis$group=="Pathway")] = 6
  
  # Render network
  vNet <- visNetwork(nvis, evis, main = NULL) %>% 
    visNodes(color = list(background="#F5F7FA", border="gray"),
             font =  list(color="#23282a", size=30)) %>%
    visEdges(length = 200, arrowStrikethrough = FALSE, 
             arrows = list(to = list(enabled = TRUE)),
             font =  list(color="#23282a", size=30)) %>%
    visGroups(groupname = "TFs", shape = "triangle", color = "#F5F7FA") %>%
    visGroups(groupname = "Perturbed", shape = "square", color = "#F5F7FA") %>%
    visGroups(groupname = "Protein", color = "#F5F7FA") %>%
    visGroups(groupname = "Pathway",  shape = "box", color = "#F5F7FA") %>%
    visPhysics(solver = "repulsion") %>%
    visLayout(randomSeed = 9) %>%
    #visLegend(addEdges = ledges, useGroups = T) %>%
    visHierarchicalLayout(levelSeparation = 500, #nodeSpacing = 500,
                          sortMethod = "directed",
                          edgeMinimization=F, blockShifting=F) %>%
    visPhysics(hierarchicalRepulsion = list(nodeDistance = 300)) %>%
    visOptions(manipulation = F, collapse = TRUE)
  
  return(c(vNet,nvis))
}
