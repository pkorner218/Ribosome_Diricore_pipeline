projectfolder=$1
pipeline=$2
Species=$3

ls -1 ${projectfolder}/*final.bed | while read fn;

	do

	orfn=${fn##*/}
	forfn="${orfn%.fastq.sam.bam_sort.bam.final.bed}"

#	echo $forfn
	bedtools coverage -a ${pipeline}/REF/bumpfinder/${Species}/longest_transcript_select_100_windows.bed -b $fn | cut -f1,2,3,4 > ${projectfolder}"/"${forfn}"_counts.txt";

	done
