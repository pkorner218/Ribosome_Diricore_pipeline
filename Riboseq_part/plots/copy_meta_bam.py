import sys
import shutil


print("")

projectfolder = sys.argv[1]

filepath = str(projectfolder)+"/input/metadata/samplenames.tsv"

srcpath = str(projectfolder)+"/output/tophat_out/"
destpath = str(projectfolder)+"/output/tophat_out/diri_comparison/"

infile = open(filepath,"r")

lines = infile.readlines()

print(srcpath)
print(destpath)
print("###")
print("")

for line in lines:
#	print(line)
	name = line.split(".fastq.gz")[0]

	print("copying ", name)

	srcn = srcpath+name
	destn = destpath+name

	shutil.copytree(srcn,destn)
