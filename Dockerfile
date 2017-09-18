
FROM phusion/baseimage:0.9.21
#FROM ubuntu:16.04
MAINTAINER Hervé Yviquel <hyviquel@gmail.com>

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

RUN rm -f /etc/service/sshd/down

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Configuration options.
ENV CGCLOUD_HOME /opt/cgcloud
ENV LIBHDFS3_SRC /opt/libhdfs3
ENV LIBHDFS3_BUILD /opt/libhdfs3-build
ENV OMPCLOUD_CONF_DIR /opt/ompcloud/conf
ENV OMPCLOUD_SCRIPT_DIR /opt/ompcloud/script
ENV CLOUD_TEMP /tmp/cloud
ENV OMPCLOUD_CONF_PATH $OMPCLOUD_CONF_DIR/cloud_local.ini
ENV LIBHDFS3_CONF $OMPCLOUD_CONF_DIR/hdfs-client.xml

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/

ENV HADOOP_REPO http://apache.mirrors.tds.net
ENV HADOOP_VERSION 2.7.4
ENV HADOOP_HOME /opt/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF $HADOOP_HOME/etc/hadoop

ENV SPARK_REPO http://d3kbcqa49mib13.cloudfront.net
ENV SPARK_VERSION 2.2.0
ENV SPARK_HADOOP_VERSION 2.7
ENV SPARK_HOME /opt/spark-$SPARK_VERSION-bin-hadoop$SPARK_HADOOP_VERSION

ENV LLVM_SRC /opt/llvm
ENV LLVM_BUILD /opt/llvm-build
ENV LIBOMPTARGET_SRC /opt/libomptarget
ENV LIBOMPTARGET_BUILD /opt/libomptarget-build
ENV OPENMP_SRC /opt/openmp
ENV OPENMP_BUILD /opt/openmp-build
ENV UNIBENCH_SRC /opt/Unibench
ENV UNIBENCH_BUILD /opt/Unibench-build
ENV OMPCLOUDTEST_SRC /opt/ompcloud-test
ENV OMPCLOUDTEST_BUILD /opt/ompcloud-test-build

ENV WORKON_HOME /opt/virtualenvs
ENV CGCLOUD_PLUGINS cgcloud.spark
ENV CGCLOUD_ZONE sa-east-1a
ENV AWS_PROFILE hyviquel
ENV CGCLOUD_ME hyviquel-docker

ENV LC_ALL en_US.UTF-8
ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SPARK_HOME/bin:$LLVM_BUILD/bin
ENV LIBRARY_PATH $LIBOMPTARGET_BUILD/lib:$LLVM_BUILD/lib:/usr/local/lib
ENV LD_LIBRARY_PATH $LIBOMPTARGET_BUILD/lib:$LLVM_BUILD/lib:/usr/local/lib
ENV CPATH $LLVM_BUILD/projects/openmp/runtime/src:$CPATH

# Install dependencies
COPY script/ompcloud-dev-install-dep.sh /opt/
RUN /opt/ompcloud-dev-install-dep.sh
RUN apt-get install -y openssh-server git wget gcc g++ cmake ninja-build

RUN mkdir $CLOUD_TEMP
ADD project-sbt/ $CLOUD_TEMP
RUN cd $CLOUD_TEMP; sbt assembly

# Install hadoop and spark
RUN wget -nv -P /opt/ $SPARK_REPO/spark-$SPARK_VERSION-bin-hadoop$SPARK_HADOOP_VERSION.tgz
RUN wget -nv -P /opt/ $HADOOP_REPO/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz
RUN cd /opt/; tar -zxf /opt/spark-$SPARK_VERSION-bin-hadoop$SPARK_HADOOP_VERSION.tgz
RUN cd /opt/; tar -zxf /opt/hadoop-$HADOOP_VERSION.tar.gz
RUN rm /opt/spark-$SPARK_VERSION-bin-hadoop$SPARK_HADOOP_VERSION.tgz /opt/hadoop-$HADOOP_VERSION.tar.gz

# Configure SSH
RUN ssh-keygen -q -N "" -t rsa -f ~/.ssh/id_rsa
RUN cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys
RUN service ssh start

# Install virtualenv
RUN pip install virtualenv virtualenvwrapper
RUN mkdir -p /opt/virtualenvs
RUN git clone -b spark-2.0 git://github.com/hyviquel/cgcloud.git $CGCLOUD_HOME

# Install cgcloud
RUN /bin/bash -c "source /usr/local/bin/virtualenvwrapper.sh \
    && cd $CGCLOUD_HOME \
    && mkvirtualenv cgcloud \
    && workon cgcloud \
    && make develop sdist"

# Create alias for running cgcloud easily
RUN echo '#!/bin/bash\n$WORKON_HOME/cgcloud/bin/cgcloud $@' > /usr/bin/cgcloud; \
    chmod +x /usr/bin/cgcloud

# Configure Hadoop and Spark
# FIXME: JAVA_HOME is hard coded
RUN sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/\n:' $HADOOP_CONF/hadoop-env.sh

# Create aliases for managining the HDFS server
RUN echo '#!/bin/bash\nstart-dfs.sh;start-yarn.sh' > /usr/bin/hdfs-start; \
    echo '#!/bin/bash\nstop-yarn.sh;stop-dfs.sh' > /usr/bin/hdfs-stop; \
    echo '#!/bin/bash\nhdfs-stop;rm -rf /opt/hadoop/hdfs/datanode;hdfs namenode -format -force;hdfs-start' > /usr/bin/hdfs-reset; \
    chmod +x /usr/bin/hdfs-start /usr/bin/hdfs-stop /usr/bin/hdfs-reset

ADD conf-hdfs/core-site.xml $HADOOP_CONF
ADD conf-hdfs/hdfs-site.xml $HADOOP_CONF
ADD conf-hdfs/config /root/.ssh

# Install and configure ZSH
RUN apt-get install -y zsh
RUN bash -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

ENV TERM xterm

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
