FROM openjdk:8-jre-alpine
LABEL maintainer="Anastasios Skarlatidis"

ENV LANG C.UTF-8
ENV DRUID_VERSION '0.14.0-incubating'

RUN wget -q -O - \
  "https://archive.apache.org/dist/incubator/druid/${DRUID_VERSION}/apache-druid-${DRUID_VERSION}-bin.tar.gz" | gunzip | tar x -C /opt \
  && ln -s /opt/apache-druid-$DRUID_VERSION /opt/druid \
  && mkdir -p /tmp/druid

RUN apk add --no-cache bash
RUN mkdir -p /opt/druid/var/tmp /opt/druid/var/druid/segments /opt/druid/var/druid/indexing-logs /opt/druid/var/druid/task /opt/druid/var/druid/hadoop-tmp /opt/druid/var/druid/segment-cache  

ENV DRUID_HOME=/opt/druid
VOLUME /opt/druid/var

RUN addgroup --gid 1000 druid \
  && adduser --home /opt/druid --shell /bin/sh --no-create-home --uid 1000 --gecos '' --ingroup druid --disabled-password druid \
  && mkdir -p /opt/druid/var \
  && chown -R druid:druid /opt/druid \
  && chmod -R 775 /opt/druid/var

COPY docker-entrypoint.sh /opt/docker-entrypoint.sh

RUN chmod +x /opt/docker-entrypoint.sh


#USER druid

WORKDIR /opt/druid

ENTRYPOINT ["/opt/docker-entrypoint.sh"]
