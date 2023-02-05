## Installation

There are two choices for the installation of MAVEN; local installation, or Docker/Singularity container installation.

```
$ These indicate commands to be typed into a Linux/Mac terminal 
```

### Local installation
Local installation consists of the following steps:
1. Download SHINY files and install required packages
2. Install PIDGINv4
3. Install ILP optimiser

Make sure you have [R](https://www.r-project.org/) version >=4.2.0 installed on your system

**Download SHINY files and install required packages**

Navigate to the [GitHub repo](https://github.com/laylagerami/MAVEN) and clone/download the entire repository. 

```
$ git clone https://github.com/laylagerami/MAVEN.git
```

Ensure that you don't move any files around or change any file names. 

The required R packages can then be installed after navigating to the inner MAVEN directory:

```
$ cd MAVEN/MAVEN/
$ Rscript install_packages.R
```
Or run install_packages.R from RStudio - make sure you set the main MAVEN directory as the working directory. 

**Install PIDGINv4**

To run the target prediction you will need to install PIDGINv4. For detailed instructions, please refer to [the documentation](https://pidginv4.readthedocs.io/en/latest/install.html).

First, navigate to the [GitHub repo](https://github.com/BenderGroup/PIDGINv4) and clone/download the entire repository.
```
$ git clone https://github.com/BenderGroup/PIDGINv4.git
```
This directory will need to be selected when choosing target prediction settings in MAVEN.

Then, install the conda environment (this is required for running PIDGIN target prediction, which uses Python scripts):
```
$ cd PIDGINv4/
$ conda env create -f pidgin4_env.yml --name pidgin4_env
```

You may encounter issues if not installing on Linux. If you get the "ResolvePackageNotFound" error, try running the following instead:
```
$ conda create -c rdkit -c conda-forge --name pidgin4_env python=2.7 rdkit scikit-learn=0.19.0 pydot graphviz standardiser statsmodels
```

You also need to download model files. Download and unzip https://tinyurl.com/pidgin4-no-ortho (md5sum: c9b226f864d5199ecd96d058081fe2eb) into the PIDGINv4 main directory (leave all subsequent files compressed).

**Install ILP optimiser**

For CARNIVAL you will need to install an ILP optimiser. The IBM ILOG optimiser (recommended) is free for academic use [here](https://www.ibm.com/products/ilog-cplex-optimization-studio?S_PKG=CoG&cm_mmc=Search_Google-_-Data+Science_Data+Science-_-WW_IDA-_-+IBM++CPLEX_Broad_CoG&cm_mmca1=000000RE&cm_mmca2=10000668&cm_mmca7=9041989&cm_mmca8=kwd-412296208719&cm_mmca9=_k_Cj0KCQiAr93gBRDSARIsADvHiOpDUEHgUuzu8fJvf3vmO5rI0axgtaleqdmwk6JRPIDeNcIjgIHMhZIaAiwWEALw_wcB_k_&cm_mmca10=267798126431&cm_mmca11=b&mkwid=_k_Cj0KCQiAr93gBRDSARIsADvHiOpDUEHgUuzu8fJvf3vmO5rI0axgtaleqdmwk6JRPIDeNcIjgIHMhZIaAiwWEALw_wcB_k_%7C470%7C135655&cvosrc=ppc.google.%2Bibm%20%2Bcplex&cvo_campaign=000000RE&cvo_crid=267798126431&Matchtype=b&gclid=Cj0KCQiAr93gBRDSARIsADvHiOpDUEHgUuzu8fJvf3vmO5rI0axgtaleqdmwk6JRPIDeNcIjgIHMhZIaAiwWEALw_wcB). Alternatively, you can install [the open source and free CBC optimiser using coinbrew](https://github.com/coin-or/coinbrew). Please see the respective link for specific installation instructions. Do not modify any file or folder names. 

It doesn't matter where on the machine the solver is installed - MAVEN will prompt you to browse and select the location of the solver file.

Please note if using Dark Mode on Mac you may encounter an [error](https://www.ibm.com/support/pages/ibm-ilog-cplex-optimization-studio-installer-has-silent-failure-mac-os-1015) when installing IBM ILOG CPLEX. This can be fixed by switching to Light Mode during installation.

You have now succssfully installed and setup MAVEN!

To run the app, simply load RStudio, set the nested MAVEN directory as your current working directory (containing ui.R and server.R), and type the following in your R console:

```
shiny::runApp()
```

NB it may take a few seconds to load while packages are imported.

### Container installation

Navigate to the [GitHub repo](https://github.com/laylagerami/MAVEN) and clone/download the entire repository.
NB To use the IBM ILOG Cplex solver in a container, download the installation package for Linux (x86-64) after obtaining a valid license and place the .bin file in the "cplex_installation" directory within the nested MAVEN directory (i.e., MAVEN/MAVEN/cplex_installation/)

```
$ git clone https://github.com/laylagerami/MAVEN.git
```

To install MAVEN in a Docker container:
1. Install [Docker](https://www.docker.com/) and ensure the server is running
2. Open a terminal window and navigate to the top-level MAVEN directory (make sure Dockerfile is present) `$ cd MAVEN/`
3. Run the command `$ docker build -t maven .` to build the container
4. After the build finishes, you can launch MAVEN using `$ docker run -i -d -p 3838:3838 maven` or by invoking the bash script `$ ./docker_command.sh`

To install MAVEN in a Singularity container:
1. Install [Singularity](https://sylabs.io/) and ensure the server is running
2. Open a terminal window and navigate to the top-level MAVEN directory (make sure Singularity.def is present) `$ cd MAVEN/`
3. Run the command `$ singularity build maven.sif Singularity.def` to build the container
4. After the build finishes, you can launch MAVEN using `$ singularity run –writable-tmpfs maven.sif`


