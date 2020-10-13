#!/bin/bash

set -e;
set -u;

projectfolder=$1
species=$2
pipeline=$(pwd)

wigdir="${projectfolder}/output/wig/"

mkdir -p "${wigdir}" 2> /dev/null || true;

bash ./scripts/copy_diribam.sh ${projectfolder}/output/tophat_out/ ${wigdir} hqmapped.bam

cd ${wigdir}


if [ $species = "mouse" ]; then

	for file in *bam; do echo $file; samtools view -h $file | awk 'BEGIN{FS=OFS="\t"} (/^@/ && !/@SQ/){print $0} $2~/^SN:[1-9]|^SN:X|^SN:Y|^SN:MT/{print $0}  $3~/^[1-9]|X|Y|MT/{$3="chr"$3; print $0} ' | sed 's/SN:/SN:chr/g' | sed 's/chrMT/chrM/g' | samtools view -bS - > $file"_chr.bam"; done
	rm *hqmapped.bam
fi


echo ""
echo "now sort"
for file in *.bam; do echo $file; samtools sort $file $file"_sort"; done

echo ""
echo "now index"
for file in *sort.bam; do echo $file; samtools index $file; done

echo ""
echo "now wig"

echo $species

if [ $species = "human" ]; then
	REFfile=hg19.chrom.sizes
	echo "in1"
	echo $REFfile
fi

if [ $species = "mouse" ]; then
	REFfile=mouse_mm10.chrom.sizes
	echo "in2"
	echo $REFfile
fi

if [ $species = "yeast" ]; then
	echo "in3"
	REFfile=sacCer3_chrom.sizes
	echo $REFfile
fi

parallel --link python ${pipeline}"/scripts/bam2wig.py" -s ${pipeline}"/REF/transcripts/${species}/${REFfile}" -i ::: *sort.bam ::: -o ::: *sort.bam

#for file in *sort.bam; do echo $file; python $pipeline"/scripts/bam2wig.py" -s $pipeline"/REF/${species}/$REFfile" -i $file -o $file; done

echo ""
echo "now wig header"
python3 $pipeline"/scripts/header_wig.py" ${wigdir}

echo ""
echo "DONE"

if [ $species = "yeast" ]; then
	for file in *.wig; do echo $file; sed -i "s/chrom=/chrom=chr/g" ${file}; done
fi
