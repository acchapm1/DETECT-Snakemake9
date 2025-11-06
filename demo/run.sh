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
