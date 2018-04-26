FROM openjdk:8-jdk

LABEL maintainer="Ionel Olteanu <olteanu94@gmail.com>"

# Arguments
ARG HADOOP_VERSION=3.1.0

#install needed software for Hadoop
RUN apt-get update && apt-get install -y ssh rsync wget openssh-server supervisor
#Add hduser
RUN addgroup hadoop && adduser --disabled-password --quiet --ingroup hadoop hduser 

USER hduser

# Add host pub key to authorized keys (for ssh connection without password)
ADD id_rsa.pub .

#Generate key for machine 
RUN ssh-keygen -q -t rsa -N '' -f /home/hduser/.ssh/id_rsa \
    && cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys \
    && cat id_rsa.pub >> $HOME/.ssh/authorized_keys \
    && echo "HashKnownHosts no" >> ~/.ssh/config \
    && echo "StrictHostKeyChecking no" >> ~/.ssh/config


USER root

WORKDIR /usr/local

# Download and install hadoop
RUN wget http://apache.javapipe.com/hadoop/core/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    && tar xzf hadoop-${HADOOP_VERSION}.tar.gz \
    && mkdir hadoop \
    && mv hadoop-${HADOOP_VERSION}/* hadoop \
    && chown -R hduser:hadoop hadoop 

# Create temp folder for hdfs
RUN mkdir -p /var/local/hadoop \
    && chown -R hduser:hadoop /var/local/hadoop \
    && chmod 755 -R /var/local/hadoop \
    && mkdir -p /var/local/hdfs/data \
    && mkdir -p /var/local/hdfs/name \
    && chown -R hduser:hadoop /var/local/hdfs \
    && chmod 755 -R /var/local/hdfs 

USER hduser

RUN echo "export HADOOP_HOME=/usr/local/hadoop"  >> $HOME/.bashrc \
    && echo "export PATH=$PATH:$HADOOP_HOME/bin" >> $HOME/.bashrc \
    && echo "export JAVA_HOME="$JAVA_HOME >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh \
    && echo "export HADOOP_OPTS=-Djava.net.preferIPv4Stack=true" >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh

# Copy configuration files
ADD config/core-site.xml config/mapred-site.xml config/hdfs-site.xml config/yarn-site.xml /usr/local/hadoop/etc/hadoop/


WORKDIR /usr/local/hadoop
#Format the folder
RUN /usr/local/hadoop/bin/hadoop namenode -format

USER root
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 22 8088 9870 9001 50070 50030
ENTRYPOINT ["/usr/bin/supervisord"]