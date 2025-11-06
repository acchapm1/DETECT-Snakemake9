#!/bin/bash

# Test configuration by running create_config.py in dry-run mode
# This validates your config.sh without actually running the workflow

set -euo pipefail

if [ ! -f "config.sh" ]; then
    echo "ERROR: config.sh not found in current directory"
    echo "Please run 'bash scripts/create_config.sh' first"
    exit 1
fi

echo "=========================================="
echo "  Testing DETECT Configuration"
echo "=========================================="
echo ""

# Run config.sh to generate config.json
echo "Step 1: Generating config.json..."
bash config.sh

if [ ! -f "work/config/config.json" ]; then
    echo "ERROR: config.json was not created"
    exit 1
fi

echo "✓ config.json created successfully"
echo ""

# Display the config
echo "Step 2: Validating configuration..."
echo ""
cat work/config/config.json
echo ""

# Test Snakemake workflow with dry-run
echo "Step 3: Testing Snakemake workflow (dry-run)..."
echo ""

module load mamba/latest
source activate sn9detect

snakemake -n -p \
  --profile profiles/slurm \
  --configfile work/config/config.json \
  -s DETECT/Snakefile

echo ""
echo "=========================================="
echo "  Configuration Test Complete"
echo "=========================================="
echo ""
echo "If no errors appeared above, your configuration is valid."
echo "Run './run.sh' to execute the actual workflow."
echo ""
