# Influenza DIP Detector

# DESCRIPTION

The mechanisms and consequences of defective interfering particle (DIP) formation during influenza A virus infection remain poorly understood.

The development of next generation sequencing (NGS) technologies have made it possible to identify large numbers of DIP-associated sequences.

This tool attempts to extract DIPs from Illumina paired-end gzipped fastq files.

# WORKFLOW OF THE PIPELINE

![Alt text](Workflow_files/DIP_Workflow.png?raw=true "Workflow")

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
- <b>Picard Tools</b>     conda install -c bioconda picard
- <b>Samtools</b>     conda install -c bioconda samtools
- <b>R</b>     conda install -c conda-forge r-base

Then clone this repository

<pre>
git clone https://gitlab.phe.gov.uk/virology_bioinformatics/viruses/influenza/elective_project_DIP_InfluenzaA_H3N2
</pre>

Place your paired-end FASTQ files in "FASTQ_files".

Place your reference genome to align against in the "Reference_genome".

Then run the DIP_workflow.sh script across your files

<pre>
for i in $(ls FASTQ_files/*R1*); do Workflow_files/DIP_workflow.sh $i; done
</pre>

The relevant output will be pasted in the "Output_files"

You can look through the output files, and keep any that are useful

QUAST produces a html
Bandage can be used to view SPAdes de novo assembles
Picard tools has useful insert size metrics and a PDF

# Currently the reference genome is hard coded in the DIP_workflow file (Reference_FASTQ/EPI_ISL_274878.fasta). 
# Please change this to the file you choose to use! 


