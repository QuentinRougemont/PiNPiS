#! /usr/bin/env python

from __future__ import print_function
from string import maketrans
import sys
import numpy as np

## cut a sequences using a GFF

def read_fasta(fp):
    name, seq = None, []
    for line in fp:
        line = line.rstrip()
        if line.startswith(">"):
            if name: yield (name, ''.join(seq))
            name, seq = line, []
        else:
            seq.append(line)
    if name: yield (name, ''.join(seq))
    
 
def revcomp(seq):
    return seq.translate(maketrans('ACGTacgtRYMKrymkVBHDvbhdNn-', 'TGCAtgcaYRKMyrkmBVDHbvdhNn-'))[::-1]

def findGeneNameInAttributesStr(AttributesStr):
	GENENAME = 0
	Attributes = AttributesStr.split(";")
	for i in Attributes:
		j = i.split('=')
		if j[0] == 'Name':
			GENENAME = j[1]
			break
	return(GENENAME)


## Main ##

fp = open(sys.argv[1])
GFFfile = open(sys.argv[2]) 
IdSeqIn = str(sys.argv[3]) 
Region = str(sys.argv[4]) 
sizeUTR = 1000


if Region != "CDS" and Region != "Introns" and Region != "3UTR" and Region != "5UTR" and Region != "Exon_1" and Region != "Exon_last":
	print("Region option must be either CDS or Introns or 3UTR or 5UTR or Exon_1 or Exon_last")
	print("Command line :\ncutSeqGff.py Scaffod.fst file.gff Name_scaffold [CDS or Introns or UTR (1000bp)]")
	exit

Gene = ""
sites = []
revc = "+"
nameSeq = []
NumberOfInd = 0
beg = []
end = []
phase = []

for name, seq in read_fasta(fp):
	name = name.lstrip('>')
	nameSeq.append(name)
		
NumberOfInd = len(nameSeq)
		
for line in GFFfile:
	line = line.rstrip()
	if line[0] == "#":
		continue
	arrline = line.split()
	
	if arrline[0] != IdSeqIn:
		continue
	
	if arrline[2] != "CDS":
		continue
	
	attributes = arrline[8]
	
	geneName = findGeneNameInAttributesStr(attributes)
	
	if Gene != geneName:
		if Gene != "":
			
			if revc == "+":
				beg[0]=beg[0]+phase[0]
			else:
				end[0]=end[0]-phase[0]
				
			fasta = open(Gene+".fst", "w")
			
			fp = open(sys.argv[1])
			if Region == "CDS":
				for name, seq in read_fasta(fp):
					print(name, file=fasta)
					if revc == "+": 
						for i, b in enumerate(beg):
							sequenceDNA = sequenceDNA+seq[b:end[i]]
					else:
						beg = sorted(beg)
						end = sorted(end)
						for i, b in enumerate(beg):
							sequenceDNA = sequenceDNA+seq[b:end[i]]
						sequenceDNA = revcomp(sequenceDNA)
						
					print(sequenceDNA, file=fasta)
					sequenceDNA = ""
			if Region == "Exon_1":
				for name, seq in read_fasta(fp):
					print(name, file=fasta)
					if revc == "+": 
						sequenceDNA = seq[beg[0]:end[0]]
					else:
						sequenceDNA = seq[beg[0]:end[0]]
						sequenceDNA = revcomp(sequenceDNA)
						
					print(sequenceDNA, file=fasta)
					sequenceDNA = ""
			if Region == "Exon_last":
				if revc == "+":
					beg[-1]=beg[-1]+phase[-1]
				else:
					end[-1]=end[-1]-phase[-1]
				for name, seq in read_fasta(fp):
					print(name, file=fasta)
					if revc == "+": 
						sequenceDNA = seq[beg[-1]:end[-1]]
					else:
						sequenceDNA = seq[beg[-1]:end[-1]]
						sequenceDNA = revcomp(sequenceDNA)
						
					print(sequenceDNA, file=fasta)
					sequenceDNA = ""
			if Region == "Introns":
				if len(beg) > 1: # CDS must have at least one intron
					for name, seq in read_fasta(fp):
						print(name, file=fasta)
						if revc == "+": 
							if len(end) > 1:
								for i, b in enumerate(beg):
									if i == len(end)-1:
										continue
									END = end[i]
									BEG = beg[i+1]
									sequenceDNA = sequenceDNA+seq[END:BEG]
						else:
							beg = sorted(beg)
							end = sorted(end)
							if len(end) > 1:
								for i, b in enumerate(beg):
									if i == len(end)-1:
										continue
									END = end[i]
									BEG = beg[i+1]
									sequenceDNA = sequenceDNA+seq[END:BEG]
								sequenceDNA = revcomp(sequenceDNA)
							
						print(sequenceDNA, file=fasta)
						sequenceDNA = ""
			if Region == "5UTR":
				for name, seq in read_fasta(fp):
					print(name, file=fasta)
					
					if revc == "+": 
						BEG = beg[0]-sizeUTR
						END = beg[0]
						sequenceDNA = sequenceDNA+seq[BEG:END]
					else:
						beg = sorted(beg)
						end = sorted(end)
						BEG = end[-1]
						END = end[-1]+sizeUTR
						sequenceDNA = sequenceDNA+seq[BEG:END]
						sequenceDNA = revcomp(sequenceDNA)
						
					print(sequenceDNA, file=fasta)
					sequenceDNA = ""
			if Region == "3UTR":
				for name, seq in read_fasta(fp):
					print(name, file=fasta)
					
					if revc == "+": 
						BEG = end[-1]
						END = end[-1]+sizeUTR
						sequenceDNA = sequenceDNA+seq[BEG:END]
					else:
						beg = sorted(beg)
						end = sorted(end)
						BEG = beg[0]-sizeUTR
						END = beg[0]
						sequenceDNA = sequenceDNA+seq[BEG:END]
						sequenceDNA = revcomp(sequenceDNA)
						
					print(sequenceDNA, file=fasta)
					sequenceDNA = ""
			fp.close()
			
		Gene = geneName 
		sequenceDNA = ""
		beg = []
		end = []
		phase = []
		
	revc = arrline[6]
	beg.append(int(arrline[3])-2)
	end.append(int(arrline[4])-1)
	phase.append(int(arrline[7]))



if Gene != "":
	if revc == "+":
		beg[0]=beg[0]+phase[0]
	else:
		end[0]=end[0]-phase[0]
	fasta = open(Gene+".fst", "w")
	fp = open(sys.argv[1])
	if Region == "CDS":
		for name, seq in read_fasta(fp):
			print(name, file=fasta)
			if revc == "+": 
				for i, b in enumerate(beg):
					sequenceDNA = sequenceDNA+seq[b:end[i]]
			else:
				beg = sorted(beg)
				end = sorted(end)
				for i, b in enumerate(beg):
					sequenceDNA = sequenceDNA+seq[b:end[i]]
				sequenceDNA = revcomp(sequenceDNA)
			print(sequenceDNA, file=fasta)
			sequenceDNA = ""
	if Region == "Exon_1":
		for name, seq in read_fasta(fp):
			print(name, file=fasta)
			if revc == "+": 
				sequenceDNA = seq[beg[0]:end[0]]
			else:
				sequenceDNA = seq[beg[0]:end[0]]
				sequenceDNA = revcomp(sequenceDNA)
			
			print(sequenceDNA, file=fasta)
			sequenceDNA = ""
	if Region == "Exon_last":
		if revc == "+":
			beg[-1]=beg[-1]+phase[-1]
		else:
			end[-1]=end[-1]-phase[-1]
		for name, seq in read_fasta(fp):
			print(name, file=fasta)
			if revc == "+": 
				sequenceDNA = seq[beg[-1]:end[-1]]
			else:
				sequenceDNA = seq[beg[-1]:end[-1]]
				sequenceDNA = revcomp(sequenceDNA)
				
			print(sequenceDNA, file=fasta)
			sequenceDNA = ""
	if Region == "Introns":
		if len(beg) > 1: # CDS must have at least one intron
		
			for name, seq in read_fasta(fp):
				print(name, file=fasta)
				if revc == "+": 
					if len(end) > 1:
						for i, b in enumerate(beg):
							if i == len(end)-1:
								continue
							END = end[i]
							BEG = beg[i+1]
							sequenceDNA = sequenceDNA+seq[END:BEG]
				else:
					beg = sorted(beg)
					end = sorted(end)
					if len(end) > 1:
						for i, b in enumerate(beg):
							if i == len(end)-1:
								continue
							END = end[i]
							BEG = beg[i+1]
							sequenceDNA = sequenceDNA+seq[END:BEG]
					sequenceDNA = revcomp(sequenceDNA)
							
				print(sequenceDNA, file=fasta)
				sequenceDNA = ""
	fp.close()
			

#fp.close()


