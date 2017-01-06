FROM debian:8.6

ENV APACHE_RUN_USER  www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_PID_FILE  /var/run/apache2.pid
ENV APACHE_RUN_DIR   /var/run/apache2
ENV APACHE_LOCK_DIR  /var/lock/apache2
ENV APACHE_LOG_DIR   /var/log/apache2
ENV APACHE_USER_UID 0

# PHP && Apache
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -yqq install --no-install-recommends\
    openssl \
    apache2-mpm-prefork\
    apache2-utils \
    ca-certificates &&\
    rm -rf /var/lib/apt/lists/* &&\
    a2enmod rewrite ssl headers proxy proxy_ajp proxy_balancer proxy_connect proxy_express proxy_fcgi proxy_fdpass proxy_ftp proxy_html proxy_http proxy_scgi proxy_wstunnel authnz_ldap xml2enc &&\
    echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Config files.
#COPY conf/apache/000-default /etc/apache2/sites-enabled/000-default.conf
COPY script/start.bash /root/start.bash

RUN openssl req \
    -new \
    -newkey rsa:4096 \
    -days 365 \
    -nodes \
    -x509 \
    -subj "/C=LU/ST=service/L=service/O=service/CN=kibana-lan.itrust.lu" \
    -keyout /epl-server.key \
    -out /epl-server.crt

RUN openssl req \
    -new \
    -newkey rsa:4096 \
    -days 365 \
    -nodes \
    -x509 \
    -subj "/C=LU/ST=service/L=service/O=service/CN=kibana-lan-ca.itrust.lu" \
    -keyout /epl-server-ca.key \
    -out /epl-server-ca.crt

RUN openssl req -subj "/C=LU/ST=service/L=service/O=service/CN=kibana-lan.itrust.lu" -new -key /epl-server.key -out /epl-server.csr

RUN openssl x509 -req -days 9000 -in /epl-server.csr -CA /epl-server-ca.crt -CAkey /epl-server-ca.key -set_serial 001 -out /epl-server.crt
RUN chmod 777 /epl-server.key /epl-server-ca.crt /epl-server.crt

RUN a2dissite 000-default

RUN cat /epl-server-ca.crt >> /epl-server.crt

EXPOSE 443

VOLUME ["/var/log/apache2","/etc/php5/apache2/","/var/www/"]

RUN mkdir /var/lock/apache2

RUN rm /etc/localtime
RUN ln -s /usr/share/zoneinfo/Europe/Luxembourg /etc/localtime
RUN echo "Europe/Luxembourg" > /etc/timezone

CMD ["/bin/bash", "/root/start.bash"]
