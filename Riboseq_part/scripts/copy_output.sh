#!/bin/bash

set -e;
set -u;

projectfolder=$1

destination=$2

pattern=$3


ls -1 ${projectfolder}/*${pattern}* | while read fn;
	do
	echo ${fn};
#	echo ${fn##*/};

	orfn=$(basename $(dirname $fn));
#	echo $orfn
	orfn2=$(basename $orfn)
	borfn2=${orfn2%.fastq*}
#	echo $borfn2
#	done

	cp $fn ${destination}"/"${borfn2}"_"${fn##*/}

	done



