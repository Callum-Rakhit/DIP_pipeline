# Convert the SAM file to a BAM
samtools view -Sb test_alignment_output.bam > test_alignment_output_bam.bam

# Sort the BAM file
samtools sort test_alignment_output_bam.bam test_alignment_output_sorted

# Get the depth (-S mean input is SAM, and -b means output BAM)
samtools depth test_alignment_output_sorted.bam > test_alignment_output.coverage

# can then import into R