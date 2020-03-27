# Influenza DIP Detector

# DESCRIPTION

The mechanisms and consequences of defective interfering particle (DIP) formation during influenza A virus infection remain poorly understood.

The development of next generation sequencing (NGS) technologies have made it possible to identify large numbers of DIP-associated sequences.

This tool attempts to extract DIPs from Illumina paired-end gzipped fastq files (i.e. sample_name_R1.fastq.gz, sample_name_R2.fastq.gz).

# WORKFLOW OF THE PIPELINE

![Alt text](DIP_Workflow.png?raw=true "Workflow")

# Installation

First, setup a new conda environment

<pre>
conda create -n DIP_Pipeline python=2.7 anaconda
conda activate DIP_Pipeline
</pre>

# Dependencies 

Install the following tools/languages in your $PATH within the conda environment:

- <b>Bowtie</b>      conda install -c bioconda bowtie
- <b>Bowtie2</b>     conda install -c bioconda bowtie2
- <b>Perl</b>        conda install -c anaconda perl
- <b>ViReMa</b>      conda install -c bioconda virema
- <b>Bandage</b>     conda install -c bioconda bandage

Then clone this repository

<pre>
git clone https://gitlab.phe.gov.uk/virology_bioinformatics/viruses/influenza/elective_project_DIP_InfluenzaA_H3N2
</pre>

Place your paired-end FASTQ files in "FASTQ_files" then run the DIP_workflow.sh script across your files

<pre>
for i in $(ls FASTQ_files/*R1*); do DIP_workflow.sh $i; done
</pre>

The relevant output will be pasted in the "Output_files"

