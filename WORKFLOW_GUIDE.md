# DETECT Workflow Configuration Guide

## Overview

The DETECT workflow has been updated to use Snakemake 9 with an interactive configuration system that makes it easy to set up and run workflows.

## Configuration Scripts

### scripts/create_config.sh

Interactive script that prompts for all workflow parameters and generates three files:

1. **config.sh** - Shell script that generates `config.json` by calling `DETECT/create_config.py`
2. **run.sh** - Interactive workflow execution script that:
   - Generates the config.json
   - Runs Snakemake on the login node (submits rules as SLURM jobs)
   - Validates outputs
3. **sbatch_run.sh** - SLURM batch submission script that:
   - Submits Snakemake itself as a SLURM batch job
   - Includes SBATCH directives (partition, time, QOS, job name)
   - Generates config.json and runs the workflow
   - Recommended for long-running workflows

## Required Parameters

### Reference Genome
- **Flag**: `-R`
- **Description**: Path to reference genome FASTA file
- **Example**: `demo/references/reference.fa`
- **Validation**: File must exist

### Input VCF
- **Flag**: `-V`
- **Description**: Variant catalog to act as false positives
- **Example**: `demo/input_variants/demo_variants.vcf`
- **Validation**: File must exist

### Mutation Input
- **Flag**: `-U`
- **Description**: Can be:
  - Mutation rate if < 1 (e.g., `2e-6`)
  - Number of mutations if >= 1 (e.g., `10000`)
  - VCF file path with specific mutations
- **Example**: `2e-6` or `10000` or `/path/to/mutations.vcf`

### Coverages
- **Flag**: `-C`
- **Description**: Coverage values for parent1, parent2, and offspring (comma-separated)
- **Example**: `"10,20,30"` or `"37.4149,37.2586,18.8947"`
- **Format**: Must be three values separated by commas

### Output Directory
- **Flag**: `-O`
- **Description**: Directory where DETECT results will be written
- **Example**: `output`
- **Note**: Will be created if it doesn't exist

## Optional Parameters

### Known Variants
- **Flag**: `-KV`
- **Description**: Variant catalog for BQSR (if different from input variants)
- **Default**: Uses input variants (`-V`)
- **Example**: `/path/to/known_variants.vcf`

### Chromosome List
- **Flag**: `-CL`
- **Description**: List of contigs for DNM detection (one per line)
- **Default**: `ALL` (all contigs in reference)
- **Example**: `demo/chrom_list.txt`

### Fragment Length
- **Flag**: `-FL`
- **Description**: Mean fragment length of sequencing library
- **Default**: `300`
- **Units**: Base pairs
- **Example**: `400`

### Read Length
- **Flag**: `-RL`
- **Description**: Read length of sequencing data
- **Default**: `100`
- **Units**: Base pairs
- **Example**: `150`

### Fragment Standard Deviation
- **Flag**: `-SD`
- **Description**: Standard deviation of fragment length distribution
- **Default**: `30`
- **Example**: `40`

### Pedigree
- **Flag**: `-P`
- **Description**: Sample names in VCF (comma-separated: parent1,parent2,offspring)
- **Default**: Random selection from VCF if not specified
- **Example**: `"dad,mom,junior"` or `"ERR466113,ERR466114,ERR466117"`

### CPU Cores
- **Flag**: `--cpus`
- **Description**: Maximum CPUs per job
- **Default**: `12`
- **Example**: `24`

### VCF Type
- **Flags**: `--trio` or `--population`
- **Description**: Specifies whether input VCF contains trio or population data
- **Default**: `--trio`
- **Required**: Must specify one if `-V` is provided

### Number of Iterations
- **Flag**: `--num-iterations`
- **Description**: Number of workflow iterations for filter distribution
- **Default**: `1`
- **Example**: `10`

### Working Directory
- **Flag**: `-WD`
- **Description**: Directory for intermediate files
- **Default**: `work`
- **Example**: `/scratch/user/detect_work`
- **Note**: Can consume significant space depending on genome size and coverage

## SLURM Job Submission Parameters

These parameters are used to configure the SLURM batch job when using `sbatch_run.sh`.

### SLURM Partition
- **SBATCH Flag**: `-p`
- **Description**: SLURM partition/queue for job submission
- **Default**: `public`
- **Example**: `compute`, `highmem`, `gpu`
- **Note**: Must be a valid partition on your cluster

### Time Limit
- **SBATCH Flag**: `-t`
- **Description**: Maximum walltime for the job
- **Default**: `4-00:00:00` (4 days)
- **Format**: `days-hours:minutes:seconds` or `hours:minutes:seconds`
- **Examples**: 
  - `4-00:00:00` (4 days)
  - `48:00:00` (48 hours)
  - `12:30:00` (12 hours 30 minutes)
- **Note**: Job will be terminated if it exceeds this time

### QOS (Quality of Service)
- **SBATCH Flag**: `-q`
- **Description**: SLURM QOS for job prioritization
- **Default**: `public`
- **Example**: `normal`, `high`, `low`
- **Note**: Available QOS options depend on cluster configuration

### Job Name
- **SBATCH Flag**: `--job-name`
- **Description**: Name for the SLURM job (appears in squeue)
- **Default**: `detect_workflow`
- **Example**: `chimp_trio_detect`, `run_12345`
- **Note**: Useful for identifying jobs in the queue

## Usage Examples

### Interactive Configuration (Recommended)

```bash
bash scripts/create_config.sh
```

Follow the prompts to configure your workflow. The script will:
- Show default values in green
- Validate file paths
- Check numeric inputs
- Generate `config.sh` and `run.sh`

### Running the Workflow

After configuration, you have three options:

```bash
# Option 1: SLURM batch submission (recommended)
sbatch sbatch_run.sh
squeue -u $USER          # Monitor job
snakejobs                # Monitor with rule names

# Option 2: Interactive execution on login node
./run.sh

# Option 3: Manual steps
./config.sh              # Generate config.json
snakemake -p --profile profiles/slurm --configfile work/config/config.json -s DETECT/Snakefile
```

**When to use each option:**

- **sbatch sbatch_run.sh**: Recommended for production workflows. Snakemake runs as a SLURM job, freeing up the login node. Job logs saved to `o-<jobid>.out` and `e-<jobid>.err`.

- **./run.sh**: Good for testing or when you want real-time output. Snakemake runs on login node. Use for workflows with few iterations or small datasets.

- **Manual steps**: Maximum control. Generate config separately, then run Snakemake with custom options.

### Manual Configuration Example

If you prefer to create `config.sh` manually:

```bash
#!/bin/bash

module load mamba/latest
source activate sn9detect

BASE="$(pwd)"

python $BASE/DETECT/create_config.py \
  -R /path/to/reference.fa \
  -U 2e-6 \
  -CL /path/to/chrom_list.txt \
  -FL 300 -RL 100 -SD 30 \
  -P "parent1,parent2,offspring" \
  -C "10,20,30" \
  -V /path/to/variants.vcf \
  --cpus 12 \
  --trio \
  --num-iterations 1 \
  -WD work \
  -O output
```

## Output Structure

### Generated Config Files

```
work/
└── config/
    └── config.json      # Workflow configuration in JSON format
```

### Workflow Outputs

```
output/
├── DETECT_output.1.txt  # Results for iteration 1
├── DETECT_output.2.txt  # Results for iteration 2 (if multiple iterations)
└── ...
```

## Configuration Validation

The `create_config.sh` script validates:

1. **File paths** - Ensures reference genome, VCF files exist
2. **Numeric values** - Validates positive numbers for coverages, lengths, etc.
3. **Mutation input** - Checks for valid number or VCF file
4. **VCF type** - Ensures either `--trio` or `--population` is specified

## Example Workflows

### Small Demo Dataset

```bash
# Use interactive script with defaults
bash scripts/create_config.sh
# Press Enter for all defaults
./run.sh
```

### Real Dataset (Chimp Trio Example)

```bash
bash scripts/create_config.sh

# Enter values:
# Reference: /scratch/user/data/panTro3.fa
# Input VCF: /scratch/user/data/Trio1.input_variants.autosomal.vcf
# Mutation input: 10000
# Coverages: 37.4149,37.2586,18.8947
# Output: /scratch/user/outputs
# Pedigree: ERR466113,ERR466114,ERR466117
# CPUs: 24
# VCF type: trio
# Working directory: /scratch/user/work
# SLURM partition: compute
# Time limit: 7-00:00:00
# QOS: normal
# Job name: chimp_trio_detect

sbatch sbatch_run.sh
```

## Troubleshooting

### Config.json not created
- Check that reference genome and VCF files exist
- Verify reference has `.dict` file (create with `samtools dict` or `gatk CreateSequenceDictionary`)
- Ensure VCF is indexed (`.tbi` or `.idx` file exists)

### Chromosome list issues
- Ensure chromosome names in list file match reference dictionary
- Use `ALL` to process all chromosomes
- Check for extra whitespace in chromosome names

### Memory/disk issues
- Working directory can grow large with high coverage/large genomes
- Consider using scratch space for `-WD`
- Monitor disk usage during workflow execution

## See Also

- `DETECT/README.md` - Original DETECT documentation
- `README.md` - Snakemake 9 setup and SLURM configuration
- `scripts/config.sh` - Example configuration script
- `scripts/config.json` - Example real-world configuration
