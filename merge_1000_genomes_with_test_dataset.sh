#!/bin/bash

# get user args
if [[ $# != 4 ]]
then
  echo "merge_1000_genomes_with_test_dataset.sh <test.fileset> <reference.fileset> </path/to/plink1.9> <outroot>"
  exit
fi
DATASET_TEST=$1
DATASET_REF=$2
PLINK_BIN=$3
OUTROOT=$4

# get script dir
scriptdir=`dirname ${BASH_SOURCE[0]}`

# get directory with outroot
outdir=`dirname $OUTROOT`

# make sure output dir exists
mkdir -p ${outdir}/

# initial alignment
python3 $scriptdir/scripts/bimfile_harmonization.py \
${DATASET_REF}.bim \
${DATASET_TEST}.bim \
$OUTROOT.bim \
$OUTROOT.testsnpid_refsnpid.tsv

# get snpids to keep
cut -f 2 $OUTROOT.testsnpid_refsnpid.tsv \
> $OUTROOT.snpid.extract.list

# subset test dataset on shared snps
${PLINK_BIN} --bed ${DATASET_TEST}.bed --bim $OUTROOT.bim --fam ${DATASET_TEST}.fam \
--extract $OUTROOT.snpid.extract.list \
--make-bed \
--out $OUTROOT.MERGE.test_dataset

# subset reference dataset on shared snps
${PLINK_BIN} --bfile ${DATASET_REF} \
--extract $OUTROOT.snpid.extract.list \
--make-bed \
--out $OUTROOT.MERGE.reference_dataset

# merge reference and test datasets
${PLINK_BIN} --bfile $OUTROOT.MERGE.test_dataset \
--bmerge $OUTROOT.MERGE.reference_dataset \
--out $OUTROOT

# clear out intermediate files
rm $OUTROOT.MERGE.*

exit
