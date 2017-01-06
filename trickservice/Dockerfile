FROM tomcat:8.0.37-jre8

RUN sed -i 's/main/main contrib/' /etc/apt/sources.list

RUN apt-get update && apt-get install -y mysql-client

ENV MYSQL_CONNECTOR_VERSION 5.1.40

ADD tomcat-users.xml /usr/local/tomcat/conf/tomcat-users.xml

ADD hashes /hashes

ADD http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-$MYSQL_CONNECTOR_VERSION.tar.gz /tmp

WORKDIR /tmp

RUN sha512sum -c /hashes

RUN tar xvzf mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.tar.gz mysql-connector-java-${MYSQL_CONNECTOR_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}-bin.jar

RUN mv mysql-connector-java-${MYSQL_CONNECTOR_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}-bin.jar /usr/local/tomcat/lib/

ADD app.war /app.war
ADD initenv.sh /initenv.sh
ADD init-ssl.sh /init-ssl.sh
ADD application.properties /application.properties
ADD deployment.properties /deployment.properties 
ADD deployment-ldap.properties /deployment-ldap.properties
ADD authentication-manager.xml /authentication-manager.xml
ADD local_policy.jar /local_policy.jar
ADD US_export_policy.jar /US_export_policy.jar
ADD server.xml /server.xml

RUN chmod 755 /initenv.sh
RUN chmod 755 /init-ssl.sh

WORKDIR /usr/local/tomcat/webapps/

RUN rm /etc/localtime
RUN ln -s /usr/share/zoneinfo/Europe/Luxembourg /etc/localtime
RUN echo "Europe/Luxembourg" > /etc/timezone

EXPOSE 8443

ENTRYPOINT ["/initenv.sh"]
