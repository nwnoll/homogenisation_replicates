#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -S /bin/bash
#$ -R y
#$ -m be


ruby tax_assignment_multiple_inputs.rb -d otus > new_otus_combined.b6 
