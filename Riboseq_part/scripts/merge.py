import sys
import os

projectfolder = str(sys.argv[1])
#loopfolder = str(sys.argv[2])


filenames = []


listedsummary = projectfolder + "/summary.txt"

listedfile = open(listedsummary)

lines = listedfile.readlines()
listedfiles = []

xcount = 0

for line in lines:
	line = line.strip()

	if xcount < 1:
		xcount = xcount + 1
	else:
		files = list(line.split("\t"))
		listedfiles.append(files[0])
		listedfiles.append(files[1])

#print(listedfiles)

for file in os.listdir(projectfolder):
	if file.endswith("counts.txt"):
#		print(file)
		for item in listedfiles:
			if str(item) in str(file):

				fullfilename = str(projectfolder) + str(file)
				filenames.append(fullfilename)

merge_dict = {}

already = []

filenames = sorted(filenames)

filenames = list(set(filenames))

#print("")
#print("")
#print(filenames)



outname = str(projectfolder) + "/" + "data.txt" 

outfile = open(outname, "w")

for filename in filenames:

	infile = open(filename, "r")

	lines = infile.readlines()

	counter = 0

	for line in lines:

		counter = counter + 1
	
		line = line.strip()

		if already == []:

			merge_dict[counter] = []
			
			xline = list(line.split("\t"))

			for item in xline:	
				merge_dict[counter].append(item)
			#outfile.write(line + "\n")

		else:
			xline = list(line.split("\t"))
			count = xline[3]
			merge_dict[counter].append(count)

	already.append(filename)





#print("")
#print(merge_dict[1])
#print(merge_dict[2])
#print(merge_dict[3])
#print(merge_dict[4])

outfile.write("id\tstart\tend\t")

for name in filenames:

	name = name.replace(".fastq.sam.bam_sort.bam.bed_final.bed_counts.txt","")
	name = name.replace(projectfolder,"")
	outfile.write(str(name)+"\t")

outfile.write("\n")

for k, v in merge_dict.items():

	for item in v:

		item = item.replace(" ","")

		outfile.write(str(item)+"\t")

	outfile.write("\n")

outfile.close()
