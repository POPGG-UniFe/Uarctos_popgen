# This script runs GONE for all ABB and SBB individuals

cd /jarvis/scratch/usr/gabrielli/ursus/marsican/GONE
for species in marsicanus slovakian
do
WD=/jarvis/scratch/usr/gabrielli/ursus/marsican/GONE/$species
mkdir -p $WD
cd $WD

# copy input files and change chromosome names
# convert vcf into ped and map files
module load plink-1.90
plink --vcf /jarvis/scratch/usr/gabrielli/ursus/marsican/SFS/var/norepeat/noHetExcess/nosex/$species.nomiss.mac1.norepeat.noHetExcesswindow.nosex.recode.vcf --chr Scaffold_1 Scaffold_3 Scaffold_4 Scaffold_5 Scaffold_6 Scaffold_7 Scaffold_8 Scaffold_9 Scaffold_10 Scaffold_11 Scaffold_12 Scaffold_13 Scaffold_14 Scaffold_15 Scaffold_16 Scaffold_17 Scaffold_18 Scaffold_19 Scaffold_20 Scaffold_21 Scaffold_22 Scaffold_23 Scaffold_24 Scaffold_25 Scaffold_26 Scaffold_27 Scaffold_28 Scaffold_29 Scaffold_30 Scaffold_31 Scaffold_32 Scaffold_33 Scaffold_34 Scaffold_35 Scaffold_36 Scaffold_37 --recode --allow-extra-chr --out $species

cat $species.map | sed 's/Scaffold_//g' >temp
mv temp $species.map
rm temp

# Run GONE
cd /jarvis/scratch/usr/gabrielli/podarcis/raffonei/GONE/GONE-master/Linux
bash script_GONE.sh $species $WD ### script_GONE.sh from GONE software, and parameter file by default, except for hc 0.01
done
