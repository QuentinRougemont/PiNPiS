#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $(basename $0) <gff>  " >&2
    echo "gff : gff file"
    exit 1
else
    #Using values from the command line
    gff=$1        #name of the gff
fi

#zcat $gff |awk '!seen[$1,$4,$5]++' > gfffile #remove some shit if needed

#check compression
if file --mime-type "$gff" | grep -q gzip$; then
  echo "$gff is gzipped"
else
  echo "$gff is not gzipped"
  echo "will compress with gzip"
  gzip "$gff"
  gff=$( echo "$gff".gz )
  echo "compression is done"
fi

zcat $gff | awk '$3 == "CDS" {print $1}' | sort | uniq > $gff.scaffIDwithCDS
