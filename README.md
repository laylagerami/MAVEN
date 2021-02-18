# MAVEN Mechanism of Action Visualisation and ENrichment
 
 R shiny app which allows for integrative bioinformatics and chemoinformatics analysis for mechansism of action analysis and visualisation.
 Target prediction provided by PIDGIN (BenderGroup/PIDGINv4) and causal reasoning provided by CARNIVAL (saezlab/CARNIVAL)
 
MoA_Viz directory contains:
- sub -> this has all of the ui.R and server.R files for each of the tabs, as well as a global.R file to define packages
- ui.R and server.R -> sources the individual server.R and ui.R files
- example data for testing the app

Required R packages:
- shiny -> self-explanatory
- shinyjs -> to use JS
- igraph -> graph maniuplation
- DT -> to render DataTables which are nicer to work with in Shiny
- miniUI -> for creation of gadgets
- chemdoodle -> chemical sketcher
- rhandsontable -> editable tables
- shinysky -> various ui widgets+components
- shinyBS -> twitter bootstrap components (buttons etc)
- shinythemes -> change visual theme
- chemdoodle (https://github.com/zachcp/chemdoodle)

PIDGIN is also required to be installed:
- https://github.com/BenderGroup/PIDGINv4 and https://pidginv4.readthedocs.io/en/latest/
- The code will ask you to point to the installation directory and assumes that you have a file in there called predict.py
- **DO NOT MODIFY ANY FILE NAMES!!!!**
 
 TO DO:
 - Documentation
 - Clean up code
 - Separate tabs into separate scripts (DONE)
 - Finish PIDGIN implementation
 - Merge with Rosa's CARNIVAL app
 - Case study :)
