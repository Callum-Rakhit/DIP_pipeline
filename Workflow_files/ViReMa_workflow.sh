# Reads taken from Ebola server, already trimmed
# Concatinate paired end to single end
cat 460165_RE17000845_H3N2-1.FLU-generic.ngsservice.processed.R1.fastq \
460165_RE17000845_H3N2-1.FLU-generic.ngsservice.processed.R2.fastq > \
460165_RE17000845_H3N2-1.FLU-generic.ngsservice.processed.concatinated.fastq

# Create a bowtie2 index
bowtie2-build ../reference_genome/EPI_ISL_274878.fasta EPI_ISL_274878_bowtie2

# Align with bowtie
bowtie2 -x  ../reference_genome/bowtie2/EPI_ISL_274878_bowtie2 \
460165_RE17000845_H3N2-1.FLU-generic.ngsservice.processed.concatinated.fastq \
-S bowtie2/test_output_bowtie2.sam

# Virema another option, aligns with bowtie then detects recombination events
ViReMa.py -DeDup --MicroInDel_Length 20 --Defuzz 3 --N 2 --X 8 -BED \
../reference_genome/bowtie2/EPI_ISL_274878 \
460165_RE17000845_H3N2-1.FLU-generic.ngsservice.processed.concatinated.fastq \
ViReMa/

# Extract ViReMa output files and sort per segment
perl parse_virus_recombination_results.pl \
-i ViReMa/Virus_Recombination_Results.txt \
-o ViReMa/Virus_Recombination_Results_Parsed.par -d 1

