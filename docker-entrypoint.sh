#!/usr/bin/env bash


###############################################################################
# Required parameters
###############################################################################


if [[ -z ${DRUID_SERVICE_PORT+x} ]]; then
   echo "ERROR - please specify the environment variable 'DRUID_SERVICE_PORT'"
   exit 1
fi

SERVICE_NAME=$1

: ${DRUID_ZK_HOST:="zookeeper"}
: ${PG_HOST:="postgres"}

: ${DRUID_SERVICE:="druid/${SERVICE_NAME}"}

###############################################################################
# Optional parameters
###############################################################################
: ${DRUID_HOME:="/opt/druid"}

PATH_TO_DRUID_CONFIG="${DRUID_HOME}/conf/druid/$1"

: ${JVM_TIMEZONE:="UTC"}

#
# Druid JVM memory configuration
#

: ${MEMORY_XMS:="1g"}
: ${MEMORY_XMX:="1g"}
: ${MEMORY_MAX_DIRECT_SIZE:="6172m"}

#
# Logging level configuration
#
: ${DRUID_LOGLEVEL:="error"}

#
# Hostname
#
: ${DRUID_HOST:="${SERVICE_NAME}"}
: ${DRUID_USE_CONTAINER_IP:="true"}

if [[ "$DRUID_USE_CONTAINER_IP" = "true" ]]; then
    DRUID_HOST=$(ip a | grep "global eth0" | awk '{print $2}' | awk -F '\/' '{print $1}')
fi

: ${PG_PORT:="5432"}


###############################################################################
# Start the process
###############################################################################

export DRUID_LOG4J='<?xml version="1.0" encoding="UTF-8" ?><Configuration status="WARN"><Appenders><Console name="Console" target="SYSTEM_OUT"><PatternLayout pattern="%d{ISO8601} %p [%t] %c - %m%n"/></Console></Appenders><Loggers><Root level="info"><AppenderRef ref="Console"/></Root><Logger name="org.apache.druid.jetty.RequestLog" additivity="false" level="DEBUG"><AppenderRef ref="Console"/></Logger></Loggers></Configuration>'

java -server \
    -Xms${MEMORY_XMS} \
    -Xmx${MEMORY_XMX} \
    -XX:MaxDirectMemorySize=${MEMORY_MAX_DIRECT_SIZE} \
    -Ddruid.plaintextPort=${DRUID_SERVICE_PORT} \
    -Duser.timezone=${JVM_TIMEZONE} \
    -Dfile.encoding=UTF-8 \
    -Djava.io.tmpdir="/opt/druid/var/tmp" \
    -Ddruid.zk.service.host=${DRUID_ZK_HOST} \
    -Ddruid.extensions.loadList="[\"druid-histogram\", \"druid-datasketches\", \"druid-lookups-cached-global\", \"druid-s3-extensions\", \"postgresql-metadata-storage\"]" \
    -Ddruid.metadata.storage.type=postgresql \
    -Ddruid.metadata.storage.connector.connectURI=jdbc:postgresql://${PG_HOST}:${PG_PORT}/druid \
    -Ddruid.metadata.storage.connector.user=druid \
    -Ddruid.metadata.storage.connector.password=druid \
    -Ddruid.coordinator.balancer.strategy=cachingCost \
    -Daws.region=us-east-1\
    -Ddruid.storage.type=s3 \
    -Ddruid.s3.accessKey="DRUIDDEEPSTORASGEACCESSKEY" \
    -Ddruid.s3.secretKey="DRUIDDEEPSTORASGESECRETKEY" \
    -Ddruid.storage.bucket=storage \
    -Ddruid.storage.baseKey=druid \
    -Ddruid.s3.endpoint.url="http://minio:9000" \
    -Ddruid.s3.protocol=http \
    -Ddruid.s3.enablePathStyleAccess=true \
    -Ddruid.indexer.logs.type=file \
    -Ddruid.indexer.logs.directory=/var/druid/indexing-logs \
    -Ddruid.indexer.fork.property.druid.processing.buffer.sizeBytes=268435456 \
    -Ddruid.indexer.runner.javaOptsArray='["-server", "-Xmx1g", "-Xms1g", "-XX:MaxDirectMemorySize=3g", "-Duser.timezone=UTC", "-Dfile.encoding=UTF-8", "-Daws.region=us-east-1",  "-Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager"]' \
    -Ddruid.segmentCache.locations="[{\"path\": \"var/druid/segment-cache\", \"maxSize\": 130000000000}]}" \
    -Ddruid.server.maxSize=130000000000 \
    -Ddruid.emitter.logging.logLevel=${DRUID_LOGLEVEL} \
    -Ddruid.sql.enable=true \
    -Ddruid.processing.numThreads=2 \
    -cp "${DRUID_HOME}/conf/druid/_common:${DRUID_HOME}/conf/druid/${1}:${DRUID_HOME}/lib/*" \
    org.apache.druid.cli.Main server $@



    #-Ddruid.service=${DRUID_SERVICE} \
    #-Ddruid.plaintextPort=${DRUID_SERVICE_PORT} \
    #-Ddruid.lookup.enableLookupSyncOnStartup=false \
    #-Ddruid.coordinator.startDelay=PT10S \
    #-Ddruid.coordinator.period=PT5S \
    #-Ddruid.indexer.queue.startDelay=PT5S \
    #-Ddruid.router.defaultBrokerServiceName=druid_broker \
    #-Ddruid.router.coordinatorServiceName=druid_coordinator \
    #-Ddruid.selectors.coordinator.serviceName=druid_coordinator \
    #-Ddruid.selectors.indexing.serviceName=druid_overlord \
    #-Ddruid.router.managementProxy.enabled=true \
    #-Ddruid.emitter=logging \
    #-Ddruid.emitter.logging.loggerClass=LoggingEmitter \
    #-Ddruid.storage.storageDirectory=/var/druid/segments \
    #-Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager \
    