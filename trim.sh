#!/bin/bash
#SBATCH --partition=medium
#SBATCH --time=1-00:00:00
#SBATCH --nodes=1
#SBATCH --mem=40gb
#SBATCH --ntasks=6
#SBATCH --output=/projects/sykesj/StdOut/R-%x.%j-trim.out
#SBATCH --error=/projects/sykesj/StdOut/R-%x.%j-trim.err

species=$1
SRR=$2
sex=$3
layout=$4
WD=$5


#### SINGLE END MODE ####

if [ $layout == "single" ]
then
java -jar /home/sykesj/software/Trimmomatic-0.39/trimmomatic-0.39.jar SE -phred33 "$WD"/raw/$species/$sex/$SRR\_1.fastq "$WD"/analyses/$species/trimmomatic/$sex/$SRR\_s.fq ILLUMINACLIP:/home/sykesj/software/Trimmomatic-0.39/adapters/TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 HEADCROP:12 && /home/sykesj/software/FastQC/fastqc --outdir "$WD"/analyses/$species/fastqc2 "$WD"/analyses/$species/trimmomatic/$sex/$SRR\_s.fq && rm -f "$WD"/raw/$species/$sex/$SRR\_1.fastq

#### PAIRED END MODE ####

elif [ $layout == "paired" ]
then
java -jar /home/sykesj/software/Trimmomatic-0.39/trimmomatic-0.39.jar PE -phred33 "$WD"/raw/$species/$sex/$SRR\_1.fastq "$WD"/raw/$species/$sex/$SRR\_2.fastq "$WD"/analyses/$species/trimmomatic/$sex/$SRR\_1.fq "$WD"/analyses/$species/trimmomatic/$sex/$SRR\_forward_unpaired.fq.gz "$WD"/analyses/$species/trimmomatic/$sex/$SRR\_2.fq "$WD"/analyses/$species/trimmomatic/$sex/$SRR\_reverse_unpaired.fq.gz ILLUMINACLIP:/home/sykesj/software/Trimmomatic-0.39/adapters/TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 HEADCROP:12 && /home/sykesj/software/FastQC/fastqc --outdir "$WD"/analyses/$species/fastqc2 "$WD"/analyses/$species/trimmomatic/$sex/$SRR\_1.fq "$WD"/analyses/$species/trimmomatic/$sex/$SRR\_2.fq && rm -f "$WD"/raw/$species/$sex/$SRR\_1.fastq && rm -f "$WD"/raw/$species/$sex/$SRR\_2.fastq

rm -f "$WD"/analyses/$species/trimmomatic/$sex/$SRR\_forward_unpaired.fq.gz ; rm -f "$WD"/analyses/$species/trimmomatic/$sex/$SRR\_reverse_unpaired.fq.gz

sed 's/_F\/1/_1/g' "$WD"/analyses/$species/trimmomatic/$sex/$SRR\_1.fq | sed 's/_f\/1/_1/g' | sed 's/_forward\/1/_1/g' | sed 's/_Forward\/1/_1/g' # > /data/projects/lross_ssa/analyses/$species/trimmomatic/$sex/$SRR\_1.fq && rm -f /data/projects/lross_ssa/analyses/$species/trimmomatic/$sex/$SRR\_11.fq
sed 's/_R\/2/_2/g' "$WD"/analyses/$species/trimmomatic/$sex/$SRR\_2.fq | sed 's/_r\/2/_2/g' | sed 's/_reverse\/2/_2/g' | sed 's/_Reverse\/2/_2/g' # > /data/projects/lross_ssa/analyses/$species/trimmomatic/$sex/$SRR\_2.fq && rm -f /data/projects/lross_ssa/analyses/$species/trimmomatic/$sex/$SRR\_22.fq

else echo 'Error in mode selection at command line'
fi


multiqc $SPECIES $LAYOUT