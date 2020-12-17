import sys
filename = sys.argv[1]
outprefix=sys.argv[2]

def translate_dna(sequence):

        codontable = {
                    'ATA':'I', 'ATC':'I', 'ATT':'I', 'ATG':'M',
                    'ACA':'T', 'ACC':'T', 'ACG':'T', 'ACT':'T',
                    'AAC':'N', 'AAT':'N', 'AAA':'K', 'AAG':'K',
                    'AGC':'S', 'AGT':'S', 'AGA':'R', 'AGG':'R',
                    'CTA':'L', 'CTC':'L', 'CTG':'L', 'CTT':'L',
                    'CCA':'P', 'CCC':'P', 'CCG':'P', 'CCT':'P',
                    'CAC':'H', 'CAT':'H', 'CAA':'Q', 'CAG':'Q',
                    'CGA':'R', 'CGC':'R', 'CGG':'R', 'CGT':'R',
                    'GTA':'V', 'GTC':'V', 'GTG':'V', 'GTT':'V',
                    'GCA':'A', 'GCC':'A', 'GCG':'A', 'GCT':'A',
                    'GAC':'D', 'GAT':'D', 'GAA':'E', 'GAG':'E',
                    'GGA':'G', 'GGC':'G', 'GGG':'G', 'GGT':'G',
                    'TCA':'S', 'TCC':'S', 'TCG':'S', 'TCT':'S',
                    'TTC':'F', 'TTT':'F', 'TTA':'L', 'TTG':'L',
                    'TAC':'Y', 'TAT':'Y', 'TAA':'_', 'TAG':'_',
                    'TGC':'C', 'TGT':'C', 'TGA':'_', 'TGG':'W',
                    }

        proteinsequence = ''
        sequencestart = sequence[0:]
        cds = str(sequencestart[:len(sequence)+3])
        for n in range(0,len(cds),3):
                if cds[n:n+3] in codontable:
                        proteinsequence += codontable[cds[n:n+3]]
                else:
                        proteinsequence += "X"
        return proteinsequence


def fourfolddegenerate(sequence):
        seqfourfold = ''
        sequencestart = sequence[0:]
        cds = str(sequencestart[:len(sequence)+3])
        for n in range(0,len(cds),3):
                if cds[n:n+3] == "CTT" or cds[n:n+3] == "CTC" or cds[n:n+3] == "CTA" or cds[n:n+3] == "CTG":  # LEUCINE
                    seqfourfold += cds[n:n+3]
                elif cds[n:n+3] == "GTT" or cds[n:n+3] == "GTC" or cds[n:n+3] == "GTA" or cds[n:n+3] == "GTG": # VALINE
                    seqfourfold += cds[n:n+3]
                elif cds[n:n+3] == "TCT" or cds[n:n+3] == "TCC" or cds[n:n+3] == "TCA" or cds[n:n+3] == "TCG": # SERINE
                    seqfourfold += cds[n:n+3]
                elif cds[n:n+3] == "CCT" or cds[n:n+3] == "CCC" or cds[n:n+3] == "CCA" or cds[n:n+3] == "CCG":# PROLINE
                    seqfourfold += cds[n:n+3]
                elif cds[n:n+3] == "ACT" or cds[n:n+3] == "ACC" or cds[n:n+3] == "ACA" or cds[n:n+3] == "ACG": # THREONINE
                    seqfourfold += cds[n:n+3]
                elif cds[n:n+3] == "GCT" or cds[n:n+3] == "GCC" or cds[n:n+3] == "GCA" or cds[n:n+3] == "GCG": # ALANINE
                    seqfourfold += cds[n:n+3]
                elif cds[n:n+3] == "CGT" or cds[n:n+3] == "CGC" or cds[n:n+3] == "CGA" or cds[n:n+3] == "CGG": # ARGININE
                    seqfourfold += cds[n:n+3]
                elif cds[n:n+3] == "GGT" or cds[n:n+3] == "GGC" or cds[n:n+3] == "GGA" or cds[n:n+3] == "GGG": # GLYCINE
                    seqfourfold += cds[n:n+3]
                else:
                    seqfourfold += "NNN"
        return seqfourfold
                                                                                
infilename=open(filename)
outfilenameprot=outprefix + ".prot"
outfilenameprotopen=open(outfilenameprot,"w")
outfilename4fold=outprefix + ".sites4foldonly"
outfilename4foldopen=open(outfilename4fold,"w")
for line in infilename:
    if line[0] == ">":
        outfilenameprotopen.write(line)
    else:
        line2print=translate_dna(line)+"\n"
        outfilenameprotopen.write(line2print)
infilename.close()
infilename=open(filename)
for line in infilename:
    if line[0] == ">":
        outfilename4foldopen.write(line)
    else:
        line2print=fourfolddegenerate(line)+"\n"
        outfilename4foldopen.write(line2print)

infilename.close()
outfilename4foldopen.close()
outfilenameprotopen.close()

