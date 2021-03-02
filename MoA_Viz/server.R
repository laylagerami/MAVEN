# SERVER
server = function(input, output, session) {
  source("sub/01_server_data.R", local=T)
  source("sub/02_server_targets.R",local=T)
  source("sub/03_server_analysis.R",local=T)
}

# IMPROVEMENTS
# Check gene symbol in network + gex
# Link to ChEMBL in DT
# venv
