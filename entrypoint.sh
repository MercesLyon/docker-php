#!/bin/bash

usermod -u ${WWWDATA_UID:-33} www-data
groupmod -g ${WWWDATA_GID:-33} www-data

chown -R www-data:www-data /var/.composer
chown -R www-data:www-data /var/www

setfacl -R -m u:www-data:rwX -m u:`whoami`:rwX /var
setfacl -dR -m u:www-data:rwX -m u:`whoami`:rwX /var

exec "$@"
