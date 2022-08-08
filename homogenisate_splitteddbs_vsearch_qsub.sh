qsub -cwd -N "${1}_otus" -o . -e . homogenisate_splitteddbs_vsearch_command.sh ${1} ${2}
