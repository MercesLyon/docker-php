FROM php:7.2-fpm-alpine

RUN addgroup -S --gid ${GID:1000} dockergroup
RUN adduser -S -G dockergroup -u ${UID:1000} dockeruser

RUN sed -i \
	-e 's/^user = www-data/user = dockeruser/' \
	-e 's/^group = www-data/group = dockergroup/' /usr/local/etc/php-fpm.d/www.conf

# Install deps
RUN apk add --no-cache $PHPIZE_DEPS autoconf c-client cmake curl git g++ mysql-client openssh-client python \
    cyrus-sasl-dev icu-dev icu-libs imap imap-dev libmcrypt libmcrypt-dev libmemcached libmemcached-dev \
    libxml2 libxml2-dev postgresql-dev postgresql-libs rabbitmq-c rabbitmq-c-dev sqlite-dev sqlite-libs zlib zlib-dev \
    && pecl install amqp memcached redis xdebug \
    && docker-php-ext-enable amqp memcached redis xdebug \
    && docker-php-ext-install bcmath imap intl mbstring opcache pcntl pdo pdo_mysql pdo_pgsql soap zip \
    && apk info | grep "\-dev" | xargs apk del autoconf dpkg file g++ gcc pkgconf re2c python \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd iconv mcrypt \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \

RUN composer global --no-interaction require symfony/var-dumper friendsofphp/php-cs-fixer phpmd/phpmd
RUN echo "auto_prepend_file=/usr/local/bin/.composer/vendor/autoload.php" >> /usr/local/etc/php/conf.d/symfony.ini

COPY entrypoint.sh /usr/local/bin/
RUN ln -s /usr/local/bin/entrypoint.sh /entrypoint.sh && chmod +x /entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
