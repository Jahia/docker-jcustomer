FROM openjdk:8

ARG RELEASE_URL

ENV JAVA_MAX_MEM="2048M"
ENV JCUSTOMER_HOME=/opt/jcustomer

RUN useradd karaf -u 1000 -U -m -d /home/karaf

# these two files need to be copied on the same line since we want to copy installer.jar IF it exists, and copy doesn't support conditional copy (only copy if file exists)
COPY entrypoint.sh jcustomer.zip* /opt/


RUN cd /opt \
    && if [ ! -f "jcustomer.zip" ]; then \
        wget -nv -O jcustomer.tar.gz $RELEASE_URL; \
        tar xzvf jcustomer.tar.gz; \
        rm jcustomer.tar.gz; \
       fi \
    && if [ -f "jcustomer.zip" ]; then \
        unzip jcustomer.zip ;\
        rm jcustomer.zip; \
       fi \
    && rm entrypoint.sh \
    && ln -s $(ls -1) jcustomer \
    && wget -nv -O  $JCUSTOMER_HOME/etc/allCountries.zip http://download.geonames.org/export/dump/allCountries.zip \
    && chown -R karaf: /opt/*

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

EXPOSE 8181 9443

WORKDIR $JCUSTOMER_HOME

CMD ["/entrypoint.sh"]
