FROM php:7.1-fpm

# PHP config
ADD conf/symfony.ini /usr/local/etc/php/
ADD conf/symfony.pool.conf /etc/php/7.1/fpm/pool.d/
RUN apt-get update && apt-get install -y \
        zlib1g-dev \
        libicu-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        g++ \
        libcurl4-gnutls-dev \
    && docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd
RUN pecl install redis-3.1.3 \
    && pecl install xdebug-2.5.0 \
    && docker-php-ext-enable redis xdebug \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl pdo pdo_mysql zip gd mbstring curl

# Install composer
RUN curl -s https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

ARG GIT_USERNAME="Merces"
ARG GIT_EMAIL="developer@merces.fr"
ARG WWW_DATA_UID=1000
ARG WWW_DATA_GID=1000

# Install git
RUN apt-get update && apt-get install -y git
RUN git config --global user.name "$GIT_USERNAME"
RUN git config --global user.email "$GIT_EMAIL"

# www-data should have different uid depending on host env and/or apache container version
RUN usermod -u "${WWW_DATA_UID}" www-data
RUN groupmod -g "${WWW_DATA_GID}" www-data

# Installing composer global dependencies
ENV COMPOSER_HOME /var/.composer
RUN mkdir -p "${COMPOSER_HOME}"
RUN chown -R www-data:www-data "${COMPOSER_HOME}"
USER www-data
RUN composer global --no-interaction require symfony/var-dumper squizlabs/php_codesniffer phpmd/phpmd
USER root
RUN sed -i '660s/auto_prepend_file =/ /g' /usr/local/etc/php/symfony.ini \
    && sed -i '660a auto_prepend_file = /var/.composer/vendor/autoload.php' /usr/local/etc/php/symfony.ini

RUN mkdir -p /etc/phpcs/Merces
ADD ruleset.xml /etc/phpcs/Merces
RUN /var/.composer/vendor/bin/phpcs --config-set installed_paths /etc/phpcs/Merces

# Install acl
RUN HTTPDUSER=`ps axo user,comm | grep -E '[a]pache|[h]ttpd|[_]www|[w]ww-data|[n]ginx' | grep -v root | head -1 | cut -d\  -f1`
RUN setfacl -R -m u:"${HTTPDUSER}":rwX -m u:`whoami`:rwX /var
RUN setfacl -dR -m u:"${HTTPDUSER}":rwX -m u:`whoami`:rwX /var

# use .ssh from local
RUN mkdir -p /var/www/.composer
RUN mkdir -p /var/www/.ssh
RUN chown -R www-data:www-data /var/www/.composer /var/www/.ssh
VOLUME /var/www/.ssh
