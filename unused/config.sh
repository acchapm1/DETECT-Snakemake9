#!/bin/bash
#SBATCH --job-name=detect-sn9-demo-cfg
#SBATCH -N 1
#SBATCH -c 4
#SBATCH -e logs/config-%j.err
#SBATCH -o logs/config-%j.out
#SBATCH -t 0-00:05:00
#SBATCH -p htc
#SBATCH -q public

module load mamba/latest
source activate sn9detect

BASE="$(pwd)"

python $BASE/src/create_config.py \
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

