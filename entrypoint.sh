#!/bin/bash

echo "xdebug.remote_host=${HOSTNAME:-localhost}" >> /usr/local/etc/php/docker-php-ext-xdebug.ini \
    && echo "xdebug.idekey=${XDEBUG_IDE_KEY:-PHPSTORM}" >> /usr/local/etc/php/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_port=${XDEBUG_PORT:-9000}" >> /usr/local/etc/php/docker-php-ext-xdebug.ini \

exec "$@"
