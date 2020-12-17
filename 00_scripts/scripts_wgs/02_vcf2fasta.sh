#!/bin/bash                            
#source /clumeq/bin/enable_cc_cvmfs    
#source /rap/ihv-653-ab/quentin/01.laben/DemographicInference/temp/bin/activate

if [ $# -ne 1 ]; then
    echo "Usage: $(basename $0) <vcf> " >&2
    echo "vcf : vcf file"
    echo "    NOTE: must be an outpout from gatk, contain all site with flag indicating lowQ variants/samples"
    exit 1
else
        #Using values from the command line
        vcf=$1        #name of the bam one by individual
        echo "vcf file is = $vcf"
fi

file=$vcf 
outputdir="OUTPUT" 
cutoffquality=20  #these are normally to be passed as arguments 
cutoffcovmin=3 
cutoffcovmax=100 
echo "file is" $file
echo "output file to:" $outputdir
echo "min qual : $cutoffquality"
echo "covmin/covmax: $cutoffcovmin $cutoffcovmax"
echo "
python2 ../00_scripts/01_scripts/VCF2Fasta_fast.py -q $cutoffquality -m $cutoffcovmin -M $cutoffcovmax -f ${file%} > $outputdir/Outputs_VCF2Fasta.txt
"
infiledir=$(dirname "${file}")
infilename=$(basename "${file}")

# create the outputfile, report an error if this directory already exists
if [ ! -d $outputdir  ]; then
    mkdir -p $outputdir
fi

### generating fasta files
echo "[INFO] starting to create fasta files from VCFs"
python2 00_scripts/VCF2Fasta_fast.py -q $cutoffquality -m $cutoffcovmin -M $cutoffcovmax -f ${file%} > $outputdir/Outputs_VCF2Fasta.txt
echo "[INFO] fasta files created"
time=$(date)
echo "[INFO] Computations performed succesfully - this script finished at $time"
echo "############################################################################################"





