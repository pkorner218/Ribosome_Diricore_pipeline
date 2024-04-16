#!/bin/bash

set -e;
set -u;

echo "main diricore plots"

a=${#}

if (($a < 1)) || [ $1 == "-h" ] || [ $1 == "-help" ]; then
	echo "";
	echo " usage of main_diriplot_pipe.sh";
	echo "";
	echo " bash main_diriplot_pipe.sh [/path/projectfolder] [projectname] [optional species] [optional subseq_min_reds] [optional rpf_min_reads]";
	echo " usage example: bash main_diriplot_pipe.sh /DATA/pkoerner/packages/diricore/tests/ 3_vs_1_new";
	echo "";
	echo " species defaults to human; other option supported is mouse";
	echo " subseq_min_reads defaults to 100";
	echo " rpf_min_reads defaults to 25";
	echo "";
	echo "          this message can also be obtained with -h or -help";

	exit 1
fi


projectfolder=$1;

projectname=$2;

#if (($a > 2)); then
Species=$3;
#else
 #       species="human";
#fi

echo " got species" ${Species}

if (($a > 3)); then
        subseq_min_reads=$4;
        echo "got min subseq as " $subseq_min_reads
else
        subseq_min_reads=100;
fi

if (($a > 4)); then
        rpf_min_reads=$5;
        echo "got min rpf as" $rpf_min_reads
else
        rpf_min_reads=100;
fi

rm -rf ${projectfolder}/output/tophat_out/diri_comparison/*

python3 ./plots/copy_meta_bam.py ${projectfolder}

bash ./subsequence_analysis.sh ${projectfolder} ${projectname} ${Species}

bash ./rpf_density_mapping.sh ${projectfolder} ${projectname} ${Species}

echo ${projectfolder} ${projectname}

#python3 ./plots/temp_rpf2frame.py ${projectfolder} ${projectname}

#cp temp_rpf_file.txt ${projectfolder}

#echo ${projectname}

#echo "./plots/${projectname}_temp_rpf_file.txt"

#if [ -f "./plots/${projectname}_temp_rpf_file.txt" ]; then

#	rm ./plots/${projectname}_temp_rpf_file.txt;
#else
#	echo "temp_rpf_file.txt not present";
#fi


#echo ""
#echo "DONE WITH" ${projectname}
