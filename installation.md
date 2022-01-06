## Installation

Installation of MAVEN includes several parts:  
1. Download SHINY files and install required packages
2. Install PIDGINv4
3. Install ILP optimiser

Please note that currently MAVEN only works on Linux and Mac OS. 

**Download SHINY files and install required packages**

Navigate to the [GitHub repo](https://github.com/laylagerami/MAVEN) and clone/download the entire repository. 
```
git clone https://github.com/laylagerami/MAVEN.git
```

Ensure that you don't move any files around or change any file names. The required R packages have been saved in the renv.lock file. Open RStudio and set the main MAVEN directory as the working directory. The R packages can then be loaded/installed with the following R code:

```
install.packages("renv") # if it is not currently installed
renv::restore()
```

If you encounter an error when installing packages, you can try the following on the commandline to manually instal theml:

```
$ Rscript install_packages.R
```

**Install PIDGINv4**

To run the target prediction you will need to install PIDGINv4. For detailed instructions, please refer to [the documentation](https://pidginv4.readthedocs.io/en/latest/install.html).

First, navigate to the [GitHub repo](https://github.com/BenderGroup/PIDGINv4) and clone/download the entire repository.
```
git clone https://github.com/BenderGroup/PIDGINv4.git
```
This directory will need to be selected when choosing target prediction settings in MAVEN.
Then, install the conda environment:
```
conda env create -f pidgin4_env.yml --name pidgin4_env
```

You may encounter issues if not installing on Linux. If you get the "ResolvePackageNotFound" error, try running the following instead:
```
conda create -c rdkit -c conda-forge --name pidgin4_env python=2.7 rdkit scikit-learn=0.19.0 pydot graphviz standardiser statsmodel
```

You also need to download model files. Download and unzip https://tinyurl.com/pidgin4-no-ortho (md5sum: c9b226f864d5199ecd96d058081fe2eb) into the PIDGINv4 main directory (leave all subsequent files compressed).

**Install ILP optimiser**

For CARNIVAL you will need to install an ILP optimiser. The IBM ILOG optimiser is free for academic use [here](https://www.ibm.com/products/ilog-cplex-optimization-studio?S_PKG=CoG&cm_mmc=Search_Google-_-Data+Science_Data+Science-_-WW_IDA-_-+IBM++CPLEX_Broad_CoG&cm_mmca1=000000RE&cm_mmca2=10000668&cm_mmca7=9041989&cm_mmca8=kwd-412296208719&cm_mmca9=_k_Cj0KCQiAr93gBRDSARIsADvHiOpDUEHgUuzu8fJvf3vmO5rI0axgtaleqdmwk6JRPIDeNcIjgIHMhZIaAiwWEALw_wcB_k_&cm_mmca10=267798126431&cm_mmca11=b&mkwid=_k_Cj0KCQiAr93gBRDSARIsADvHiOpDUEHgUuzu8fJvf3vmO5rI0axgtaleqdmwk6JRPIDeNcIjgIHMhZIaAiwWEALw_wcB_k_%7C470%7C135655&cvosrc=ppc.google.%2Bibm%20%2Bcplex&cvo_campaign=000000RE&cvo_crid=267798126431&Matchtype=b&gclid=Cj0KCQiAr93gBRDSARIsADvHiOpDUEHgUuzu8fJvf3vmO5rI0axgtaleqdmwk6JRPIDeNcIjgIHMhZIaAiwWEALw_wcB). Alternatively, you can install [open source and free CBC optimiser](https://github.com/coin-or/Cbc). Please see the respective link for specific installation instructions. Do not modify any file or folder names.

You have now succssfully installed and setup MAVEN!

To run the app, simply load RStudio, set the main MAVEN directory as your current working directory, and type the following in your R console:

```
shiny::runApp()
```

NB it may take a few seconds to load while packages are imported.

