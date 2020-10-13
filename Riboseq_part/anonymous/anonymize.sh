#!/bin/bash

set -e;
set -u;

a=${#}

projectfolder=$1

Counter=1




for file in ${projectfolder}"/input/fastq/"*.gz; do
	echo "here we have" $file; FILE=${file##*/};
	echo $Counter;

	mv ${file} ${projectfolder}/input/fastq/Sample_${Counter}_fastq.gz;

	echo ${file##*/};

	sed -i "s|"${FILE}"|Sample_"${Counter}".fastq.gz|g" ${projectfolder}"/summary.txt"; 
	
	echo "";Counter=$[$Counter+1];
	echo ${FILE%.fastq.gz};

done

python3 ./anonym.py ${projectfolder}

mv ${projectfolder}"/newsummary.txt" ${projectfolder}"/summary.txt"

for file in ${projectfolder}/*BumpDEsummary.txt;

	do
		echo $file
		args+=("$file");

	done;

python3 ./anonymBump.py ${projectfolder} ${#args[@]} ${args[@]}

echo ""
echo ""

