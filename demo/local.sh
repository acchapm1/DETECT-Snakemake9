#!/bin/bash

module load mamba/latest
source activate DETECT

BASE="$(pwd)"

python ../DETECT/create_config.py \
  -R demo/references/reference.fa \
  -U 2e-6 \
  -CL demo/chrom_list.txt \
  -FL 300 -RL 100 -SD 30 \
  -P "dad,mom,junior" \
  -C "10,20,30" \
  -V demo/input_variants/demo_variants.vcf \
  --cpus 12 \
  --trio \
  --num-iterations 1 \
  -WD work \
  -O output

echo "Config created Successfully"
echo " "
echo "Starting DETECT run"
echo " "

snakemake -p \
  --profile profiles/slurm \
  --configfile work/config/config.json \
  -s DETECT/Snakefile
