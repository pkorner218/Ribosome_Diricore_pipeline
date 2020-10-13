#!/bin/bash

set -e;
set -u;

a=${#}

if (($a < 1)) || [ $1 == "-h" ] || [ $1 == "-help" ]; then
	echo "";
	echo " usage of singleAA_rpf_plotting.sh";
	echo "";
	echo " bash singleAA_rpf_plotting.sh [/path/projectfolder] [projectname] [Amino Acid] [y-axis limits]";
	echo "		Amino Acid options : single AA with name in Caps / split_ATG / ALL; gives all AA except ATG_split";
	echo " 		y-axis lmits are given with   positive int , negative int";
	echo "";
	echo " usage example: bash singleAA_rpf_ploting.sh /DATA/pkoerner/packages/diricore/tests/ 3_vs_1_new TRP 0.2,-0.2";
	echo "";
	echo "		this message can also be obtained with -h or -help";

	exit 1
fi

projectfolder=$1;
projectname=$2;
aa=$3;

if (($a > 3)); then
        yaxis=$4;
else
        yaxis=None;
fi

#yaxis=$4;

minreads=100;
#minreads=25;
species="human";

OUTDIR=${projectfolder}"output/h5_files/";
INDIR=${projectfolder}"/output/tophat_out/diri_comparison/";

PLOTDIR=${projectfolder}"/output/plots/";

SAMPLENAME_FILE=${projectfolder}"/input/metadata/samplenames.tsv";
CONTRAST_FILE=${projectfolder}"/input/metadata/rpf_density_contrasts.tsv";

INDEXDATA_FILE="/DATA/pkoerner/REF/diricore_genomic_data/${species}/transcript_data.hdf5";

datafile="${OUTDIR}/${projectname}.txcoord_counts.hdf5";

echo $datafile

if [ "${aa}" == "ATG_split" ]; then
        MAPS_FILE="/DATA/pkoerner/REF/diricore_genomic_data/${species}/codon_regions.START_Other_ATG.width_61.hdf5";
else
        MAPS_FILE="/DATA/pkoerner/REF/diricore_genomic_data/${species}/codon_regions.width_61.hdf5";
fi

###

if [ "${aa}" == "ALL" ]; then
	declare -A aa2codon=( ["ALA"]="GCT,GCC,GCG,GCT" ["ARG"]="CGA,CGC,CGG,CGT,AGA,AGG" ["ASN"]="AAC,AAT" ["CYS"]="TGC,TGT" ["GLN"]="CAA,CAG" ["GLU"]="GAA,GAG" ["GLY"]="GGA,GGC,GGG,GGT" ["HIS"]="CAC,CAT" ["ILE"]="ATA,ATC,ATT" ["LEU"]="CTA,CTC,CTG,CTT,TTA,TTG" ["LYS"]="AAA,AAG" ["MET"]="ATG" ["PHE"]="TTC,TTT" ["PRO"]="CCA,CCC,CCG,CCT" ["SER"]="TCA,TCC,TCG,TCT,AGC,AGT" ["THR"]="ACA,ACC,ACG,ACT" ["TRP"]="TGG" ["TYR"]="TAC,TAT" ["VAL"]="GTA,GTC,GTG,GTT" )

	for aminoacid in ${!aa2codon[@]}; do echo " ";
		of="${PLOTDIR}/rpf_5p_density_plots/${projectname}.m${minreads}.${aminoacid}.rpf_5p_density_shift_plot.pdf";
		codongroupstr=${aa2codon[${aminoacid}]};
		codons=$(echo $codongroupstr | sed 's/,/ /g');
		echo ""
		echo $aminoacid ": " $codons
		echo ""
		python ./bin/plot_rpf_5p_density.py -c "${CONTRAST_FILE}" -n "${SAMPLENAME_FILE}" -o "${of}" -m ${minreads} "${datafile}" ${MAPS_FILE} ${codons} --y-limits ${yaxis};
	done;

else
	declare -A aa2codon=( ["ALA"]="GCT,GCC,GCG,GCT" ["ARG"]="CGA,CGC,CGG,CGT,AGA,AGG" ["ASN"]="AAC,AAT" ["CYS"]="TGC,TGT" ["GLN"]="CAA,CAG" ["GLU"]="GAA,GAG" ["GLY"]="GGA,GGC,GGG,GGT" ["HIS"]="CAC,CAT" ["ILE"]="ATA,ATC,ATT" ["LEU"]="CTA,CTC,CTG,CTT,TTA,TTG" ["LYS"]="AAA,AAG" ["MET"]="ATG" ["PHE"]="TTC,TTT" ["PRO"]="CCA,CCC,CCG,CCT" ["SER"]="TCA,TCC,TCG,TCT,AGC,AGT" ["THR"]="ACA,ACC,ACG,ACT" ["TRP"]="TGG" ["TYR"]="TAC,TAT" ["VAL"]="GTA,GTC,GTG,GTT" ["ATG_split"]="START_ATG,Other_ATG" )
	of="${PLOTDIR}/rpf_5p_density_plots/${projectname}.m${minreads}.${aa}.rpf_5p_density_shift_plot.pdf";
	codongroupstr=${aa2codon[${aa}]}
	codons=$(echo $codongroupstr | sed 's/,/ /g');
	echo ""
	echo $aa ": " $codons
	echo ""
	python ./bin/plot_rpf_5p_density.py -c "${CONTRAST_FILE}" -n "${SAMPLENAME_FILE}" -o "${of}" -m ${minreads} "${datafile}" ${MAPS_FILE} ${codons} --y-limits ${yaxis}

fi


if [ -f "./temp_rpf_file.txt" ]; then
	rm ./temp_rpf_file.txt;
else
	echo "temp_rpf_file.txt not present";
fi
