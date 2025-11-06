# DETECT using Snakemake 9

Tested with the latest version of Snakemake available 9.13.4 (11-04-2025)

To build the Conda env on Sol use:
```shell
module load mamba/latest
mamba env create --file DETECT/DETECT.yml
```

## SLURM Configuration

### Job Names in Snakemake 9 vs Snakemake 7

**Important Breaking Change:** In Snakemake 8+, SLURM job names cannot be customized and appear as UUIDs (e.g., `f48e0cfd-54ec-48b9-8857-eee71371cded`) instead of rule names. This is a design decision by the SLURM executor plugin, which uses unique job names for internal job tracking.

In Snakemake 7, rule names were displayed as SLURM job names. This is **no longer possible** in Snakemake 8+.

### Viewing Rule Names in squeue

Snakemake stores the rule name and wildcards in the SLURM job's **comment** field. To view rule names when checking job status, use the comment field (`%k`) in your squeue output format:

```shell
# View jobs with rule names in the comment field
squeue -u acchapm1 -o "%.18i %.9P %.40k %.8u %.2t %.10M"
```

Where:
- `%.18i` = Job ID
- `%.9P` = Partition
- `%.40k` = Comment field (contains rule name and wildcards)
- `%.8u` = User
- `%.2t` = State
- `%.10M` = Time used

For running jobs, you can also use:
```shell
squeue -u acchapm1 -o "%i,%P,%.10j,%.40k"
```

The comment field width can be adjusted (e.g., `%.40k` for 40 characters, `%.60k` for 60 characters) depending on your rule naming conventions.

### Alternative: Create a Custom myjobs Script

If your cluster's `myjobs` script doesn't show rule names, create a wrapper script:

```bash
#!/bin/bash
# Save as ~/bin/snakejobs or similar
squeue -u $USER -o "%.18i %.9P %.40k %.8u %.2t %.10M %.6D %R"
```

Make it executable: `chmod +x ~/bin/snakejobs`

See DETECT/README.md for more information. 
