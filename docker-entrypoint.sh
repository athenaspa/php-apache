#!/bin/bash
set -e

# Post deployment Assets warm up
if [ -d /var/www/html/drupal ];
then
  if [ ! -d /var/www/html/drupal/vendor ]
  then
      cd /var/www/html/drupal && composer install --no-interaction;
  fi
fi

if [ ! -f /var/www/html/drupal/web/sites/default/settings.local.php ];
then
    cd /var/www/html/drupal && vendor/bin/robo config:settings;
fi


# Start supervisord
echo "Start Supervisord"
/usr/bin/supervisord
