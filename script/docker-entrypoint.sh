#!/bin/bash

echo "now config drupal ..."
set -e

export MYSQL_HOST=${MYSQL_HOST:-'172.17.0.2'}
export MYSQL_USER=${MYSQL_USER:-'root'}
export MYSQL_PASS=${MYSQL_PASS:-'root'}
#export MYSQL_PORT=${MYSQL_PORT:-'3306'}
export MYSQL_PORT='3306'


if [ ! -f /data/.dbimported ];then
  php /app/script/importdb.php /app/script/createdb.sql
  touch /data/.dbimported
fi

if [ ! -d "/data/sites" ];then
	mv /app/drupal/sites /data/sites
	mv /app/drupal/modules /data/modules
	mv /app/drupal/profiles /data/profiles
else
    rm -rf /app/drupal/sites
    rm -rf /app/drupal/modules
    rm -rf /app/drupal/profiles
fi

#chown -R www-data:www-data /data/
#chmod -R 777 /data/sites/default

ln -s /data/sites /app/drupal/sites
ln -s /data/modules /app/drupal/modules
ln -s /data/profiles /app/drupal/profiles

apache2-foreground