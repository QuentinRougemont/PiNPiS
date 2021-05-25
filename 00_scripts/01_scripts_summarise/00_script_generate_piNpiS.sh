# TL - 130318
# QR - 2020

# ./script_generate_piNpiS.sh file._withoutquantiles.CDS.sumstats.txt
if [ $# -ne 1 ]; then 
    echo "Usage: $(basename $0) <myfile>" >&2 
    echo "myfile: pnps file"
    echo "obtained after running cds2stats.sh" 
    exit 1 
else 
        myfile=$1  #name of the file 
fi 


pNseq=$(awk '{s+=$8} END {print s}' $myfile | awk '{printf "%.1f\n", $1}')
pSseq=$(awk '{s+=$7} END {print s}' $myfile | awk '{printf "%.1f\n", $1}')
NbSynSites=$(awk '{s+=$9} END {print s}' $myfile | awk '{printf "%.1f\n", $1}')
totallength=$(awk '{s+=$2} END {print s}' $myfile | awk '{printf "%.1f\n", $1}')
pSratio=$(echo "scale=8; ($pSseq/$NbSynSites)" | bc)
pNratio=$(echo "scale=8; ($pNseq/($totallength-$NbSynSites))" | bc)
pNpSratio=$(echo "scale=6; ($pNseq/($totallength-$NbSynSites))/($pSseq/$NbSynSites)" | bc)

echo "$myfile	$pNseq	$pSseq	$NbSynSites	$totallength	$pSratio	$pNratio	$pNpSratio" >> pnps.txt

echo "results printed into file pnps.txt"
