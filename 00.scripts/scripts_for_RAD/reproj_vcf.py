#!/usr/bin/env python2
#$Id$

###run with python reproj_vcf.py GCF_002021735.1_Okis_V1_genomic.gff.sed.gene.agp ALA.cds.50klines.txt > ALA.cds.50klines.txt.reproj


import os
import re
import string
import sys
import glob

file1 = open(sys.argv[1]) # le fichier agp
file2 = open(sys.argv[2]) # le fichier vcf
outfilename=str(sys.argv[2])+".reproj"
outfile= open(outfilename,"w")

agpdico = {} # creation dico

for line1 in file1.readlines(): # lecture agp
	line1 = line1.replace('\n','')
	splitted_line1 = line1.split('\t')
	scaffID = splitted_line1[5] # recup le scaffID
	posstart = splitted_line1[6] # startgenescaff
	posend = splitted_line1[7] # endgenescaff
	geneID=  splitted_line1[0] # geneID
	genepos=0
        #print geneID
        for pos in range(int(posstart), int(posend)+1, 1):
		genepos+=1
		key = (scaffID + '-' + str(pos)) 
                to_keep= (geneID+"\t"+str(genepos))
		agpdico[key] = to_keep


for line2 in file2.readlines(): # lecture vcf
	line2 = line2.replace('\n','')
	splitted_line2 = line2.split('\t')
	scaffID_vcf = splitted_line2[0] #scaff
	pos_vcf = splitted_line2[1] # pos
	key_vcf = (scaffID_vcf + '-' + pos_vcf) #key
        #print key_vcf
	if (agpdico.has_key(key_vcf)): # find the agp key
		#print agpdico[key_vcf]+"\t"+line2
                myline=str(agpdico[key_vcf])+"\t"+line2+"\n"
                outfile.write(myline)
	
file1.close()
file2.close()
outfile.close()
