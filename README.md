# PiNPiS

computation of $\frac{$\pi$_{N}}{$\pi$_{S}}$  for Whole Genome data

$\pi$


This was used in this [paper](https://www.biorxiv.org/content/10.1101/732750v3) looking at expansion load in coho salmon

# Purpose
Computing $\pi$N/$\pi$S ratio from Whole Genome data and eventually RAD sequencing data of high quality.

# Input file:
* compressed vcf file obtained after running [GATK](https://gatk.broadinstitute.org/hc/en-us) it must include variants and invariants sites for all genes (option --all-site in gatk).  
For instance I used a modification of this [pipline](https://github.com/QuentinRougemont/gatk_haplotype)  
For RADseq, the sequencing data falling into the genes can be intersected with [bedtools](https://bedtools.readthedocs.io/en/latest/content/tools/intersect.html) intersect fonction for instance.

* gff file for the studied species

# Dependencies

* python2
* Linux

# Running :

1. first split the vcf file with ***./00.scripts/00.script_split_vcf.sh input_file.vcf.gz***
the scripts will need to be modified depending on the species genome
2. run ***./00.scripts/01.script_lanceur_vcf2fasta_to_CDSfasta_arg.sh input.cds.vcf vcfheader pop***
where :
* `input.cds.vcf` is the input vcf file containing gene only (without header)
* `vcfheader` : the vcf header
* `pop` : a name for the population
