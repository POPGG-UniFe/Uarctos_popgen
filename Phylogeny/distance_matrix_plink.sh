#!/bin/bash
#SBATCH --time=96:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=10G
#SBATCH --nodelist=mark4
#SBATCH -e input_gendist.sh.e
#SBATCH -o input_gendist.sh.o

WD=/jarvis/scratch/usr/gabrielli/ursus/marsican/phylogeny/4pop
cd $WD
GZVCF=/jarvis/scratch/usr/fabbri/bear/varcall/filtration/Ursus.allchr.hq.snp.masked.filt.GQ10.noallmiss.norepeat.highmap.noHetExcess.vcf.gz
module load plink-1.90
plink --vcf $GZVCF --distance square 1-ibs flat-missing --out Ursus.allsp.allchr.hq.snp.masked.filt.GQ10 --allow-extra-chr
