#!/bin/bash

projectfolder=$1

identifyfolder=${projectfolder}"/identify_bumps/"

bedtools sort -i ${identifyfolder}/PLUS_peaks.txt > ${identifyfolder}/PLUS_peaks_sort.txt
bedtools sort -i ${identifyfolder}/MINUS_peaks.txt > ${identifyfolder}/MINUS_peaks_sort.txt

bedtools intersect -v -a ${identifyfolder}/PLUS_peaks_sort.txt -b ${identifyfolder}/MINUS_peaks_sort.txt > ${identifyfolder}/PLUS_only_peaks.txt
bedtools closest -a ${identifyfolder}/PLUS_only_peaks.txt -b ${identifyfolder}/MINUS_peaks_sort.txt -d > ${identifyfolder}/PLUS_ONLY_CLOSEST.txt


bedtools intersect -v -a ${identifyfolder}/MINUS_peaks_sort.txt -b ${identifyfolder}/PLUS_peaks_sort.txt > ${identifyfolder}/MINUS_only_peaks.txt
bedtools closest -a ${identifyfolder}/MINUS_only_peaks.txt -b ${identifyfolder}/PLUS_peaks_sort.txt  -d > ${identifyfolder}/MINUS_ONLY_CLOSEST.txt


#bedtools intersect -v -a ${identifyfolder}/PLUS_peaks.txt -b ${identifyfolder}/MINUS_peaks.txt > ${identifyfolder}/PLUS_only_peaks.txt
#bedtools closest -a ${identifyfolder}/PLUS_only_peaks.txt -b ${identifyfolder}/MINUS_peaks.txt -d > ${identifyfolder}/PLUS_ONLY_CLOSEST.txt
#bedtools intersect -v -a ${identifyfolder}/MINUS_peaks.txt -b ${identifyfolder}/PLUS_peaks.txt > ${identifyfolder}/MINUS_only_peaks.txt
#bedtools closest -a ${identifyfolder}/MINUS_only_peaks.txt -b ${identifyfolder}/PLUS_peaks.txt  -d > ${identifyfolder}/MINUS_ONLY_CLOSEST.txt

