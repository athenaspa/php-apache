FROM php:7-apache
RUN a2enmod rewrite

# Install the PHP extensions we need
RUN apt-get update && apt-get install -y \
  git \
  wget \
  mysql-client \
  ssmtp \
  patch \
  unzip \
  nano \
  openssh-server \
  libpng12-dev \
  libjpeg-dev \
  libpq-dev \
  libxml2-dev \
  libcurl3 \
  libcurl4-gnutls-dev \
  && rm -rf /var/lib/apt/lists/* \
  && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
  && docker-php-ext-install gd mbstring opcache pdo pdo_mysql pdo_pgsql zip calendar json curl xml soap

# See https://secure.php.net/manual/en/opcache.installation.php
RUN { \
  echo 'opcache.memory_consumption=128'; \
  echo 'opcache.interned_strings_buffer=8'; \
  echo 'opcache.max_accelerated_files=4000'; \
  echo 'opcache.revalidate_freq=60'; \
  echo 'opcache.fast_shutdown=1'; \
  echo 'opcache.enable_cli=1'; \
  } > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Set recommended PHP.ini settings
RUN {  \
  echo 'memory_limit = 512M'; \
  echo 'upload_max_filesize = 64M'; \
  echo 'post_max_size = 64M'; \
  echo 'max_execution_time = 600'; \
  echo 'date.timezone = Europe/Rome'; \
  } >> /usr/local/etc/php/conf.d/custom-php-settings.ini

WORKDIR /root

# Install Drush 8.1.7
RUN wget https://github.com/drush-ops/drush/releases/download/8.1.7/drush.phar && php drush.phar core-status \
  && chmod +x drush.phar \
  && mv drush.phar /usr/local/bin/drush

# Install Drupal Console
RUN curl http://drupalconsole.com/installer -L -o drupal.phar \
  && mv drupal.phar /usr/local/bin/drupal && chmod +x /usr/local/bin/drupal \
  && drupal init

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php -r "if (hash_file('SHA384', 'composer-setup.php') === 'aa96f26c2b67226a324c27919f1eb05f21c248b987e6195cad9690d5c1ff713d53020a02ac8c217dbf90a7eacc9d141d') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
  && php -r "unlink('composer-setup.php');" \
  && chmod +x /usr/local/bin/composer

WORKDIR /var/www/html

# This will fix problem with permission
COPY ./match-current-dirs-owner.sh /usr/local/bin/match-current-dirs-owner

# Exposing ports
EXPOSE 80

COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod a+x /usr/local/bin/docker-entrypoint

# Command
CMD ["docker-entrypoint"]
