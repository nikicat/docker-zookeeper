# Dockerfile for ZooKeeper

FROM yandex/ubuntu:14.04
MAINTAINER Nikolay Bryskin <devel.niks@gmail.com>

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -qyy install openjdk-7-jre-headless -y && apt-get clean
# Get latest stable release of ZooKeeper
RUN wget -q -O - http://mirrors.sonic.net/apache/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz | tar -C /opt -xz
RUN mv /opt/zookeeper-* /opt/zookeeper

ADD jmxagent.jar /opt/zookeeper/lib/
ADD run.sh /root/

WORKDIR /opt/zookeeper/

VOLUME /var/lib/zookeeper
VOLUME /var/log/zookeeper
VOLUME /opt/zookeeper/conf

EXPOSE 2181 2888 3888 4888

CMD /root/run.sh
