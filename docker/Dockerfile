# recipe taken from https://hub.docker.com/r/emosyne/plink2

FROM ubuntu:20.04

RUN apt-get update && apt-get install -y wget python3 python3-pip unzip libbz2-dev liblzma-dev

RUN wget https://s3.amazonaws.com/plink2-assets/alpha3/plink2_linux_x86_64_20221024.zip && \
    unzip plink2_linux_x86_64_20221024.zip

RUN wget https://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20220402.zip && \
    unzip plink_linux_x86_64_20220402.zip

RUN install -dm0755 /usr/local/bin
RUN install -Dm0755 plink2 /usr/local/bin
RUN install -Dm0755 plink /usr/local/bin

RUN apt-get update && apt-get install -y dstat atop

RUN pip3 install CrossMap

