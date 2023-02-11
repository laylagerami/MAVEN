## Troubleshooting + FAQ

This page will be updated as we receieve question and queries about the software.

### General troubleshooting

#### I have multiple compounds which I would like to analyse. Can I perform a batch analysis?
Currently we do not support batch upload. However, we hope to add the option to upload multiple CARNIVAL results to analyse similarity between different networks.

### Data

#### I get a warning saying that some of my genes in the network/data are not valid gene symbols. What does this mean?
Most of the time, this should not be an issue. Issues arise when there are mismatches for gene identifiers between gene expression data/network data/targets. The biggest problem is usually due to Excel automatically changing some gene symbols to dates, which may disrupt the downstream analysis. We recommend that you check the log files to ensure that this is not the case.

#### I have a large transcriptional signature (many measured genes) and/or a large network. Can I use MAVEN?
Due to the transcription factor activity inference step with DoRothEA, large transcriptional signatures are reduced to a smaller set (typically 50-100) of transcription factors meaning that this will not increase the time it takes for the network optimisation to complete. When using a large prior knowledge network with many nodes or edges it is recommended to use the IBM ILOG CPLEX solver, as this solver is able to handle large network inputs better than Cbc.

### Targets

#### What is the PIDGINv4 directory?
You need to install PIDGINv4 to be able to use the target prediction functionality. Please see [installation](https://laylagerami.github.io/MAVEN/installation.html) instruction for more details on how to install PIDGINv4. Then, you simply need to select the main directory when prompted.

#### What is "similarity" in the results table?
As well as running the target prediction, the [Tanimoto similarities](https://www.ccdc.cam.ac.uk/support-and-resources/support/case/?caseid=899a6a77-e379-4981-84f4-07de67f39016) to the nearest neighbours for each model (target) are also calculated and output, along with the ChEMBLID, in the table (ranges from 0-1). You can use this to investigate if structurally similar compounds are active against targets of interest.

#### Why do I get no target predictions? (blank cells)
PIDGIN will output NaN for predictions which are outside of the defined applicability domain (AD) threshold for a particular model - which is displayed as blank cells in the results table. Try to reduce this number to a less stringent threshold. Alternatively, turn off the AD filter (input 0 as the option).

#### Do I have to define targets?
No. Your network will begin with a proxy "Perturbation" node, connecting to the input TFs _via_ the optimised network.

### Analysis

#### How do I decide on the thresholds for PROGENy and DoRoTHEA?
There is no exact rule for this, but the following tips may help guide you to choosing the correct thresholds:

PROGENy :- According to [guidance](https://github.com/saezlab/transcriptutorial/blob/master/scripts/03_Pathway_activity_with_Progeny.Rmd) from the authors, "It is worth noting that we are going to use the 100 most responsive genes per pathway. This number can be increased depending on the coverage of your experiments. For instance, the number of quantified genes for single-cell RNA-seq is smaller than for Bulk RNA-seq or microarray. In those cases, we suggest to increase the number of responsive genes to 200-500."

DoRothEA :- According to [guidance](https://github.com/saezlab/transcriptutorial/blob/master/FAQ_CARNIVAL.md) from the authors, "What is the number of Dorothea scores to feed CARNIVAL? It feels that the smaller number you use, the better the results will be. However, this is not the general experience. The solver needs to check a lot more possible solutions when having few inputs for the prior knowledge network(PKN). This situation could lead to long processing times and big gap value in the ILP solution." Relaxing the confidence levels (i.e. including those with confidence D and E) can enable the enrichment of more TFs, if you find that you are obtaining too little. Also, you can look at the enriched TFs' UniProt entries by clicking directly on them in the results table, and see what makes sense with your compound. More information on the DoRothEA confidence levels can be found [here](https://github.com/saezlab/dorothea), or by clicking on the question mark in the MAVEN app.

Generally, the default options should be appropriate for most inputs.

#### How do I choose the activation or inhibition states of predicted targets?
You can either review the literature to see whether target inhibition or activation would make more sense (for example, see which other compounds target the particular protein(s) and their phenotypic responses), or run CARNIVAL multiple times with activation and inhibition and decide based on the resulting networks.

#### What is a solver and why do I need to install it?
CARNIVAL works with Integer Linear Programming (ILP) optimisation, which requires a special solver to do so. You can use the IBM ILOG CPLEX solver (free for academic use), or the cbc solver (free and open-source for all). The lpSolve R package is another option, but is only suitable for toy examples so we do not recommend using this option. Please see the [installation](https://laylagerami.github.io/MAVEN/installation.html) instruction for more details on how to install the solvers.

### Visualisation

#### How do I perform custom enrichment analysis?
You need a .gmt file containing pathways of interest. Please visit the [MSigDB Documentation](https://software.broadinstitute.org/cancer/software/gsea/wiki/index.php/Data_formats)  for guidance on the structure of the .gmt file. Then, you can select "Custom" fom the dropdown menu and upload your custom .gmt file to perform enrichment analysis.

