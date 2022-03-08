# Base image https://hub.docker.com/u/rocker/
FROM rocker/shiny-verse:latest

# system libraries of general use
## install debian packages
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    libxml2-dev \
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
    apt-get clean

## copy package installation script
COPY install_packages.R .

## copy app
COPY MAVEN/ ./MAVEN

## run package installation script
RUN Rscript install_packages.R
<<<<<<< HEAD

## get cbc
RUN git clone https://github.com/coin-or/coinbrew /cbc
WORKDIR /cbc
RUN ./coinbrew fetch Cbc@2.9.10 --no-prompt --no-third-party
RUN ./coinbrew build Cbc@2.9.10 --no-prompt --no-third-party

WORKDIR /root

# expose port
EXPOSE 3838

# run app on container start
CMD ["R", "-e", "shiny::runApp('/MAVEN', host = '0.0.0.0', port = 3838)"]
