import sys
import csv
import os
import os.path
import matplotlib
import numpy as np
from matplotlib.font_manager import FontProperties

if os.environ.get('DISPLAY','') == '':
#	print("")
#	print('no display found. Using non-interactive Agg backend')
	matplotlib.use('Agg')
#	print("")

import matplotlib.pyplot as plt


filenames = []
plotnames = []
colors = []

nrinputs = int(len(sys.argv))

if nrinputs <= 1 or sys.argv[1] == "-h" or sys.argv[1] == "-help":
	print("")
	print("python3 rpf_density.py [projectfolder] [projectname] [color1] [color...]")
	print("")
	print("script supports up to unlimited standard colors given")
	print("colors should be given in order of files in bash dir")
	print("this information can also be obtained with -h or -help")
	print("")
	quit()


projectfolder = sys.argv[1]

if int(len(sys.argv)) > 2:
	projectname = sys.argv[2]
else:
	projectname = projectfolder.split("/output/transcript")[0]
	print(projectname)
	projectname = projectname.rsplit("/",1)[1]


print("prohjectname",projectname)

projectpre = str(projectfolder) + str(projectname) + "_"

for file in os.listdir(projectfolder):
        filename = os.fsdecode(file)

        if filename.endswith("bam.bed"):
        # print(os.path.join(directory, filename))
                print(filename)
                filenames.append(projectfolder+filename)

filenames = sorted(filenames)
print(filenames)


#for i in range(nroffiles):
#	i = i+1
#	filename = sys.argv[i+1]
#	filenames.append(filename)

print(len(sys.argv))

if int(len(sys.argv)) > 3:

	colornr = int(len(sys.argv)-2)

	for i in range(colornr-1):
		i = i+1
		color = sys.argv[(i+1)+1]
		colors.append(color)

else:
	colors = ["navy","green","crimson","orangered","orange","lightgreen","grey","black","yellow","pink","blue","purple","firebrick"]


print("colors",colors)

master_dict = {}
plot_dict = {}

#colors = ["navy","green","crimson","orangered","orange","green","grey","black"]

#outfile = open("test_peak_genes.txt","w")

def get_relative_read_position(filename):

	X_axis_array = []

	for i in range(300):
		X_axis_array.append(0)

	print("")
	print ("processing ", filename)

	master_dict[filename] = {}

	infile = open(filename,"r")
	lines = infile.readlines()

	#outfile.write(str(filename) + "\n")

	for line in lines:

		if "CDS" in line:

			ENSline = line.split("|")
			ENST = ENSline[0]
			ENSG = ENSline[1]
			Gene = ENSline[5]

			if ENST not in master_dict[filename]:				
				master_dict[filename][ENST] = {}
				master_dict[filename][ENST]["Gene"] = [] 

				master_dict[filename][ENST]["UTR5"] = []
				master_dict[filename][ENST]["CDS"] = []
				master_dict[filename][ENST]["UTR3"] = [] 
				master_dict[filename][ENST]["reads"] = []
				master_dict[filename][ENST]["x_pos"] = []
			
			master_dict[filename][ENST]["Gene"].append(Gene)

			if "UTR5:" in line:

				if "UTR3:" in line:
					line = line.split("|")
					UTR5 = line[7]
					CDS = line[8]
					UTR3 = line[9]
					Reads = line[10]

				else:
					line = line.split("|")
					UTR5 = line[7]
					CDS = line[8]
					UTR3 = None
					Reads = line[9]

			else:
				if "UTR3:" in line:
					line = line.split("|")
					UTR5 = None
					CDS = line[7]
					UTR3 = line[8]
					Reads = line[9]
				else:
					line = line.split("|")
					UTR5 = None
					CDS = line[7]
					UTR3 = None
					Reads = line[8]	

			CDS_xplus = CDS.split(":")[1]

			if CDS_xplus not in master_dict[filename][ENST]["CDS"]:
				master_dict[filename][ENST]["CDS"].append(CDS_xplus)

			CDS_x1 = CDS_xplus.split("-")[0]
			CDS_x2 = CDS_xplus.split("-")[1] 
			CDS_x1 = int(CDS_x1)
			CDS_x2 = int(CDS_x2)

			readsstring = Reads.lstrip("\t")

			read_x1 = readsstring.split("\t")[0]
			read_xplus = readsstring.split("\t")[1]
			read_x2 = read_xplus.split("\t")[0]

			CDS_x1 = int(CDS_x1)
			CDS_x2 = int(CDS_x2)
			read_x1 = int(read_x1)
			read_x2 = int(read_x2)
	
			read_median = read_x1 + 11

			#if read_median not in master_dict[filename][ENST]["reads"]:
			#	if read_median == 
			#	print ("got here with ", read_median)
			
			#	master_dict[filename][ENST]["reads"].append(read_median)

			if UTR5 != None:
				UTR5_xplus = UTR5.split(":")[1]
				UTR5_x1 = UTR5_xplus.split("-")[0]
				UTR5_x2 = UTR5_xplus.split("-")[1]
				UTR5_x1 = int(UTR5_x1)
				UTR5_x2 = int(UTR5_x2)
			else:
				UTR5_x2 = 0

			if UTR5_x2 not in master_dict[filename][ENST]["UTR5"]:
				master_dict[filename][ENST]["UTR5"].append(UTR5_x2)

			if UTR3 != None:
				UTR3_xplus = UTR3.split(":")[1]
				UTR3_x1 = UTR3_xplus.split("-")[0]
				UTR3_x2 = UTR3_xplus.split("-")[1]
				UTR3_x1 = int(UTR3_x1)
				UTR3_x2 = int(UTR3_x2)
				
			else:
				UTR3_x2 = None
			
			if UTR3_x2 not in master_dict[filename][ENST]["UTR3"]:
				master_dict[filename][ENST]["UTR3"].append(UTR3_x2)

						 
			if read_median < CDS_x1:
				point = (float(read_median)/float(UTR5_x2))
				point = float(point)*100
				X_pos = int(point) 
		
				#if X_pos == 67 or X_pos == 68:
				#	outfile.write(str(Gene) + "\t" + str(ENSG) + "\t" + str(ENST) + "\n")  
	
				#X_axis_array[X_pos] = X_axis_array[X_pos] + 1

				
				if X_pos not in master_dict[filename][ENST]["x_pos"]:
					master_dict[filename][ENST]["x_pos"].append(X_pos)
					X_axis_array[X_pos] = X_axis_array[X_pos] + 1		 

						 
			if CDS_x1 <= read_median <= CDS_x2:
				CDS_x2 = float(CDS_x2-UTR5_x2)
				read_median = float(read_median-UTR5_x2)
				point = (float(read_median)/float(CDS_x2))
				point = float(point)*100
				X_pos = int(point) + 100

				if X_pos not in master_dict[filename][ENST]["x_pos"]:
					master_dict[filename][ENST]["x_pos"].append(X_pos)
					X_axis_array[X_pos] = X_axis_array[X_pos] + 1		 


				#X_axis_array[X_pos] = X_axis_array[X_pos] + 1	


				#master_dict[filename][ENST]["x_pos"].append(X_pos)


			if CDS_x2 < read_median:
				UTR3_x2 = float(UTR3_x2-CDS_x2)
				read_median = float(read_median-CDS_x2)
				point = (float(read_median)/float(UTR3_x2))
				point = float(point)*100
				X_pos = int(point) + 200
				#X_axis_array[X_pos] = X_axis_array[X_pos] + 1

				if X_pos not in master_dict[filename][ENST]["x_pos"]:
					master_dict[filename][ENST]["x_pos"].append(X_pos)
					X_axis_array[X_pos] = X_axis_array[X_pos] + 1		 

				

				#master_dict[filename][ENST]["x_pos"].append(X_pos)					

				#if X_pos == 274:
				#	outfile.write(str(Gene) + "\t" + str(ENSG) + "\t" + str(ENST) + "\n")	

	return X_axis_array

for filename in filenames:

	x_axis_array = get_relative_read_position(filename)
	print (x_axis_array)
	xsum = sum(x_axis_array)

	for n, item in enumerate(x_axis_array):
		item = float(item/xsum)
		#item = item*100
		x_axis_array[n] = item 

	plotname = os.path.basename(filename)
	plotname = plotname.split(".")[0]
	plotnames.append(plotname)

	master_dict[filename]["X_array"] = x_axis_array
	plot_dict[plotname] = x_axis_array

f = plt.figure(figsize=(15, 5))

print("")
print("now starting to plot")

for i in range(len(plotnames)):
	plt.plot(plot_dict[plotnames[i]],colors[i],linewidth=0.5, label = plotnames[i])
	i = i + 1

plt.legend(bbox_to_anchor=(1.12,1),loc="upper right", borderaxespad=0., fontsize = 10)

plt.ylabel('RPF density',fontsize = 14)

plt.xticks([25,100,200,275],("5 UTR","CDS START","CDS STOP","3 UTR"),fontsize = 14, weight="bold" )

savename = str(projectpre + 'RPF_density.pdf')

f.savefig(savename)


##############################################################

outfile = open(projectpre + "rpf_summary.csv","w")
outfile2 = open(projectpre + "rpf_R_plotmatrix.csv","w")


outfile2.write("Pos,Value,Sample"+"\n")

names = list(plot_dict.keys())

for i in range(len(names)):
	
	if i != int(len(names)-1):
		#print(names[i]+",")
		outfile.write(names[i]+",")
	else:
		outfile.write(names[i]+"\n")
	

for i in range(len(names)):
#	print(names[i])
#
	for j in range(300):
#		print(plot_dict[names[i]][j],names[i])
		outfile2.write(str(j+1)+","+str(plot_dict[names[i]][j])+","+str(names[i])+"\n")



for j in range(300):
	for i in range(len(names)):
		#print(plot_dict[names[i]][j])

		#print(j)
		#print(i)

		if i != int(len(names)-1):
			outfile.write(str(plot_dict[names[i]][j])+",")
		else:
			outfile.write(str(plot_dict[names[i]][j])+"\n")	



outfile.close()
outfile2.close()





#################################################################################











#print (master_dict)
#print (plot_dict)

#for name, array in plot_dict.items():
	
#	chunks = [array[x:x+100] for x in range(0, len(array), 100)]
#
#	print (name)
#	#print (chunks)
#	print (len(chunks[0]))
#	print (len(chunks[1]))
#	print (len(chunks[2]))
#	print ("")

#	list_UTR5 = chunks[0]
#	list_CDS = chunks[1]
#	list_UTR3 = chunks[2]
#
#3	list_UTR5 = sorted(list_UTR5, reverse = True) 
#3	list_UTR3 = sorted(list_UTR3, reverse = True)

#	print (list_UTR5[0:2])
#	print (list_UTR3[0:2])


#	Peak1_pos_5 = array.index(list_UTR5[0])
#	if float(list_UTR5[1]) >= 0.8:	
#		Peak2_pos_5 = array.index(list_UTR5[1])
#		print ("5_2",Peak2_pos_5)

#	Peak1_pos_3 = array.index(list_UTR3[0])
#	if float(list_UTR3[1]) >= 1:	
#		Peak2_pos_3 = array.index(list_UTR3[1])
#		print ("3_2",Peak2_pos_3)
#
#	print ("5_1",Peak1_pos_5)
#	print ("3_1",Peak1_pos_3)
#	print ("")

#outfile.close()	

#print (master_dict["riboseq_mIFN_merged.fastq.sam.bam_sort.bam.bed"]["ENST00000450898.1"])
