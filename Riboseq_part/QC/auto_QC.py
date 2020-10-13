import sys

filename = str(sys.argv[1])

#print(filename)

filename = filename.replace(".bam","")

filename = filename.split("QC/")[1]

#print("here",filename)

infile = open("./QC/ribowaltz_all_files.txt","r")

lines = infile.readlines()

for line in lines:
	
	if "here_name" in line:

		if not "df <-" in line:		
			line = line.replace("here_name","'"+filename)
		else:
			line = line.replace("here_name","`"+filename)

	print(line)
