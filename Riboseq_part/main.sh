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
	echo " bash main.sh [/path/projectfolder] [species] [anonymous] [email adress] [adapter] [optional adapter2]";
	echo " usage example: bash main.sh /tests/ human [Yes/No] email@test AGATCGGAAGAGCACACGTCT CTGTAGGCACCATCAATATCTCGTATGCCGTCTTCTGCTTG";
	echo "";
	echo " Projectfolder needs to have subfolders /input/fastq/";
	echo " The anonymous variable defaults to no if nothing is given in the shiny. For command line usage please enter yes or no"
	echo " If the shiny is used outside of the Webserver the email adress has no function. However the user is asked to enter some string here (example: 'None') and not leave the field empty! "
	echo "";
	echo "          this message can also be obtained with -h or -help";

	exit 1
fi




projectfolder=$main"/"$1"/"

Species=$2

anonymous=$3

email=$4

adapter=$5


echo $Species
echo $anonymous
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

mergefile=${projectfolder}"/mergefile.txt"

if [ -f "$mergefile" ]; then
	echo "${mergefile} exists"

	python3 ./scripts/get_merges.py ${mergefile} > ${projectfolder}"/input/fastq/merge.sh"
	cd ${projectfolder}"/input/fastq/"
	bash "merge.sh"

else
	echo "${mergefile} does not exist"
fi

cd ${pipeline}

########################## fastq files merged ##################

python3 ./scripts/summary_creator.py ${projectfolder} > ${projectfolder}"/1_BumpDEsummary.txt"

##############################################

if [ "$anonymous" = "Yes" ]; then
	echo "annonymous yes"
	cd ./anonymous/
	bash anonymize.sh ${projectfolder}
fi

####################### Sample and Conditions names have been anonymized #############

cd ${pipeline}

if (($a > 5)); then
    adapter2=$6

	parallel bash preprocessing.sh ::: ${projectfolder}"/input/fastq/"*".gz" ::: ${projectfolder} :::  ${Species} :::  ${adapter} ::: ${adapter2}
#	bash old_preprocessing.sh ${projectfolder} ${Species} ${adapter} ${adapter2}
else
#	bash old_preprocessing.sh ${projectfolder} ${Species} ${adapter}
	parallel bash preprocessing.sh ::: ${projectfolder}"/input/fastq/"*".gz" ::: ${projectfolder} :::  ${Species} :::  ${adapter}
fi

parallel bash ./align.sh ::: ${projectfolder}"/output/clean/"*".gz" ::: ${projectfolder} ::: ${Species}
#bash ./old_align.sh ${projectfolder} ${Species}

head -15 ${projectfolder}"/output/clean/"*"2.err" >> ${projectfolder}"/output/cutadapt_summaries.txt"

head ${projectfolder}"/output/tophat_out/"*"/align_summary.txt" >> ${projectfolder}"/output/align_summaries.txt"


##################### end of preprocessing #################

bash ./fastqClean2SortBamBed.sh ${projectfolder} ${Species}

head -15 ${projectfolder}"/output/transcript/"*"log" >> ${projectfolder}"/output/transcript_summaries.txt"

bash ./UCSC_track.sh ${projectfolder} ${Species}

if [ $Species != "yeast" ]; then
	bash ./auto_QC.sh ${projectfolder} ${Species}
	python3 ./transcript_densities/rpf_density2.py ${projectfolder}"/output/transcript/QC/" ${Species}
	python3 ./transcript_densities/transcript_rpf_frame.py ${projectfolder}"/output/transcript/QC/" ${Species}
fi

##################### end of Quality Control ,UCSC, and per transcrip as well as global RPF density #######

mkdir -p ${projectfolder}/output/tophat_out/diri_comparison/ 2> /dev/null || true;

mkdir -p ${projectfolder}/input/metadata/ 2> /dev/null || true;

python3 ./meta/create_plotall.py ${projectfolder} ${Species}

bash ${projectfolder}/plotall.sh

cd ${projectfolder}/output/h5_files/

for file in *.txt; do  echo $file; awk -v a=$file '{print a "_" $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 }' $file | grep -v -e "codon" | sed 's/_rpf_file.txt//g' >> all_rpf_shiny.txt; done; sed -i '1i codon\tsample1\tsample2\tdiff\tposition' all_rpf_shiny.txt

cd ${pipeline}

####################### end of Diricore Subsequence and RPF density #######


mkdir -p ${projectfolder}/output/bumpfinder/ 2> /dev/null || true;

cp ${projectfolder}/*_BumpDEsummary.txt ${projectfolder}/output/bumpfinder/

cp ${projectfolder}/output/transcript/*bam.bed ${projectfolder}/output/bumpfinder/

bash first_bumpfinder_pipe.sh ${projectfolder}/output/bumpfinder/ ${Species}



####################### end of bumpfinder #############################

mkdir -p ${projectfolder}/output/htseq_out/ 2> /dev/null || true;

cp ${projectfolder}/*_BumpDEsummary.txt ${projectfolder}/output/htseq_out/

bash DE.sh ${projectfolder} ${Species}


############## end of Differential expression analysis #######

bash copy_final_results.sh ${projectfolder}


