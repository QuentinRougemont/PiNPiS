# TL - 011219
# QR - 021219

#DEFINE GLOBAL VARIABLE
file_path="$(pwd)" #path to cwd

rawvcf=$1           #vcf cds file #without vcf header
rawvcf=${file_path}/$rawvcf

vcfheader=$2        #path to header #uncompressed vcfheader  #contain name of individuals
vcfheader=${file_path}/$vcfheader

vcffile="$rawvcf".reproj.clean.withheader

prefix=$3          #name of the pop
outputdirscaffolds="$prefix"_v3_fastafiles

outprefix="$prefix"_v3_withoutquantiles

#here check that the input file are provided
if [ -z "$rawvcf" ]
then
    echo "Error: need cds rawvcf file name"
    exit
fi

if [ -z "$vcfheader" ]
then
    echo "Error: need vcfheader"
    exit
fi

if [ -z "$prefix" ]
then
    echo "Error: need population name prefix"
    exit
fi


# define file & directory names (full path)
gfffile=$($file_path/gff/gff)
cutoffcovmin=$(echo "3") # note that this is an absolute cutoff and can be adjusted for each individual to higher values based on the distrib of coverage over the genome

# generate input files
python2 ${file_path}/00.scripts/reproj_vcf.py ${file_path}/vcf_genes/GCF_002021735.1_Okis_V1_genomic.gff.sed.withoutheader.gene.filtered.agp2_part1 $rawvcf.part1
python2 ${file_path}/00.scripts/reproj_vcf.py ${file_path}/vcf_genes/GCF_002021735.1_Okis_V1_genomic.gff.sed.withoutheader.gene.filtered.agp2_part2 $rawvcf.part2
python2 ${file_path}/00.scripts/reproj_vcf.py ${file_path}/vcf_genes/GCF_002021735.1_Okis_V1_genomic.gff.sed.withoutheader.gene.filtered.agp2_part3 $rawvcf.part3
python2 ${file_path}/00.scripts/reproj_vcf.py ${file_path}/vcf_genes/GCF_002021735.1_Okis_V1_genomic.gff.sed.withoutheader.gene.filtered.agp2_part4 $rawvcf.part4
python2 ${file_path}/00.scripts/reproj_vcf.py ${file_path}/vcf_genes/GCF_002021735.1_Okis_V1_genomic.gff.sed.withoutheader.gene.filtered.agp2_part5 $rawvcf.part5
python2 ${file_path}/00.scripts/reproj_vcf.py ${file_path}/vcf_genes/GCF_002021735.1_Okis_V1_genomic.gff.sed.withoutheader.gene.filtered.agp2_part6 $rawvcf.part6

cat $rawvcf.part1.reproj $rawvcf.part2.reproj $rawvcf.part3.reproj $rawvcf.part4.reproj $rawvcf.part5.reproj $rawvcf.part6.reproj > $rawvcf.reproj

awk '{$3 = ""; $4 = ""; print $0}' $rawvcf.reproj | sed 's/ \+/\t/g' > $rawvcf.reproj.clean
cat $vcfheader $rawvcf.reproj.clean > $vcffile

# MAIN
### VCF2Fasta (GENERATE ALIGNED FASTA SEQUENCES 2xNbInd for each scaffold)
if [ -d "$outputdirscaffolds" ]; then
    rm $outputdirscaffolds/*.fst
else
    mkdir "$outputdirscaffolds"
fi

cd $outputdirscaffolds
python ${file_path}/00.scripts/VCF2Fasta_fast_CohoRADseqVersion.py -m $cutoffcovmin -f $vcffile > Outputs_VCF2Fasta.txt
cd ..

### GET FASTA ON CDS
#awk '$3 == "CDS" {print $0}' $gfffile | awk '{print $1}' | sort | uniq > $gfffile.scaffIDwithCDS

outputdirCDS=$(echo "$outputdirscaffolds" | sed 's/fastafiles/fastafiles_CDS/g')
if [ -d "$outputdirCDS" ]; then
    rm $outputdirCDS/*.fst
else
    mkdir "$outputdirCDS"
fi
cd $outputdirCDS
while read line; do python ${file_path}/00.scripts/scutSeqGff.py $outputdirscaffolds/$line.fst $gfffile $line CDS; done < $gfffile.scaffIDwithCDS
for i in *.fst; do 
    missing=$(grep -e "^$" $i | wc -l) # lines withoutinfo
    #echo "$missing"
    if [ "$missing" == "0" ]; then
        continue
        #echo "no missing"
    else
        rm $i
        #echo "missing"
    fi
    missing=$(echo "bidon") 
done
cd ..

### FILTER ALIGNMENTS & COMPUTE STATS
## list of all fasta CDS
ls $outputdirCDS/ | grep ".fst" > $outprefix.list_CDS.txt
cd $outputdirCDS
# remove last codon
${file_path}/00.scripts/removeLastStopCodon -seq ../$outprefix.list_CDS.txt -f fasta -code univ
cd ..

cd $outputdirCDS
for i in *.fst; do
    missing=$(grep -e "^$" $i | wc -l) # lines withoutinfo
    #echo "$missing"
    if [ "$missing" == "0" ]; then
        continue
        #echo "no missing"
    else
        rm $i
        #echo "missing"
    fi
    missing=$(echo "bidon")
done
cd ..

## generate a new list with processed alignments
ls $outputdirCDS/ | grep ".fst.clean.fst" > $outprefix.list_CDS.txt
## clean alignments
cd $outputdirCDS
${file_path}/00.scripts/cleanAlignment -seq ../$outprefix.list_CDS.txt -f fasta -n 4
cd ..

cd $outputdirCDS
for i in *.fst; do
    missing=$(grep -e "^$" $i | wc -l) # lines withoutinfo
    #echo "$missing"
    if [ "$missing" == "0" ]; then
        continue 
        #echo "no missing"
    else
        rm $i
        #echo "missing"
    fi
    missing=$(echo "bidon")
done
cd ..

## generate a new list with processed alignments
ls $outputdirCDS/ | grep ".fst.clean.fst.clean.fst" > $outprefix.list_CDS.txt
## compute summary statistics (-tstv = transition transervision ratio here fixed to 2 but can be set to another value)
cd $outputdirCDS
${file_path}/00.scripts/seq_stat_coding -seq ../$outprefix.list_CDS.txt -f fasta -tstv 2 -code univ -o ../$outprefix.CDS.sumstats > ../$outprefix.CDS.sumstats.info
cd ..

# keep info of genes without premature stop codons
grep "stop" $outprefix.CDS.sumstats.info | awk '{print $1}' > $outprefix.CDS.withprematurestopcodons
### compute GC3s based on 4-fold degenerate sites (also includes prot alignments)
outputdir4fold=$(echo "$outputdirscaffolds" | sed 's/fastafiles/fastafiles_4fold/g')
if [ -d "$outputdir4fold" ]; then
    rm $outputdir4fold/*
else
    mkdir "$outputdir4fold"
fi

outputdirprot=$(echo "$outputdirscaffolds" | sed 's/fastafiles/fastafiles_prot/g') 
if [ -d "$outputdirprot" ]; then
    rm $outputdirprot/*
else
     mkdir "$outputdirprot"
fi

# parse sequences containing 4 fold codons only
cd $outputdirCDS
rm ../$outprefix.list_CDS.4fold
while read line; do
    python ${file_path}/00.scripts/script_python_sequencecodons4folddegenerateonly.py $line $line
    mv $line.sites4foldonly $outputdir4fold/
    mv $line.prot $outputdirprot/
    echo "$outputdir4fold/$line.sites4foldonly" >> ../$outprefix.list_CDS.4fold # generate a list
done < ../$outprefix.list_CDS.txt

# clean alignments
cd $outputdir4fold
${file_path}/00.scripts//cleanAlignment -seq ../$outprefix.list_CDS.4fold -f fasta -n 4
ls $outputdir4fold/ | grep ".sites4foldonly.clean.fst" > ../$outprefix.list_CDS.4fold

# compute GC3s
${file_path}/00.scripts/seq_stat_coding -seq ../$outprefix.list_CDS.4fold -f fasta -tstv 2 -code univ -o ../$outprefix.4fold.CDS.sumstats
cd ..
awk '{print $1"	"$2"	"$3"	"$11}' $outprefix.4fold.CDS.sumstats | sed 's/GC3/GC3s/g' > $outprefix.4fold.CDS.sumstats.GC3s
### merge pnps datasets & GC3s [require to exclude GC3s for seq with premature stop codons]
echo "name	Size	N	S	P	W	Ps	Pn	NbSS	D_Taj	GC3	name2	Size4fold	N4fold	GC3s" > $outprefix.4fold.CDS.sumstats.final
less $outprefix.4fold.CDS.sumstats.GC3s | grep -v "Size" > tmp

while read line; do
    grep -v "$line" tmp > tmp2
    mv tmp2 tmp
done < $outprefix.CDS.withprematurestopcodons

grep -v "Size" $outprefix.CDS.sumstats > tmp2

paste tmp2 tmp >> $outprefix.4fold.CDS.sumstats.final # please check that this output is correct
rm tmp*
