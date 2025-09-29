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

module load bcftools-1.11
bcftools mpileup -f /jarvis/scratch/usr/gabrielli/ursus/marsican/alignment/mUrsArc1.1.primarysoftmask.fasta -q30 -Q30 --ff DUP -r $chr $FINALOUTPATH/"$code"_sorted_dedup_rg_real_rmopt.bam | bcftools call -c | /opt/software/ngs/bcftools-1.11/misc/vcfutils.pl vcf2fq -d $mindepth -D $maxdepth > input/"$code"_DP"$mindepth"_"$maxdepth"_"$chr".fa
