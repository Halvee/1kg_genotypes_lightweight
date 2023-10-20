#!/bin/bash

# make sure output dir exists
mkdir -p snp_sites/

# get plink range for SNP sites common to a wide set of Illumina genotype arrays
python3 scripts/overlapping_array_positions.py \
  data/genotype_array/*_Physical-and-Genetic-Coordinates.txt \
| sort -k1,1 -k2,2n \
> snp_sites/common_to_genotype_arrays.plink.range

# get plink range for extracting snps 
# that meet the following criteria : 
# 1. MAF >= 0.05
# 2. required absence of label 'MULTI_ALLELIC' (multi-allelic site)
# 3. chromosome+position in set 
# 4. nonambiguous SNPs only (no A/T, T/A, G/C, or C/G SNPs)
python3 scripts/g1k_phase3_get_rsids.py \
--variant-type SNP \
--chromosomes-keep 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22 \
--allele-freq-min 0.05 \
--allele-freq-max 0.95 \
--flags-require-absent MULTI_ALLELIC \
--nonambiguous-snps-only \
--output-plink-range \
data/1000_genomes_phase3/all_phase3_ns.pvar \
snp_sites/g1k_phase3.auto_MAFgt05.plink.range

# get subset of sites that are also in sites common to all genotype arrays.
# Ideal for genotype array data or whole genome sequencing data
awk 'FNR==NR {chrpos[$1":"$3]=1;next}
     {if ($1":"$3 in chrpos) {print $0}}' \
snp_sites/common_to_genotype_arrays.plink.range \
snp_sites/g1k_phase3.auto_MAFgt05.plink.range \
> snp_sites/g1k_phase3.auto_MAFgt05_genotype_arrays.plink.range

# get rid of plink range file for all auto maf > 0.05, file too big
rm snp_sites/g1k_phase3.auto_MAFgt05.plink.range

# get plink range for extracting snps 
# that meet the following criteria : 
# 1. MAF >= 0.05
# 2. required absence of label 'MULTI_ALLELIC' (multi-allelic site)
# 3. required label 'EX_TARGET' (exome target locus)
# 4. nonambiguous SNPs only (no A/T, T/A, G/C, or C/G SNPs)
# Ideal for exome sequencing or whole genome sequencing data
python3 scripts/g1k_phase3_get_rsids.py \
--variant-type SNP \
--chromosomes-keep 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22 \
--allele-freq-min 0.05 \
--allele-freq-max 0.95 \
--flags-require-absent MULTI_ALLELIC \
--flags-require-present EX_TARGET \
--nonambiguous-snps-only \
--output-plink-range \
data/1000_genomes_phase3/all_phase3_ns.pvar \
snp_sites/g1k_phase3.auto_MAFgt05_exontarget.plink.range

# repeat the same step but this time get snp ids
python3 scripts/g1k_phase3_get_rsids.py \
--variant-type SNP \
--chromosomes-keep 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22 \
--allele-freq-min 0.05 \
--allele-freq-max 0.95 \
--flags-require-absent MULTI_ALLELIC \
--flags-require-present EX_TARGET \
--keep-original-snpid \
--nonambiguous-snps-only \
data/1000_genomes_phase3/all_phase3_ns.pvar \
snp_sites/g1k_phase3.auto_MAFgt05_exontarget.snpid.list

exit
