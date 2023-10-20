#!/bin/bash

# run whole pipeline using docker container we built

# step 1 : download 1000 genomes phase 3 reference data
docker run --workdir /data/ -v $PWD:/data/ -it plink2 ./01.download_1000_genomes_phase3_data.sh

# step 2 : download genotype array marker data
docker run --workdir /data/ -v $PWD:/data/ -it plink2 ./02.download_genotype_array_data.sh

# step 3 : download liftover files 
docker run --workdir /data/ -v $PWD:/data/ -it plink2 ./03.download_liftover_data.sh

# step 4 : get snp sites for variants 1) common to a bunch of genotype arrays, 2) in exon target sites 
docker run --workdir /data/ -v $PWD:/data/ -it plink2 ./04.snp_sites.sh

# step 5 : form plink bed/bim/fam files with 1000 genomes phase 3 reference genotypes
docker run --workdir /data/ -v $PWD:/data/ -it plink2 ./05.plink_bedbimfam.sh

# merge the sliced 1000 genomes phase 3 data with your test data with merge_1000_genomes_with_test_dataset.sh,
# outside of this pipeline

exit
