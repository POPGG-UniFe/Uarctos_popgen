#!/bin/bash

WD=$1
FINALOUTPATH=$2
code=$3
chr=$4

cd $WD
FILEDEPTH="$code"_sorted_dedup_rg_real_rmopt_meandepth.txt

meandepth=$(cat $FINALOUTPATH/$FILEDEPTH)
mindepth=$(echo $meandepth | awk '{printf("%.0f\n", $1/3)}')
maxdepth=$(echo $meandepth | awk '{printf("%.0f\n", $1*2)}')

echo "mean depth = $meandepth"
echo "min depth = $mindepth"
echo "max depth = $maxdepth"

### create input for PSMC
module load bcftools-1.11
bcftools mpileup -f /jarvis/scratch/usr/gabrielli/ursus/marsican/alignment/mUrsArc1.1.primarysoftmask.fasta -q30 -Q30 --ff DUP -r $chr $FINALOUTPATH/"$code"_sorted_dedup_rg_real_rmopt.bam | bcftools call -c | /opt/software/ngs/bcftools-1.11/misc/vcfutils.pl vcf2fq -d $mindepth -D $maxdepth > input/"$code"_DP"$mindepth"_"$maxdepth"_"$chr".fa

### concatenate all scaffolds into a single fasta per individual
cat chr.list | while read chr
do
cat input/"$code"_DP"$mindepth"_"$maxdepth"_"$chr".fa >>input/"$code"_DP"$mindepth"_"$maxdepth".fa
done

### convert fasta sequences into psmcfa
#-q minimum quality (default 10)
#-s bin size
#N_ratio = 0.9 default
#-g = n_min_good = mininal length of sequence to print

/opt/software/genetics/psmc-0.6.5/utils/fq2psmcfa -s100 -g500000 input/"$code"_DP"$mindepth"_"$maxdepth".fa > input/"$code"_DP"$mindepth"_"$maxdepth".psmcfa

### run PSMC
module load psmc-0.6.5
psmc -N25 -t15 -r5 -p "4+25*2+4+6" -o output/"$code"_DP"$mindepth"_"$maxdepth".psmc input/"$code"_DP"$mindepth"_"$maxdepth".psmcfa
