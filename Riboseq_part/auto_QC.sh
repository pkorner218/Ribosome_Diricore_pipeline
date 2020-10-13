#!/bin/bash

set -e;
set -u;

pipeline=$(pwd)
projectfolder=$1
species=$2

mkdir -p "${projectfolder}/output/transcript/QC" 2> /dev/null || true;

cp ./QC/ribowaltz_general.txt "${projectfolder}/output/transcript/QC/auto_ribo_QC.R"

cp "${projectfolder}/output/transcript/"*sam.bam "${projectfolder}/output/transcript/QC/"

for file in ${projectfolder}"/output/transcript/QC/"*sam.bam; do echo $file; python3 ./QC/auto_QC.py $file >> "${projectfolder}/output/transcript/QC/auto_ribo_QC.R"; done

cd ${projectfolder}"/output/transcript/QC/"

if [ $species = "human" ]; then
	REFfile=$pipeline"/REF/transcripts/${species}/gencode.v19.annotation.gtf"
	sed -i "s|gencode.v19.annotation.gtf|$REFfile|g" auto_ribo_QC.R
	echo "in1"
	echo $REFfile
fi

if [ $species = "mouse" ]; then
	REFfile=$pipeline"/REF/transcripts/${species}/gencode.vM25.annotation.gtf"
	echo "in2"
	echo $REFfile
	sed -i "s|gencode.v19.annotation.gtf|$REFfile|g" auto_ribo_QC.R
fi

if [ $species = "yeast" ]; then
	echo "in3"
	REFfile=$pipeline"/REF/transcripts/${species}/Saccharomyces_cerevisiae.R64-1-1.100_minstringmRNAall.gtf"
	sed -i "s|gencode.v19.annotation.gtf|$REFfile|g" auto_ribo_QC.R
	echo $REFfile
fi


#REFfile=$pipeline"/REF/human/gencode.v19.annotation.gtf"

#sed -i "s|gencode.v19.annotation.gtf|$REFfile|g" auto_ribo_QC.R

Rscript "auto_ribo_QC.R"

