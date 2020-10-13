#!/bin/bash

set -e;
set -u;

projectfolder=$1

mkdir -p "${projectfolder}/output/transcript/QC" 2> /dev/null || true;

cp ./QC/ribowaltz_general.txt "${projectfolder}/output/transcript/QC/auto_ribo_QC.R"

cp "${projectfolder}/output/transcript/"*sam.bam "${projectfolder}/output/transcript/QC/"

for file in ${projectfolder}"output/transcript/QC/"*sam.bam; do echo $file; python3 ./QC/auto_QC.py $file >> "${projectfolder}output/transcript/QC/auto_ribo_QC.R"; done


