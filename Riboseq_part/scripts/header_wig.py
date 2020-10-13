import sys
import os
import os.path

path = str(sys.argv[1])

#print(path)

filenames = []

for file in os.listdir(path):
        filename = os.fsdecode(file)

        if filename.endswith(".wig"):
                filenames.append(filename)

filenames = sorted(filenames)

for filename in filenames:

	infile = open(filename, "r")
	lines = infile.readlines()

#	print(lines)

	#trackname = filename.replace("_accepted_hits.hqmapped.bam_sort.bam.wig", "")
	#outfilename = filename + ".wig"

	outfilename = filename.replace("_accepted_hits.hqmapped.bam","")
	outfilename = outfilename.replace(".bam_sort.bam.wig",".wig")

	#outfilename = filename.replace("_accepted_hits.hqmapped.bam_sort.bam.wig",".wig")

	trackname = filename.replace("_accepted_hits.hqmapped.bam","")
	trackname = trackname.replace(".bam_sort.bam.wig","")

	trackname = "track name='" + trackname + "' visibility='full' type=wig"

	outfile = open(outfilename,"w")

	print(outfilename)

	outfile.write(trackname + "\n")

	for line in lines:

		outfile.write(line)

	outfile.close()
