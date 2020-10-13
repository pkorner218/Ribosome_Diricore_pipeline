import sys

filepath = str(sys.argv[1])
Species = str(sys.argv[2])



metapath = filepath + "input/metadata/"

summaryfile = filepath + "summary.txt"
bashfilename = filepath + "/plotall.sh"

outbash = open(bashfilename,"w")

summarylines = open(summaryfile ,"r")

lines = summarylines.readlines()

for line in lines:

	line = line.strip()

	xline = list(line.split("\t"))

	print("")
	print(xline)
	print("")

	print("bash ./main_diriplot_pipe.sh",filepath,xline[0])
	
	print("python3 create_metadata.py",filepath,xline[0])

	outbash.write("python3 ./meta/create_metadata.py "+ " " +  filepath + " " + xline[0] + "\n")
	outbash.write("bash ./main_diriplot_pipe.sh" + " " +  filepath + " " + xline[0] + " " + Species + "\n")
outbash.close()

