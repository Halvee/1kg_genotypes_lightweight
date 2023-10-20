#!/bin/bash

# make sure output dir exists, go into it
mkdir -p data/1000_genomes_phase3/
cd data/1000_genomes_phase3/

# download 1000 genomes phase3 data
# (sample-level data, pop/superpop/sex per sample)
wget -N \
"http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/integrated_call_samples_v3.20130502.ALL.panel"

# download preformatted PLINK2 fileset for 1000 genomes phase3 samples
wget -N \
"https://www.dropbox.com/s/dps1kvlq338ukz8/all_phase3_ns.pgen.zst" \
"https://www.dropbox.com/s/brkchmursq4vqwr/all_phase3_ns.pvar.zst" \
"https://www.dropbox.com/s/6ppo144ikdzery5/phase3_corrected.psam"

# make copy of psam to match filenames of pgen/pvar
cp phase3_corrected.psam all_phase3_ns.psam

# decompress pgen file with extension .zst
plink2 --zst-decompress all_phase3_ns.pgen.zst > all_phase3_ns.pgen
plink2 --zst-decompress all_phase3_ns.pvar.zst > all_phase3_ns.pvar

# go back to parent dir
cd ../../

exit
