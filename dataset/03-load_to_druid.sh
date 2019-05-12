#!/usr/bin/env bash

: ${INPUT_FILE:="yellow_tripdata-index.json"}
: ${DRUID_HOST:="localhost"}
: ${DRUID_PORT:=8090}
: ${API_TASK_PATH:="druid/indexer/v1/task"}
: ${PROTOCOL:="http"}

curl -X 'POST' -H 'Content-Type:application/json' -d @${INPUT_FILE} "${PROTOCOL}://${DRUID_HOST}:${DRUID_PORT}/${API_TASK_PATH}"