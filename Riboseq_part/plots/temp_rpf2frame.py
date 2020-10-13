import sys

projectfolder = sys.argv[1]
projectname = sys.argv[2]

#if len(sys.argv) > 3:
#	project_aa = sys.argv[3]
#	outfile = open(str(projectfolder)+"/output/h5_files/"+str(projectname)+"_"+str(project_aa)+"_rpf_file.txt","w")
#e##lse:
#	outfile = open(str(projectfolder)+"/output/h5_files/"+str(projectname)+"_rpf_file.txt","w")

#auto_temp_rpf_file.txt

infilestring = "./plots/" + str(projectname) + "_temp_rpf_file.txt" 

infile = open(infilestring,"r")

outfile = open(str(projectfolder)+"/output/h5_files/"+str(projectname)+"_rpf_file.txt","w")


outfile.write("codon" + "\t" + "sample1" + "\t" + "sample2" + "\t" + "diff" + "\t" + "position" + "\n")

lines = infile.readlines()

once = False
skip = False

codon_reads_dict = {}
codons_per_AA = []

for line in lines:

	line = line.strip()

	if "*" in line:

		codons_per_AA = []
		skip = False
		once = False

	if "'" in line:
		line = line.replace("'","")

		if line not in codon_reads_dict.keys():
			codon_reads_dict[line] = {}
			codon_reads_dict[line]["sample1"] = []
			codon_reads_dict[line]["sample2"] = []

			codons_per_AA.append(line)
	else:
		if "[" in line:

			line = line.replace("[',[","[")
			line = line.replace("['[","[")
			line = line.replace(",[","[")

			line = line.replace("[[[", "[")
			line = line.replace("[[", "[")
			line = line.replace("]]]", "]")
			line = line.replace("]]", "]")
			line = line.replace("], ", "]")	

			c = 0

			if len(codons_per_AA) == 1:

				for sample in range(2):

					for codon_nr in range(int(len(codons_per_AA))):

						listed = line.split("]")[sample]

						if len(codons_per_AA) == 1:
							if sample == 0:
								codon_reads_dict[codons_per_AA[codon_nr]]["sample1"]=listed.replace("[","")

							if sample == 1:
								codon_reads_dict[codons_per_AA[codon_nr]]["sample2"]=listed.replace("[","")

			if len(codons_per_AA) > 1:
				for j in range(2):

					for i in range(int(len(codons_per_AA))):
						if str(line.split("]")[c]) != "":

							if j == 0:
								codon_reads_dict[codons_per_AA[i]]["sample1"]=line.split("]")[c].replace("[","")
							if j == 1:
								codon_reads_dict[codons_per_AA[i]]["sample2"]=line.split("]")[c].replace("[","")


						else:
							skip = True
							codon_reads_dict[codons_per_AA[i]]["sample2"]=line.split("]")[c].replace("[","")


						if skip:
							if not once:
								c = c + 1
								once = True
						c = c + 1


for key in codon_reads_dict.keys():
	for i in range(101):
		print(key)
		print(key,codon_reads_dict[key]["sample1"].split(", ")[i], codon_reads_dict[key]["sample2"].split(", ")[i],i-30 )
		outfile.write(key + "\t" + codon_reads_dict[key]["sample1"].split(", ")[i] + "\t" + codon_reads_dict[key]["sample2"].split(", ")[i] + "\t" + str(float(codon_reads_dict[key]["sample2"].split(", ")[i]) - float(codon_reads_dict[key]["sample1"].split(", ")[i])) + "\t" + str(i-30) + "\n")

outfile.close()






