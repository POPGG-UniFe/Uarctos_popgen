#!/bin/bash
#SBATCH -c 1
#SBATCH --mem-per-cpu=3G
#SBATCH --time=24:00:00
#SBATCH -J spliceai
#SBATCH -o slurm_%A_%x.o
#SBATCH -e slurm_%A_%x.e

#########
# USAGE #
#########

#sbatch run_spliceai.sh <gene>

WD=/jarvis/scratch/usr/fabbri/bear/selection/mutations/spliceai

source /opt/miniconda3/bin/activate genomes

GENE=$1

VCF_IN=${WD}/input/${GENE}_varSites.vcf.gz
VCF_OUT=${WD}/output/${GENE}_spliceAnnot.vcf

REF=/jarvis/scratch/usr/gabrielli/ursus/marsican/alignment/mUrsArc1.1.primarysoftmask.fasta
ANNOT=${WD}/input/annot_${GENE}.txt

# consider -D <integer> flag to extend the analysis of effect on splicing around a variant. Default=50, max 10K (actually 499 for each side of the variant)
spliceai -I $VCF_IN -O $VCF_OUT -R $REF -A $ANNOT -D 4999

# compress file
/opt/software/ngs/angsd-0.932/htslib/bgzip $VCF_OUT

# explore results: threshold >= 0.5
bcftools view -H ${GENE}_spliceAnnot.vcf.gz | cut -f1,2,8 | awk -v OFS="\t" 'BEGIN { FS = "SpliceAI=" } {print $1, $2, $3, $4}' | sed 's/|/\t/g' | cut -f1,2,4-13 | awk '$5 >=0.5 || $6 >=0.5 ||$7 >=0.5 || $8 >=0.5'
