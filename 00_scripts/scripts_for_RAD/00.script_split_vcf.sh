#!/bin/bash 
#TL + QR

inputvcf=$1 #the cds vcf file
#test if inputfile is present
if [ -z "$file" ]
then
    echo "Error: need cds vcf file name (eg: sample1.cds.gz)"
    exit
fi

gunzip $inputvcf.gz

#split according to scaffold name of the Coho
#this have to be changed depending on you reference genome and coordinates:
sed '/NC_034177\.1	75276997/q' $inputvcf > $inputvcf.part1
sed -n '/NC_034177\.1	75276997/,/NC_034182\.1	5580203/p' $inputvcf | sed '1d' > $inputvcf.part2
sed -n '/NC_034182\.1	5580203/,/NC_034186\.1	58514866/p' $inputvcf |  sed '1d' > $inputvcf.part3
sed -n '/NC_034186\.1	58514866/,/NC_034191\.1	43637264/p' $inputvcf | sed '1d' > $inputvcf.part4
sed -n '/NC_034191\.1	43637264/,/NC_034198\.1	645148/p' $inputvcf | sed '1d' > $inputvcf.part5
sed -n '/NC_034198\.1	645148/,/NC_009263\.1 16518/p' $inputvcf | sed '1d' > $inputvcf.part6
