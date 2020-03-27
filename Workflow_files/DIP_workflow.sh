VAR1="$1"
VAR2=`echo $VAR1 | awk '{print substr($VAR1, 1, length($VAR1)-10)"2.fastq.gz"}'`
VAR3=`echo $VAR1 | awk '{print substr($VAR1, 1, length($VAR1)-45)}'`
VAR4=`echo $VAR3 | cut -c13-`

mkdir temp

# Run SPADes and then analyse results with QUAST (and bandage using GUI)
spades.py -k 21,33,55,77 --careful -1 $VAR1 -2 $VAR2 -o temp/SPAdes_output/$VAR3
quast.py temp/SPAdes_output/$VAR3/scaffolds.fasta -o temp/SPAdes_output_analysis_by_QUAST/$VAR3

# Run alignment using bwa mem
mkdir -p temp/bwa_output/FASTQ_files/
bwa index Reference_FASTQ/EPI_ISL_274878.fasta
bwa mem Reference_FASTQ/EPI_ISL_274878.fasta $VAR1 $VAR2 > temp/bwa_output/$VAR3.sam

# General alignment metrics from picard
mkdir -p temp/picard_output/FASTQ_files/

# Sort using Picard tools
picard.jar SortSam \
I=temp/bwa_output/$VAR3.sam \
O=temp/bwa_output/$VAR3.picardsorted.sam \
SORT_ORDER=coordinate

# Extract metrics on the alignment using Picard tools
picard.jar CollectAlignmentSummaryMetrics \
R=Reference_FASTQ/EPI_ISL_274878.fasta \
I=temp/bwa_output/$VAR3.picardsorted.sam O=temp/picard_output/$VAR3.AlignmentSummaryMetrics

# Insert size metrics using Picard tools
picard.jar CollectInsertSizeMetrics \
I=temp/bwa_output/$VAR3.picardsorted.sam \
O=temp/picard_output/$VAR3.InsertSizeMetrics \
H=temp/picard_output/$VAR3.InsertSizeHistogram.pdf \
M=0

# Samtools depth
samtools view -bS temp/bwa_output/$VAR3.sam > temp/bwa_output/$VAR3.bam
samtools sort temp/bwa_output/$VAR3.bam temp/bwa_output/$VAR3.sorted
samtools index temp/bwa_output/$VAR3.sorted.bam
samtools depth temp/bwa_output/$VAR3.sorted.bam > temp/bwa_output/$VAR3.depth

# Rscript for coverage
mkdir -p Output_files/R_plots/

Rscript Workflow_files/coverage_per_base_plot.R \
temp/bwa_output/$VAR3.depth \
`pwd` \
Output_files/R_plots/$VAR4.pdf

# Concatinate paired end to single end, run Virema (aligns with bowtie then detects recombination events)
mkdir -p temp/ViReMa_output/

 Run ViReMa
mkdir -p temp/ViReMa_output/$VAR3
cat $VAR1 $VAR2 | gunzip > temp/ViReMa_output/$VAR3.concatenated.fastq

cd temp/ViReMa_output/$VAR3

ViReMa.py --MicroInDel_Length 20 -DeDup --Defuzz 3 --Aligner bwa \
--N 2 --X 8 -ReadNamesEntry --p 4 \
../../../../Reference_FASTQ/EPI_ISL_274878.fasta \
../$VAR4.concatenated.fastq \
ViReMa_output.results

cd ../../../../

# Extract ViReMa output files and sort per segment

perl Workflow_files/parse_virus_recombination_results.pl \
-d 50 \
-o temp/ViReMa_output/$VAR3.Recombination_Results.parsed \
-i temp/ViReMa_output/$VAR3/Virus_Recombination_Results.txt

# Paste it all into a summary text file
echo $VAR4 >> Output_files/DIPs_summary.txt
cat temp/ViReMa_output/$VAR3.Recombination_Results.parsed >> Output_files/DIPs_summary.txt
