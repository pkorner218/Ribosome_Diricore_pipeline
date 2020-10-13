import sys
import os

filepath = str(sys.argv[1])

experimentname = str(sys.argv[2])

#print(experimentname)

metapath = filepath + "input/metadata/"

summaryfile = filepath + "summary.txt"

summarylines = open(summaryfile ,"r")

lines = summarylines.readlines()

wanted = []

for line in lines:

	line = line.strip()
	xline = list(line.split("\t"))

#	print(xline[0])

	if experimentname == xline[0]:
		print(xline)

		wanted = xline


cwd = os.getcwd()
originpath = cwd + "/meta/"
#originpath = "/DATA/pkoerner/packages/diricore/actualpipe/meta/"



rpf_density_file = originpath + "rpf_density_contrasts.tsv"
samplenames_file = originpath + "samplenames.tsv"
subsequence_file = originpath + "subsequence_contrasts.tsv"

rpf_density_file_out = metapath + "rpf_density_contrasts.tsv"
samplenames_file_out = metapath + "samplenames.tsv"
subsequence_file_out = metapath + "subsequence_contrasts.tsv"



infile1 = open(rpf_density_file,"r")
outfile1 = open(rpf_density_file_out,"w")
lines = infile1.readlines()



for line in lines:
	print(line)
	line = line.replace("sample_Tr",wanted[1])
	line = line.replace("sample_Ctrl",wanted[2])
	outfile1.write(line)
outfile1.close()

os.chmod(rpf_density_file_out, 0o777)


infile2 = open(samplenames_file,"r")
outfile2 = open(samplenames_file_out,"w")
lines = infile2.readlines()

for line in lines:
	line = line.replace("sample_Tr",wanted[1])
	line = line.replace("sample_Ctrl",wanted[2])
	line = line.replace("condition_Tr",wanted[3])
	line = line.replace("condition_Ctrl",wanted[4])
	outfile2.write(line)
outfile2.close()

os.chmod(samplenames_file_out, 0o777)


infile3 = open(subsequence_file,"r")
outfile3 = open(subsequence_file_out,"w")
lines = infile3.readlines()

for line in lines:
	line = line.replace("sample_Tr",wanted[1])
	line = line.replace("sample_Ctrl",wanted[2])
	outfile3.write(line)
outfile3.close()

os.chmod(subsequence_file_out, 0o777)
