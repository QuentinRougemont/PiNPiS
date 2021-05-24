#!/bin/bash
#SBATCH -J "fasta2CDS"
#SBATCH -o log_%j
#SBATCH -c 1
#SBATCH -p small
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=YOUREMAIL
#SBATCH --time=24:00:00
#SBATCH --mem=8G

# Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR


./00_scripts/scripts_wgs/05_vcf2fasta_to_CDSstats.sh
