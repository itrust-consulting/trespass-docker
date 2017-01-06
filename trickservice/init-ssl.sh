#!/bin/bash

echo "Start of ssl generation"
openssl req \
	-new \
    -newkey rsa:4096 \
    -days 365 \
    -nodes \
    -x509 \
    -subj "/C=LU/ST=service/L=service/O=service/CN=trickservice" \
    -keyout /server.key \
    -out /server.crt

openssl req \
    -new \
    -newkey rsa:4096 \
    -days 365 \
    -nodes \
    -x509 \
    -subj "/C=LU/ST=service/L=service/O=service/CN=ca" \
    -keyout /ca.key \
    -out /ca.crt

openssl req -subj "/C=LU/ST=service/L=service/O=service/CN=trickservice" -new -key /server.key -out /server.csr

openssl x509 -req -days 9000 -in /server.csr -CA /ca.crt -CAkey /ca.key -set_serial 001 -out /server.crt

openssl pkcs12 -export -passout pass:tomcat -in /server.crt -inkey /server.key \
               -out /server.p12 -name tomcat \
               -CAfile /ca.crt -caname root
               

keytool -importkeystore \
        -deststorepass tomcat -destkeypass tomcat -destkeystore /keystore-tomcat \
        -srckeystore /server.p12 -srcstoretype PKCS12 -srcstorepass tomcat \
        -alias tomcat -noprompt 

echo "End of ssl generation"
