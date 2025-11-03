#!/bin/bash
#SBATCH -n 1 
#SBATCH -c 4
#SBATCH -t 04:00:00
#SBATCH -p htc
#SBATCH -q public
#SBATCH --job-name=detect_sn9
#SBATCH -o logs/o-%j.out
#SBATCH -e logs/e-%j.err

module load mamba/latest
source activate sn9detect

snakemake -p \
  --profile profiles/slurm \
  --configfile work/config/config.json \
  -s src/Snakefile
