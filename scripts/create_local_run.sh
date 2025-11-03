#!/bin/bash

# Interactive script to create local.sh run script
# Prompts for all configuration parameters needed for DETECT workflow

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to prompt for input with default value
prompt_input() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"
    
    echo -e "${YELLOW}$prompt${NC}"
    if [[ -n "$default" ]]; then
        echo -e "Default: ${GREEN}$default${NC}"
    fi
    read -p "> " input
    
    if [[ -z "$input" && -n "$default" ]]; then
        input="$default"
    fi
    
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
        echo -e "${YELLOW}$prompt${NC}"
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

echo -e "${GREEN}=== DETECT Local Run Script Generator ===${NC}"
echo ""
echo "This script will create a local.sh run script by prompting for all required parameters."
echo "Press Enter to use the default values shown in green."
echo ""

# Prompt for all parameters
prompt_input "Path to reference FASTA file:" "demo/references/reference.fa" "REFERENCE"
prompt_input "Mutation rate (e.g., 2e-6):" "2e-6" "MUTATION_RATE"
prompt_input "Path to chromosome list file:" "demo/chrom_list.txt" "CHROM_LIST"
prompt_input "Fragment length (mean):" "300" "FRAGMENT_LENGTH"
prompt_input "Read length:" "100" "READ_LENGTH"
prompt_input "Fragment length standard deviation:" "30" "FRAGMENT_SD"
prompt_input "Pedigree (comma-separated: sire,dam,offspring):" "dad,mom,junior" "PEDIGREE"
prompt_input "Coverages (comma-separated: sire,dam,offspring):" "10,20,30" "COVERAGES"
prompt_input "Path to input VCF file:" "demo/input_variants/demo_variants.vcf" "INPUT_VCF"
prompt_input "Number of CPUs to use:" "12" "CPUS"
prompt_yes_no "Is this a trio analysis?" "yes" "IS_TRIO"
prompt_input "Number of iterations:" "1" "NUM_ITERATIONS"
prompt_input "Working directory:" "work" "WORK_DIR"
prompt_input "Output directory:" "output" "OUTPUT_DIR"

# Set trio flag based on response
if [[ "$IS_TRIO" == "yes" ]]; then
    TRIO_FLAG="--trio"
else
    TRIO_FLAG=""
fi

echo -e "${GREEN}=== Creating local.sh script ===${NC}"

# Use sed to substitute placeholders in the template
sed -e "s|__REFERENCE__|$REFERENCE|g" \
    -e "s|__MUTATION_RATE__|$MUTATION_RATE|g" \
    -e "s|__CHROM_LIST__|$CHROM_LIST|g" \
    -e "s|__FRAGMENT_LENGTH__|$FRAGMENT_LENGTH|g" \
    -e "s|__READ_LENGTH__|$READ_LENGTH|g" \
    -e "s|__FRAGMENT_SD__|$FRAGMENT_SD|g" \
    -e "s|__PEDIGREE__|$PEDIGREE|g" \
    -e "s|__COVERAGES__|$COVERAGES|g" \
    -e "s|__INPUT_VCF__|$INPUT_VCF|g" \
    -e "s|__CPUS__|$CPUS|g" \
    -e "s|__TRIO_FLAG__|$TRIO_FLAG|g" \
    -e "s|__NUM_ITERATIONS__|$NUM_ITERATIONS|g" \
    -e "s|__WORK_DIR__|$WORK_DIR|g" \
    -e "s|__OUTPUT_DIR__|$OUTPUT_DIR|g" \
    run.tmpl > local.sh

# Make the script executable
chmod +x local.sh

echo -e "${GREEN}=== Success! ===${NC}"
echo "Created local.sh script with your configuration."
echo "You can now run: ./local.sh"
echo ""
echo -e "${YELLOW}Configuration summary:${NC}"
echo "Reference: $REFERENCE"
echo "Mutation rate: $MUTATION_RATE"
echo "Pedigree: $PEDIGREE"
echo "Coverages: $COVERAGES"
echo "Working directory: $WORK_DIR"
echo "Output directory: $OUTPUT_DIR"