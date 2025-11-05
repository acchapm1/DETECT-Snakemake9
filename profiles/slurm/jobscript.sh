#!/bin/bash
# properties = {"cluster": {"jobname": "{rulename}.{jobid}", "partition": "{resources.partition}", "mem": "{resources.mem_mb}", "time": "{resources.time_min}", "cpus": "{resources.cpus}"}}

#SBATCH --job-name={rulename}.{jobid}
#SBATCH --partition={resources.partition}
#SBATCH --mem={resources.mem_mb}
#SBATCH --time={resources.time_min}
#SBATCH --cpus-per-task={resources.cpus}
#SBATCH --output=logs/{rulename}.{jobid}.%j.out
#SBATCH --error=logs/{rulename}.{jobid}.%j.err


{resources.shellcmd}
