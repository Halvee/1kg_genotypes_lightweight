# 1kg\_genotypes\_lightweight
---------------------------------------

## What is this?

This is a repository that contains key common variant genotypes from 1000 genomes phase 3 low pass whole genome sequence data. Specifically, genotypes have been included for 1) SNPs shared across multiple Illumina genotype arrays, and 2) within exon target regions (ie. likely captured in exome sequencing). 

## Purpose 

The purpose of these 1000 genomes phase 3 genotype data is primarily for use in anecstry prediction in a seperate set of samples. These target sample genotypes can either be derived from genotype array data or high-throughput sequencing (exome, whole genome). I originally put this together for teaching purposes, but it might be useful for anyone looking for (relatively) lightweight 1000 genomes phase 3 reference genotypes that can be used for ancestry classification in their target data.

## The data in this repository

Within this repository there are two different sets of 1000 genomes phase 3 genotypes : 

1) SNPs shared across multiple Illumina genotype arrays. Specifically, we used SNPs found on all of the following Illumina arrays: Global Screening Array v1, v2 and v3; Global Diversity Array v1; OmniExpress; PsychArray; 610K. We furthermore kept the subset of these SNPs that meet the following criteria : non-ambiguous SNPs only (no A/T, T/A, G/C or C/G); autosomal SNPs only; no SNPs on multi-allelic sites in 1000 genomes phase 3 genotype data; AF field in 1000 genomes INFO between 0.05 and 0.95.

2) SNPs that are in exon target regions, as represented by the label 'EX_TARGET' in 1000 genomes INFO. Many of these SNPs will be in protein-coding regions, and will be suitable for use with exome sequencing data. We kept the subset of these SNPs that met the following criteria : non-ambiguous SNPs only (no A/T, T/A, G/C or C/G); autosomal SNPs only; no SNPs on multi-allelic sites in 1000 genomes phase 3 genotype data; AF field in 1000 genomes INFO between 0.05 and 0.95.

All data were initially processed using hg19 reference build coordinates. We used CrossMap (PMID 24351709) to lift over these coordinates to hg18 and hg38 reference builds, and have full genotype files for these as well.

## Where are the genotype files?

From the parent directory, the paths to genotype array hg19, hg18 and hg38 PLINK bed/bim/fam filesets respectively are as follows:

```
plink_bedbimfam/g1k_phase3.auto_MAFgt05_genotype_arrays
plink_bedbimfam/crossmap/g1k_phase3.auto_MAFgt05_genotype_arrays.crossmap.hg18
plink_bedbimfam/crossmap/g1k_phase3.auto_MAFgt05_genotype_arrays.crossmap.hg38
```

The paths to exon target hg19, hg18 and hg38 PLINK bed/bim/fam filesets respectively are as follows:

```
plink_bedbimfam/g1k_phase3.auto_MAFgt05_exontarget
plink_bedbimfam/crossmap/g1k_phase3.auto_MAFgt05_exontarget.crossmap.hg18
plink_bedbimfam/crossmap/g1k_phase3.auto_MAFgt05_exontarget.crossmap.hg38
```

## Okay, how do I use these files with my data?

In general, before proceeding you'll want to convert your target sample genotypes to PLINK bed/bim/fam format, using PLINK (https://www.cog-genomics.org/plink/). To make the files smaller, you could use the corresponding PLINK range files in the repository that go with your target SNP set and reference build :

```
# hg19 : 
snp_sites/*.plink.range
# hg19/hg38 : 
plink_bedbimfam/crossmap/*.plink.range
```

You will want to merge the 1000 genomes phase 3 reference data and your reference data on SNPs that are found in both datasets. To facilitate this you could use the included script 'merge_1000_genomes_with_test_dataset.sh' found in the parent directory like so:

```
./merge_1000_genomes_with_test_dataset.sh <test.fileset> <reference.fileset> </path/to/plink1.9> <outroot>
```

Where 'test.fileset' is a PLINK bed/bim/fam fileset for your test genotypes, 'reference.fileset' is one of the included 1000 genomes phase 3 PLINK bed/bim/fam filesets, '/path/to/plink1.9' is the path to a plink v1.9 executable on your machine, and 'outroot' is the root name for all output files, including a PLINK bed/bim/fam fileset with the test and 1000 genomes genotypes merged on a shared set of SNPs.

## Building the data from scratch

Building the data from scratch shouldn't be necessary unless there are changes to the pipeline that you wish to make yourself. Note that we're assuming that you're working within a Mac or Linux environment as you're doing this.

To build the data, you'll first have to build the Docker image to create the same environment the pipeline was run on. to do this, from the parent directory execute the following commands:

```
cd docker/
./build.sh
cd ../
```

Note that if Docker is not installed and running on your machine, the command above won't work.

Next, from the parent directory, just execute this command to run each step of the pipeline in the proper order wtihin the Docker image:

```
./run.sh
```

