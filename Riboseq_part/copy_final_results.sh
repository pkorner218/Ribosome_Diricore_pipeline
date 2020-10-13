#!/bin/bash

projectfolder=$1

destinationfolder=${projectfolder}/user_output/

bnfolder=$(basename "$projectfolder");

mkdir -p  ${destinationfolder} 2> /dev/null || true;

echo -ne "\QualityControl\nWig\nDEseq\nReadcounts\nDiricore\nBumpfinder
" | while read subfolder groupstr; do

	mkdir -p ${destinationfolder}/${subfolder} 2> /dev/null || true;
done

for file in ${projectfolder}/output/*summaries.txt; do echo $file; bn=$(basename "$file"); echo $bn; cp $file ${destinationfolder}/QualityControl/${bnfolder}"_"${bn}; done

cp ${projectfolder}/output/transcript/QC/*sam*pdf ${destinationfolder}/QualityControl/

ls -1 ${projectfolder}/output/wig/*.wig | while read file; do echo $file ; if grep -F "track name=" $file ; then cp $file ${destinationfolder}/Wig/; fi;  done

cp -r ${projectfolder}/output/htseq_out/*/ ${destinationfolder}/DEseq/

cp ${projectfolder}/output/htseq_out/*/*.out ${destinationfolder}/Readcounts/

cp ${projectfolder}/output/h5_files/all_rpf_shiny.txt ${destinationfolder}/Diricore/

cp ${projectfolder}/output/plots/subsequence_shift_plots/*.pdf ${destinationfolder}/Diricore/

cp ${projectfolder}/output/transcript/QC/*_rpf* ${destinationfolder}/Diricore/

for dir in ${projectfolder}/output/bumpfinder/*/;

	do echo $dir;

	bn=$(basename "$dir");

	echo $bn

	mkdir ${projectfolder}/user_output/Bumpfinder/$bn;

	echo -ne "\PLUS\nMINUS
" | while read condition groupstr; do


		for file in $dir/identify_bumps/${condition}/*.pdf;
			do echo $file;

			bfile=$(basename "$file");
			echo $bfile

			cp $file ${projectfolder}/user_output/Bumpfinder/${bn}/${condition}"_"$bfile;

			done;

		for scorefile in $dir/identify_bumps/${condition}/bumpfinderScores.txt,
			do;
					
			cp $file ${projectfolder}/user_output/Bumpfinder/${bn}/${condition}"_"$scorefile;
			
			done;
		done;
	done;


