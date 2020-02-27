FROM ubuntu:18.04

ARG ZEPPELIN_VERSION="0.8.2"
ARG SPARK_VERSION="2.3.4"
ARG HADOOP_VERSION="2.7"

LABEL maintainer "tsagadai"
LABEL zeppelin.version=${ZEPPELIN_VERSION}
LABEL spark.version=${SPARK_VERSION}
LABEL hadoop.version=${HADOOP_VERSION}

# use a faster mirror
#RUN sed -i -e 's/http:\/\/archive/mirror:\/\/mirrors/' \
#  -e 's/http:\/\/security*.mirror.txt/mirror:\/\/mirrors\.security/' \
#  -e 's/\/ubuntu\//\/mirrors.txt/' /etc/apt/sources.list && cat /etc/apt/sources.list
RUN sed -i -e 's/http:\/\/archive/http:\/\/au.archive/' /etc/apt/sources.list
# Install Java and some tools
ENV DEBIAN_FRONTEND noninteractive
RUN apt update && apt upgrade -y && \
    apt -q -y install curl less openjdk-8-jdk vim.nox wget ssh


##########################################
# SPARK
##########################################
RUN mkdir -p /usr/local/spark &&\
    mkdir -p /tmp/spark-events    # log-events for spark history server
ENV SPARK_HOME /usr/local/spark

ENV PATH $PATH:${SPARK_HOME}/bin
RUN wget -qO- http://apache.mirror.cdnetworks.com/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz | tar -xz -C  /usr/local/spark --strip-components=1

COPY spark-defaults.conf ${SPARK_HOME}/conf/

##########################################
# Zeppelin
##########################################
RUN mkdir /usr/zeppelin &&\
    wget -qO- http://apache.mirror.cdnetworks.com/zeppelin/zeppelin-${ZEPPELIN_VERSION}/zeppelin-${ZEPPELIN_VERSION}-bin-all.tgz | tar -xz -C /usr/zeppelin
RUN echo '{ "allow_root": true }' > /root/.bowerrc

ENV ZEPPELIN_PORT 8888
EXPOSE $ZEPPELIN_PORT

ENV ZEPPELIN_HOME /usr/zeppelin/zeppelin-${ZEPPELIN_VERSION}-bin-all
ENV ZEPPELIN_CONF_DIR $ZEPPELIN_HOME/conf
ENV ZEPPELIN_NOTEBOOK_DIR $ZEPPELIN_HOME/notebook

RUN mkdir -p $ZEPPELIN_HOME \
  && mkdir -p $ZEPPELIN_HOME/logs \
  && mkdir -p $ZEPPELIN_HOME/run



# my WorkDir
RUN mkdir /data
WORKDIR /data


ENTRYPOINT  /usr/local/spark/sbin/start-history-server.sh; $ZEPPELIN_HOME/bin/zeppelin-daemon.sh start  && bash

