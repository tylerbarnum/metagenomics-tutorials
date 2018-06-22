#!/bin/bash

# This script will take a FASTA file of proteins and E-value for HMM and perform
# a search of UBA bacterial genomes. The output includes an alignment and phylogenetic
# tree of proteins.
#
# Dependencies: HMMER, MUSCLE, perl, FastTree
#
# Input: supplementary table 2 from Parks et. al 2017, UBA bacterial proteins in the
# file uba-bac-proteins.faa, reference proteins (<protein>.faa) and outgroup proteins
# (<protein>-outgroup.faa).
#
# Command line usage:
# sh uba-hmmer-pipeline.sh <protein> <E-value threshold>

PROTEIN=$1
E_VALUE=$2

# Assign variable for paths to reference protein sets and to HMMs
PATH_TO_HMM=HMMS
PATH_TO_REF=REFERENCE_SETS
REFERENCE=$PATH_TO_REF/$PROTEIN.faa
OUTGROUP=$PATH_TO_REF/$PROTEIN-outgroup.faa

# Create directories
mkdir $PATH_TO_HMM
mkdir $PATH_TO_REF
mkdir ./OUTPUT/

# Change to the HMM directory
cd $PATH_TO_HMM

# Align reference proteins
muscle -clwstrict -in ../$REFERENCE -out $PROTEIN.aln;

# Build Hidden Markov Model
hmmbuild $PROTEIN.hmm $PROTEIN.aln

# Test your HMM by searching against your reference proteins
hmmsearch $PROTEIN.hmm $PROTEIN.faa

# Return to directory with UBA genomes
cd -

# Perform HMMER search using HMM and a threshold
HMM_OUT=./OUTPUT/table-${PROTEIN}.out
hmmsearch -E $E_VALUE --tblout $HMM_OUT $PATH_TO_HMM/$PROTEIN.hmm uba-bac-proteins.faa

# Collect the headers of sequences above the threshold i.e. "hits" and sort
LIST_OF_HITS=./OUTPUT/hits-${PROTEIN}.txt
awk '{print $1}' $HMM_OUT > $LIST_OF_HITS
sort $LIST_OF_HITS -o $LIST_OF_HITS

# Optional: remove all lines with "#" using sed
sed -i 's/.*#.*//' $LIST_OF_HITS

# Collect proteins using headers
# Perl code from: http://bioinformatics.cvr.ac.uk/blog/short-command-lines-for-manipulation-fastq-and-fasta-sequence-files/
HITS=./OUTPUT/hits-${PROTEIN}.faa
perl -ne 'if(/^>(\S+)/){$c=$i{$1}}$c?print:chomp;$i{$_}=1 if @ARGV' $LIST_OF_HITS uba-bac-proteins.faa > $HITS

# Create list of genome IDs appended with comma, de-depulicated, and first line removed
# Note: Any line not a full UBA ID like "UBA#####," will return extra results
LIST_OF_GENOMES=./OUTPUT/genomes-${PROTEIN}.txt
sed 's/_.*/,/' $LIST_OF_HITS > $LIST_OF_GENOMES
sort -u $LIST_OF_GENOMES -o $LIST_OF_GENOMES
echo "$(tail -n +2 $LIST_OF_GENOMES)" > $LIST_OF_GENOMES

# Create csv table of genome information from Supplementary Table 2
TABLE_OF_GENOMES=./OUTPUT/genomes-${PROTEIN}.csv
head -1 supp_table_2.csv > $TABLE_OF_GENOMES
while read LINE; do grep "$LINE" supp_table_2.csv >> $TABLE_OF_GENOMES; done <$LIST_OF_GENOMES

# You may open this in a table viewing software, or...
# View "UBA Genome ID," "NCBI Organism Name," "CheckM Completeness," "CheckM Contamination" (fields 2, 8, 5, and 6)
awk -F "\"*,\"*" '{print $2,$8,$5,$6}' $TABLE_OF_GENOMES

# Align reference proteins with hits and outgroup proteins
ALL_PROTEINS=./OUTPUT/all-${PROTEIN}
cat $REFERENCE $OUTGROUP $HITS > $ALL_PROTEINS.faa
muscle -in $ALL_PROTEINS.faa -out $ALL_PROTEINS.aln

# Create tree (default settings for simplicity)
FastTree $ALL_PROTEINS.aln > $ALL_PROTEINS.tre

# Open and view the align with GUI software such as AliView
# Open and view the tree with GUI software such as MEGA
# Edit PDF in Adobe Illustrator or InkScape if you're fancy