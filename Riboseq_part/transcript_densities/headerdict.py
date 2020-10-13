
import sys

file = str(sys.argv[1])

infile = open(file, "r")

lines = infile.readlines()

for line in lines:

	line = line.strip()

	xline = list(line.split("|"))

	xline = xline[:-1]

	xline[0] = xline[0].replace(">","")

	ENST = xline[0]
	ENSG = xline[1]
	GENE = xline[5]

	#print(line)
	#print(ENST,GENE)

	UTR3 = None
	UTR5 = None

	if "UTR5:" in line:

		UTR5 = xline[7]
		CDS = xline[8]

		if "UTR3:" in line:
			UTR3 = xline[9]

			#UTR3 = xline[8]
			UTR3range = UTR3.split(":")[1]
			END = UTR3range.split("-")[1]
		else:
			CDSrange = CDS.split(":")[1]
			END = CDSrange.split("-")[1]


#			print(UTR3)
#
#		print(UTR5)
#		print(xline)


	else:
		CDS = xline[7]

		if "UTR3:" in line:
			UTR3 = xline[8]
			UTR3range = UTR3.split(":")[1]
			END = UTR3range.split("-")[1]
		else:
			CDSrange = CDS.split(":")[1]
			END = CDSrange.split("-")[1]

	print(ENST,GENE,UTR5,CDS,UTR3, END)

