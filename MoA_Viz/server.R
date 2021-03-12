# SERVER
server = function(input, output, session) {
  source("sub/01_server_data.R", local=T)
  source("sub/02_server_targets.R",local=T)
  source("sub/03_server_analysis.R",local=T)
  source("sub/04_server_vis.R",local=T)
  source("sub/support_enrichment.R")
  source("sub/support_networks.R")
  
}

# IMPROVEMENTS
# Check gene symbol in network + gex
# Link to ChEMBL in DT
# venv
