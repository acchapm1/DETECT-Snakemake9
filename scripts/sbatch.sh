#!/bin/bash
#SBATCH -n 1
#SBATCH -c 2
#SBATCH -t 04:00:00
#SBATCH -p public
#SBATCH -q public
#SBATCH --job-name=sn9-demo
#SBATCH -o o-%j.out
#SBATCH -e e-%j.err

module load mamba/latest
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
