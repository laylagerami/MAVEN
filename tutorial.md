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

##### (A) Upload SMILES
In the (A) Upload SMILES tab, load the Lapatanib SMILES by clicking on the toggle. Check that the structure is correct by viewing the rendered compound image. You can also manually upload the SMILES file <i>Example_Data/lapatanib/lapatanib.txt</i>.

NB If you don't know your compound's SMILES, it is possible to generate a SMILES file by sketching the compond structure in the applet and clicking "Get SMILES".

##### (B) Run options
In the (B) Run options tab you can define several different options. For target prediction, compound bioactivities are binarised at different thresholds (0.1, 1, 10 and 100 uM). The default threshold used to generate predictions is 10 uM. Because the Lapatanib gene expression data were measured at 1 uM, change this option to 1.

Predictions derived from machine learning models cannot be trusted if the query compound is very dissimilar to the componds used to train the models - known as being outside of the "Applicability Domain" or AD of the models. Hence, AD percentiles (0-100) are computed using the [Reliability Density Neighbourhood](https://jcheminf.biomedcentral.com/articles/10.1186/s13321-016-0182-y) methodology and used to filter the  predictions. For each model (target), if the computed AD percentile falls below the defined threshold (here 50), the prediction is not output. To obtain more prediction (but potentially less realible) decrease the AD filter and vice versa. To turn off the AD filter altogether, you can input 0 for this option. For this tutorial, keep the AD threshold to its default value.

It is possible to parallelise the target prediction over a number of cores. You can change this number to one that is appropriate for your machine.

Finally, browse to select the PIDGIN installation directory (the folder containing the predict.py file). You can type in a filepath using the pen symbol on the file browser.

To run the target prediction, press the RUN PIDGIN button. This may take a while depending on how many cores are being used. Once the predictions have finished running, the (C) Results page will be populated. In the output/ folder of the main MAVEN directory, a directory will be created containing the output files from the target prediction, as well as a file containing the corresponding command line operation, to keep record of the parameters used to generate the predictions.

##### (C) Results
The (C) Results page will display the target prediction results when they are obtained. 


It is also possible to upload the output from a previous run. In Example_Data/ there is a folder entitled target_prediction_results/. This contains the predictions (PIDGIN_out_predictions.txt) and the similarity analysis (PIDGIN_similarity_details.txt) from the Lapatanib results using the above parameters. When uploading results, please select <b>BOTH</b> files to populate the page.















