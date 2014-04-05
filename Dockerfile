# Dockerfile for ZooKeeper

FROM yandex/ubuntu
MAINTAINER Nikolay Bryskin <devel.niks@gmail.com>

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install openjdk-7-jre-headless -y && apt-get clean
# Get latest stable release of ZooKeeper
RUN wget -q -O - http://mirrors.sonic.net/apache/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz | tar -C /opt -xz
RUN curl https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py | python && rm *.zip && python -m easy_install -H *.python.org git+git://github.com/signalfuse/maestro-ng

ADD jmxagent.jar /opt/zookeeper-3.4.6/lib/
ADD run.py /opt/zookeeper-3.4.6/.docker/
ADD log4j.properties /opt/zookeeper-3.4.6/conf/

WORKDIR /opt/zookeeper-3.4.6/
VOLUME /var/lib/zookeeper
VOLUME /var/log/zookeeper
CMD ["python", "/opt/zookeeper-3.4.6/.docker/run.py"]
