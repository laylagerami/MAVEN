# SERVER
server = function(input, output, session) {
  source("sub/00_server_welcome.R", local=T)
  source("sub/01_server_data.R", local=T)
  source("sub/02_server_targets.R",local=T)
  source("sub/03_server_analysis.R",local=T)
  source("sub/04_server_vis.R",local=T)
  source("sub/support_enrichment.R")
  source("sub/support_networks.R")
}

#APAP
#https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE104601
#https://www.sciencedirect.com/science/article/abs/pii/S0024320520300783
#https://pubmed.ncbi.nlm.nih.gov/12153990/

# *DATA* = done!

# *TARGETS*  = done!

# *ANALYSIS* = done!

# *VISUALISATION*
# proteins are in a line 


# *OTHER*
# bookmarking?
## welcome page explaining each step (in progress, need to fill it in, do at the end)
# more guidance for question marks
# default 10 entries 
# push PIDGIN

# *TROUBLESHOOTING IN DOCUMENTATION*
# PIDGIN AD - reduce to get more predictons
# No network results - increase time limit and re-run
# rstudio server time out

# *DO LATER*
# batch upload tab (upload multiple CARNIVAL networks)
# generation of files to run batch uploads