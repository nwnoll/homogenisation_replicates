#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -S /bin/bash
#$ -R y
#$ -m be


vsearch --usearch_global ${2} --db ${1} --blast6out homogenisate_splitted_db_otus_${1}_085.b6 --id 0.85 --dbmask none --qmask none --threads 1 --maxhits 1000 --maxaccepts 0
