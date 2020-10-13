import sys

path = str(sys.argv[1])

nroffiles = int(sys.argv[2])

filenames = []

for i in range(nroffiles):
	i = i+1

	filename = sys.argv[(i+1)+1]

	filenames.append(filename)

#print(filenames)
#print("")

#summaryfile = path + "/summary.txt"
#outsummary = "newsummary.txt"


for filename in filenames:

#	print(filename)
	print("##########################")

	outfilename = filename
	#.replace("summary.txt","mary.txt")

	infile = open(filename, "r")

	lines = infile.readlines()

	conddict = {}
	conddict2 = {}

	conds = []
	samples = []

	headcounter = 0

	for line in lines:

		line = line.strip()
#		print(line)

		if headcounter == 0:

			header = line

#			print("conds are:", header)

			headcounter = headcounter + 1

			c1 = header.split("\t")[0]
			c2 = header.split("\t")[1]

			if c1 not in conds:
				conds.append(c1)
			if c2 not in conds:
				conds.append(c2)

#			print("c1",c1)
#			print("c2",c2)

		else:
#			print("samples are:", line)

			s1 = line.split("\t")[0]
			s2 = line.split("\t")[1]

			if s1 not in samples:
				samples.append(s1)
			if s2 not in samples:
				samples.append(s2)

#			print("c1_2",c1)
#			print("c2_2",c2)
#			print("s1",s1)
#			print("s2",s2)


#			if c1 not in conddict.keys():
#				conddict[c1] = [s1]
#			else:
#				if s1 not in conddict[c1]:
#					conddict[c1].append(s1)
#
#			if c2 not in conddict.keys():
#				conddict[c2] = [s2]
#			else:
#				if s2 not in conddict[c2]:
#					conddict[c2].append(s2)


#			conddict2[s1] = c1
#			conddict2[s2] = c2

#	print("")


#	print(conddict)
#	print(conddict2)

	print("condslist",conds)
	print("sampleslist",samples)

	print("")
	print("************************************")
	print("")

	outfile = open(outfilename,"w")

	for line in lines:

		line = line.strip()

		xline = list(line.split("\t"))

		print(xline)

		if xline[0] in conds:
			print("treatment","(",xline[0],")",int(conds.index(xline[0]))+1,"...treatment","(",xline[1],")",int(conds.index(xline[1]))+1)
			outfile.write("Treatment_" + str(int(conds.index(xline[0]))+1) + "\t" + "Treatment_" + str(int(conds.index(xline[1]))+1) + "\n")

		else:
			print("Sample","(",xline[0],")",int(samples.index(xline[0]))+1,"Sample","(",xline[1],")",int(samples.index(xline[1]))+1)

			outfile.write("Sample_" + str(int(samples.index(xline[0]))+1) + "\t" + "Sample_" + str(int(samples.index(xline[1]))+1) + "\n")

	outfile.close()
