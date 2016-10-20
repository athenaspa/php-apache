#!/bin/bash
set -e

# Post deployment Assets warm up
cd /var/www/html
composer install --no-interaction
if [ ! -f /var/www/html/web/sites/default/settings.local.php ];
  then
      vendor/bin/robo config:settings;
fi

# Start supervisord
echo "Start Supervisord"
/usr/bin/supervisord
