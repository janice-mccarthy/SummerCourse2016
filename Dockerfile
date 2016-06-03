# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
FROM jupyter/scipy-notebook

MAINTAINER Jupyter Project <jupyter@googlegroups.com>

USER root

# R pre-requisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fonts-dejavu \
    gfortran \
    gcc && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER jovyan

# R packages including IRKernel which gets installed globally.
RUN conda config --add channels r && \
    conda install --quiet --yes \
    'rpy2=2.7*' \
    'r-base=3.2*' \
    'r-irkernel=0.5*' \
    'r-plyr=1.8*' \
    'r-devtools=1.9*' \
    'r-dplyr=0.4*' \
    'r-ggplot2=1.0*' \
    'r-tidyr=0.3*' \
    'r-shiny=0.12*' \
    'r-rmarkdown=0.8*' \
    'r-forecast=5.8*' \
    'r-stringr=0.6*' \
    'r-rsqlite=1.0*' \
    'r-reshape2=1.4*' \
    'r-nycflights13=0.1*' \
    'r-caret=6.0*' \
    'r-rcurl=1.95*' \
    'r-randomforest=4.6*' && conda clean -tipsy

RUN echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.revolutionanalytics.com/'; options(repos = r)" > ~/.Rprofile
RUN Rscript -e "source('http://bioconductor.org/biocLite.R');biocLite(suppressUpdates = FALSE);biocLite('ShortRead', suppressUpdates = FALSE);biocLite('phyloseq', suppressUpdates = FALSE)"

# Install Bash Kernel
RUN pip install --user --no-cache-dir bash_kernel && \
    python -m bash_kernel.install

USER root
#
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Install Less
###~~~~~~~~~~~~
 RUN apt-get update && \
     apt-get install -y --no-install-recommends \
     less \
     && apt-get clean && \
     rm -rf /var/lib/apt/lists/*
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## make, git
RUN apt-get -q -y  install make
RUN apt-get -q -y  install git
#
#
### libxml2
RUN apt-get update
RUN apt-get -q -y  install libxml2-dev
#
### ea-utils (fastq-mcf)
RUN apt-get -q -y  install libgsl0-dev
RUN wget "https://drive.google.com/uc?export=download&id=0B7KhouP0YeRAc2xackxzRnFrUEU" -O ea-utils.1.1.2-806.tar.gz
RUN tar -xvf ea-utils.1.1.2-806.tar.gz
RUN cd ea-utils.1.1.2-806; make; cp -a fastq-mcf /usr/local/bin/; cd ~;rm -rf ea-utils.1.1.2-806 ea-utils.1.1.2-806.tar.gz
#
### fastqc
RUN apt-get -q -y  install fastqc default-jre
#
### sra-toolkit
## apt-get -q -y  install sra-toolkit
RUN wget http://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.4.3/sratoolkit.2.4.3-ubuntu64.tar.gz
RUN tar -zxf sratoolkit.2.4.3-ubuntu64.tar.gz
RUN cp -r sratoolkit.2.4.3-ubuntu64/bin/*  /usr/local/bin/
RUN rm sratoolkit.2.4.3-ubuntu64.tar.gz
RUN rm -r sratoolkit.2.4.3-ubuntu64
RUN vdb-config --restore-defaults
RUN echo "test sra-toolkit with the following command:"
RUN echo "fastq-dump -X 5 -Z SRR390728"

RUN conda install --quiet --yes -n python2 --channel https://conda.anaconda.org/Biobuilds htseq
RUN conda install --quiet --yes -n python2 --channel https://conda.anaconda.org/Biobuilds pysam

USER root
## tophat, bowtie2, bwa, samtools^M
RUN apt-get update && \
     apt-get install -q -y tophat \
     bwa \
     samtools \
     && apt-get clean
