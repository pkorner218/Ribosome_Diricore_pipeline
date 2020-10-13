import sys

projectfolder = str(sys.argv[1])
pipeline = str(sys.argv[2])

samples= [[],[]]
s0 = samples[0]
s1 = samples[1]

indices = [[],[]]

#print(s0,s1)

infile2str = projectfolder + "/" + "summary.txt"
infilestr = projectfolder + "/" + "data.txt"

infile2 = open(infile2str,"r")

lines = infile2.readlines()

for line in lines:
	line = line.strip()

	xline = list(line.split("\t"))

	if len(xline) > 1:

#		print(xline)
		s0.append(xline[0])
		s1.append(xline[1])


infile = open(infilestr, "r")

lines = infile.readlines()

dataline = list(lines[0].split("\t"))

#print("")
#print(dataline)
#print(samples)


#print("")

counter = 0

templatestr = pipeline + "/scripts/profiler_template.R"

infile = open(templatestr,"r")

lines = infile.readlines()



for sample in samples:

	for x in sample:
		x = x.replace(" ","")

	for string in sample:
		if string in dataline:

#			print(counter,samples[counter][0],string,int(dataline.index(string)) + 1)

			indices[counter].append(int(dataline.index(string)) + 1)

	counter = counter + 1

#print(indices)
#print("")
#print("")

for line in lines:
	
	line = line.strip()


	if len(indices[0]) > 1:
		if "gene$minus = Means1" in line:
			line = line.replace("gene$minus = Means1","gene$minus = rowMeans(gene[,c("+str(indices[0])+")])")
			line = line.replace("c([","c(")
			line = line.replace("])])",")])")
		if "gene$plus = Means2" in line:
			line = line.replace("gene$plus = Means2","gene$plus = rowMeans(gene[,c("+str(indices[1])+")])")
			line = line.replace("c([","c(")
			line = line.replace("])])",")])")

	else:
		if "gene$minus = Means1" in line:
			line = line.replace("gene$minus = Means1","gene$minus = gene[," + str(indices[0]) + "]")
			line = line.replace("gene[,[","gene[,")
			line = line.replace("]]","]")	
		if "gene$plus = Means2" in line:
			line = line.replace("gene$plus = Means2","gene$plus = gene[," + str(indices[1]) + "]")
			line = line.replace("gene[,[","gene[,")
			line = line.replace("]]","]")
	print(line)


