#!/bin/bash

#SBATCH -c 2
#SBATCH --mem=1G
#SBATCH --time=1-00
#SBATCH -o /jarvis/scratch/usr/fabbri/slurmout/pbs4pop.o
#SBATCH -e /jarvis/scratch/usr/fabbri/slurmout/pbs4pop.e

WD=/jarvis/scratch/usr/fabbri/bear/selection/pbs4pop

## compute pairwise Fst
module load vcftools-0.1.16

A="/jarvis/scratch/usr/fabbri/bear/varcall/filtration/ind_marsican.txt"
B="/jarvis/scratch/usr/fabbri/bear/varcall/filtration/ind_slovakian.txt"
C="/jarvis/scratch/usr/fabbri/bear/varcall/filtration/ind_canadian.txt"
D="/jarvis/scratch/usr/fabbri/bear/varcall/filtration/ind_alaskan.txt"
INPUT_VCF="/jarvis/scratch/usr/fabbri/bear/varcall/filtration/Ursus.allchr.hq.snp.masked.filt.GQ10.noallmiss.norepeat.highmap.noHetExcess.vcf.gz"

# window 50K Fst and 50K step 
vcftools --gzvcf $INPUT_VCF --weir-fst-pop $A --weir-fst-pop $B --fst-window-size 50000 --fst-window-step 50000 --out ${WD}/output/noMAF/fst_A-B_50kWin_50kStep
vcftools --gzvcf $INPUT_VCF --weir-fst-pop $A --weir-fst-pop $C --fst-window-size 50000 --fst-window-step 50000 --out ${WD}/output/noMAF/fst_A-C_50kWin_50kStep
vcftools --gzvcf $INPUT_VCF --weir-fst-pop $A --weir-fst-pop $D --fst-window-size 50000 --fst-window-step 50000 --out ${WD}/output/noMAF/fst_A-D_50kWin_50kStep
vcftools --gzvcf $INPUT_VCF --weir-fst-pop $B --weir-fst-pop $C --fst-window-size 50000 --fst-window-step 50000 --out ${WD}/output/noMAF/fst_B-C_50kWin_50kStep
vcftools --gzvcf $INPUT_VCF --weir-fst-pop $B --weir-fst-pop $D --fst-window-size 50000 --fst-window-step 50000 --out ${WD}/output/noMAF/fst_B-D_50kWin_50kStep

## compute PBS 4 populations and plot with Rscript
source /opt/miniconda3/bin/activate r-env

Rscript /jarvis/scratch/usr/fabbri/bear/selection/pbs4pop/script/pbs4pop_50kWin_50kStep.R
