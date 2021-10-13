### Tutorial

To demonstrate MAVEN we will be using a dataset from [Hegde et al.](https://mct.aacrjournals.org/content/6/5/1629), GEO accession [GSE129254](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE129254) which is found in Example_Data/lapatinib. The filetree structure of the folder is shown below:

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
The gene expression data is contained in GSE12954_lapatanib_BT474.txt and was generated using the get_data.R script. The data represents the response of BT474 cells following treatment with lapatanib in terms of the t-statistic compared to control (DMSO-treated BT474 cells). The compound SMILES are contained in lapatanib.txt.

#### Step 1. Data




