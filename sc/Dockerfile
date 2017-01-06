FROM tomcat:8.0.37-jre8

ENV MYSQL_CONNECTOR_VERSION 5.1.39

RUN apt-get update && apt-get install -y mysql-client

ADD tomcat-users.xml /usr/local/tomcat/conf/tomcat-users.xml

ADD http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-$MYSQL_CONNECTOR_VERSION.tar.gz /tmp

WORKDIR /tmp

RUN tar xvzf mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.tar.gz mysql-connector-java-${MYSQL_CONNECTOR_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}-bin.jar

RUN mv mysql-connector-java-${MYSQL_CONNECTOR_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}-bin.jar /usr/local/tomcat/lib/

ADD app.war /app.war
ADD initenv /initenv
ADD application.properties /application.properties
ADD local_policy.jar /local_policy.jar
ADD US_export_policy.jar /US_export_policy.jar

RUN openssl req \
    -new \
    -newkey rsa:4096 \
    -days 365 \
    -nodes \
    -x509 \
    -subj "/C=LU/ST=service/L=service/O=service/CN=sc" \
    -keyout /server.key \
    -out /server.crt

RUN openssl req \
    -new \
    -newkey rsa:4096 \
    -days 365 \
    -nodes \
    -x509 \
    -subj "/C=LU/ST=service/L=service/O=service/CN=ca" \
    -keyout /ca.key \
    -out /ca.crt

RUN openssl req -subj "/C=LU/ST=service/L=service/O=service/CN=sc" -new -key /server.key -out /server.csr

RUN openssl x509 -req -days 9000 -in /server.csr -CA /ca.crt -CAkey /ca.key -set_serial 001 -out /server.crt

RUN openssl pkcs12 -export -chain -passout pass:tomcat -in /server.crt -inkey /server.key \
               -out /server.p12 -name tomcat \
               -CAfile /ca.crt -caname ca
               
RUN keytool -importkeystore \
        -deststorepass tomcat -destkeypass tomcat -destkeystore /keystore-tomcat \
        -srckeystore /server.p12 -srcstoretype PKCS12 -srcstorepass tomcat \
        -alias tomcat -noprompt 

ADD server.xml /server.xml

RUN chmod 755 /initenv

RUN rm /etc/localtime
RUN ln -s /usr/share/zoneinfo/Europe/Luxembourg /etc/localtime
RUN echo "Europe/Luxembourg" > /etc/timezone

EXPOSE 8443

ENTRYPOINT ["/initenv"]
