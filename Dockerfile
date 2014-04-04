# Dockerfile for ZooKeeper

FROM quay.io/signalfuse/maestro-base:0.1.6
MAINTAINER Maxime Petazzoni <max@signalfuse.com>

# Get latest stable release of ZooKeeper
RUN wget -q -O - http://mirrors.sonic.net/apache/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz \
  | tar -C /opt -xz

ADD jmxagent.jar /opt/zookeeper-3.4.6/lib/
ADD run.py /opt/zookeeper-3.4.6/.docker/
ADD log4j.properties /opt/zookeeper-3.4.6/conf/

WORKDIR /opt/zookeeper-3.4.6/
VOLUME /var/lib/zookeeper
VOLUME /var/log/zookeeper
CMD ["python", "/opt/zookeeper-3.4.6/.docker/run.py"]
