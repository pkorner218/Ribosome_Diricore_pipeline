#!/bin/bash

set -e;
set -u;

a=${#}

projectfolder=$1;
projectname=$2;

if (($a > 2)); then
        minreads=$3;
else
        minreads=25;
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
CONTRAST_FILE=${projectfolder}"/input/metadata/rpf_density_contrasts.tsv";


INDEXDATA_FILE="/DATA/pkoerner/REF/diricore_genomic_data/${species}/transcript_data.hdf5";
MAPS_FILE="/DATA/pkoerner/REF/diricore_genomic_data/${species}/codon_regions.width_61.hdf5";
MAPSSTART_FILE="/DATA/pkoerner/REF/diricore_genomic_data/${species}/codon_regions.START_Other_ATG.width_61.hdf5";


###

of="${OUTDIR}/${projectname}.txcoord_counts.hdf5";

mkdir ${OUTDIR} || true;
mkdir -p "${PLOTDIR}/rpf_5p_density_plots/" || true;

###map RPFs to transcriptome coordinates

if [ -f "${of}" ]; then
	echo "${of} already exists"
else
	/DATA/pkoerner/packages/diricore/actualpipe/plots/bin/map_rpfs_to_transcriptome_positions.py \
	    -t "${INDEXDATA_FILE}" \
	    -o "${of}" \
	    -b <(\
	        ls -1 ${INDIR}/*/*cluster9.bam | sort -V | while read fn; do
	       	        b=$(basename $(dirname "$fn"));
	              	b=${b%%.*};

               	echo -e "${b}\t${fn}";
            	done \
        	)
fi

#########

# { generate RPF density shift plots
datafile="${of}";
echo -ne "\
Ala\tGCA,GCC,GCG,GCT
Arg\tCGA,CGC,CGG,CGT,AGA,AGG
Asn\tAAC,AAT
Asp\tGAC,GAT
Cys\tTGC,TGT
Gln\tCAA,CAG
Glu\tGAA,GAG
Gly\tGGA,GGC,GGG,GGT
His\tCAC,CAT
Ile\tATA,ATC,ATT
Leu\tCTA,CTC,CTG,CTT,TTA,TTG
Lys\tAAA,AAG
Met\tATG
Phe\tTTC,TTT
Pro\tCCA,CCC,CCG,CCT
Ser\tTCA,TCC,TCG,TCT,AGC,AGT
Thr\tACA,ACC,ACG,ACT
Trp\tTGG
Tyr\tTAC,TAT
Val\tGTA,GTC,GTG,GTT
" | while read aa codongroupstr; do
    of="${PLOTDIR}/rpf_5p_density_plots/${projectname}.m${minreads}.${aa}.rpf_5p_density_shift_plot.pdf";
    codons=$(echo $codongroupstr | sed 's/,/ /g');

    python /DATA/pkoerner/packages/diricore/actualpipe/plots/bin/plot_rpf_5p_density.py \
        -c "${CONTRAST_FILE}" \
        -n "${SAMPLENAME_FILE}" \
        -o "${of}" \
        -m ${minreads} \
        "${datafile}" \
        ${MAPS_FILE} \
        ${codons}
done

# RPF density at special codons
# (START/other ATG)
echo -ne "\
ATG_split\tSTART_ATG,Other_ATG
" | while read aa codongroupstr; do
    of="${PLOTDIR}/rpf_5p_density_plots/${projectname}.m${minreads}.${aa}.rpf_5p_density_shift_plot.pdf";
    codons=$(echo $codongroupstr | sed 's/,/ /g');

    python /DATA/pkoerner/packages/diricore/actualpipe/plots/bin/plot_rpf_5p_density.py \
        -c "${CONTRAST_FILE}" \
        -n "${SAMPLENAME_FILE}" \
        -o "${of}" \
        -m ${minreads} \
        "${datafile}" \
        ${MAPSSTART_FILE} \
        ${codons}
done


