FROM iolteanu/haclup

LABEL maintainer="Ionel Olteanu <olteanu94@gmail.com>"

ARG SPARK_VERSION=2.3.0
# Add spark Configuration
USER root

WORKDIR /opt/

RUN wget http://apache.javapipe.com/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz  \
    && tar xvf spark-${SPARK_VERSION}-bin-hadoop2.7.tgz \
    && mkdir spark \
    && mv spark-${SPARK_VERSION}-bin-hadoop2.7/* spark \
    && chown -R hduser:hadoop spark

USER hduser

ADD config/spark-env.sh config/spark-defaults.conf config/slaves /opt/spark/conf/

USER root
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf_extra
RUN cat /etc/supervisor/conf.d/supervisord.conf_extra >> /etc/supervisor/conf.d/supervisord.conf

EXPOSE 7077 53411 4040

ENTRYPOINT ["/usr/bin/supervisord"]