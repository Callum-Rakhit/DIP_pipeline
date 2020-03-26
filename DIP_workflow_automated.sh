#!/usr/bin/env bash

# To setup the gitignore without large file use;
# find . -size +750kb | cat >> .gitignore

# To set this script as executable use;
# chmod ugo+x DIP_Workflow/DIP_workflow_automated.sh

#RE17001035
#RE17001039
#RE17000846
#RE17000909
#RE17000867
#RE17000910
#RE17000913
#RE17000917
#RE17000921
#RE17000847
#RE17000922 # absent
#RE17000923
#RE17002155 # absent
#RE17000848
#RE17000868
#RE17000924
#RE17000926
#RE17000850
#RE17001048
#RE17000851
#RE17000930
#RE17000853
#RE17000855
#RE17000857
#RE17000947
#RE17000879
#RE17000952
#RE17000956
#RE17000959
#RE17000896
#RE17000866
#RE17001032
#RE17001033

# When in /home/callum.rakhit/Addenbrooks_DIP_pos_flu

# Run SPAdes for all samples in identical_clade folder, save to DIP_Workflow/SPAdes_output/
for i in $(ls identical_clade/*R1*); do DIP_Workflow/SPAdes_runner.sh $i; done

# First do some trimming with "sickle" quality control
# Joshi NA, Fass JN. (2011). Sickle: A sliding-window, adaptive, quality-based trimming
# tool for FastQ files (v1.33) - Available at https://github.com/najoshi/sickle

# defualt for -l (minimum read length after chopping off low quality bases) is 20
# se = single end, pe = paired end
# sickle se -f input_file.fastq -t illumina -o trimmed_output_file.fastq -q 25

# sickle pe -f input_file1.fastq -r input_file2.fastq -t illumina-q 25 \
# -o trimmed_output_file1.fastq -p trimmed_output_file2.fastq \
# -s trimmed_singles_file.fastq

# QUAST: assembly statistics
# This is able to compare multiple assembles to assess quality
# Metrics are number of contigs, largest contig, total length, GC content,
# N50 (minimum contig length needed to cover 50% of the genome)
#quast.py scaffolds.fasta -o SPAdes

# Gridss for structural changes

# SSPACE is a script able to extend and scaffold pre-assembled contigs
# SSPACE_Standard_v3.0.pl -l Species_library.txt -s test.fasta -b SSPACE -T 16
# module load quast/5.0.6
# quast.py test.fasta -o SSPACE

# Can also do an alignment
# AlignGraph is a software that extends and joins contigs or scaffolds by reassembling
# `them with help provided by a reference genome of a closely related organism

# Another aligner is virulign, specifically made for viruses
# VIRULIGN: fast codon-correct alignment and annotation of viral genomes
# Bioinformatics, 2018, https://doi.org/10.1093/bioinformatics/bty851

# Convert mutliple sequence reference fasta to single line
#awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);} END {printf("\n");}' \
#< ../reference_genome/EPI_ISL_274878.fasta > ../reference_genome/oneline_EPI_ISL_274878.fasta
#
#awk '{if(NR==1) {print $0} else {if($0 ~ /^>/) {print "\n"$0} else {printf $0}}}' \
#../reference_genome/EPI_ISL_274878.fasta > ../reference_genome/oneline_EPI_ISL_274878.fasta
#
#grep -v ">" ../reference_genome/EPI_ISL_274878.fasta \
#| tr '\n' ' ' | sed -e 's/ //g' > ../reference_genome/oneline_EPI_ISL_274878.fasta
#
## Convert fastq to fasta
#sed -n '1~4s/^@/>/p;2~4p' INFILE.fastq > OUTFILE.fasta
#
## Run virulign
#virulign ../reference_genome/oneline_EPI_ISL_274878.fasta \
#460165_RE17000845_H3N2-1.FLU-generic.ngsservice.processed.R1.fasta \
#> virulign/test_alignment/test_alignment_output 2> virulign/test_alignment/test_alignment_err

# Run BWA mem
bwa mem ../reference_genome/EPI_ISL_274878.fasta 460165_RE17000845_H3N2-1.FLU-generic.ngsservice.processed.R1.fastq \
460165_RE17000845_H3N2-1.FLU-generic.ngsservice.processed.R2.fastq > bwa/test_alignment/test_alignment_output.bam

# Picard tools

# General alignment metrics
java -jar picard.jar CollectAlignmentSummaryMetrics \
R=reference_sequence.fasta \
I=input.bam O=output.txt

# Insert size metrics
java -jar picard.jar CollectInsertSizeMetrics \
I=bwa/test_alignment/test_alignment_output.bam \
O=bwa/test_alignment/test_insert_size_metrics.txt \
H=bwa/test_alignment/test_insert_size_histogram.pdf \
M=0

# Rscript for coverage
Rscript script.R $1


