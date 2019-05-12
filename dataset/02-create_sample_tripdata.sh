#!/usr/bin/env bash

: ${START_DATE:="2015-01-01"}
: ${END_DATE:="2015-04-01"}
: ${SAMPLE_SIZE_PER_DAY:="500"}
: ${TRIP_RECORD_TYPE:="yellow"} # 'yellow', 'green' or 'fhv'
: ${OUTPUT_FILE:="${TRIP_RECORD_TYPE}_trip_data-sample.csv"}
: ${OVERWRITE:="false"}
: ${INPUT_FILE_PREFIX:="${TRIP_RECORD_TYPE}_tripdata"}

if [[ -f ${OUTPUT_FILE} ]] && [[ ${OVERWRITE} == "false" ]]; then
    echo "ERROR: file ${OUTPUT_FILE} exists from a previous run. You can either manually delete the file or set different 'OUTPUT_FILE' parameter or set 'OVERWRITE=true'"
    exit 1
fi


curr_date="${START_DATE}"


# Write file header to $OUTPUT_FILE
curr_date_filename=$( date +%Y-%m --date "$curr_date" )
curr_filename="${INPUT_FILE_PREFIX}_${curr_date_filename}.csv.gz"
cat ${curr_filename} | gunzip -c | head -1 > ${OUTPUT_FILE}

# Append sample data to ${OUTPUT_FILE}
while true
do
  curr_date_input_filename=$( date +%Y-%m --date "$curr_date" )
  curr_input_filename="${INPUT_FILE_PREFIX}_${curr_date_input_filename}.csv.gz"

  echo "Taking ${SAMPLE_SIZE_PER_DAY} samples from ${curr_input_filename} for date ${curr_date} without replacement"
  cat ${curr_input_filename} | gunzip -c | grep "^[0-9][0-9]*,${curr_date}" | shuf -n ${SAMPLE_SIZE_PER_DAY} | sort --field-separator=',' --key=2 >> ${OUTPUT_FILE}

  
  curr_date=$( date +%Y-%m-%d --date "$curr_date +1 day" )
  [ "$curr_date" \< "$END_DATE" ] || break
done

if [[ -f ${OUTPUT_FILE} ]]; then
  if [[ ${OVERWRITE} = "true" ]]; then 
    gzip -9 --force ${OUTPUT_FILE}
  else
    gzip -9 ${OUTPUT_FILE}
  fi
fi
