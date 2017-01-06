#!/bin/bash

find / -wholename "/run/apache2.pid" -delete

APACHE_MODE=${APACHE_MODE:-svn}

if [ ! "$(ls -A /etc/apache2/sites-enabled)" ]; then
	if [ "$APACHE_MODE" = "svn" ]; then
		ln -s /default_svn.conf /etc/apache2/sites-enabled/
	elif [ "$APACHE_MODE" = "cherrypy" ]; then
		ln -s /default.conf /etc/apache2/sites-enabled/
		rm /etc/apache2/apache2.conf
		ln -s /apache2.conf /etc/apache2/apache2.conf
	elif [ "$APACHE_MODE" = "tkblogs" ]; then
		ln -s /default_tkblogs.conf /etc/apache2/sites-enabled/
                rm /etc/apache2/apache2.conf
                ln -s /apache2.conf /etc/apache2/apache2.conf
	fi
fi

if [ $APACHE_USER_UID != 0 ];then
  usermod -u $APACHE_USER_UID $APACHE_RUN_USER
fi
/usr/sbin/apache2 -DFOREGROUND
