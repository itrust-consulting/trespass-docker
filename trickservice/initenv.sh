#!/bin/bash

set -e

if [[ -e /app.war ]]; then

	TOMCAT_USER_FILE=/usr/local/tomcat/conf/tomcat-users.xml
	APP_PROPERTIES_FILE=/usr/local/tomcat/webapps/ROOT/WEB-INF/classes/application.properties

	JDBC_HOST=${JDBC_HOST:-mysql}
	JDBC_PORT=${JDBC_PORT:-3306}
	JDBC_DBNAME=${JDBC_DBNAME:-trickservice}
	JDBC_USERNAME=${JDBC_USERNAME:-}
	JDBC_PASSWORD=${JDBC_PASSWORD:-}
	JDBC_SHOW_SQL=${JDBC_SHOW_SQL:-}
	JDBC_HBM2DDL_AUTO=${JDBC_HBM2DDL_AUTO:-}
	JDBC_CURRENT_SESSION_CLASS=${JDBC_CURRENT_SESSION_CLASS:-}
	
	if [[ ! -e /keystore-tomcat ]]; then
		/init-ssl.sh
	fi
	
	if [[ -e /restore.sql ]]; then
		echo "Start to restore database"
		mysql -u $JDBC_USERNAME -p$JDBC_PASSWORD -h $JDBC_HOST < /restore.sql
		echo "End of database restoring"
	fi

	TOMCAT_USER=${TOMCAT_USER:-tomcat}
	TOMCAT_PASSWORD=${TOMCAT_PASSWORD:-tacmot}
	
	sed -i 's/{{TOMCAT_USER}}/'"${TOMCAT_USER}"'/' $TOMCAT_USER_FILE
	sed -i 's/{{TOMCAT_PASSWORD}}/'"${TOMCAT_PASSWORD}"'/' $TOMCAT_USER_FILE

	TOMCAT_JAVA_OPTS=${TOMCAT_JAVA_OPTS:- -server}	
	
	rm -R /usr/local/tomcat/webapps/*

	unzip -d /usr/local/tomcat/webapps/ROOT /app.war

	cp /application.properties /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/
	cp /deployment.properties /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/
	cp /deployment-ldap.properties /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/
	cp /authentication-manager.xml /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/spring/
	
	cp /server.xml /usr/local/tomcat/conf/server.xml

	cp /US_export_policy.jar /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/
	cp /local_policy.jar /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/

	sed -i "/#JAVA_OPTS/a JAVA_OPTS=\"$TOMCAT_JAVA_OPTS\"" /usr/local/tomcat/bin/catalina.sh
	
	/usr/local/tomcat/bin/catalina.sh run
else
	echo "Cannot start without a war. Mount it to /app.war"
fi
