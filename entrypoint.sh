#!/bin/bash

echo "xdebug.remote_enable=On" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.profiler_enable=On" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_host=${HOSTNAME:-upway.local}" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.idekey=${XDEBUG_IDE_KEY:-PHPSTORM}" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_port=${XDEBUG_PORT:-9000}" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_handler=dbgp" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_connect_back=On" >> /usr/local/etc/php/conf.d/xdebug.ini

exec "$@"
