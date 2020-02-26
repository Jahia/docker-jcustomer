FROM openjdk:8

ARG RELEASE_URL

ENV JAVA_MAX_MEM="2048M"
ENV JCUSTOMER_HOME=/opt/jcustomer

RUN useradd karaf -u 1000 -U -m -d /home/karaf

RUN cd /opt \
    && wget -nv -O jcustomer.tar.gz $RELEASE_URL \
    && tar xzvf jcustomer.tar.gz \
    && rm jcustomer.tar.gz \
    && ln -s $(ls -1) jcustomer \
    && wget -nv -O  $JCUSTOMER_HOME/etc/allCountries.zip http://download.geonames.org/export/dump/allCountries.zip \
    && chown -R karaf: /opt/*

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

EXPOSE 80 8181 9443

WORKDIR $JCUSTOMER_HOME

CMD "/entrypoint.sh"
