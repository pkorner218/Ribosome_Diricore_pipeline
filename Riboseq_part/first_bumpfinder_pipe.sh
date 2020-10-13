#!/bin/bash

set -e;
set -u;

a=${#}

pipeline=$(pwd)

projectfolder=$1

Species=$2



cd ${projectfolder}

for file in *summary.txt; do grep -m1 "" $file | sed 's/\t/-/g' | while read header; do echo $header ; mkdir -p $header 2> /dev/null || true; mv $file $header/"summary.txt" ; done ; done

for file in *.bam.bed; do python3 ${pipeline}/scripts/shorten_ribo.py ${file} ${Species} > ${projectfolder}"/"${file}"_final.bed"; done

bash ${pipeline}/scripts/bed2count.sh ${projectfolder} ${pipeline} ${Species}

for dir in */; do python3 ${pipeline}/scripts/merge2.py ${projectfolder} ${projectfolder}"/"${dir}; done

echo ""
echo "finished preprocessing and merging all files in data.txt"
echo ""



for dir in */; do bash ${pipeline}/second_bumpfinder_pipe.sh ${projectfolder}"/"${dir} ${Species} ${pipeline}; done
