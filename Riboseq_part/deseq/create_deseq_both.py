import sys
import os

projectfolder = str(sys.argv[1])

#project_name = str(sys.argv[2])

project_name = list(projectfolder.split("/"))

projectlength = len(project_name)

project_name = project_name[projectlength-2]

print(project_name)


#pipeline = str(sys.argv[2])

samples= [[],[]]
s0 = samples[0]
s1 = samples[1]

indices = [[],[]]

#print(s0,s1)

projectfolder = str(projectfolder) 

print("")
print("herrre",projectfolder)
print("")

infile2str = projectfolder + "/" + "summary.txt"
#infilestr = projectfolder + "/" + "data.txt"

infile2 = open(infile2str,"r")

lines = infile2.readlines()

for line in lines:
	line = line.strip()

	xline = list(line.split("\t"))

	if len(xline) > 1:

#		print(xline)
		s0.append(xline[0])
		s1.append(xline[1])


#print(samples)

#print(s0)
#print(s1)

#print(s0[0])
#print(s1[0])

filenames = []

for file in sorted(os.listdir(projectfolder)):
        filename = os.fsdecode(file)

        if filename.endswith(".out"):
        # print(os.path.join(directory, filename))
#                print(filename)
                filenames.append(projectfolder+filename)



print(filenames)
print("")

conds = []

for item in samples:

	for sub in item:

		for sth in filenames:


#			print("$$$$",sub,sth)

			if sub != s0[0] and sub !=s1[0]: 
				if str(sub) in str(sth):


#					print(sub, item[0], filenames.index(sth))
		
					conds.insert(filenames.index(sth),str(item[0]))

for item in conds:

	item = "'" + item
	item = item + "'"

#print("")
#print("______",conds)
#print(project_name)




condsstr = str(conds)

condsstr = condsstr.replace("[","")
condsstr = condsstr.replace("]","")

#print(condsstr)

print("***********************")
print("samples",samples)
print(len(samples))
print("")

if len(samples[0]) > 2:
	print("multiple")

	infile = open("./deseq/deseq2_template.R", "r")

	lines = infile.readlines()


	outfilestr = str(projectfolder) + "/deseq2_script.R"

	outfile = open(outfilestr,"w")


	for line in lines:


		line = line.replace("sampleCondition<-c('','')","sampleCondition<-c("+condsstr+")")
		line = line.replace("sampleType<-c('','')","sampleType<-c("+condsstr+")")
		line = line.replace("ProjectName",'"' + project_name)
		line = line.replace("COND1",conds[-1])
		line = line.replace("COND2",conds[0])
		outfile.write(line)
	#	print(line)

	outfile.close()


else:

	print(" 1 vs 1")

	infile = open("./deseq/deseq_template.R", "r")

	lines = infile.readlines()

	outfilestr = str(projectfolder) + "/deseq_script.R"

	outfile = open(outfilestr,"w")

#	for sample in samples:
#		sample = sample.replace(".fastq.gz","_accepted_hits.hqmapped.bam")

	for line in lines:

#		print(samples)
#		print(conds)
#		print(samples,conds)

		repl_sample1 = "'" + str(samples[1][1]) + "'"
		repl_sample2 = "'" + str(samples[0][1]) + "'"
		repl_cond1 = str(samples[1][0])
		repl_cond2 = str(samples[0][0])

		line = line.replace("sample2",repl_sample2)
		line = line.replace("sample1",repl_sample1)

		line = line.replace("condition2",repl_cond2)
		line = line.replace("condition1",repl_cond1)

		

		outfile.write(line)

	outfile.close()
