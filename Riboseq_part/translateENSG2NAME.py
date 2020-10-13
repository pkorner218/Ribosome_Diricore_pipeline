import sys

trans = sys.argv[1]
Species = sys.argv[2]

#print(trans, "$$$$$$$$$$$$$$$$$$$$$$$")
#print(Species, "$$$$$$$$$$$$$$$$$$$$$$$")


dictionary = {}

filewithpath = "./REF/transcripts/" + str(Species) + "/ENSG2GENENAME_dict_mart_export.txt"

#print(filewithpath)

infile1 = open(filewithpath,"r")

lines1 = infile1.readlines()

for line in lines1:

	line = line.strip()
	ENSG = line.split(",")[0]
	GENE = line.split(",")[1]

	dictionary[ENSG] = GENE


#print(dictionary)

infile = open(trans, "r")

lines = infile.readlines()

counter = 0

for line in lines:


#	if counter < 5:
#		print(line)
	counter = counter + 1

	line = line.strip()
	xline = list(line.split("\t"))

	ENSG = xline[0]
	ENSGnew = ENSG.split(".")[0]


	if ENSGnew in dictionary.keys():
		GENEname = dictionary[ENSGnew]
		line = line.replace(ENSG,GENEname)

#		if counter < 5:
		print(line)

