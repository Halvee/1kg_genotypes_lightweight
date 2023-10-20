#!/bin/bash

# start docker container for running dataset compilation in
docker run --workdir /data/ -v $PWD:/data/ -it plink2

exit
