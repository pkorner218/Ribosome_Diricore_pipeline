#!/bin/bash

set -e;
set -u;

projectfolder=$1
species=$2 

pipeline=$(pwd)

mkdir -p "${projectfolder}/output/transcript/" 2> /dev/null || true;

cd ${projectfolder}"/output/clean/"

cp *.gz ${projectfolder}"/output/transcript/"

echo $species

if [ $species = "human" ]; then
	REFfile=gencode.v19.pc_transcripts.fa
	echo "in1"
	echo $REFfile
fi

if [ $species = "mouse" ]; then
	REFfile=gencode.vM25.pc_transcripts.fa
	echo "in2"
	echo $REFfile
fi

if [ $species = "yeast" ]; then
        REFfile=Saccharomyces_cerevisiae.R64-1-1.cds_minstringmRNAall.fa
        echo "in3"
        echo $REFfile
fi


cd $pipeline"/REF/transcripts/$species/"

ls -1 ${projectfolder}"/output/transcript/"*.fastq.gz | while read fn; do
	echo ${fn};
	gunzip ${fn};
	nfn=${fn%.*}
	echo ${nfn}
	bowtie -S ${REFfile} ${nfn} ${nfn}".sam" > ${nfn}".log" 2>&1;
	done

cd $pipeline

echo "finished alignment"

for file in ${projectfolder}"/output/transcript/"*.fastq.sam; do echo $file; samtools view -Sb $file > $file".bam"; done

echo "finished sam2bam conversion"

for file in ${projectfolder}"/output/transcript/"*.fastq.sam.bam; do echo $file; samtools sort $file $file"_sort"; done

for file in ${projectfolder}"/output/transcript/"*.fastq.sam.bam_sort.bam; do echo $file; samtools index $file; done

echo "finished sorting and indexing"

for file in ${projectfolder}"/output/transcript/"*.fastq.sam.bam_sort.bam; do echo $file; bamToBed -i $file > $file".bed"; done

echo "finished bamtobed conversion"


