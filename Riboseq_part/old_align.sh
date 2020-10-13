#!/bin/bash

set -e;
set -u;

projectfolder=$1

INDIR=$projectfolder"/output/clean/";
OUTDIR=$projectfolder"/output/tophat_out/";

BOWTIE_PATH="bowtie2"
TOPHAT_BIN="tophat2"

species=$2

RRNA_REF="/DATA/pkoerner/REF/diricore_genomic_data/${species}/rRNAs";
TRNA_REF="/DATA/pkoerner/REF/diricore_genomic_data/${species}/tRNAs";

REF="/DATA/pkoerner/REF/diricore_genomic_data/${species}/genome";
GTF="/DATA/pkoerner/REF/diricore_genomic_data/${species}/transcripts.gff";
TIDX="/DATA/pkoerner/REF/diricore_genomic_data/${species}/transcripts";


echo "starting with alignment";

ls -1 ${INDIR}/*.fastq.gz | while read fn; do
    bn=$(basename "$fn");
    b=${bn%%.*};

    od="${OUTDIR}/${b}";

    mkdir -p "${od}" 2> /dev/null || true;
    thout="${od}/tophat.out"
    therr="${od}/tophat.err"

    echo "Starting alignment of file: $bn";

    PATH="${BOWTIE_PATH}:$PATH" \
        ${TOPHAT_BIN} --seed 42 -n 2 -m 1 \
        --no-novel-juncs --no-novel-indels --no-coverage-search \
        --segment-length 25 \
        --transcriptome-index "${TIDX}" -G "${GTF}" \
        -o "${od}" \
        -p 1 "${REF}" "${fn}" \
        > "${thout}" 2> "${therr}";
done

echo "Done with alignments; now filtering out non-primary/low-quality alignments";

# isolate "hqmapped" reads
ls -1 ${OUTDIR}/*/accepted_hits.bam | while read fn; do
    dn=$(dirname "$fn");
    of="${dn}/accepted_hits.hqmapped.bam";

    cat \
        <(samtools view -H "${fn}") \
        <(cat "${fn}" | samtools view -q10 -F260 -) \
    | samtools view -bS - \
    > "${of}";
done

echo "Done filtering";
###

