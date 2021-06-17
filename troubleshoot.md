## Troubleshooting + FAQ

This page will be updated as we receieve question and queries about the software.

### General troubleshooting

#### I have multiple compounds which I would like to analyse. Can I perform a batch analysis?
Currently we do not support batch upload. However, we hope to add the option to upload multiple CARNIVAL results to analyse similarity between different networks.

### Data

#### I get a warning saying that some of my genes in the network/data are not valid gene symbols. What does this mean?
Most of the time, this should not be an issue. Issues arise when there are mismatches for gene identifiers between gene expression data/network data/targets. The biggest problem is usually due to Excel automatically changing some gene symbols to dates, which may disrupt the downstream analysis. We recommend that you check the log files to ensure that this is not the case.

### Targets

#### Why do I get no target predictions? (blank cells)
PIDGIN will output NaN for predictions which are outside of the defined applicability domain (AD) threshold for a particular model - which is displayed as blank cells in the results table. Try to reduce this number to a less stringent threshold. Alternatively, turn off the AD filter (input 0 as the option).

### Analysis

#### How do I decide on the thresholds for PROGENy and DoRoTHEA?

#### How do I choose the activation or inhibition states of predicted targets?
You can either review the literature to see whether target inhibition or activation would make more sense (for example, see which other compounds target the particular protein(s) and their phenotypic responses), or run CARNIVAL multiple times with activation and inhibition and decide based on the resulting network.

### Visualisation

#### How do I perform custom enrichment analysis?
You need a .gmt file containing pathways of interest. Please visit the [MSigDB Documentation](https://software.broadinstitute.org/cancer/software/gsea/wiki/index.php/Data_formats)  for guidance on the structure of the .gmt file. Then, you can select "Custom" fom the dropdown menu and upload your custom .gmt file to perform enrichment analysis.

