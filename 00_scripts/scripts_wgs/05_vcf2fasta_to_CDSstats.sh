#!/bin/bash

#script to convert fasta to CDS, clean CDS and compute GC3 and pn/ps
# define file & directory names (full path)

gff=$1 #gffile
gfffile=$(echo $(readlink -f $gff )) 
scaffolds=$(echo "fasta_files_withoutquantiles_scaffold")

#outputdirscaffolds=$(echo "$path"/"$scaffolds" )
outputdirscaffolds=$(echo $(readlink -f $scaffolds ))
outprefix=$(echo "POP_withoutquantiles")

echo $outputdirscaffolds
echo $gfffile

outputdirCDS=$(echo "$outputdirscaffolds" | sed 's/scaffold/CDS/g' | sed 's/chromosome/CDS/g')
if [ -d "$outputdirCDS" ]; then
    rm $outputdirCDS/*.fst
else
    mkdir "$outputdirCDS"
fi
cd $outputdirCDS

while read line; do 
	python2 ../01_scripts/cutSeqGff.py $outputdirscaffolds/$line.fst $gfffile $line CDS; 
done < $gfffile.scaffIDwithCDS
cd ..

### FILTER ALIGNMENTS & COMPUTE STATS

# echo "REMOVE EMPTY ALIGNMENT"
# This should be deprecated if the CDS and gff are clean
#outputdirEMPTY=$(echo "$outputdirscaffolds" | sed 's/scaffold/EMPTY_CDS/g' ) # | sed 's/chromosome/CDS/g')
#mkdir $outputdirEMPTY 2>/dev/null
#rm check_length.txt 2>/dev/null

#for i in $outputdirCDS/*fst ; do
#   awk '/^>/ {if (seqlen){print seqlen}; print ;seqlen=0;next; } { seqlen += length($0)}END{print seqlen}' $i |awk -v var=$i '{print var"\t"$1}' >> check_length.txt ;
#done
#awk '$2<5 {print $1}' check_length.txt |uniq >> empty.cds.tmp
#for i in $(cat empty.cds.tmp) ; do mv $i $outputdirEMPTY ; done
#rm empty.cds.tmp

echo "FILTERING ALIGNMENTS"
## list of all fasta CDS
ls $outputdirCDS/ | grep ".fst" > $outprefix.list_CDS.txt
cd $outputdirCDS
## remove last codon
echo "removing last codon"
../01_scripts/removeLastStopCodon -seq ../$outprefix.list_CDS.txt -f fasta -code univ
cd ..

## generate a new list with processed alignments
ls $outputdirCDS/ | grep ".fst.clean.fst" > $outprefix.list_CDS.txt
## clean alignments
cd $outputdirCDS
echo  "cleaning alignment now"
../01_scripts/cleanAlignment -seq ../$outprefix.list_CDS.txt -f fasta -n 4
cd ..

## generate a new list with processed alignments
ls $outputdirCDS/ | grep ".fst.clean.fst.clean.fst" > $outprefix.list_CDS.txt
## compute summary statistics (-tstv = transition transervision ratio here fixed to 2 but can be set to another value)
echo "COMPUTING SUMMARY STATISTICS"
cd $outputdirCDS
../01_scripts/seq_stat_coding -seq ../$outprefix.list_CDS.txt -f fasta -tstv 2 -code univ -o ../$outprefix.CDS.sumstats > ../$outprefix.CDS.sumstats.info
cd ..


# keep info of genes without premature stop codons
grep "stop" $outprefix.CDS.sumstats.info | awk '{print $1}' > $outprefix.CDS.withprematurestopcodons
### compute GC3s based on 4-fold degenerate sites (also includes prot alignments)
outputdir4fold=$(echo "$outputdirscaffolds" | sed 's/scaffold/4fold/g' | sed 's/chromosome/4fold/g')
if [ -d "$outputdir4fold" ]; then
    rm $outputdir4fold/*
else
    mkdir "$outputdir4fold"
fi

outputdirprot=$(echo "$outputdirscaffolds" | sed 's/scaffold/prot/g' | sed 's/chromosome/prot/g')
if [ -d "$outputdirprot" ]; then
    rm $outputdirprot/*
else
     mkdir "$outputdirprot"
fi
        
# parse sequences containing 4 fold codons only
cd $outputdirCDS
rm ../$outprefix.list_CDS.4fold
while read line; do
    python2 ../01_scripts/script_python_sequencecodons4folddegenerateonly.py $line $line
    mv $line.sites4foldonly $outputdir4fold/
    mv $line.prot $outputdirprot/
    echo "$outputdir4fold/$line.sites4foldonly" >> ../$outprefix.list_CDS.4fold # generate a list
done < ../$outprefix.list_CDS.txt 

# clean alignments
cd $outputdir4fold
../01_scripts/cleanAlignment -seq ../$outprefix.list_CDS.4fold -f fasta -n 4
ls $outputdir4fold/ | grep ".sites4foldonly.clean.fst" > ../$outprefix.list_CDS.4fold

# compute GC3s
../01_scripts/seq_stat_coding -seq ../$outprefix.list_CDS.4fold -f fasta -tstv 2 -code univ -o ../$outprefix.4fold.CDS.sumstats
cd ..
awk '{print $1" "$2"    "$3"	"$11}' $outprefix.4fold.CDS.sumstats | sed 's/GC3/GC3s/g' > $outprefix.4fold.CDS.sumstats.GC3s

### merge pnps datasets & GC3s [require to exclude GC3s for seq with premature stop codons]
echo "name  Size    N   S   P   W   Ps  Pn  NbSS    D_Taj   GC3 name2    Size4fold  N4fold  GC3s" > $outprefix.4fold.CDS.sumstats.final
less $outprefix.4fold.CDS.sumstats.GC3s | grep -v "Size" > tmp
while read line; do
    grep -v "$line" tmp > tmp2
    mv tmp2 tmp
done < $outprefix.CDS.withprematurestopcodons
grep -v "Size" $outprefix.CDS.sumstats > tmp2
paste tmp2 tmp >> $outprefix.4fold.CDS.sumstats.final # please check that this output is correct
rm tmp*
