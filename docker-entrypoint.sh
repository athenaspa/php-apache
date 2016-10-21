#!/bin/bash
set -e

# Post deployment Assets warm up
cd /var/www/html
composer install --no-interaction > /dev/null 2>&1
if [ ! -f /var/www/html/web/sites/default/settings.local.php ];
  then
      vendor/bin/robo config:settings > /dev/null 2>&1;
fi

# Start supervisord
/usr/local/bin/apache2-foreground
