# AGENTS.md - DETECT Workflow Guidelines

## Build/Lint/Test Commands
- **Validate workflow**: `bash DETECT/scripts/validate_workflow.sh` (lint + dry-run)
- **Lint only**: `snakemake --lint -s DETECT/Snakefile --configfile <config.json>`
- **Dry-run local**: `snakemake -n -p -s DETECT/Snakefile --cores 4 --configfile <config.json>`
- **Dry-run with SLURM**: `snakemake -n -p -s DETECT/Snakefile --profile profiles/slurm --configfile <config.json>`
- **Run workflow**: `snakemake -s DETECT/Snakefile --configfile <config.json> --cluster "sbatch options"`
- **Unlock stuck workflow**: `snakemake --configfile <config.json> -s DETECT/Snakefile --unlock`

## Code Style Guidelines
- **Python**: Use argparse for CLI scripts, import standard modules first (sys, os, json), then third-party (numpy, Bio), then local
- **Naming**: snake_case for variables/functions, UPPER_CASE for constants
- **Error handling**: Use argparse for argument validation, check file existence before processing
- **Snakemake**: Follow existing resource profiles (short/medium/long/very_long/extra_long/extreme), use wildcard_constraints for validation
- **Shell commands**: Use proper quoting for paths with spaces, include set -euo pipefail in bash scripts
- **Documentation**: Include usage examples in README, maintain parameter descriptions in argparse
- **Dependencies**: Use conda environment DETECT.yml, prefer bioconda packages for bioinformatics tools