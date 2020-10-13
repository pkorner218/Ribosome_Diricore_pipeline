#!/bin/bash


#echo 'here'

path=$1 

species=$2

ano=$3

email=$4

adapter=$5

adapter2=$6


echo "path:" $path
echo "species:" $species
echo "email: " $email
echo "adapter 1" $adapter
echo "adapter 2" $adapter2

#zcat  $path*.gz | head

ls -l $path

cd $path

mkdir input
mkdir input/fastq

mv *.gz input/fastq

for file in $path'/input/fastq/'*.gz; do echo $file; done

echo "for anonymous user decided" $ano

echo " now in BASH script part / Server "
