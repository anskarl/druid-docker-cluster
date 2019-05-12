#!/usr/bin/env bash

: ${START_DATE:="2015-01"}
: ${END_DATE:="2015-03"}
: ${TRIP_RECORD_TYPE:="yellow"} # 'yellow', 'green' or 'fhv'

BASE_TRIPDATA_URL="https://s3.amazonaws.com/nyc-tlc/trip+data"
FILE_PREFIX="${TRIP_RECORD_TYPE}_tripdata"
OUTPUT_PATH="."

curr_date="${START_DATE}"

while true
do
  curr_filename="${FILE_PREFIX}_${curr_date}.csv"
  echo "Downloading '${BASE_TRIPDATA_URL}/${curr_filename}' to '${OUTPUT_PATH}/${curr_filename}.gz"

  curl -L "${BASE_TRIPDATA_URL}/${curr_filename}" | gzip -9 > "${OUTPUT_PATH}/${curr_filename}.gz"
  
  [ "$curr_date" \< "$END_DATE" ] || break
  curr_date=$( date +%Y-%m --date "$curr_date-01 +1 month" )
done

