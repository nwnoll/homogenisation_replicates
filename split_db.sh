while getopts c:d:f: flag
do
    	case "${flag}" in
        	c) core_num=${OPTARG};;
		d) db=${OPTARG};;
    		f) query_file=${OPTARG};;
	esac
done

echo "cores: ${core_num}";
echo "db: ${db}";
echo "file: ${query_file}";

if [ $core_num -gt 1 ]
then
	echo "calculating file length...";
	db_lines_num=$(wc -l ${db} | cut -d' ' -f1);
	echo "number of lines of db ${db}: ${db_lines_num}";

	db_lines_per_part=$((db_lines_num / core_num));
	echo "db file will be splitted into ${core_num} parts";

	lines_to_add=$(( $db_lines_per_part  % 2 ))
	db_lines_per_part=$((db_lines_per_part + lines_to_add));
	echo "beginning to split file ${db_lines_per_part}...";
	
	split -l ${db_lines_per_part} ${db};
	array=($(ls -d [x]*));
	echo "$array";
	

	filearr=( x* )
	for f in "${filearr[@]}"; do

		echo "submit job for $f"
		./homogenisate_splitteddbs_vsearch_qsub.sh $f $query_file
	
	done


fi
