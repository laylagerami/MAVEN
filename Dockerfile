# Base image https://hub.docker.com/u/rocker/
FROM rocker/shiny-verse:latest

# Buildfile adapted from https://github.com/SBRG/MASSpy/blob/main/docker/Dockerfile

# Copy files
ADD MAVEN MAVEN/

# system libraries of general use
## install debian packages
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    libxml2-dev \
    build-essential \
    wget \
    libsqlite3-dev \
    libpq-dev \
    libssh2-1-dev \
    unixodbc-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libglpk40 \
    default-jdk \
    r-cran-rjava \
    git

## update system libraries
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install miniconda
ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
     /bin/bash ~/miniconda.sh -b -p /opt/conda

# put conda in PATH
ENV PATH=$CONDA_DIR/bin:$PATH

# change default locale https://github.com/rocker-org/rocker/issues/19#issuecomment-58311985
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
   && locale-gen en_US.utf8 \
   && /usr/sbin/update-locale LANG=en_US.UTF-8

## run package installation script
RUN Rscript MAVEN/install_packages.R

## get cbc
RUN git clone https://github.com/coin-or/coinbrew cbc/ && \
    cd cbc/ && \
    ./coinbrew fetch Cbc@stable/2.9 --no-prompt --no-third-party && \
    ./coinbrew build Cbc@stable/2.9 --no-prompt --no-third-party

# install Cplex
RUN echo \
	&& if [ -f MAVEN/cplex_installation/*.bin ] ; then \
        echo "Installing CPLEX"  \
        && chmod a+rwx MAVEN/cplex_installation/*.bin \
        && MAVEN/cplex_installation/*.bin \
            -f cplex.installer.properties \
            -DUSER_INSTALL_DIR="/IBM_cplex/"  \
        # Copy CPLEX license into license directory
        && mkdir opt/licenses \
        && mkdir opt/licenses/CPLEX/ \
        && mv IBM_cplex/license/*.txt opt/licenses/CPLEX/ \
        # Clean files that aren't needed
        && for to_clean in 'concert' 'cpoptimizer' 'doc' 'license' 'opl' 'python' 'Uninstall' ; \
            do rm -rf IBM_cplex/$to_clean ; \
            done \
        && for to_clean in 'examples' 'matlab' 'readmeUNIX.html' ; \
            do rm -rf IBM_cplex/cplex/$to_clean ; \
            done ; \
    else \
       echo "No installer found for CPLEX, cbc will be installed only" ; \
    fi

# install PIDGIN
RUN git clone https://github.com/BenderGroup/PIDGINv4.git PIDGINv4/ && \
    conda create -c rdkit -c conda-forge --name pidgin4_env python=2.7 rdkit scikit-learn=0.19.0 pydot graphviz standardiser statsmodels && \
    cd PIDGINv4/ && \
    wget -O no_ortho_mar22.tar.gz  https://figshare.com/ndownloader/files/34387541  && \
    tar -xvzf no_ortho_mar22.tar.gz

# expose port
EXPOSE 3838

# run app on container start
CMD ["R", "-e", "shiny::runApp('/MAVEN', host = '0.0.0.0', port = 3838)"]
