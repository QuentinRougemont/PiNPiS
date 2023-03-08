#!/bin/bash                                  

#note: bcftools can do the same, probably faster. 

if [ $# -ne 2 ]; then
    echo "Usage: $(basename $0) <vcf> <chrlist>" >&2
    echo "purpose: extract each chromosome from a vcf file"
    echo "vcf : vcf file"
    echo "NOTE: must be an outpout from gatk, contain all site with flag indicating lowQ variants/samples"
    echo "chrlist : list of chromosome on which to run separate instance of gatk"
    exit 1
else
        #Using values from the command line
        vcf=$1    #name of the vcf file
        echo "vcf file is = $vcf"
        chr=$2    #list of chromosomes
        echo "chromosome list is = $chr"
fi

head -n 10000 $vcf |grep "^#" > header

#check compression
if file --mime-type "$vcf" | grep -q gzip$; then
   echo "$vcf is gzipped"
   for i in $(cat $chr ) ; do 
      zcat $vcf |grep "^$i"  > $i.tmp
      cat header $i.tmp >${vcf%.vcf.gz}.$i.vcf
   done
else
   echo "$vcf is not gzipped"
   for i in $(cat $chr ) ; do 
      grep "^$i" $vcf > $i.tmp
      cat header $i.tmp >${vcf%.vcf}.$i.vcf
   done
fi

rm *tmp

