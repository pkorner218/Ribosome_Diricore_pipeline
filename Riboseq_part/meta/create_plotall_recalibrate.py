import sys

filepath = str(sys.argv[1])

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

	print("bash /DATA/pkoerner/packages/diricore/actualpipe/plot/singleAA_rpf_ploting.sh",filepath,xline[0])

	print("python3 create_metadata.py",filepath,xline[0])

	outbash.write("python3 /DATA/pkoerner/packages/diricore/actualpipe/meta/create_metadata.py "+ " " +  filepath + " " + xline[0] + "\n")
	outbash.write("bash /DATA/pkoerner/packages/diricore/actualpipe/plots/singleAA_rpf_ploting.sh" + " " +  filepath + " " + xline[0] + " " + "TRP" + "\n")
	outbash.write("bash /DATA/pkoerner/packages/diricore/actualpipe/plots/singleAA_rpf_ploting.sh" + " " +  filepath + " " + xline[0] + " " + "CYS" + "\n")
	outbash.write("bash /DATA/pkoerner/packages/diricore/actualpipe/plots/singleAA_rpf_ploting.sh" + " " +  filepath + " " + xline[0] + " " + "ATG_split" + "\n")
outbash.close()

