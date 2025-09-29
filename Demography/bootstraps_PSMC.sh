### This script runs 100 bootstraps for the 3 individuals with most coverage for ABB and SBB bears

# 1) Create bootstraps runs

WD=/jarvis/scratch/usr/gabrielli/ursus/marsican/PSMC/bootstraps
cd $WD

mkdir -p run

FINALOUTPATH=/jarvis/scratch/usr/gabrielli/ursus/marsican/alignment/finaloutput

for code in 4212_S74_001 4573_S39_001 8657_S62_001 U1897_S25_001 U1916_S61_001 U1919_S73_001
do
ind=$(echo $code | cut -f 1 -d "_")
FILEDEPTH="$code"_sorted_dedup_rg_real_rmopt_meandepth.txt

meandepth=$(cat $FINALOUTPATH/$FILEDEPTH)
mindepth=$(echo $meandepth | awk '{printf("%.0f\n", $1/3)}')
maxdepth=$(echo $meandepth | awk '{printf("%.0f\n", $1*2)}')

for i in {1..100}
do
echo "#!/bin/bash" >run/script_"$code"_"$i".sh
echo psmc -N25 -t15 -r5 -b -p "4+25*2+4+6" -o output/$ind-round-"$i".psmc input/"$code"_DP"$mindepth"_"$maxdepth"_split.psmcfa >>run/script_"$code"_"$i".sh
done

done

# 2) Run bootstraps, in 2 batches of 50 jobs for each of the 6 individuals

WD=/jarvis/scratch/usr/gabrielli/ursus/marsican/PSMC/bootstraps
mkdir -p $WD/output
cd $WD

for code in 4212_S74_001 4573_S39_001 8657_S62_001 U1897_S25_001 U1916_S61_001 U1919_S73_001
do
ind=$(echo $code | cut -f 1 -d "_")
for i in {1..50}
do
module load psmc-0.6.5
sbatch --time=96:00:00 --nodes=1 --ntasks=1 --mem=4G --nodelist=mark7 -J PSMC-"$ind"_"$i" -e errors/PSMC-"$ind"_"$i".e -o errors/PSMC-"$ind"_"$i".o run/script_"$code"_"$i".sh
done
sleep 3h
for i in {51..100}
do
module load psmc-0.6.5
sbatch --time=96:00:00 --nodes=1 --ntasks=1 --mem=4G --nodelist=mark7 -J PSMC-"$ind"_"$i" -e errors/PSMC-"$ind"_"$i".e -o errors/PSMC-"$ind"_"$i".o run/script_"$code"_"$i".sh
done
sleep 3h
done

