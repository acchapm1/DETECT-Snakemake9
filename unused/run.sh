#!/bin/bash
#SBATCH -n 1
#SBATCH -c 4
#SBATCH -t 04:00:00
#SBATCH -p htc
#SBATCH -q public
#SBATCH --job-name=detect_sn9_demo
#SBATCH -o logs/o-%j.out
#SBATCH -e logs/e-%j.err

module load mamba/latest
source activate sn9detect

BASE="$(pwd)"

python $BASE/DETECT/create_config.py \
  -R $BASE/demo/references/reference.fa \
  -U 2e-6 \
  -CL $BASE/demo/chrom_list.txt \
  -FL 300 -RL 100 -SD 30 \
  -P "dad,mom,junior" \
  -C "10,20,30" \
  -V $BASE/demo/input_variants/demo_variants.vcf \
  --cpus 12 \
  --trio \
  --num-iterations 1 \
  -WD $BASE/work \
  -O $BASE/output

snakemake -p \
  --profile profiles/slurm \
  --configfile work/config/config.json \
  -s DETECT/Snakefile

