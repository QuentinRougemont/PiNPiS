#!/bin/bash                            
#Date: 24-01-2021
#purpose; convert vcf to fasta


if [ $# -ne 4 ]; then
    echo "Usage: $(basename $0) <vcf> <min_qual> <min_cov> <max_cov> " >&2
    echo "vcf : vcf file"
    echo "NOTE: must be an outpout from gatk, must contain all sites with flag indicating lowQ variants/samples"
    exit 1
else
    #Using values from the command line
    vcf=$1        #name of the vcf filr
    min_qual=$2
    min_cov=$3
    max_cov=$4
    echo "vcf file is = $vcf"
fi

# create the outputfile, report an error if this directory already exists
outputdir="OUTPUT" 
if [ ! -d $outputdir  ]; then
    mkdir -p $outputdir
fi

echo "file is" $file
echo "output file to:" $outputdir
echo "min qual : $min_qual"
echo "covmin/covmax are: $min_cov / $max_cov"
echo "
python2 ./00_scripts/VCF2Fasta_fast.py -q $min_qual -m $min_cov -M $max_cov -f ${file%} > $outputdir/Outputs_VCF2Fasta.txt
"
infiledir=$(dirname "${file}")
infilename=$(basename "${file}")

#check compression
if file --mime-type "$vcf" | grep -q gzip$; then
    echo "$vcf is gzipped"
    file=${vcf}

    ## generating fasta files
    echo "[INFO] starting to create fasta files from VCFs"
    python2 00_scripts/VCF2Fasta_fast.py -q $min_qual -m $min_cov -M $max_cov -f ${file} > $outputdir/Outputs_VCF2Fasta.txt
    echo "[INFO] fasta files created"
    time=$(date)
    echo "[INFO] Computations performed succesfully - this script finished at $time"
    echo "############################################################################################"
    
else

   echo "$vcf is not gzipped"
   file=$vcf 
   python2 00_scripts/VCF2Fasta_fast_zip.py -q $min_qual -m $min_cov -M $max_cov -f ${file} > $outputdir/Outputs_VCF2Fasta.txt

fi
