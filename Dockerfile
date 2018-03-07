
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

ENV OMPCLOUD_INSTALL_DIR /opt
ENV OMPCLOUD_DIR $OMPCLOUD_INSTALL_DIR/ompcloud

# Configuration options.
ENV OMPCLOUD_CONF_PATH $OMPCLOUD_DIR/conf/cloud_local.ini
ENV LIBHDFS3_CONF $OMPCLOUD_DIR/conf/hdfs-client.xml

ENV CLOUD_TEMP /tmp/cloud

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/

ENV APACHE_MIRROR http://apache.mirrors.tds.net
ENV HADOOP_VERSION 2.7.4
ENV HADOOP_HOME /opt/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF $HADOOP_HOME/etc/hadoop

ENV SPARK_VERSION 2.2.0
ENV SPARK_HADOOP_VERSION 2.7
ENV SPARK_HOME /opt/spark-$SPARK_VERSION-bin-hadoop$SPARK_HADOOP_VERSION

ENV WORKON_HOME $OMPCLOUD_INSTALL_DIR/virtualenvs
ENV CGCLOUD_HOME $OMPCLOUD_INSTALL_DIR/cgcloud
ENV CGCLOUD_PLUGINS cgcloud.spark
ENV CGCLOUD_ZONE sa-east-1a
ENV AWS_PROFILE hyviquel
ENV CGCLOUD_ME hyviquel-docker

ENV LC_ALL en_US.UTF-8
ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SPARK_HOME/bin:$OMPCLOUD_INSTALL_DIR/llvm-build/bin
ENV LIBRARY_PATH $OMPCLOUD_INSTALL_DIR/libomptarget-build/lib:$OMPCLOUD_INSTALL_DIR/llvm-build/lib:/usr/local/lib
ENV LD_LIBRARY_PATH $OMPCLOUD_INSTALL_DIR/libomptarget-build/lib:$OMPCLOUD_INSTALL_DIR/llvm-build/lib:/usr/local/lib
ENV CPATH $OMPCLOUD_INSTALL_DIR/llvm-build/projects/openmp/runtime/src:$CPATH

# Install dependencies
COPY script/ompcloud-dev-install-dep.sh $OMPCLOUD_INSTALL_DIR/
RUN $OMPCLOUD_INSTALL_DIR/ompcloud-dev-install-dep.sh
RUN apt-get install -y openssh-server wget ninja-build ccache

RUN mkdir $CLOUD_TEMP
ADD project-sbt/ $CLOUD_TEMP
RUN cd $CLOUD_TEMP; sbt assembly

# Install hadoop and spark
RUN wget -nv -P $OMPCLOUD_INSTALL_DIR/ $APACHE_MIRROR/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$SPARK_HADOOP_VERSION.tgz
RUN wget -nv -P $OMPCLOUD_INSTALL_DIR/ $APACHE_MIRROR/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz
RUN cd $OMPCLOUD_INSTALL_DIR/; tar -zxf $OMPCLOUD_INSTALL_DIR/spark-$SPARK_VERSION-bin-hadoop$SPARK_HADOOP_VERSION.tgz
RUN cd $OMPCLOUD_INSTALL_DIR/; tar -zxf $OMPCLOUD_INSTALL_DIR/hadoop-$HADOOP_VERSION.tar.gz
RUN rm $OMPCLOUD_INSTALL_DIR/spark-$SPARK_VERSION-bin-hadoop$SPARK_HADOOP_VERSION.tgz $OMPCLOUD_INSTALL_DIR/hadoop-$HADOOP_VERSION.tar.gz

# Configure SSH
RUN ssh-keygen -q -N "" -t rsa -f ~/.ssh/id_rsa
RUN cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys
RUN service ssh start

# Install virtualenv
RUN pip install virtualenv virtualenvwrapper
RUN mkdir -p $WORKON_HOME
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

RUN echo 'export PATH="/usr/lib/ccache:$PATH"' >> /root/.zshrc
RUN echo 'export LC_ALL=en_US.UTF-8' >> /root/.zshrc
RUN echo 'export LANG=en_US.UTF-8' >> /root/.zshrc

ENV TERM xterm

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
