#!/bin/bash

# make sure output dir exists
mkdir -p data/liftover/

# go to liftover dir
cd data/liftover/

# get liftover chain files
wget "https://hgdownload.cse.ucsc.edu/goldenpath/hg19/liftOver/hg19ToHg18.over.chain.gz"
wget "https://hgdownload.cse.ucsc.edu/goldenpath/hg19/liftOver/hg19ToHg38.over.chain.gz"

# decompress liftover chain files
gunzip -c hg19ToHg18.over.chain.gz > hg19ToHg18.over.chain
gunzip -c hg19ToHg38.over.chain.gz > hg19ToHg38.over.chain

# back to parent dir
cd ../../

exit
