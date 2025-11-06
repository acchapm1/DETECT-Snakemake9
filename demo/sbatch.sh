#!/bin/bash
#!/bin/bash
#SBATCH -n 1
#SBATCH -c 4
#SBATCH -t 3-00:00:00
#SBATCH -p public
#SBATCH -q public
#SBATCH --job-name=detect_sn9
#SBATCH -o logs/o-%j.out
#SBATCH -e logs/e-%j.err

module load mamba/latest
# source activate sn9detect
source activate DETECT

BASE="$(pwd)"


echo "Config created Successfully"
echo " "
echo "Starting DETECT run"
echo " "

snakemake -p \
  --profile ../profiles/slurm \
  --configfile work/config/config.json \
  -s ../DETECT/Snakefile
