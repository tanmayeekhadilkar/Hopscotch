#!/bin/bash -login
## make sure to put the proper SLURM headers here! 
## we can go through and make sure those work

## there are various modules available on FARM
## these are programs installed that can be used by all users
## sratoolkit is a set of programs that can be used to interact with the NCBI Short Read Archive (SRA)

module load sratoolkit

## when papers are published, the sequence data is deposited into the SRA
## you can find out more about them at the NCBI SRA website https://www.ncbi.nlm.nih.gov/sra
## this is sequence from a teosinte inbred line, TIL01
SRRNUM=SRR447883

## this will start the download, and tell the sratoolkit where to look for files
prefetch $SRRNUM

## this will split the .sra file into two fastq files (for paired end sequencing)
fastq-dump --split-files -I ${SRRNUM}

## now we should have two files, SRRNUM_1.fastq and SRRNUM_2.fastq
## we can use these as input for relocaTE and other TE finding software


## then let's repeat it all for some more sequencing data of TIL01

SRRNUM=SRR447882
prefetch $SRRNUM
fastq-dump --split-files -I ${SRRNUM}

