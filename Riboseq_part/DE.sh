#!/bin/bash

pipeline=$(pwd)

projectfolder=$1
species=$2

if [ $species = "human" ]; then

	REFfile=./REF/transcripts/human/gencode.v19.annotation.gtf

	echo "in1"
	echo $REFfile
fi

if [ $species = "mouse" ]; then
	REFfile=./REF/transcripts/mouse/gencode.vM25.annotation.gtf
	echo "in2"
	echo $REFfile
fi

if [ $species = "yeast" ]; then
	echo "in3"
	REFfile=./REF/transcripts/yeast/Saccharomyces_cerevisiae.R64-1-1.100.gtf
	echo $REFfile
fi


#bash ./scripts/copy_diribam.sh ${projectfolder}/output/tophat_out/ ${projectfolder}/output/htseq_out/ hqmapped.bam

#for file in ${projectfolder}"/output/htseq_out/"*".bam"; do echo $file; samtools view -h $file > ${file}".sam"; done

#for file in ${projectfolder}"/output/htseq_out/"*".sam"; do echo $file ; htseq-count -s no -t exon ${file} ${REFfile} > ${file}".out"; done

#cd  ${projectfolder}"/output/htseq_out/"

#for file in *"summary.txt"; do grep -m1 "" $file | sed 's/\t/-/g' | while read header; do echo $header ; mkdir -p $header 2> /dev/null || true; cp $file $header"/summary.txt" ; done ; done

#for dir in *"/" ; do echo $dir; tail -n+2 $dir"/summary.txt" | awk -F "\t" '{print $1 "\n" $2}' | while read sample; do cp $sample*".out" $dir"/"; done ; done

cd ${pipeline}

for dir in ${projectfolder}"/output/htseq_out/"*"/";

	do

	echo ${dir}

#####	cp ${projectfolder}"/output/htseq_out/"*".out" ${dir}

#	python3 ./deseq/create_deseq_both.py  ${dir}

	cd ${dir}

#	cat "./summary.txt"

	if (($(wc -l <"./summary.txt") <= 2 ));then
		echo " 1 vs 1"
#		cat summary.txt

#		Rscript ${dir}/deseq_script.R

#		cp ${dir}/*tab_All*.csv ${dir}"DESEQ.txt"
#		sed -i '1d' ${dir}/*DESEQ.txt
#		sed -i '1i ID\tbaseMean\tbaseMeanA\tbaseMeanB\\tFoldChange\tlog2FoldChange\tpvalue\tpadj' ${dir}/*DESEQ.txt

		cd ${pipeline}

		python3 translateENSG2NAME.py $dir/*DESEQ.txt $species > $dir/GENE_DESEQ.txt

		sed -i '1i ID\tbaseMean\tbaseMeanA\tbaseMeanB\tFoldChange\tlog2FoldChange\tpvalue\tpadj' ${dir}/*DESEQ.txt

	else
		echo "larger 1"

#		Rscript ${dir}/deseq2_script.R

#		sed -i '1d' ${dir}/*_DESEQ2.txt
#		sed -i '1i ID\tbaseMean\tlog2FoldChange\tlfcSE\tstat\tpvalue\tpadj' ${dir}/*_DESEQ2.txt

		cd ${pipeline}

		python3 translateENSG2NAME.py $dir/*DESEQ2.txt $species > $dir/GENE_DESEQ2.txt

		sed -i '1i ID\tbaseMean\tlog2FoldChange\tlfcSE\tstat\tpvalue\tpadj' ${dir}/*DESEQ2.txt

	fi;
#

done

cd ${pipeline}

####sed -i '1i ID\tbaseMean\tlog2FoldChange\tlfcSE\tstat\tpvalue\tpadj' ${projectfolder}/output/htseq_out/GENE_auto_test_DESEQ2.txt
