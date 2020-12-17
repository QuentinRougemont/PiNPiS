

gff=$1  #gffilfe 
zcat $gff |awk '!seen[$1,$4,$5]++' > gfffile #remove some shit if needed
 
awk '$3 == "CDS" {print $1}' gfffile | sort | uniq > gfffile.scaffIDwithCDS
