# MAVEN Mechanism of Action Visualisation and ENrichment
 
 Directory contains 3 files:
 - app.R -> Main app
 - gadget.R -> Chemical sketcher app
 - gadget_script.R -> Script to invoke the running of the chemical sketcher app 

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
 - Separate tabs into separate scripts
 - Finish PIDGIN implementation
