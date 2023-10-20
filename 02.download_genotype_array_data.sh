#!/bin/bash

# make sure output dir exists, go into it
mkdir -p data/genotype_array/
cd data/genotype_array/

# download Illumina genotype array marker information for ..

# GSA v1 (build 37)
wget -N \
"https://support.illumina.com/content/dam/illumina-support/documents/downloads/productfiles/global-screening-array-24/infinium-global-screening-array-24-v1-0-c1-physical-genetic-coordinates.zip"
unzip -o "infinium-global-screening-array-24-v1-0-c1-physical-genetic-coordinates.zip"

# GSA v2 (build 37)
wget -N \
"https://support.illumina.com/content/dam/illumina-support/documents/downloads/productfiles/global-screening-array-24/v2-0/infinium-global-screening-array-24-v2-0-a1-locus-report.zip"
unzip -o "infinium-global-screening-array-24-v2-0-a1-locus-report.zip"
wget -N \
"https://support.illumina.com/content/dam/illumina-support/documents/downloads/productfiles/global-screening-array-24/v2-0/infinium-global-screening-array-24-v2-0-a1-physical-genetic-coordinates.zip"
unzip -o "infinium-global-screening-array-24-v2-0-a1-physical-genetic-coordinates.zip"

# GSA v3 (build 37)
wget -N \
"https://support.illumina.com/content/dam/illumina-support/documents/downloads/productfiles/global-screening-array-24/v3-0/infinium-global-screening-array-24-v3-0-a1-physical-genetic-coordinates.zip"
unzip -o "infinium-global-screening-array-24-v3-0-a1-physical-genetic-coordinates.zip"

# Global Diversity Array v1 (build 37)
wget -N \
"https://support.illumina.com/content/dam/illumina-support/documents/downloads/productfiles/global-diversity-array/infinium-global-diversity-array-8-v1-0_D1.csv_Physical-and-Genetic-Coordinates.txt"

# OmniExpress (build 37)
wget -N \
"https://support.illumina.com/content/dam/illumina-support/documents/downloads/productfiles/humanomniexpress-24/v1-3/infinium-omniexpress-24-v1-3-a1-physical-genetic-coordinates.zip"
unzip -o "infinium-omniexpress-24-v1-3-a1-physical-genetic-coordinates.zip"

# PsychArray (build 37)
wget -N \
"https://support.illumina.com/content/dam/illumina-support/documents/downloads/productfiles/infinium-psycharray/v1-2/infinium-psycharray-24-v1-2-a1-phsyical-genetic-coordinates.zip"
unzip -o "infinium-psycharray-24-v1-2-a1-phsyical-genetic-coordinates.zip"

# 610K (bed file, build 37)
wget -N \
"https://support.illumina.com/content/dam/illumina-support/documents/downloads/productfiles/human610/human610-quadv1_h.zip"
unzip -o human610-quadv1_h.zip
# make physical-genetic-coordinates formatted file from bed file
echo -e "Name\tChr\tMapInfo\tdeCODE(cM)" > Human610-Quadv1_H.bed_Physical-and-Genetic-Coordinates.txt
cat Human610-Quadv1_H.bed \
| sed 's/^chr//g' \
| awk '{OFS="\t"; if (NR!=1) {print $4,$1,$3,"NA"}}' \
>> Human610-Quadv1_H.bed_Physical-and-Genetic-Coordinates.txt

# go back to parent dir
cd ../../

exit
