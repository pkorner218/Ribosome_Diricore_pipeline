#!/bin/bash

set -e;
set -u;

a=${#}

projectfolder=$1;
projectname=$2;

if (($a > 2)); then
        minreads=$3;
else
        minreads=100;
fi

if (($a > 3)); then
        species=$4;
else
        species="human";
fi


OUTDIR=${projectfolder}"output/h5_files/";
INDIR=${projectfolder}"/output/tophat_out/diri_comparison/";
PLOTDIR=${projectfolder}"/output/plots/";

SAMPLENAME_FILE=${projectfolder}"/input/metadata/samplenames.tsv";
CONTRAST_FILE=${projectfolder}"/input/metadata/subsequence_contrasts.tsv";

INDEXDATAFN="/DATA/pkoerner/REF/diricore_genomic_data/${species}/subseq_index_data.pkl.gz";
of="${OUTDIR}/${projectname}.subsequence_data.frame0.hdf5";

echo "now bash for extract"

###
mkdir ${OUTDIR} || true;
mkdir -p "${PLOTDIR}/subsequence_shift_plots/" || true;

#####

if [ -f "${of}" ]; then
	echo "${of} already exists"
else

	ls -1 ${INDIR}/*/*cluster9.bam | sort -V | while read bamfn; do
	    b=$(basename $(dirname "$bamfn"));

	    echo ${b}

	    /DATA/pkoerner/packages/diricore/actualpipe/plots/bin/extract_subsequences.py \
	        -v \
	        run \
	        -o "${of}" \
	        -f 0 \
	        "${INDEXDATAFN}" \
	        "${b},${bamfn}" \
	    ;
	done
fi

#echo "now bash for plots"

# create subsequence shift plots
/DATA/pkoerner/packages/diricore/actualpipe/plots/bin/plot_subsequence_shifts.py \
    -o ${PLOTDIR}/subsequence_shift_plots/${projectname}.m${minreads}. \
    -m $minreads \
    --sample-names ${SAMPLENAME_FILE} \
    --contrasts ${CONTRAST_FILE} \
    "${of}"
###

