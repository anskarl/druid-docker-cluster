#!/bin/sh

: ${S3_ACCESS_KEY:="DRUIDDEEPSTORASGEACCESSKEY"}
: ${S3_SECRET_KEY:="DRUIDDEEPSTORASGESECRETKEY"}
: ${S3_ENDPOINT_URL:="http://minio:9000"}
: ${S3_STORAGE_BUCKET:="storage"}
: ${S3_LOGS_BUCKET:="logs"}

set -ex

/wait-for minio:9000 -- echo "S3 storage is up! \o/"

mc config host add deep_storage ${S3_ENDPOINT_URL} ${S3_ACCESS_KEY} ${S3_SECRET_KEY} 

mc mb deep_storage/${S3_STORAGE_BUCKET} 
mc policy set download deep_storage/${S3_STORAGE_BUCKET}
mc policy set upload deep_storage/${S3_STORAGE_BUCKET}

mc mb deep_storage/${S3_LOGS_BUCKET}
mc policy set download deep_storage/${S3_LOGS_BUCKET}
mc policy set upload deep_storage/${S3_LOGS_BUCKET}