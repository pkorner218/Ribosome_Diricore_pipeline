#!/bin/bash

set -e;
set -u;

echo "main"

echo $(pwd)

main=$(pwd)

pipeline=$(pwd)"/Riboseq_part/"

a=${#}

if (($a < 1)) || [ $1 == "-h" ] || [ $1 == "-help" ]; then
	echo "";
	echo " usage of main.sh";
	echo "";
	echo " bash main.sh [/path/projectfolder] [species] [adapter] [optional adapter2]";
	echo " usage example: bash main.sh /tests/ human AGATCGGAAGAGCACACGTCT CTGTAGGCACCATCAATATCTCGTATGCCGTCTTCTGCTTG";
	echo "";
	echo " Projectfolder needs to have subfolders /input/fastq/";
	echo " this message can also be obtained with -h or -help";

	exit 1
fi




projectfolder=$main"/"$1"/"

Species=$2

adapter=$3

echo $Species
echo $adapter

############################ variables loaded #######################


cd $projectfolder

mkdir ./input
mkdir ./input/fastq

mv *.gz ./input/fastq

for file in $projectfolder'/input/fastq/'*.gz; do echo $file; done

echo " now in BASH script part / Server "



############################# copied files to folder #########################################

cd ${pipeline}

if (($a > 5)); then
    adapter2=$6

#	parallel bash preprocessing.sh ::: ${projectfolder}"/input/fastq/"*".gz" ::: ${projectfolder} :::  ${Species} :::  ${adapter} ::: ${adapter2}
	bash old_preprocessing.sh ${projectfolder} ${Species} ${adapter} ${adapter2}
else
	bash old_preprocessing.sh ${projectfolder} ${Species} ${adapter}
#	parallel bash preprocessing.sh ::: ${projectfolder}"/input/fastq/"*".gz" ::: ${projectfolder} :::  ${Species} :::  ${adapter}
fi

#parallel bash ./align.sh ::: ${projectfolder}"/output/clean/"*".gz" ::: ${projectfolder} ::: ${Species}
bash ./old_align.sh ${projectfolder} ${Species}

head -15 ${projectfolder}"/output/clean/"*"2.err" >> ${projectfolder}"/output/cutadapt_summaries.txt"

head ${projectfolder}"/output/tophat_out/"*"/align_summary.txt" >> ${projectfolder}"/output/align_summaries.txt"


##################### end of preprocessing #################

mkdir -p ${projectfolder}/output/tophat_out/diri_comparison/ 2> /dev/null || true;

mkdir -p ${projectfolder}/input/metadata/ 2> /dev/null || true;

python3 ./meta/create_plotall.py ${projectfolder} ${Species}

bash ${projectfolder}/plotall.sh

cd ${projectfolder}/output/h5_files/

cd ${pipeline}

####################### end of Diricore Subsequence and RPF density #######

bash copy_final_results.sh ${projectfolder}


