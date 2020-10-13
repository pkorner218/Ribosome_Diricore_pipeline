import sys

projectfolder = sys.argv[1]
projectname = sys.argv[2]



infile = open("auto_temp_rpf_file.txt", "r")

outfile = open(str(projectfolder)+"/output/h5_files/"+str(projectname)+"_rpf_file.txt","w")


outfile.write("codon" + "\t" + "sample1" + "\t" + "sample2" + "\t" + "diff" + "\t" + "position" + "\n")


lines = infile.readlines()

for line in lines:

	print(line)
