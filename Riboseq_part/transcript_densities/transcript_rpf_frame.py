import sys
import os
import math
import numpy as np
import matplotlib.pyplot as plt

dirpath = str(sys.argv[1])
Species = str(sys.argv[2])

directory = os.fsencode(dirpath)

filenames = []

for file in os.listdir(directory):

	filename = os.fsdecode(file)

	if filename.endswith("sam.csv"):

		filenames.append(filename)

print(filenames)

#wanted_AA = str(sys.argv[2])

#print(wanted_AA)

#wanted_AA = "TGG"

COD_TO_AA = { # T
'TTT': 'PHE', 'TCT': 'SER', 'TAT': 'TYR', 'TGT': 'CYS', # TxT
'TTC': 'PHE', 'TCC': 'SER', 'TAC': 'TYR', 'TGC': 'CYS', # TxC
'TTA': 'LEU', 'TCA': 'SER', 'TAA': '---', 'TGA': '---', # TxA
'TTG': 'LEU', 'TCG': 'SER', 'TAG': '---', 'TGG': 'TRP', # TxG
# C
'CTT': 'LEU', 'CCT': 'PRO', 'CAT': 'HIS', 'CGT': 'ARG', # CxT
'CTC': 'LEU', 'CCC': 'PRO', 'CAC': 'HIS', 'CGC': 'ARG', # CxC
'CTA': 'LEU', 'CCA': 'PRO', 'CAA': 'GLN', 'CGA': 'ARG', # CxA
'CTG': 'LEU', 'CCG': 'PRO', 'CAG': 'GLN', 'CGG': 'ARG', # CxG
# A
'ATT': 'ILE', 'ACT': 'THR', 'AAT': 'ASN', 'AGT': 'SER', # AxT
'ATC': 'ILE', 'ACC': 'THR', 'AAC': 'ASN', 'AGC': 'SEr', # AxC
'ATA': 'ILE', 'ACA': 'THR', 'AAA': 'LYS', 'AGA': 'ARG', # AxA
'ATG': 'MET', 'ACG': 'THR', 'AAG': 'LYS', 'AGG': 'ARG', # AxG
# G
'GTT': 'VAL', 'GCT': 'ALA', 'GAT': 'ASP', 'GGT': 'GLY', # GxT
'GTC': 'VAL', 'GCC': 'ALA', 'GAC': 'ASP', 'GGC': 'GLY', # GxC
'GTA': 'VAL', 'GCA': 'ALA', 'GAA': 'GLU', 'GGA': 'GLY', # GxA
'GTG': 'VAL', 'GCG': 'ALA', 'GAG': 'GLU', 'GGG': 'GLY'  # GxG
}



#print(len(sys.argv)-1) #check for possible changes in filters !
#	AA or default or all
#	transcript_REF_file (gencode 19 as default)
#	read filter (100 as default)
#	per gene dread filter around codon (5 as default)

#gene_coverage_filter = int(sys.argv[3])
#gene_coverage_filter = 100

def dna_to_codon(dna_seq):

	codons = []

	for i in range(0, len(dna_seq), 3):
		codons.append(dna_seq[i:i + 3])

	return codons

#wanted = dna_to_codon(wanted_AA)

#global Symbol
#Symbol = COD_TO_AA[wanted[0]]

#AA_wantedstring = " ".join(str(x) for x in wanted)

#print(AA_wantedstring)
#print(Symbol)
#print(filenames)

CDS_UTR_dict = {}

CDSstring = "./transcript_densities/" + Species + "_CDS_UTRS.fa"

CDS_UTRfile = open(CDSstring, "r")

lines = CDS_UTRfile.readlines()

for line in lines:

	line = line.strip()

	line = list(line.split(" "))

	ENST = line[0]

	UTR5 = line[2]
	if ":" in UTR5:
		UTR5 = UTR5.split(":")[1]

	CDS = line[3]
	CDS = CDS.split(":")[1]

	UTR3 = line[4]

	END = line[5]

	if ":" in UTR3:
		UTR3 = UTR3.split(":")[1]

	if ENST not in CDS_UTR_dict.keys():
		CDS_UTR_dict[ENST] = {}
		CDS_UTR_dict[ENST]["GENE"] = line[1]
		CDS_UTR_dict[ENST]["UTR5"] = UTR5
		CDS_UTR_dict[ENST]["CDS"] = CDS
		CDS_UTR_dict[ENST]["UTR3"] = UTR3
		CDS_UTR_dict[ENST]["END"] = END

#print(CDS_UTR_dict["ENST00000337304.2"])
#print(CDS_UTR_dict["ENST00000432135.1"])
#print(CDS_UTR_dict)
#ENST00000598296.1': {'GENE': 'NOSIP', 'UTR5': 'None', 'CDS': '1-529', 'UTR3': 'None'}

headerstring = ("ID GENE Count UTR5_psites CDS_psites UTR3_psites UTR5_frames_0 UTR5_frames_1 UTR5_frames_2 CDS_frames_0 CDS_frames_1 CDS_frames_2 UTR3_frames_0 UTR3_frames_1 UTR3_frames_2 X1 X2 X3 X4 X5 X6 X7 X8 X9 X10 X11 X12 X13 X14 X15 X16 X17 X18 X19 X20 X21 X22 X23 X24 X25 X26 X27 X28 X29 X30 X31 X32 X33 X34 X35 X36 X37 X38 X39 X40 X41 X42 X43 X44 X45 X46 X47 X48 X49 X50 X51 X52 X53 X54 X55 X56 X57 X58 X59 X60 X61 X62 X63 X64 X65 X66 X67 X68 X69 X70 X71 X72 X73 X74 X75 X76 X77 X78 X79 X80 X81 X82 X83 X84 X85 X86 X87 X88 X89 X90 X91 X92 X93 X94 X95 X96 X97 X98 X99 X100 X101 X102 X103 X104 X105 X106 X107 X108 X109 X110 X111 X112 X113 X114 X115 X116 X117 X118 X119 X120 X121 X122 X123 X124 X125 X126 X127 X128 X129 X130 X131 X132 X133 X134 X135 X136 X137 X138 X139 X140 X141 X142 X143 X144 X145 X146 X147 X148 X149 X150 X151 X152 X153 X154 X155 X156 X157 X158 X159 X160 X161 X162 X163 X164 X165 X166 X167 X168 X169 X170 X171 X172 X173 X174 X175 X176 X177 X178 X179 X180 X181 X182 X183 X184 X185 X186 X187 X188 X189 X190 X191 X192 X193 X194 X195 X196 X197 X198 X199 X200 X201 X202 X203 X204 X205 X206 X207 X208 X209 X210 X211 X212 X213 X214 X215 X216 X217 X218 X219 X220 X221 X222 X223 X224 X225 X226 X227 X228 X229 X230 X231 X232 X233 X234 X235 X236 X237 X238 X239 X240 X241 X242 X243 X244 X245 X246 X247 X248 X249 X250 X251 X252 X253 X254 X255 X256 X257 X258 X259 X260 X261 X262 X263 X264 X265 X266 X267 X268 X269 X270 X271 X272 X273 X274 X275 X276 X277 X278 X279 X280 X281 X282 X283 X284 X285 X286 X287 X288 X289 X290 X291 X292 X293 X294 X295 X296 X297 X298 X299 X300")

for filename in filenames:




	#for i in range(300):
	#	X_axis_array.append(0)

#	print("")

	ENST_dict = {}

	print(filename)

	strfilename = str(dirpath) + str(filename)

	outfilename = strfilename.replace(".fastq.sam.csv", "_rpftranscript_output.txt")

	outfile = open(outfilename,"w")

	outfile.write(headerstring + "\n")

	infile = open(strfilename,"r")

	lines = infile.readlines()

	counter = 0

	for line in lines:

		line = line.strip()

		line = list(line.split(","))

		if "ENS" in line[0]:

			ENST = line[0].replace('"','')

			#ENST = ENST.replace('"','')

			cdsstart = line[5]
			cdsend = line[6]
			cds_region = str(cdsstart) + "-" + str(cdsend)

			psite = line[2]

			region = line[9].replace('"','')

			frame = line[10]

			#print(region)

			theread = str(psite) + "_" + str(frame)

			#print(ENST,psite,region,frame,theread)

			if ENST not in ENST_dict.keys():
				ENST_dict[ENST] = {}
				ENST_dict[ENST]["count"] = 1
				ENST_dict[ENST]["psites"] = [psite]
				ENST_dict[ENST]["frames"] = [frame]
				ENST_dict[ENST]["cds"] = [cds_region]
				ENST_dict[ENST]["pframe"] = [theread]
			else:
				ENST_dict[ENST]["count"] = ENST_dict[ENST]["count"] + 1
				ENST_dict[ENST]["psites"].append(psite)
				ENST_dict[ENST]["frames"].append(frame)
				ENST_dict[ENST]["pframe"].append(theread)

#	print(ENST_dict)

	for ENST in ENST_dict.keys():

		UTR5_psites = 0
		CDS_psites = 0
		UTR3_psites = 0

		UTR5_frames = [0,0,0]
		CDS_frames = [0,0,0]
		UTR3_frames = [0,0,0]

		X_axis_array = [] 

		for i in range(300): #300
			X_axis_array.append(0)


		if ENST in CDS_UTR_dict.keys():

			CDSx1 = CDS_UTR_dict[ENST]["CDS"].split("-")[0]
			CDSx2 = CDS_UTR_dict[ENST]["CDS"].split("-")[1]

		#	print("*******************************************************************************")

		#	print("")
#			print(ENST_dict[ENST],"#######",CDSx1,CDSx2,"#########",CDS_UTR_dict[ENST])
		#	print("")

			for i in range(len(ENST_dict[ENST]["pframe"])):

				
#				print((CDSx1))
#				print(ENST_dict[ENST]["pframe"][i])
#				print(ENST_dict[ENST],"#######",CDSx1,CDSx2,"#########",CDS_UTR_dict[ENST])
				if "e" not in str(ENST_dict[ENST]["pframe"][i].split("_")[0]):
					if int(ENST_dict[ENST]["pframe"][i].split("_")[0]) < int(CDSx1): # UTR5 

						CDSx1 = int(CDSx1) - 1

						UTR5_psites = UTR5_psites + 1

						frame = int(ENST_dict[ENST]["pframe"][i].split("_")[1])
						UTR5_frames[frame] = UTR5_frames[frame] + 1

#					print("herrre UTR5",ENST_dict[ENST]["psites"][i])

						point = float(ENST_dict[ENST]["psites"][i])/float(CDSx1)
					#print("herrre UTR5",ENST_dict[ENST]["psites"][i], point)
						point = float(point)*100
						X_pos = int(point)
						X_axis_array[X_pos] = X_axis_array[X_pos] + 1
					#print("herrre UTR5",ENST_dict[ENST]["psites"][i], point, X_pos)

					else:

					#print(ENST,ENST_dict[ENST]["pframe"][i].split("_")[0], CDSx2,CDS_UTR_dict[ENST], "$$$$$$$$$$$$$$$$$$$$$$$$$")

						if int(ENST_dict[ENST]["pframe"][i].split("_")[0]) > int(CDSx2):


							UTR3_psites = UTR3_psites + 1
							frame = int(ENST_dict[ENST]["pframe"][i].split("_")[1])
							UTR3_frames[frame] = UTR3_frames[frame] + 1

						#print("herrre UTR3",ENST_dict[ENST]["psites"][i])

							ENST_dict[ENST]["psites"][i] = float(ENST_dict[ENST]["psites"][i]) - int(CDSx2)

						#print("Now new herrre UTR3",ENST_dict[ENST]["psites"][i])

						#CDS_UTR_dict[ENST]["END"] = float(CDS_UTR_dict[ENST]["END"])-int(CDSx2)

						#print("Now new herrre UTR3",ENST_dict[ENST]["psites"][i])
							CDS_UTR_dict[ENST]["END"] = float(CDS_UTR_dict[ENST]["END"])

							point = float(ENST_dict[ENST]["psites"][i])/float((CDS_UTR_dict[ENST]["END"])-int(CDSx2))
						#print("point1", point)
							point = float(point)*100
						#print("point2", point)
							X_pos = int(point) + 200
						#print("herrre UTR3",ENST_dict[ENST]["psites"][i], point, X_pos, CDSx2)
							X_axis_array[X_pos] = X_axis_array[X_pos] + 1
						#print("herrre UTR3",ENST_dict[ENST]["psites"][i], point, X_pos)

						else:

							CDS_psites = CDS_psites + 1
							frame = int(ENST_dict[ENST]["pframe"][i].split("_")[1])

							CDS_frames[frame] = CDS_frames[frame] + 1
#						print("herre CDS",ENST_dict[ENST]["psites"][i])	

							ENST_dict[ENST]["psites"][i] = (float(ENST_dict[ENST]["psites"][i])) - (int(CDSx1))

							newCDSx2 = int(CDSx2)-int(CDSx1)

							point = float(ENST_dict[ENST]["psites"][i])/int(newCDSx2)


							point = float(point)*100
							X_pos = int(point) + 100
						#print("herrre CDS",ENST_dict[ENST]["psites"][i], point, X_pos)
							X_axis_array[X_pos] = X_axis_array[X_pos] + 1
						#print("herrre CDS",ENST_dict[ENST]["psites"][i], point, X_pos)

#		print("______")


			#print(ENST, X_axis_array)
			xsum = sum(X_axis_array)

			for n, item in enumerate(X_axis_array):

				item = float(item/xsum)
				X_axis_array[n] = item

			X_axis_array = str(X_axis_array)
			X_axis_array = X_axis_array.replace("[","")
			X_axis_array = X_axis_array.replace("]","")
			X_axis_array = X_axis_array.replace(",","")

			outfile.write(str(ENST) + " " + str(CDS_UTR_dict[ENST]["GENE"]) + " "+ str(ENST_dict[ENST]["count"]) + " " + str(UTR5_psites) + " " + str(CDS_psites) + " "+ str(UTR3_psites) + " "+ str(UTR5_frames[0]) + " "+ str(UTR5_frames[1]) + " "+ str(UTR5_frames[2]) + " "+ str(CDS_frames[0]) +" "  + str(CDS_frames[1]) + " "+ str(CDS_frames[2]) +" " + str(UTR3_frames[0]) +" " + str(UTR3_frames[1]) +" " + str(UTR3_frames[2]) +" "+ str(X_axis_array) + "\n")

			#print(ENST,CDS_UTR_dict[ENST]["GENE"],ENST_dict[ENST]["count"],UTR5_psites, CDS_psites, UTR3_psites, UTR5_frames[0],UTR5_frames[1],UTR5_frames[2], CDS_frames[0], CDS_frames[1], CDS_frames[2], UTR3_frames[0], UTR3_frames[1], UTR3_frames[2], X_axis_array)		



