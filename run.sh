#!/bin/bash

#change the UID/GID of Apache
APACHE_RUN_USER=${APACHE_RUN_USER:=33}
APACHE_RUN_GROUP=${APACHE_RUN_GROUP:=33}

usermod -u $APACHE_RUN_USER www-data
groupmod -g $APACHE_RUN_GROUP www-data

chown -R www-data:www-data /var/www

# ssmtp config
SSMTP_SERVER=${SSMTP_SERVER:-mailhog}
SSMTP_PORT=${SSMTP_PORT:-1025}
SSMTP_HOSTNAME=${SSMTP_HOSTNAME:-localhost}
SSMTP_TO=${SSMTP_TO:-postmaster}

cat << EOF > /etc/ssmtp/ssmtp.conf
root=$SSMTP_TO
mailhub=$SSMTP_SERVER:$SSMTP_PORT
hostname=$SSMTP_HOSTNAME
FromLineOverride=YES
EOF

# Apache gets grumpy about PID files pre-existing
rm -f /var/run/apache2/apache2.pid && \
rm -rf /var/lock/apache2 && \
sed -i "s|DOCUMENT_ROOT|$DOCUMENT_ROOT|g" /etc/apache2/sites-available/default && \
sed -i "s|ENVIRONMENT_VAR|$ENVIRONMENT|g" /etc/apache2/sites-available/default && \
/usr/sbin/apache2ctl -D FOREGROUND
