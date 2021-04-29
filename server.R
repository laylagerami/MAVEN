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


# *DATA* = done!

# *TARGETS*  = done!

# *ANALYSIS*
# Check contents of solver files
## Put settings in log files for future reference (PIDGIN done, need to do the same for when run CARNIVAL is clicked including all vars)
# include all settings including non-default in the log files, as well as .RDS and .sif
# create separate log file for carnival then copy it to output, like with PIDGIN

# *VISUALISATION*
# lightn edges too
# fix downloader disable button
# allow deselect pathways 
# choose specific nodes to be enriched instead of all of them, lighten them in the network when deselcted
# zoom into nodes?

# *OTHER*
# bookmarking?
## welcome page explaining each step (in progress, need to fill it in, do at the end)
# more guidance for question marks
# default 10 entries 

# *DO LATER*
# batch upload tab (upload multiple CARNIVAL networks)
# generation of files to run batch uploads