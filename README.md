# PiNPiS

computation of 	&pi;N /	&pi;S for Whole Genome data



This was used in this [paper](https://www.biorxiv.org/content/10.1101/732750v3) looking at expansion load in coho salmon

# Purpose
Computing 	&pi;N /	&pi;S ratio from Whole Genome data and eventually RAD sequencing data of high quality.

# Input file:
* compressed vcf file obtained after running [GATK](https://gatk.broadinstitute.org/hc/en-us) it must include variants and invariants sites for all genes (option --all-site in gatk).  
For instance I used a modification of this [pipline](https://github.com/QuentinRougemont/gatk_haplotype)  
For RADseq, the sequencing data falling into the genes can be intersected with [bedtools](https://bedtools.readthedocs.io/en/latest/content/tools/intersect.html) intersect fonction for instance.

* gff file for the studied species

# Dependencies

* python2
* Linux

# Running :

## Procedure for Whole Genome data  

1. first split the vcf file by chromosome :
```./00_scripts/00_scripts_wgs/01.extract.sh <vcf> <chrlist>```

where:
* vcf is the vcf file (comressed or not)
* chrlist is the list of chromosome

This save time when converting vcf into fasta by running several instance of the same script in parallel for each chromosome

## Note: the same results can be achieved (probably faster) with bcftools :  
something like this should work:

```for chr in $(cat list_of_chromosome.txt ) ; do bcftools view --regions $chr -Oz -o $chr.vcf.gz your.vcf.gz ; done``` 

this requires a compressed and indexed vcf

2. convert into fasta:  
```./00_scripts/00_scripts_wgs/02_vcf2fasta.sh <vcf> <min_qual> <min_cov> <max_cov> ```

where:  
* vcf is the vcf splitted by chromosome
* min_qual is the minimum quality (20 or 30)
* min_cov is the minimum coverage of a site
* max_cov is the max coverage of a site

This steps takes several hours when processing a whole genome. Splitting by chromosome and running in parallel greatly reduce computing time.  
The memory requirement of this step can be around 80Go.

3. (recompress the vcf to save space)  
 
```/00_scripts/00_scripts_wgs/03.compress.sh``` 

4. extract the cdsID from the gff:  
 
```./00_scripts/00_scripts_wgs/04_prepare_gff.sh <gff>``` 

/!\ warning:  make sure that each CDS has a unique ID in column 9 of the GFF.

5. Extract the cds from all fasta and compute the pnps and gc3 value for each cds: 
```./00_scripts/00_scripts_wgs/05_fasta_to_CDS_to_stats.sh <gff>```  

Note: there is also an exemple script to run this part on a cluster (see ```00_scripts/00_scripts_wgs/05_slurm_submission_fasta_to_CDS_to_stats.sh ```)  
It can be easily modify to run the previous step on a cluster as well

As previously computing this by chromosome will greatly decrease run time.  
Depending on the dataset size up to 20Go of memory are necessarry

6. Summarize and plot the results:  
#see:
```00_scripts/01_scripts_summarise/00_script_generate_piNpiS.sh```  

#other scripts will arrive soon

TO DO



## ------------- DEPRECATED --------------- ##
## procedure for GBS/RADseq data

# WARNINGS: 
/!\ UNLESS you have very polymorphic species with many SNPs in the genes I would not recommend tihs anymore 
/!\ warning: this procedure was customized to work on Coho salmon on a previous draft reference genome. 
Adjustement are needed to work on other data. 

1. run: 
```00_scripts/scripts_for_RAD/00.script_split_vcf.sh ``` 
to split the vcf into chunks

2. run :  
```./00_scripts/scripts_for_RDA/01.script_lanceur_vcf2fasta_to_CDSfasta_arg.sh input.cds.vcf vcfheader pop ```
where :
* `input.cds.vcf` is the input vcf file containing gene only (without header)
* `vcfheader` : the vcf header
* `pop` : a name for the population

as you'll see the gff were modified with some reprojection as seen here: 
```python2 ${file_path}/00_scripts/scripts_for_RAD//reproj_vcf.py ${file_path}/vcf_genes/GCF_002021735.1_Okis_V1_genomic.gff.sed.withoutheader.gene.filtered.agp2_part1 ```

overall this pipeline for GBS certainly needs several customizations


