#!/bin/bash

#change the UID/GID of Apache

APACHE_RUN_USER=${APACHE_RUN_USER:=33}
APACHE_RUN_GROUP=${APACHE_RUN_GROUP:=33}

usermod -u $APACHE_RUN_USER www-data
groupmod -g $APACHE_RUN_GROUP www-data

chown -R www-data:www-data /var/www/html

# Apache gets grumpy about PID files pre-existing
rm -f /var/run/apache2/apache2.pid && \
sed -i "s|DOCUMENT_ROOT|$DOCUMENT_ROOT|g" /etc/apache2/sites-available/default && \
sed -i "s|ENVIRONMENT_VAR|$ENVIRONMENT|g" /etc/apache2/sites-available/default && \
/usr/sbin/apache2ctl -D FOREGROUND
