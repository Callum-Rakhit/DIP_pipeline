VAR1="$1"
VAR2=`echo $VAR1 | awk '{print substr($VAR1, 1, length($VAR1)-10)"2.fastq.gz"}'`
VAR3=`echo $VAR1 | awk '{print substr($VAR1, 1, length($VAR1)-45)}'`
VAR4=`echo $VAR3 | cut -c17-`

# Run SPADes and then analyse results with QUAST (and bandage using GUI)
spades.py -k 21,33,55,77 --careful -1 $VAR1 -2 $VAR2 -o DIP_Workflow/SPAdes_output/$VAR3
quast.py DIP_Workflow/SPAdes_output/$VAR3/scaffolds.fasta -o DIP_Workflow/SPAdes_output_analysis_by_QUAST/$VAR3

# Run alignment using bwa mem
mkdir -p DIP_Workflow/bwa_output/identical_clade/
bwa mem ./reference_genome/EPI_ISL_274878.fasta $VAR1 $VAR2 > DIP_Workflow/bwa_output/$VAR3.sam

# General alignment metrics from picard
mkdir -p DIP_Workflow/picard_output/identical_clade/

# Sort using Picard tools
picard.jar SortSam \
I=DIP_Workflow/bwa_output/$VAR3.sam \
O=DIP_Workflow/bwa_output/$VAR3.picardsorted.sam \
SORT_ORDER=coordinate

# Extract metrics on the alignment using Picard tools
picard.jar CollectAlignmentSummaryMetrics \
R=reference_genome/EPI_ISL_274878.fasta \
I=DIP_Workflow/bwa_output/$VAR3.picardsorted.sam O=DIP_Workflow/picard_output/$VAR3.AlignmentSummaryMetrics

# Insert size metrics using Picard tools
picard.jar CollectInsertSizeMetrics \
I=DIP_Workflow/bwa_output/$VAR3.picardsorted.sam \
O=DIP_Workflow/picard_output/$VAR3.InsertSizeMetrics \
H=DIP_Workflow/picard_output/$VAR3.InsertSizeHistogram.pdf \
M=0

# Samtools depth
samtools view -bS DIP_Workflow/bwa_output/$VAR3.sam > DIP_Workflow/bwa_output/$VAR3.bam
samtools sort DIP_Workflow/bwa_output/$VAR3.bam DIP_Workflow/bwa_output/$VAR3.sorted
samtools index DIP_Workflow/bwa_output/$VAR3.sorted.bam
#samtools depth DIP_Workflow/bwa_output/$VAR3.sorted.bam > DIP_Workflow/bwa_output/$VAR3.depth

# Rscript for coverage
mkdir -p DIP_Workflow/R_plots/identical_clade/

Rscript DIP_Workflow/coverage_per_base_plot.R \
DIP_Workflow/bwa_output/$VAR3.depth \
DIP_Workflow/R_plots/$VAR3.pdf

# Concatinate paired end to single end, run Virema (aligns with bowtie then detects recombination events)
mkdir -p DIP_Workflow/ViReMa_output/identical_clade/

# Run ViReMa
cat $VAR1 $VAR2 | gunzip > DIP_Workflow/ViReMa_output/$VAR3.concatenated.fastq

ViReMa.py -DeDup --MicroInDel_Length 20 --Defuzz 3 --N 2 --X 8 -BED \
./reference_genome/bowtie2/EPI_ISL_274878 \
DIP_Workflow/ViReMa_output/$VAR3.concatenated.fastq \
DIP_Workflow/ViReMa_output/$VAR3.recombination.results

mkdir -p ViReMa_output/$VAR3
cd ViReMa_output/$VAR3

ViReMa.py --MicroInDel_Length 20 -DeDup --Defuzz 3 \
--N 2 --X 8 -ReadNamesEntry --p 4 \
~/Addenbrooks_DIP_pos_flu/reference_genome/bowtie2/EPI_ISL_274878 \
~/Addenbrooks_DIP_pos_flu/ViReMa_output/$VAR3.concatenated.fastq \
ViReMa_output.results

cd ~/Addenbrooks_DIP_pos_flu/

# Extract ViReMa output files and sort per segment

perl DIP_Workflow/parse_virus_recombination_results.pl \
-d 50 \
-o ViReMa_output/$VAR3.Recombination_Results.parsed \
-i ViReMa_output/$VAR3/Virus_Recombination_Results.txt

# Paste it all into a summary text file
echo $VAR4 >> summary.txt
cat ViReMa_output/$VAR3.Recombination_Results.parsed >> summary.txt
