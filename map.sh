#!/bin/bash
#SBATCH --partition=medium
#SBATCH --time=1-00:00:00
#SBATCH --nodes=1
#SBATCH --mem=40gb
#SBATCH --ntasks=6
#SBATCH --output=/home/sykesj/scripts/StdOut/R-%x.%j.out
#SBATCH --error=/home/sykesj/scripts/StdOut/R-%x.%j.err


SPECIES=$1
SRR=$2
SEX=$3
LAYOUT=$4
DUEL_LAYOUT=$5

if [ $DUEL_LAYOUT == 'YES']
then
	PAIRED_BUSCO_SCORE=$(sed '8q;d' /projects/sykesj/analyses/$SPECIES/busco/BUSCO_out_testp_PAIRED.txt | awk -F[CS] '{print $2}' | sed 's/[^0-9]*//g')
	SINGLE_BUSCO_SCORE=$(sed '8q;d' /projects/sykesj/analyses/$SPECIES/busco/BUSCO_out_testp_SINGLE.txt | awk -F[CS] '{print $2}' | sed 's/[^0-9]*//g')
	if $PAIRED_BUSCO_SCORE > $SINGLE_BUSCO_SCORE
	then
			BEST_TRANS_IDX=paired_$SPECIES.idx
	else
	fi		BEST_TRANS_IDX=single_$SPECIES.idx
fi


kallisto_map () {

	mkdir /projects/sykesj/analyses/$SPECIES/kallisto/$SRR
	mkdir /scratch/projects/sykesj/map_$SRR

	if [ $LAYOUT == 'PAIRED' ]
	then
		if [ $DUEL_LAYOUT == 'YES']
		then
			TRANS_IDX=$BEST_TRANS_IDX
		else
			TRANS_IDX=paired_$SPECIES.idx
		fi

		kallisto quant -t 16 -i /projects/sykesj/analyses/$SPECIES/kallisto/$TRANS_IDX -o /scratch/projects/sykesj/map_$SRR/$SRR \
			-b 100 /projects/sykesj/analyses/$SPECIES/trimmomatic/$LAYOUT/$SEX/$SRR\_1.fq /projects/sykesj/analyses/$SPECIES/trimmomatic/$LAYOUT/$SEX/$SRR\_2.fq


	elif [ $LAYOUT == 'SINGLE' ]
	then
		if [ $DUEL_LAYOUT == 'YES']
		then
			TRANS_IDX=$BEST_TRANS_IDX
		else
			TRANS_IDX=single_$SPECIES.idx
		fi

		READ_LENGTH=$(awk 'BEGIN { t=0.0;sq=0.0; n=0;} ;NR%4==2 {n++;L=length($0);t+=L;sq+=L*L;}END{m=t/n;printf("%f\n",m);}'  /projects/sykesj/analyses/$SPECIES/trimmomatic/$LAYOUT/$SEX/$SRR\_s.fq)
		SD=$(awk 'BEGIN { t=0.0;sq=0.0; n=0;} ;NR%4==2 {n++;L=length($0);t+=L;sq+=L*L;}END{m=t/n;printf("%f\n",sq/n-m*m);}' /projects/sykesj/analyses/$SPECIES/trimmomatic/$LAYOUT/$SEX/$SRR\_s.fq)

		kallisto quant -t 16 -i /projects/sykesj/analyses/$SPECIES/kallisto/$TRANS_IDX -o /scratch/projects/sykesj/map_$SRR/$SRR -b 100 \
			--single -l $READ_LENGTH -s $SD /projects/sykesj/analyses/$SPECIES/trimmomatic/$LAYOUT/$SEX/$SRR\_s.fq

	fi

	rsync -a /scratch/projects/sykesj/map_$SRR/$SRR /projects/sykesj/analyses/$SPECIES/kallisto && rm -rf /scratch/projects/sykesj/map_$SRR

####### setting up files for sleuth #########

	#mkdir /projects/sykesj/analyses/$SPECIES/kallisto/kal_results
	
	ln -s /projects/sykesj/analyses/$SPECIES/kallisto/$SRR /projects/sykesj/analyses/$SPECIES/kallisto/kal_results/kal_files/
	rm -rf /projects/sykesj/analyses/testp/kallisto/$SRR/$SRR

}

kallisto_map $SPECIES $SRR $SEX $LAYOUT 