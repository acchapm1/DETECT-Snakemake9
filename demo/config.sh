#!/bin/bash

module load mamba/latest
source activate sn9detect

BASE="$(pwd)"

python ../DETECT/create_config.py \
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

