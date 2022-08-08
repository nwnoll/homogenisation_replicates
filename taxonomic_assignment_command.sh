#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -S /bin/bash
#$ -R y
#$ -M n.noll@leibniz-zfmk.de
#$ -m be


ruby taxonomic_assignment.rb $1 > new_otus_combined_tax.tsv
