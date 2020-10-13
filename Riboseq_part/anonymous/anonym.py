import sys

path = str(sys.argv[1])
summaryfile = path + "/summary.txt"

outsummary = path + "newsummary.txt"

infile = open(summaryfile, "r")

lines = infile.readlines()

conddict = {}
conddict2 = {}

conds = []

for line in lines:

	line = line.strip()

	xline = list(line.split("\t"))

	print(xline)

	label = xline[0]

	s1 = xline[1]

	s2 = xline[2]

	c1 = xline[3]

	c2 = xline[4]

	print(c1,c2)

	ls1 = s1.strip(".fastq.gz")
	ls2 = s2.strip(".fastq.gz")

	print(ls1,"vs",ls2, "...",s1,"...",s2,"...")


	if c1 not in conds:
		print(c1,"###")
		conds.append(c1)

	if c2 not in conds:
		conds.append(c2)

	conddict[c1] = ls1
	conddict[c2] = ls2

	conddict2[ls1] = c1
	conddict2[ls2] = c2

print("")
print(conddict)
print("")
print(conddict2)
print("")
print(conds)
print("")

#for treatment in conds:

#	print(treatment,"...","treatment_",conds.index(treatment))

#	print(conddict[treatment],"treatment_",conds.index(treatment))


outfile = open(outsummary, "w")

for line in lines:

	
	line = line.strip()

	xline = list(line.split("\t"))

	print(xline)

	label = xline[0]

	s1 = xline[1]

	s2 = xline[2]

	c1 = xline[3]

	c2 = xline[4]


	ls1 = s1.strip(".fastq.gz")
	ls2 = s2.strip(".fastq.gz")

	print(ls1,"vs",ls2, "...",s1,"...",s2,"...","treatment_",int(conds.index(conddict2[ls1]))+1, "treatment_",int(conds.index(conddict2[ls2]))+1)

	outfile.write(str(ls1) + "_vs_" + str(ls2) + "\t" + str(s1) + "\t" + str(s2) + "\t" + "treatment_" + str(int(conds.index(conddict2[ls1]))+1) + "\t" + "treatment_" + str(int(conds.index(conddict2[ls2]))+1) + "\n")

outfile.close()
