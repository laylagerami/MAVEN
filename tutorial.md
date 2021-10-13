### Tutorial

To demonstrate MAVEN we will be using a dataset from [Sun et al.](https://pubmed.ncbi.nlm.nih.gov/31462705/), GEO accession [GSE129254](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE129254) which is found in Example_Data/lapatinib. The filetree structure of the folder is shown below:

```
Example_Data/
├─ lapatinib/
│  ├─ CARNIVAL_results/
│  │  ├─ carnival_result.RDS
│  │  ├─ network.sif
│  ├─ target_prediction_results/
│  │  ├─ PIDGIN_out_predictions.txt
│  │  ├─ PIDGIN_similarity_details.txt
│  ├─ get_data.R
│  ├─ GSE129254_lapatinib_BT474.txt
│  ├─ lapatanib.txt
```
The gene expression data is contained in GSE12954_lapatanib_BT474.txt and was generated using the get_data.R script. The data represents the response of BT474 cells following treatment with Lapatanib in terms of the t-statistic compared to control (DMSO-treated BT474 cells). The compound SMILES are contained in lapatanib.txt.

#### Step 1. Data
To begin the analysis, click on the <b>1. Data</b> button in the top toolbar. In this step, the prior knowledge network and gene expression data are uploaded. 

The gene expression data will be used in <b>3. Analysis</b> with DoRothEA to infer transcription factor activities, and with PROGENy to infer pathway activities. The transcription factors are used as input to CARNIVAL, along with the protein weights as defined by the pathway activities, and the prior knowledge network. 

To load the example data, click on the "Load example network" and "Load example data" buttons. This will load the files <i>Example_Data/omnipath_full_carnival.sif</i> and <i>Example_Data/lapatanib/GSE129254_lapatinib_BT474.txt</i>.

Alternatively, you can upload the two files manually. NB a check is performed to make sure all gene symbols are valid. Any invalid symbols will be written to a log file in the logs/ folder of the main MAVEN directory.

Now move on to <b>2. Targets</b>.

#### Step 2. Targets
Targets are optional in MAVEN, and it is possible to perform the CARNIVAL analysis without defining targets. For this tutorial, we will be predicting the targets of Lapatanib using its chemical structure. It is also possible to skip the prediction step and define targets if they are known beforehand.

In MAVEN, target prediction is carried out with PIDGIN, which is essentially a collection of pre-trained models (one for each protein target contained in ChEMBL). Only human targets are predicted in MAVEN.

The Targets tab contains 4 sub-tabs - (A) Upload SMILES (B) Run options (C) Results (D) User-defined targets.

<b>(A) Upload SMILES</b>  
In the (A) Upload SMILES tab, load the Lapatanib SMILES by clicking on the toggle. Check that the structure is correct by viewing the rendered compound image. You can also manually upload the SMILES file <i>Example_Data/lapatanib/lapatanib.txt</i>.

NB If you don't know your compound's SMILES, it is possible to generate a SMILES file by sketching the compond structure in the applet and clicking "Get SMILES".

<b>(B) Run options</b>  
In the (B) Run options tab you can define several different options. For target prediction, compound bioactivities are binarised at different thresholds (0.1, 1, 10 and 100 uM). The default threshold used to generate predictions is 10 uM. Because the Lapatanib gene expression data were measured at 1 uM, change this option to 1.

Predictions derived from machine learning models cannot be trusted if the query compound is very dissimilar to the componds used to train the models - known as being outside of the "Applicability Domain" or AD of the models. Hence, AD percentiles (0-100) are computed using the [Reliability Density Neighbourhood](https://jcheminf.biomedcentral.com/articles/10.1186/s13321-016-0182-y) methodology and used to filter the  predictions. For each model (target), if the computed AD percentile falls below the defined threshold (here 50), the prediction is not output. To obtain more prediction (but potentially less realible) decrease the AD filter and vice versa. To turn off the AD filter altogether, you can input 0 for this option. For this tutorial, keep the AD threshold to its default value.

It is possible to parallelise the target prediction over a number of cores. You can change this number to one that is appropriate for your machine.

Finally, browse to select the PIDGIN installation directory (the folder containing the predict.py file). You can type in a filepath using the pen symbol on the file browser.

To run the target prediction, press the RUN PIDGIN button. This may take a while depending on how many cores are being used, and you can check the progress by monitoring the console in R Studio. 

Once the predictions have finished running, the (C) Results page will be populated. In the output/ folder of the main MAVEN directory, a directory will be created containing the output files from the target prediction, as well as a file containing the corresponding command line operation, to keep record of the parameters used to generate the predictions.

<b>(C) Results</b>  
The (C) Results page will display the target prediction results when they are obtained. 

By default, the results table is sorted by probability of activity (descending). The columns represent the following:-  
Gene ID -> Target HGNC symbol - you can click to take you to the corresponding UniProt entry for more information on the protein's function.  
Name -> Target preferred name.  
Predicted Probability -> Probability (between 0 and 1) of activity at the defined bioactivity threshold.  
Nearest Neighbour -> ChEMBL ID of the most structurally similar compound in the target's training dataset. You can click to take you to the corresponding page on ChEMBL.  
NN Tanimoto Sim -> Tanimoto Similarity (between 0 and 1) of the Nearest Neighbour compound compared to the query compound.  
NN pChEMBL -> pChEMBL (bioactivity) value for the Nearest Neighbour for the particular target. pChEMBL is defined as -log10(XC50).

You will notice that many of the targets have a value of 1 for NN Tanimoto Sim. This means that Lapatanib itself was part of the training set - click on the ChEMBL link (ChEMBL554) to see for yourself. 

For this tutorial, we are investigating the cellular response of HER2-positive BRT474 cell line to the modulation of EGFR and ERBB2 by Lapatanib. Select the corresponding rows, such that they are displayed under <b>Selected targets</b> below the table.

It is also possible to upload the output from a previous run. In Example_Data/ there is a folder entitled target_prediction_results/. This contains the predictions (PIDGIN_out_predictions.txt) and the similarity analysis (PIDGIN_similarity_details.txt) from the Lapatanib results using the above parameters. When uploading results, please select <b>BOTH</b> files to populate the page.

<b>(D) User-defined targets</b>  
For the purpose of the tutorial, leave this blank. If you know your query compound's targets then it is possible to skip the target prediction altogether and click on this tab to directly input the target HGNC symbols.

#### Step 3. Analysis
Now we have all of the information we need to begin the analysis. The <b>3. Analysis</b> tab contains 3 sub-tabs - (A) DoRothEA (B) PROGENy (C) CARNIVAL.

<b> (A) DoRothEA </b>  
For DoRothEA transcription factor (TF) enrichment there are two options. The first, Confidence levels, defines which TF-gene regulons will be used to perform the enrichment (where A is most confident and E is least confident). For more information on confidence levels, refer to the [DoRothEA documentation](https://github.com/saezlab/dorothea). Keep the defaults (A, B and C).

The second option defines the number of TFs to be used as input for CARNIVAL. Keep the default (50).

Click "RUN DOROTHEA" and the page will be shortly populated with a plot and results table. 

The plot and table display the HGNC symbol for each enriched TF with its normalised enrichment score (NES). A positive NES indicates an upregulation of the TF, and negative indicates a downregulation. You can click on a symbol in the results table to take you to the corresponding UniProt page. Note that the top upregulated TF, FOXO3, is known to be activated by Lapatanib [ref](https://pubmed.ncbi.nlm.nih.gov/31727006/) and the top downregulated TF, ESRRA, is known to be degraded by Lapatanib [ref](https://www.nature.com/articles/ncomms12156).

You can also save the results (plot image, results table and parameter log) to your machine with the Download button.

<b> (B) PROGENy </b>
For PROGENy there is only one option; the number of top responsive genes to include in the pathway activity calculation. The default (100) should be suitable for most cases. 

Press "RUN PROGENY" and the page will be shortly populated with a plot and results table.

The plot and table display the pathway activity score for each of the 14 pathways contained in the PROGENy methodology, where again a negative score indicates downregulation and a positive score upregulation.

Like with DoRothEA, you can save the results to your machine with the Download button.

<b> (C) CARNIVAL </b>















