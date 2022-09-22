# Script to install packages required
# Requires R version 4.2.X

# CRAN
list.of.packages <- c("parallel","snowfall","readr","rJava","shiny","shinyjs","igraph","DT","miniUI","rhandsontable","shinyBS","shinythemes","shinyFiles","dplyr","tibble","ggplot2","visNetwork","shinyalert","shinyWidgets","lpSolve","sortable","colorspace","devtools","BiocManager")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)


# CARNIVAL
if (require(devtools)) install.packages("BiocManager")#if not already installed
# Uncomment the below line if it tells you to upgrade BiocManager *WARNING* updating all Biocondutor packages may take a while
# BiocManager::install(version = "3.15")
BiocManager::install("CARNIVAL")

# Bioconductor
list.of.packages <- c("org.Hs.eg.db","dorothea","progeny","HGNChelper","piano","GSEABase")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) BiocManager::install(new.packages)

devtools::install_github("zachcp/chemdoodle")
devtools::install_github("AnalytixWare/ShinySky")
