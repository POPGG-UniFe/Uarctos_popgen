#!/bin/bash
#SBATCH -c 1
#SBATCH --mem=2G
#SBATCH --time=5-00
module load vcftools-0.1.16
cd /jarvis/scratch/usr/vilaca/orso/xpclr/MarSlo_50kb
source /opt/miniconda3/bin/activate p36
xpclr --input ../Mar_Scaffold_1.recode.vcf --format vcf --out /jarvis/scratch/usr/vilaca/orso/xpclr/MarSlo_50kb/MarsSlov_50kb_Scaffold_1 --samplesA popMars --samplesB popSlov --size 50000 --step 50000 --chr Scaffold_1
