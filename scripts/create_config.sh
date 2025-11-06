#!/bin/bash

# Interactive script to create config.sh and run.sh for DETECT workflow
# Prompts for all configuration parameters needed

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to prompt for input with default value
prompt_input() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"
    local validation="${4:-}"
    
    while true; do
        echo -e "${YELLOW}$prompt${NC}"
        if [[ -n "$default" ]]; then
            echo -e "Default: ${GREEN}$default${NC}"
        fi
        read -p "> " input
        
        if [[ -z "$input" && -n "$default" ]]; then
            input="$default"
        fi
        
        # Validate if validation function provided
        if [[ -n "$validation" ]]; then
            if $validation "$input"; then
                break
            else
                echo -e "${RED}Invalid input. Please try again.${NC}"
                continue
            fi
        else
            break
        fi
    done
    
    # Export the variable for later use
    export "$var_name"="$input"
    echo -e "${GREEN}Set $var_name = $input${NC}"
    echo ""
}

# Function to prompt for yes/no
prompt_yes_no() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"
    
    while true; do
        echo -e "${YELLOW}$prompt (yes/no)${NC}"
        if [[ -n "$default" ]]; then
            echo -e "Default: ${GREEN}$default${NC}"
        fi
        read -p "> " input
        
        if [[ -z "$input" && -n "$default" ]]; then
            input="$default"
        fi
        
        case "$input" in
            [Yy]|[Yy][Ee][Ss])
                export "$var_name"="yes"
                echo -e "${GREEN}Set $var_name = yes${NC}"
                break
                ;;
            [Nn]|[Nn][Oo])
                export "$var_name"="no"
                echo -e "${GREEN}Set $var_name = no${NC}"
                break
                ;;
            *)
                echo -e "${RED}Please enter yes or no${NC}"
                ;;
        esac
    done
    echo ""
}

# Function to prompt for choice
prompt_choice() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"
    shift 3
    local choices=("$@")
    
    while true; do
        echo -e "${YELLOW}$prompt${NC}"
        echo -e "Choices: ${BLUE}${choices[*]}${NC}"
        if [[ -n "$default" ]]; then
            echo -e "Default: ${GREEN}$default${NC}"
        fi
        read -p "> " input
        
        if [[ -z "$input" && -n "$default" ]]; then
            input="$default"
        fi
        
        # Check if input is valid choice
        for choice in "${choices[@]}"; do
            if [[ "$input" == "$choice" ]]; then
                export "$var_name"="$input"
                echo -e "${GREEN}Set $var_name = $input${NC}"
                echo ""
                return 0
            fi
        done
        
        echo -e "${RED}Invalid choice. Please select from: ${choices[*]}${NC}"
    done
}

# Validation functions
validate_file_exists() {
    local file="$1"
    # Expand relative paths
    if [[ "$file" != /* ]]; then
        file="$(pwd)/$file"
    fi
    
    if [[ -f "$file" ]]; then
        return 0
    else
        echo -e "${RED}File not found: $file${NC}"
        return 1
    fi
}

validate_positive_number() {
    local num="$1"
    if [[ "$num" =~ ^[0-9]+(\.[0-9]+)?$ ]] && (( $(echo "$num > 0" | bc -l) )); then
        return 0
    else
        echo -e "${RED}Must be a positive number${NC}"
        return 1
    fi
}

validate_mutation_input() {
    local input="$1"
    # Check if it's a number (int or float, or scientific notation)
    if [[ "$input" =~ ^[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]]; then
        return 0
    # Check if it's a file path
    elif [[ -f "$input" ]]; then
        return 0
    else
        echo -e "${RED}Must be a number (rate/count) or valid VCF file path${NC}"
        return 1
    fi
}

# Banner
echo -e "${BLUE}"
echo "=========================================="
echo "  DETECT Configuration Script Generator"
echo "=========================================="
echo -e "${NC}"
echo ""
echo "This script will create config.sh and run.sh for the DETECT workflow."
echo "Press Enter to use default values shown in green."
echo ""

# Get base directory
BASE_DIR="$(pwd)"
echo -e "${GREEN}Base directory: $BASE_DIR${NC}"
echo ""

# Required Parameters
echo -e "${BLUE}=== Required Parameters ===${NC}"
echo ""

prompt_input "Path to reference genome FASTA file:" \
    "demo/references/reference.fa" \
    "REFERENCE" \
    validate_file_exists

prompt_input "Input VCF file (variants to act as false positives):" \
    "demo/input_variants/demo_variants.vcf" \
    "INPUT_VCF" \
    validate_file_exists

prompt_input "Mutation input (rate <1, count >=1, or VCF file path):" \
    "2e-6" \
    "MUTATION_INPUT" \
    validate_mutation_input

prompt_input "Coverages (comma-separated: parent1,parent2,offspring):" \
    "10,20,30" \
    "COVERAGES"

prompt_input "Output directory for results:" \
    "output" \
    "OUTPUT_DIR"

# Optional Parameters
echo -e "${BLUE}=== Optional Parameters ===${NC}"
echo ""

prompt_yes_no "Do you want to specify a known variants file for BQSR?" \
    "no" \
    "HAS_KNOWN_VARIANTS"

if [[ "$HAS_KNOWN_VARIANTS" == "yes" ]]; then
    prompt_input "Path to known variants VCF file:" \
        "" \
        "KNOWN_VARIANTS" \
        validate_file_exists
    KNOWN_VARIANTS_FLAG="-KV $KNOWN_VARIANTS"
else
    KNOWN_VARIANTS_FLAG=""
fi

prompt_input "Chromosome/contig list file (one per line, or 'ALL' for all):" \
    "demo/chrom_list.txt" \
    "CHROM_LIST"

prompt_input "Fragment length (mean, in bp):" \
    "300" \
    "FRAGMENT_LENGTH" \
    validate_positive_number

prompt_input "Read length (in bp):" \
    "100" \
    "READ_LENGTH" \
    validate_positive_number

prompt_input "Fragment length standard deviation:" \
    "30" \
    "FRAGMENT_SD" \
    validate_positive_number

prompt_yes_no "Do you want to specify a pedigree?" \
    "yes" \
    "HAS_PEDIGREE"

if [[ "$HAS_PEDIGREE" == "yes" ]]; then
    prompt_input "Pedigree (comma-separated: parent1,parent2,offspring):" \
        "dad,mom,junior" \
        "PEDIGREE"
    PEDIGREE_FLAG="-P \"$PEDIGREE\""
else
    PEDIGREE_FLAG=""
fi

prompt_input "Number of CPU cores to use:" \
    "12" \
    "CPUS" \
    validate_positive_number

prompt_choice "VCF type:" \
    "trio" \
    "VCF_TYPE" \
    "trio" "population"

if [[ "$VCF_TYPE" == "trio" ]]; then
    VCF_TYPE_FLAG="--trio"
else
    VCF_TYPE_FLAG="--population"
fi

prompt_input "Number of iterations:" \
    "1" \
    "NUM_ITERATIONS" \
    validate_positive_number

prompt_input "Working directory:" \
    "work" \
    "WORK_DIR"

# SLURM Parameters
echo -e "${BLUE}=== SLURM Job Submission Parameters ===${NC}"
echo ""

prompt_input "SLURM partition for job submission:" \
    "public" \
    "SLURM_PARTITION"

prompt_input "Time limit (format: days-hours:minutes:seconds or hours:minutes:seconds):" \
    "4-00:00:00" \
    "SLURM_TIME"

prompt_input "SLURM QOS (Quality of Service):" \
    "public" \
    "SLURM_QOS"

prompt_input "SLURM job name:" \
    "detect_workflow" \
    "SLURM_JOBNAME"

# Convert paths to absolute if relative
if [[ "$REFERENCE" != /* ]]; then
    REFERENCE="$BASE_DIR/$REFERENCE"
fi

if [[ "$INPUT_VCF" != /* ]]; then
    INPUT_VCF="$BASE_DIR/$INPUT_VCF"
fi

if [[ "$CHROM_LIST" != "ALL" && "$CHROM_LIST" != /* ]]; then
    CHROM_LIST="$BASE_DIR/$CHROM_LIST"
fi

if [[ "$OUTPUT_DIR" != /* ]]; then
    OUTPUT_DIR="$BASE_DIR/$OUTPUT_DIR"
fi

if [[ "$WORK_DIR" != /* ]]; then
    WORK_DIR="$BASE_DIR/$WORK_DIR"
fi

if [[ -n "$KNOWN_VARIANTS_FLAG" && "$KNOWN_VARIANTS" != /* ]]; then
    KNOWN_VARIANTS="$BASE_DIR/$KNOWN_VARIANTS"
    KNOWN_VARIANTS_FLAG="-KV $KNOWN_VARIANTS"
fi

# Summary
echo ""
echo -e "${BLUE}=== Configuration Summary ===${NC}"
echo -e "Reference genome:    ${GREEN}$REFERENCE${NC}"
echo -e "Input VCF:           ${GREEN}$INPUT_VCF${NC}"
echo -e "Mutation input:      ${GREEN}$MUTATION_INPUT${NC}"
echo -e "Coverages:           ${GREEN}$COVERAGES${NC}"
echo -e "Output directory:    ${GREEN}$OUTPUT_DIR${NC}"
echo -e "Working directory:   ${GREEN}$WORK_DIR${NC}"
echo -e "Chromosome list:     ${GREEN}$CHROM_LIST${NC}"
echo -e "Fragment length:     ${GREEN}$FRAGMENT_LENGTH${NC}"
echo -e "Read length:         ${GREEN}$READ_LENGTH${NC}"
echo -e "Fragment SD:         ${GREEN}$FRAGMENT_SD${NC}"
if [[ -n "$PEDIGREE_FLAG" ]]; then
    echo -e "Pedigree:            ${GREEN}$PEDIGREE${NC}"
fi
if [[ -n "$KNOWN_VARIANTS_FLAG" ]]; then
    echo -e "Known variants:      ${GREEN}$KNOWN_VARIANTS${NC}"
fi
echo -e "CPUs:                ${GREEN}$CPUS${NC}"
echo -e "VCF type:            ${GREEN}$VCF_TYPE${NC}"
echo -e "Iterations:          ${GREEN}$NUM_ITERATIONS${NC}"
echo ""
echo -e "${BLUE}SLURM Parameters:${NC}"
echo -e "Partition:           ${GREEN}$SLURM_PARTITION${NC}"
echo -e "Time limit:          ${GREEN}$SLURM_TIME${NC}"
echo -e "QOS:                 ${GREEN}$SLURM_QOS${NC}"
echo -e "Job name:            ${GREEN}$SLURM_JOBNAME${NC}"
echo ""

prompt_yes_no "Proceed with creating config.sh, run.sh, and sbatch_run.sh?" \
    "yes" \
    "PROCEED"

if [[ "$PROCEED" != "yes" ]]; then
    echo -e "${RED}Aborted.${NC}"
    exit 1
fi

# Create config.sh
echo ""
echo -e "${GREEN}=== Creating config.sh ===${NC}"

cat > config.sh << 'EOF'
#!/bin/bash

module load mamba/latest
source activate sn9detect

BASE="$(pwd)"

python $BASE/DETECT/create_config.py \
  -R __REFERENCE__ \
  -U __MUTATION_INPUT__ \
  -CL __CHROM_LIST__ \
  -FL __FRAGMENT_LENGTH__ -RL __READ_LENGTH__ -SD __FRAGMENT_SD__ \
  __PEDIGREE_FLAG__ \
  -C "__COVERAGES__" \
  -V __INPUT_VCF__ \
  __KNOWN_VARIANTS_FLAG__ \
  --cpus __CPUS__ \
  __VCF_TYPE_FLAG__ \
  --num-iterations __NUM_ITERATIONS__ \
  -WD __WORK_DIR__ \
  -O __OUTPUT_DIR__

EOF

# Substitute placeholders in config.sh
sed -i \
    -e "s|__REFERENCE__|$REFERENCE|g" \
    -e "s|__MUTATION_INPUT__|$MUTATION_INPUT|g" \
    -e "s|__CHROM_LIST__|$CHROM_LIST|g" \
    -e "s|__FRAGMENT_LENGTH__|$FRAGMENT_LENGTH|g" \
    -e "s|__READ_LENGTH__|$READ_LENGTH|g" \
    -e "s|__FRAGMENT_SD__|$FRAGMENT_SD|g" \
    -e "s|__PEDIGREE_FLAG__|$PEDIGREE_FLAG|g" \
    -e "s|__COVERAGES__|$COVERAGES|g" \
    -e "s|__INPUT_VCF__|$INPUT_VCF|g" \
    -e "s|__KNOWN_VARIANTS_FLAG__|$KNOWN_VARIANTS_FLAG|g" \
    -e "s|__CPUS__|$CPUS|g" \
    -e "s|__VCF_TYPE_FLAG__|$VCF_TYPE_FLAG|g" \
    -e "s|__NUM_ITERATIONS__|$NUM_ITERATIONS|g" \
    -e "s|__WORK_DIR__|$WORK_DIR|g" \
    -e "s|__OUTPUT_DIR__|$OUTPUT_DIR|g" \
    config.sh

# Clean up empty flags
sed -i 's/  \+/ /g' config.sh

chmod +x config.sh

echo -e "${GREEN}Created config.sh${NC}"

# Create run.sh
echo -e "${GREEN}=== Creating run.sh ===${NC}"

cat > run.sh << 'EOF'
#!/bin/bash

# DETECT Workflow Execution Script
# Generated by create_config.sh

set -euo pipefail

echo "=========================================="
echo "  Running DETECT Workflow"
echo "=========================================="
echo ""

# Step 1: Generate config.json
echo "Step 1: Generating config.json..."
bash config.sh

if [ ! -f "__WORK_DIR__/config/config.json" ]; then
    echo "ERROR: config.json was not created successfully"
    exit 1
fi

echo "✓ Config created successfully"
echo ""

# Step 2: Run Snakemake workflow
echo "Step 2: Starting DETECT Snakemake workflow..."
echo ""

module load mamba/latest
source activate sn9detect

snakemake -p \
  --profile profiles/slurm \
  --configfile __WORK_DIR__/config/config.json \
  -s DETECT/Snakefile

echo ""
echo "=========================================="
echo "  DETECT Workflow Complete"
echo "=========================================="
echo "Results in: __OUTPUT_DIR__"

EOF

# Substitute work dir and output dir in run.sh
sed -i \
    -e "s|__WORK_DIR__|$WORK_DIR|g" \
    -e "s|__OUTPUT_DIR__|$OUTPUT_DIR|g" \
    run.sh

chmod +x run.sh

echo -e "${GREEN}Created run.sh${NC}"

# Create sbatch_run.sh
echo -e "${GREEN}=== Creating sbatch_run.sh ===${NC}"

cat > sbatch_run.sh << 'EOF'
#!/bin/bash
#SBATCH -n 1
#SBATCH -c 2
#SBATCH -t __SLURM_TIME__
#SBATCH -p __SLURM_PARTITION__
#SBATCH -q __SLURM_QOS__
#SBATCH --job-name=__SLURM_JOBNAME__
#SBATCH -o o-%j.out
#SBATCH -e e-%j.err

# DETECT Workflow Execution Script (SLURM Batch Mode)
# Generated by create_config.sh

set -euo pipefail

echo "=========================================="
echo "  Running DETECT Workflow (SLURM Batch)"
echo "=========================================="
echo ""

# Step 1: Generate config.json
echo "Step 1: Generating config.json..."
bash config.sh

if [ ! -f "__WORK_DIR__/config/config.json" ]; then
    echo "ERROR: config.json was not created successfully"
    exit 1
fi

echo "✓ Config created successfully"
echo ""

# Step 2: Run Snakemake workflow
echo "Step 2: Starting DETECT Snakemake workflow..."
echo ""

module load mamba/latest
source activate sn9detect

snakemake -p \
  --profile profiles/slurm \
  --configfile __WORK_DIR__/config/config.json \
  -s DETECT/Snakefile

echo ""
echo "=========================================="
echo "  DETECT Workflow Complete"
echo "=========================================="
echo "Results in: __OUTPUT_DIR__"

EOF

# Substitute placeholders in sbatch_run.sh
sed -i \
    -e "s|__SLURM_TIME__|$SLURM_TIME|g" \
    -e "s|__SLURM_PARTITION__|$SLURM_PARTITION|g" \
    -e "s|__SLURM_QOS__|$SLURM_QOS|g" \
    -e "s|__SLURM_JOBNAME__|$SLURM_JOBNAME|g" \
    -e "s|__WORK_DIR__|$WORK_DIR|g" \
    -e "s|__OUTPUT_DIR__|$OUTPUT_DIR|g" \
    sbatch_run.sh

chmod +x sbatch_run.sh

echo -e "${GREEN}Created sbatch_run.sh${NC}"
echo ""

# Success message
echo -e "${GREEN}=========================================="
echo "  Success!"
echo "==========================================${NC}"
echo ""
echo "Created files:"
echo "  - config.sh        (generates config.json)"
echo "  - run.sh           (executes workflow interactively on login node)"
echo "  - sbatch_run.sh    (submits workflow as SLURM batch job)"
echo ""
echo "Next steps:"
echo ""
echo "Option 1: Interactive execution (runs Snakemake on login node)"
echo "  1. Review config.sh to verify parameters"
echo "  2. Run: ./run.sh"
echo ""
echo "Option 2: SLURM batch submission (recommended for long workflows)"
echo "  1. Review config.sh and sbatch_run.sh to verify parameters"
echo "  2. Run: sbatch sbatch_run.sh"
echo "  3. Monitor: squeue -u \$USER  (or 'snakejobs' for rule names)"
echo ""
echo "Both scripts will:"
echo "  - Generate config.json from config.sh"
echo "  - Execute the DETECT workflow with Snakemake"
echo "  - Submit individual rules as SLURM jobs via profiles/slurm"
echo ""
