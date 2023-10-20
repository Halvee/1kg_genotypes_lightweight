#!/bin/bash

# make sure output dir exists
mkdir -p plink_bedbimfam/crossmap/

# make a copy of 1000 genomes phase 3 ancestry groups table
cp \
data/1000_genomes_phase3/integrated_call_samples_v3.20130502.ALL.panel \
plink_bedbimfam/

# make plink bedbimfam for SNPs in sites common across genotype arrays 
# (SNPs only at sites with no multi-alleic snps matching details above)
plink2 \
--pfile data/1000_genomes_phase3/all_phase3_ns \
--snps-only \
--extract range snp_sites/g1k_phase3.auto_MAFgt05_genotype_arrays.plink.range \
--make-bed \
--out plink_bedbimfam/g1k_phase3.auto_MAFgt05_genotype_arrays

# make plink bedbimfam for SNPs in exon target regions (SNPs only at sites with no multi-alleic snps matching details above)
plink2 \
--pfile data/1000_genomes_phase3/all_phase3_ns \
--snps-only \
--extract range snp_sites/g1k_phase3.auto_MAFgt05_exontarget.plink.range \
--make-bed \
--out plink_bedbimfam/g1k_phase3.auto_MAFgt05_exontarget

# for each BIM file produced ..
for x in "genotype_arrays" "exontarget"
do
  # make genomic interval bed file from PLINK bim file
  awk '{OFS="\t"; print $1,$4-1,$4,$2}' \
  plink_bedbimfam/g1k_phase3.auto_MAFgt05_${x}.bim \
  > plink_bedbimfam/crossmap/g1k_phase3.auto_MAFgt05_${x}.interval.hg19.bed 
  
  # for each other alternate ref genome build ..
  for y in "38" "18"
  do
    # liftover from hg19 to target reference using CrossMap,
    # interval bed and liftover chain file
    CrossMap.py bed \
      --chromid s \
      --unmap-file plink_bedbimfam/crossmap/g1k_phase3.auto_MAFgt05_${x}.interval.crossmap.hg${y}.unmap \
      data/liftover/hg19ToHg${y}.over.chain \
      plink_bedbimfam/crossmap/g1k_phase3.auto_MAFgt05_${x}.interval.hg19.bed \
      plink_bedbimfam/crossmap/g1k_phase3.auto_MAFgt05_${x}.interval.crossmap.hg${y}.bed \
      2> plink_bedbimfam/crossmap/g1k_phase3.auto_MAFgt05_${x}.interval.crossmap.hg${y}.log
    # make PLINK range file (basically bed file with 1-based coordinates)
    awk '{OFS="\t"; print $1,$3,$3,$4}' \
      plink_bedbimfam/crossmap/g1k_phase3.auto_MAFgt05_${x}.interval.crossmap.hg${y}.bed \
    > plink_bedbimfam/crossmap/g1k_phase3.auto_MAFgt05_${x}.interval.crossmap.hg${y}.plink.range
    # make new bim file with lifted over coordinates
    awk 'FNR==NR {chr[$4]=$1;pos[$4]=$3;next}
         {if (($2 in chr) && ($1==chr[$2])){OFS="\t"; print chr[$2],$2,$3,pos[$2],$5,$6}}' \
      plink_bedbimfam/crossmap/g1k_phase3.auto_MAFgt05_${x}.interval.crossmap.hg${y}.bed \
      plink_bedbimfam/g1k_phase3.auto_MAFgt05_${x}.bim \
    > plink_bedbimfam/crossmap/g1k_phase3.auto_MAFgt05_${x}.crossmap.hg${y}.bim
    # copy over fam file
    cp plink_bedbimfam/g1k_phase3.auto_MAFgt05_${x}.fam \
       plink_bedbimfam/crossmap/g1k_phase3.auto_MAFgt05_${x}.crossmap.hg${y}.fam
    # make list of snps to keep post-liftover
    cut -f 2 plink_bedbimfam/crossmap/g1k_phase3.auto_MAFgt05_${x}.crossmap.hg${y}.bim \
    > plink_bedbimfam/crossmap/g1k_phase3.auto_MAFgt05_${x}.crossmap.hg${y}.extract.snpid.list
    # make new plink bed file to go along with bim/fam fileset
    plink2 \
    --bfile plink_bedbimfam/g1k_phase3.auto_MAFgt05_${x} \
    --extract plink_bedbimfam/crossmap/g1k_phase3.auto_MAFgt05_${x}.crossmap.hg${y}.extract.snpid.list \
    --make-bed \
    --out plink_bedbimfam/crossmap/g1k_phase3.auto_MAFgt05_${x}.crossmap.TMP.hg${y}
    # remove intermediate files
    mv plink_bedbimfam/crossmap/g1k_phase3.auto_MAFgt05_${x}.crossmap.TMP.hg${y}.bed \
       plink_bedbimfam/crossmap/g1k_phase3.auto_MAFgt05_${x}.crossmap.hg${y}.bed
    rm plink_bedbimfam/crossmap/g1k_phase3.auto_MAFgt05_${x}.crossmap.TMP.hg${y}.fam \
       plink_bedbimfam/crossmap/g1k_phase3.auto_MAFgt05_${x}.crossmap.TMP.hg${y}.bim
  done
done

# md5 checksums for plink files
cd plink_bedbimfam/
> plink_files.md5
for x in "genotype_arrays" "exontarget"
do
  for y in "bed" "bim" "fam"
  do
    md5sum g1k_phase3.auto_MAFgt05_${x}.${y} >> plink_files.md5
  done
done
cd crossmap/
> plink_files.md5
for x in "genotype_arrays" "exontarget"
do
  for y in "bed" "bim" "fam"
  do
    for z in "18" "38"
    do
      md5sum g1k_phase3.auto_MAFgt05_${x}.crossmap.hg${z}.${y} >> plink_files.md5
    done
  done
done
cd ../../

exit
