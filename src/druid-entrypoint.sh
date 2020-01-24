#!/usr/bin/env bash

###############################################################################
# Required parameters
###############################################################################

if [[ -z ${DRUID_SERVICE_PORT+x} ]]; then
   echo "ERROR - please specify the environment variable 'DRUID_SERVICE_PORT'"
   exit 1
fi

SERVICE_NAME=$1

###############################################################################
# Optional parameters
###############################################################################

#
# External dependencies (deep storage and metadata)
#

# S3 deep storage
: ${S3_ACCESS_KEY:="DRUIDDEEPSTORASGEACCESSKEY"}
: ${S3_SECRET_KEY:="DRUIDDEEPSTORASGESECRETKEY"}
: ${S3_ENDPOINT_URL:="http://minio:9000"}
: ${S3_AWS_REGION:="us-east-1"}
: ${S3_STORAGE_BUCKET:="storage"}
: ${S3_STORAGE_BASE_KEY:="druid"}
: ${S3_LOGS_BUCKET:="logs"}

# Zookeeper
: ${DRUID_ZK_HOST:="zookeeper"}

# Postgres
: ${PG_HOST:="postgres"}
: ${PG_PORT:="5432"}
: ${PG_USER:="druid"}
: ${PG_PASSWD:="druid"}


#
# Druid params
#

: ${DRUID_LOG_LEVEL:="ERROR"}
: ${DRUID_SERVICE:="druid/${SERVICE_NAME}"}
: ${DRUID_HOME:="/opt/druid"}
: ${JVM_TIMEZONE:="UTC"}
: ${DRUID_SQL_ENABLE:="true"}
: ${DRUID_PROCESSING_NUM_THREAD:="2"}



#
# Druid memory parameters
#
: ${MEMORY_XMS:="384m"}
: ${MEMORY_XMX:="1024m"}
: ${MEMORY_MAX_DIRECT_SIZE:="3g"}


#
# Hostname
#
: ${DRUID_HOST:="${SERVICE_NAME}"}
: ${DRUID_USE_CONTAINER_IP:="true"}

if [[ "$DRUID_USE_CONTAINER_IP" = "true" ]]; then
    DRUID_HOST=$(ip a | grep "global eth0" | awk '{print $2}' | awk -F '\/' '{print $1}')
fi

PATH_TO_DRUID_CONFIG="${DRUID_HOME}/conf/druid/${SERVICE_NAME}"

###############################################################################
# Wait external dependencies
###############################################################################

/opt/wait-for ${PG_HOST}:${PG_PORT} -- echo "Metadata storage is up! \o/"
/opt/wait-for ${DRUID_ZK_HOST}:2181 -- echo "Zookeper is up! \o/"
/opt/wait-for minio:9000 -- echo "Deep storage is up! \o/"

###############################################################################
# Start the process
###############################################################################

LOG_LEVEL=${DRUID_LOG_LEVEL} java -server \
    -Xms${MEMORY_XMS} \
    -Xmx${MEMORY_XMX} \
    -XX:MaxDirectMemorySize=${MEMORY_MAX_DIRECT_SIZE} \
    -XX:+UseG1GC \
    -Ddruid.zk.paths.base="/druid" \
    -Ddruid.service=${DRUID_SERVICE} \
    -Ddruid.plaintextPort=${DRUID_SERVICE_PORT} \
    -Duser.timezone=${JVM_TIMEZONE} \
    -Dfile.encoding=UTF-8 \
    -Djava.io.tmpdir="/opt/druid/var/tmp" \
    -Ddruid.zk.service.host=${DRUID_ZK_HOST} \
    -Ddruid.extensions.loadList="[ \"druid-histogram\", \"druid-datasketches\", \"druid-lookups-cached-global\", \"druid-s3-extensions\", \"postgresql-metadata-storage\", \"druid-kafka-indexing-service\" ]" \
    -Ddruid.metadata.storage.type=postgresql \
    -Ddruid.metadata.storage.connector.connectURI=jdbc:postgresql://${PG_HOST}:${PG_PORT}/druid \
    -Ddruid.metadata.storage.connector.user=${PG_USER} \
    -Ddruid.metadata.storage.connector.password=${PG_PASSWD} \
    -Ddruid.coordinator.balancer.strategy=cachingCost \
    -Daws.region="${S3_AWS_REGION}" \
    -Ddruid.storage.type=s3 \
    -Ddruid.s3.accessKey="${S3_ACCESS_KEY}" \
    -Ddruid.s3.secretKey="${S3_SECRET_KEY}" \
    -Ddruid.storage.bucket=${S3_STORAGE_BUCKET} \
    -Ddruid.storage.baseKey=${S3_STORAGE_BASE_KEY} \
    -Ddruid.s3.endpoint.url="${S3_ENDPOINT_URL}" \
    -Ddruid.s3.protocol=http \
    -Ddruid.s3.enablePathStyleAccess=true \
    -Ddruid.indexer.logs.type=s3 \
    -Ddruid.indexer.logs.s3Bucket="${S3_LOGS_BUCKET}" \
    -Ddruid.indexer.logs.s3Prefix="druid/indexing-logs" \
    -Ddruid.indexer.fork.property.druid.processing.buffer.sizeBytes=268435456 \
    -Ddruid.segmentCache.locations="[{\"path\": \"var/druid/segment-cache\", \"maxSize\": 130000000000}]}" \
    -Ddruid.server.maxSize=130000000000 \
    -Ddruid.emitter="noop" \
    -Ddruid.emitter.logging.loggerClass="NoopServiceEmitter" \
    -Ddruid.emitter.logging.logLevel=error \
    -Ddruid.sql.enable="${DRUID_SQL_ENABLE}" \
    -Ddruid.processing.numThreads="${DRUID_PROCESSING_NUM_THREAD}" \
    -Ddruid.router.managementProxy.enabled=true \
    -cp "${DRUID_HOME}/conf/druid/_common:${DRUID_HOME}/conf/druid/${SERVICE_NAME}:${DRUID_HOME}/lib/*" \
    org.apache.druid.cli.Main server $@