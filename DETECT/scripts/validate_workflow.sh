#!/usr/bin/env bash
set -euo pipefail

CORES=4
SNAKEFILE="Snakefile"
CONFIG="demo/demo_workdir/config/config.json"
USE_PROFILE=0

usage() {
  cat <<'EOF'
Usage: scripts/validate_workflow.sh [-c config.json] [-s Snakefile] [-j cores] [-p]

Checks Snakemake version, runs lint, and performs dry-runs.

Options:
  -c  Path to config.json (default: demo/demo_workdir/config/config.json)
  -s  Path to Snakefile (default: Snakefile)
  -j  Cores/jobs for dry-run (default: 4)
  -p  Also dry-run using the SLURM profile at profiles/slurm
  -h  Show this help
EOF
}

while getopts ":c:s:j:ph" opt; do
  case $opt in
    c) CONFIG="$OPTARG" ;;
    s) SNAKEFILE="$OPTARG" ;;
    j) CORES="$OPTARG" ;;
    p) USE_PROFILE=1 ;;
    h) usage; exit 0 ;;
    \?) echo "Invalid option -$OPTARG" >&2; usage; exit 2 ;;
    :) echo "Option -$OPTARG requires an argument." >&2; usage; exit 2 ;;
  esac
done

if ! command -v snakemake >/dev/null 2>&1; then
  echo "Error: snakemake not found in PATH. Activate the DETECT conda env first." >&2
  exit 1
fi

echo "Snakemake version: $(snakemake --version)"

echo "[1/3] Linting workflow..."
snakemake --lint -s "$SNAKEFILE" --configfile "$CONFIG"

if [ ! -f "$CONFIG" ]; then
  echo "Config not found: $CONFIG" >&2
  echo "Generate one with create_config.py (see README) or pass -c <path>." >&2
  exit 1
fi

echo "[2/3] Dry-run (local)..."
mkdir -p logs || true
snakemake -n -p -s "$SNAKEFILE" --cores "$CORES" --configfile "$CONFIG"

if [ "$USE_PROFILE" -eq 1 ]; then
  if [ -d "profiles/slurm" ]; then
    echo "[3/3] Dry-run (SLURM profile)..."
    snakemake -n -p -s "$SNAKEFILE" --configfile "$CONFIG" --profile profiles/slurm -j "$CORES"
  else
    echo "profiles/slurm not found; skipping profile dry-run." >&2
  fi
else
  echo "[3/3] Profile dry-run skipped (pass -p to enable)."
fi

echo "Success: lint and dry-run completed."
