#!/bin/bash

a=${#}

if (($a < 1)) || [ $1 == "-h" ] || [ $1 == "-help" ]; then
	echo "";
	echo " usage of frameshift.sh";
	echo "";
	echo " bash frameshift.sh [/path/projectfolder] [Amino Acid] optional[gene filter]";
	echo "		Amino Acid options : single AA with name in Caps / ALL; gives all AA";
	echo "		gene filter (defaults to 100) ";
	echo "";
	echo " usage example: bash frameshift.sh /DATA/pkoerner/scripts/frameshift_trials/ TRP ";
	echo "";
	echo "		this message can also be obtained with -h or -help";
	echo "";
	exit 1
fi

projectpath=$1

aa=$2;

#echo ${projectpath}
#echo ${aa}



if (($a > 2)); then
	genefilter=$3
else
	genefilter=100
fi


#echo $genefilter

if [ "${aa}" == "ALL" ]; then
	declare -A aa2codon=( ["ALA"]="GCT,GCC,GCG,GCT" ["ARG"]="CGA,CGC,CGG,CGT,AGA,AGG" ["ASN"]="AAC,AAT" ["CYS"]="TGC,TGT" ["GLN"]="CAA,CAG" ["GLU"]="GAA,GAG" ["GLY"]="GGA,GGC,GGG,GGT" ["HIS"]="CAC,CAT" ["ILE"]="ATA,ATC,ATT" ["LEU"]="CTA,CTC,CTG,CTT,TTA,TTG" ["LYS"]="AAA,AAG" ["MET"]="ATG" ["PHE"]="TTC,TTT" ["PRO"]="CCA,CCC,CCG,CCT" ["SER"]="TCA,TCC,TCG,TCT,AGC,AGT" ["THR"]="ACA,ACC,ACG,ACT" ["TRP"]="TGG" ["TYR"]="TAC,TAT" ["VAL"]="GTA,GTC,GTG,GTT" )

	for aminoacid in ${!aa2codon[@]}; do echo " ";
		codongroupstr=${aa2codon[${aminoacid}]};
		codons=$(echo $codongroupstr | sed 's/,/,/g');
#		echo ""
#		echo $aminoacid ": " $codons
#		echo ""
		python3 ./frameshift.py ${projectpath} ${codons} ${genefilter};
	done;

else
	declare -A aa2codon=( ["ALA"]="GCT,GCC,GCG,GCT" ["ARG"]="CGA,CGC,CGG,CGT,AGA,AGG" ["ASN"]="AAC,AAT" ["CYS"]="TGC,TGT" ["GLN"]="CAA,CAG" ["GLU"]="GAA,GAG" ["GLY"]="GGA,GGC,GGG,GGT" ["HIS"]="CAC,CAT" ["ILE"]="ATA,ATC,ATT" ["LEU"]="CTA,CTC,CTG,CTT,TTA,TTG" ["LYS"]="AAA,AAG" ["MET"]="ATG" ["PHE"]="TTC,TTT" ["PRO"]="CCA,CCC,CCG,CCT" ["SER"]="TCA,TCC,TCG,TCT,AGC,AGT" ["THR"]="ACA,ACC,ACG,ACT" ["TRP"]="TGG" ["TYR"]="TAC,TAT" ["VAL"]="GTA,GTC,GTG,GTT" ["ATG_split"]="START_ATG,Other_ATG" )
	codongroupstr=${aa2codon[${aa}]}
	codons=$(echo $codongroupstr | sed 's/,/,/g');
#	echo ""
#	echo $aa ": " $codons
#	echo ""
	#python3 ./frameshift.py ${projectpath} ${codons} ${genefilter};
	python3 ./transcript_rpf_frame.py ${projectpath} ${codons} ${genefilter}; 	
fi


