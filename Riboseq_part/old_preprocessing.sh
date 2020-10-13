#!/bin/bash

set -e;
set -u;

a=${#}

projectfolder=$1;

INDIR=${projectfolder}"/input/fastq/";
OUTDIR=${projectfolder}"/output/clean/";

species=$2
adapter=$3;

if (($a > 3)); then
	adapter2=$4
fi

RRNA_REF="/DATA/pkoerner/REF/diricore_genomic_data/${species}/rRNAs";
TRNA_REF="/DATA/pkoerner/REF/diricore_genomic_data/${species}/tRNAs";

###
mkdir -p $OUTDIR || true;

if (($a > 3)); then

	ls -1 ${INDIR}/*.fastq.gz | while read fn; do
	    bn=$(basename "$fn");
	    b=${bn%%.*};

	    of="${OUTDIR}/${b}.fastq.gz";
	    ca_err="${OUTDIR}/${b}.clipadapt.err";
	    ca2_err="${OUTDIR}/${b}.clipadapt_2.err";
	    rrna_err="${OUTDIR}/${b}.rrna.err";
	    trna_err="${OUTDIR}/${b}.trna.err";

	    tmpfile=$(tempfile -d "/tmp/" -s ".${b}.rrna_cleaned.tmp.fastq.gz");

	    echo "Starting preprocessing of file: ${bn}";
	    cat "${fn}" \
	    | gzip -dc \
	    | cutadapt --quality-base=33 -a "${adapter}" -a "${adapter2}" -O 7 -e 0.15 -m 20 -q 5 --untrimmed-output=/dev/null - 2> "${ca2_err}" \
	    | bowtie2 --seed 42 -p 1 --local --un-gz "${tmpfile}" -x  "${RRNA_REF}" - \
	    > /dev/null 2> "${rrna_err}";

	    cat "${tmpfile}" \
	    | gzip -dc \
	    | bowtie2 --seed 42 --local --un-gz "${of}" -x  "${TRNA_REF}" - \
	    > /dev/null 2> "${trna_err}";

	    rm ${tmpfile};
	done

else

        ls -1 ${INDIR}/*.fastq.gz | while read fn; do
            bn=$(basename "$fn");
            b=${bn%%.*};

            of="${OUTDIR}/${b}.fastq.gz";
            ca_err="${OUTDIR}/${b}.clipadapt.err";
            ca2_err="${OUTDIR}/${b}.clipadapt_2.err";
            rrna_err="${OUTDIR}/${b}.rrna.err";
            trna_err="${OUTDIR}/${b}.trna.err";

            tmpfile=$(tempfile -d "/tmp/" -s ".${b}.rrna_cleaned.tmp.fastq.gz");

            echo "Starting preprocessing of file: ${bn}";
            cat "${fn}" \
            | gzip -dc \
            | cutadapt --quality-base=33 -a "${adapter}" -O 7 -e 0.15 -m 20 - 2> "${ca2_err}" \
            | bowtie2 --seed 42 -p 1 --local --un-gz "${tmpfile}" -x  "${RRNA_REF}" - \
            > /dev/null 2> "${rrna_err}";

            cat "${tmpfile}" \
            | gzip -dc \
            | bowtie2 --seed 42 --local --un-gz "${of}" -x "${TRNA_REF}" - \
            > /dev/null 2> "${trna_err}";

            rm ${tmpfile};
        done

fi

echo "Done with preprocessing";
###
