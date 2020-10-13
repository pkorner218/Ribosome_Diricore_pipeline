
import sys

filename = str(sys.argv[1])

Species = str(sys.argv[2])

infile = open(filename,"r")

lines = infile.readlines()

#outfilename = str(filename+"_final.bed")

#outfile = open(outfilename, "w")
#counter = 0

for line in lines:

	line = line.strip()

	if Species == "yeast":

		x = list(line.split("\t"))
		ID = x[0]
	else:

		ID = list(line.split("|"))[0]
		x = list(line.split("|"))[-1]
		x = list(x.split("\t"))

	start = x[1]
	end = x[2]

	strand = x[5]

	diff = (int(end) - int(start)) + 1

	string = str(ID) + "\t" + str(start) + "\t" + str(end) + "\t" + str(diff) + "\t" + str(strand)

	print(string)
