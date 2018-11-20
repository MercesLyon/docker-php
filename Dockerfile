FROM php:7.2-fpm-alpine as merces

# Install deps
RUN apk add --no-cache $PHPIZE_DEPS autoconf c-client cmake curl git g++ mysql-client openssh-client python \
    cyrus-sasl-dev icu-dev icu-libs imap imap-dev libmcrypt libmcrypt-dev libmemcached libmemcached-dev \
    libxml2 libxml2-dev postgresql-dev postgresql-libs rabbitmq-c rabbitmq-c-dev sqlite-dev sqlite-libs zlib zlib-dev \
    && pecl install amqp memcached redis xdebug \
    && docker-php-ext-enable amqp memcached redis xdebug \
    && docker-php-ext-install bcmath imap intl opcache pcntl pdo_mysql pdo_pgsql soap zip \
    && apk info | grep "\-dev" | xargs apk del autoconf dpkg file g++ gcc pkgconf re2c python

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN composer global --no-interaction require symfony/var-dumper friendsofphp/php-cs-fixer phpmd/phpmd
RUN echo "auto_prepend_file=/home/dockeruser/.composer/vendor/autoload.php" >> /usr/local/etc/php/conf.d/symfony.ini

COPY conf/xdebug.ini .
RUN cat xdebug.ini >> /usr/local/etc/php/docker-php-ext-xdebug.ini
