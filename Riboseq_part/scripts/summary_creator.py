import sys

projectfolder = sys.argv[1]

infilestr = str(projectfolder + "/summary.txt")

infile= open(infilestr,"r")

lines = infile.readlines()

x = 0

condlist1  = []
condlist2 = []

for line in lines:

	line = line.strip()

	xline = list(line.split("\t"))

#	print(xline)

	sample1 = xline[1]
	sample2 = xline[2]
	cond1 = xline[3]
	cond2 = xline[4]

	sample1 = sample1.replace(".fastq.gz","")
	sample2 = sample2.replace(".fastq.gz","")
	sample1 = sample1.replace(" ","")
	sample2 = sample2.replace(" ","")

	#condstr = cond2+"\t"+cond1

	if x < 1:
		print("Diricore_" + cond2+"\t"+cond1)
		x += 1

	if sample1 not in condlist1:
		condlist1.append(sample1)
	if sample2 not in condlist2:
		condlist2.append(sample2)


for i in range(len(condlist1)):

#	print(i)
#	print(len(condlist2))

	if (len(condlist2)) > i:

		#istring = condlist2[i]+"\t"+condlist1[i]
#		print(condlist2, condlist1)
		print(condlist2[i]+"\t"+condlist1[i])

