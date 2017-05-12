#!/bin/bash -login
#SBATCH -D /home/tmkhadil/projects/Hopscotch/
#SBATCH -o /home/tmkhadil/projects/Hopscotch/slurm-log/simulate_hopscotch-stdout-%j.txt
#SBATCH -e /home/tmkhadil/projects/Hopscotch/slurm-log/simulate_hopscotch-stderr-%j.txt
#SBATCH -J simulate_hopscotch
#SBATCH -t 24:00:00
set -e
set -u

####################################################################
## Simulate hopscotch at random locations in the reference genome ##
####################################################################

##### pick a random region of the genome

export CHR=$(( ( RANDOM % 10 )  + 1 ))   ## this is picking a random number between 1 and 10

##!!!! this needs to be done! one way it could be done would be to make a file or array with each chromosome, and then make the max random number the chromosome length of the selected chromsome.

## chrsize is decided by the following logic
## there are size files with file name format <chromosomenumber>.CHR.SIZE for each chromosome which contain the sizes of each chromosome, i dont know the size of each chromosome but when I find that out I can put in those values into the files

export CHRSIZE=$( cat $CHR.CHR.SIZE )

POSITION=$(( ( RANDOM % CHRSIZE ) + 1 )) ## want to make this so that it can't be longer than the chromsome length

##### get two halves of the sequence, so we can put hopscotch in the middle, with a TSD

LEFTFLANKSTART=$POSITION
LEFTFLANKEND=$(expr $POSITION + 505)  ### TSD is 5 bp
RIGHTFLANKSTART=$(expr $POSITION+500)
RIGHTFLANKEND=$(expr $POSITION+1000)

echo $RIGHTFLANKSTART   ## this should be where the TE insertion is called by relocaTE

##### samtools faidx can be used to get regions of chromosomes
samtools faidx Zea_mays.AGPv4.dna.toplevel.fa
samtools faidx referencegenome.fa ${CHR}:$LEFTFLANKSTART-$LEFTFLANKEND > upstream_ins.fa
samtools faidx referencegenome.fa ${CHR}:$RIGHTFLANKSTART-$RIGHTFLANKEND > downstream_ins.fa


##### combine up, down, and hopscotch

cat upstream_ins.fa > simulated_hopscotch_$CHR_$RIGHTFLANKSTART.fa
tail -n+1 hopscotch.fa >> simulated_hopscotch_$CHR_$RIGHTFLANKSTART.fa
tail -n+1 downstream_ins.fa >> simulated_hopscotch_$CHR_$RIGHTFLANKSTART.fa

##### now this should be a fasta file of the region where we have inserted the TE
## use it to simulate 30x coverage of these regions
## may need to install wgsim https://github.com/lh3/wgsim

## no errors, fragment length 400, stdev=100, 2thousand reads, 100bp for and rev, pi 0.002, all SNPs (no indel), fixed seed
wgsim -e 0 -d 400 -s 100 -N 2000 -1 100 -2 100 -r 0.002 -R 0 -S 1234 simulated_hopscotch_$CHR_$RIGHTFLANKSTART.fa simulated_hopscotch_$CHR_$RIGHTFLANKSTART.r1.fq simulated_hopscotch_$CHR_$RIGHTFLANKSTART.r2.fq 
##here it throws up an error message that /path/to/wgsim does not exist, is samtools downloaded???

##### could repeat this in a for loop or something to get 10 simulated insertions

##### use these fq as input to relocaTE
## these are not many reads, so don't need to split the fq and can supply them directly to the relocate script

