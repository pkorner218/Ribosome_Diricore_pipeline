#!/bin/bash

set -e;
set -u;

a=${#}

if (($a < 1)) || [ $1 == "-h" ] || [ $1 == "-help" ]; then
	echo "";
	echo " usage of main_bumpfinder_pipe.sh";
	echo "";
	echo " bash main_bumpfinder_pipe.sh [/path/projectfolder] [species]";
	echo " usage example: bash main_riboseq_pipe.sh /DATA/pkoerner/packages/bumpfinder/tests/12T_test/ human" ;
	echo "";
	echo " Projectfolder containing bam.bed files and a summary.txt file ";
	echo " summary.txt file is a tab separeted file build up like described below. Important Note ! the Sampleames are only the prefixes without any .extension";
	echo ""
	echo " 1st line:  Controlname	TreatmentName";
	echo " 2nd line:  Control Samplename	Treatment Samplename";
	echo " ... urether samplenames as line2";
	echo "";
	echo "          this message can also be obtained with -h or -help";

	exit 1
fi

#pipeline=$(pwd)

projectfolder=$1

Species=$2

pipeline=$3

bumpfolder=${projectfolder}"/"

echo ${projectfolder} "#####################"

CDSFile=${pipeline}"/REF/bumpfinder/${Species}/CDS.bed"

if [ $Species = "human" ]; then
	PEPfile="/gencode.v19.pc_translations.fa"
fi

if [ $Species = "mouse" ]; then
	PEPfile="/gencode.vM25.pc_translations2.fa"
fi

if [ $Species = "yeast" ]; then
        PEPfile="/Saccharomyces_cerevisiae.R64-1-1.pep.all_min_mRNAstring_2.fa"
fi


cut -f1 ${bumpfolder}"/data.txt" | sort -u > ${bumpfolder}"/ids.txt"

python3 ${pipeline}/scripts/data_profiler.py ${bumpfolder} ${pipeline} > ${bumpfolder}"/profiler.R"

echo ""
echo "now running Rprofiler, this script might take a while"
echo ""

cd ${bumpfolder}

Rscript ${bumpfolder}"/profiler.R"

echo ""
echo "now identification of bumps"
echo ""

mkdir -p ${bumpfolder}"/identify_bumps/" 2> /dev/null || true;

cp ${bumpfolder}"/GENE_DETAILS.txt" ${bumpfolder}"/identify_bumps/"

grep "id" ${bumpfolder}"/data.txt" | sed 's/$/minus\tplus\taverage\tplus_log\tminus_log\tplus_log_norm\tminus_log_norm\tprof\tprof_norm /' | while read header; do sed -i "1 i$header" ${bumpfolder}"/identify_bumps/GENE_DETAILS.txt"; done

cd ${bumpfolder}"/identify_bumps/"

cp ${pipeline}/scripts/script_1.R ${bumpfolder}"/identify_bumps/"
cp ${pipeline}/scripts/script_2.R ${bumpfolder}"/identify_bumps/"

Rscript script_1.R

bash ${pipeline}/scripts/bedtools.sh ${bumpfolder}

Rscript script_2.R

echo ""
echo "now starting separate bumpfinder analysis for PLUS and MINUS signals"
echo ""

echo -ne "\PLUS\nMINUS
" | while read condition groupstr; do

	echo ""
	echo $condition;
	echo ""

	mkdir -p  ${bumpfolder}"/identify_bumps/"${condition} 2> /dev/null || true;

	cp ${bumpfolder}"/identify_bumps/"${condition}"_ONLY_AWAY_DETAILED.xls" ${bumpfolder}"/identify_bumps/"${condition}

	awk '{print $1 "\t" }' ${bumpfolder}"/identify_bumps/"${condition}"_ONLY_AWAY_DETAILED.xls" | sed 's/_/\t/g' | sed '1d' > ${bumpfolder}"/identify_bumps/${condition}/"${condition}"_ONLY_AWAY_DETAILED.bed"

	cp ${pipeline}/scripts/script_3_.R ${bumpfolder}"/identify_bumps/"${condition}"/script_3_"${condition}".R"

	sed -i "s|_ONLY_AWAY_DETAILED.bed|"${condition}"_ONLY_AWAY_DETAILED.bed|g" ${bumpfolder}"/identify_bumps/"${condition}"/script_3_"${condition}".R"

	cd ${bumpfolder}"/identify_bumps/"${condition}

	sed -i "s|CDS.bed|$CDSFile|g" "script_3_"${condition}".R"

	Rscript "./script_3_"${condition}".R"

	awk '{print $1 "\t" $7 -29 "\t" $7 +29}' ${bumpfolder}"/identify_bumps/"${condition}"/bumps_cds_atleast30.txt" | sed '1d' > ${bumpfolder}"/identify_bumps/"${condition}"/bumps_30each.bed"

	if [ $Species = "human" ]; then
		cp ${pipeline}"/scripts/sequence_extractor.pl" ${bumpfolder}"/identify_bumps/"${condition}/
	else
		cp ${pipeline}"/scripts/sequence_extractor2.pl" ${bumpfolder}"/identify_bumps/"${condition}"/sequence_extractor.pl"
	fi

	sed -i "s|species|${Species}|g" ${bumpfolder}"/identify_bumps/"${condition}"/sequence_extractor.pl"
	sed -i "s|_translations.fa|${PEPfile}|g" ${bumpfolder}"/identify_bumps/"${condition}"/sequence_extractor.pl"

	perl "./sequence_extractor.pl" ${pipeline} | sort -u > "bumps_30_each.txt"

	echo -ne "\A\nC\nD\nE\nF\nM\nN\nG\nH\nI\nK\nL\nP\nQ\nR\nS\nT\nV\nY\nW\n" | while read aa codongroupstr; do
		cut -f5 bumps_30_each.txt | sed "s/${aa}/1\t/g" | sed 's/[A-Z]/0\t/g' | cut -f1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,49,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58 > ${aa}".txt";
		done;

	cp ${pipeline}"/scripts/plot_bumpfinder.R" "./"${condition}"_plot_bumpfinder.R"

	sed -i "s|_ONLY_AWAY_DETAILED.bed|"${condition}"_ONLY_AWAY_DETAILED.bed|g" ${condition}"_plot_bumpfinder.R"
	sed -i "s|CDS.bed|$CDSFile|g" ${condition}"_plot_bumpfinder.R"

	echo ""
	echo "now Plotting"
	echo ""

	Rscript "./"${condition}"_plot_bumpfinder.R"

	cd ${projectfolder}

	done;

echo ""
echo "---- Bumpfinder has finished ---"
echo ""

