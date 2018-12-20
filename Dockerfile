FROM debian:wheezy

# Add Environment var
ENV DOCUMENT_ROOT /var/www \
    ENVIRONMENT dev \
    SSMTP_SERVER mailhog \
    SSMTP_PORT 1025

# Running nano in docker container
ENV TERM xterm

RUN \
  apt-get update && \
  apt-get install -y \
  ssmtp \
  curl \
  wget \
  nano \
  git \
  unzip \
  locales \
  iptables \
  apache2 \
  php5 \
  php5-mysql \
  php5-mcrypt \
  php5-gd \
  php5-memcached \
  php5-memcache \
  php5-curl \
  php-pear \
  php-apc \
  php5-cli \
  php5-curl \
  php5-mcrypt \
  php5-sqlite \
  php5-intl \
  php5-tidy \
  php5-imap \
  php5-json \
  php5-imagick \
  libapache2-mod-php5 && \
  a2enmod proxy && \
  a2enmod proxy_http && \
  a2enmod alias && \
  a2enmod dir && \
  a2enmod env && \
  a2enmod mime && \
  a2enmod reqtimeout && \
  a2enmod rewrite && \
  a2enmod status && \
  a2enmod filter && \
  a2enmod deflate && \
  a2enmod setenvif && \
  a2enmod vhost_alias && \
  a2enmod ssl && \
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists

# Install Composer
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
    && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
    && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }"
RUN php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer \
  	&& rm /tmp/composer-setup.php \
    && chmod +x /usr/local/bin/composer

# Configure timezone
RUN echo Europe/Rome > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

RUN { echo 'en_GB ISO-8859-1'; \
echo 'en_GB.ISO-8859-15 ISO-8859-15'; \
echo 'en_US ISO-8859-1'; \
echo 'en_US.ISO-8859-15 ISO-8859-15'; \
echo 'en_US.UTF-8 UTF-8'; \
} >> /etc/locale.gen && usr/sbin/locale-gen

RUN ln -sf /dev/stderr /var/log/apache2/error.log

COPY httpd/dummy.crt  /etc/ssl/crt/dummy.crt
COPY httpd/dummy.key  /etc/ssl/crt/dummy.key
COPY httpd/default.conf /etc/apache2/sites-available/default
COPY httpd/php.ini  /etc/php5/apache2/conf.d/
COPY httpd/php.ini  /etc/php5/cli/conf.d/

COPY run.sh /run.sh

RUN chmod +x /run.sh

EXPOSE 80
EXPOSE 443

WORKDIR /var/www

CMD ["/run.sh"]
