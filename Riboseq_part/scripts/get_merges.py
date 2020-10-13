import sys

filename = str(sys.argv[1])

infile = open(filename,"r")

lines = infile.readlines()

mergedict = {}

for line in lines:

	line = line.strip()

	xline = list(line.split(","))

	singles = xline[0]
	merge = xline[1]

	if merge not in mergedict.keys():

		mergedict[merge] = []
		mergedict[merge].append(singles)
	else:
		mergedict[merge].append(singles)

#print(mergedict)

for key,value in mergedict.items():

	value = str(value)
	value = value.replace("[","")
	value = value.replace("]","")
	value = value.replace("'","")
	value = value.replace(",","")
		
	print("cat",value,">",key)	
