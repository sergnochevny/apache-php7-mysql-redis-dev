#!/bin/bash

APACHE_RUN_USER='www-data'
APACHE_RUN_GROUP='www-data'
APACHE_PID_FILE='/var/run/apache2.pid'
APACHE_RUN_DIR='/var/run/apache2'
APACHE_LOCK_DIR='/var/lock/apache2'
APACHE_LOG_DIR='/var/log/apache2'

MYSQL_RUN_USER='mysql'
MYSQL_RUN_GROUP='mysql'
MYSQL_PID_FILE='/var/run/mysqld/mysqld.pid'
MYSQL_SOCKET='/var/run/mysqld/mysqld.sock'
MYSQL_PORT='3306'
MYSQL_DATA_DIR='/var/lib/mysql'
MYSQL_LOG_DIR='/var/log/mysql'


REDIS_RUN_USER='redis'
REDIS_RUN_GROUP='redis'
REDIS_DATA_DIR='/var/lib/redis'
REDIS_PID_FILE='/var/run/redis/redis-server.pid'
REDIS_LOG_DIR='/var/log/redis'
REDIS_LOG_FILE="$REDIS_LOG_DIR/redis-server.log"

LANG=C

export APACHE_RUN_USER APACHE_RUN_GROUP APACHE_PID_FILE APACHE_RUN_DIR APACHE_LOCK_DIR APACHE_LOG_DIR MYSQL_RUN_USER MYSQL_RUN_GROUP MYSQL_PID_FILE MYSQL_SOCKET MYSQL_PORT MYSQL_DATA_DIR MYSQL_LOG_DIR REDIS_RUN_USER REDIS_RUN_GROUP REDIS_DATA_DIR REDIS_PID_FILE REDIS_LOG_DIR REDIS_LOG_FILE LANG=C

chown ${APACHE_RUN_USER}:${APACHE_RUN_GROUP} -R /var/www
chown ${APACHE_RUN_USER}:${APACHE_RUN_GROUP} -R ${APACHE_RUN_DIR}
chown ${APACHE_RUN_USER}:${APACHE_RUN_GROUP} -R ${APACHE_LOCK_DIR}
chown ${APACHE_RUN_USER}:${APACHE_RUN_GROUP} -R ${APACHE_LOG_DIR}

chown ${MYSQL_RUN_USER}:${MYSQL_RUN_GROUP} -R ${MYSQL_DATA_DIR}
chown ${MYSQL_RUN_USER}:${MYSQL_RUN_GROUP} -R ${MYSQL_LOG_DIR}

chown ${REDIS_RUN_USER}:${REDIS_RUN_GROUP} -R ${REDIS_LOG_DIR}
chown ${REDIS_RUN_USER}:${REDIS_RUN_GROUP} -R ${REDIS_DATA_DIR}

chown ${MYSQL_RUN_USER}:${MYSQL_RUN_GROUP} /etc/mysql/conf.d/mysql.cnf

service redis-server start

cp /root/dev-env/supervisor/*.conf /etc/supervisor/conf.d/
sed -i "s/root/$MYSQL_RUN_USER/" /etc/mysql/conf.d/mysql.cnf
echo "mysqld_safe --skip-networking &" > /tmp/config && \
echo "mysqladmin --silent --wait=30 ping || exit 1" >> /tmp/config && \
echo "mysql -e \"GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES; \"" >> /tmp/config && \
echo "service mysql restart" >> /tmp/config && \
bash /tmp/config && \
rm -f /tmp/config

composer self-update
composer -g config http-basic.tp.ait.com tp tp
composer -g config repositories.ait composer https://tp.ait.com/repo/private/
composer -g config repositories.ait_packagist composer https://tp.ait.com/repo/packagist/
composer -g config repositories.packagist false
composer -g config -l
composer global require "fxp/composer-asset-plugin:^1.2.0"

mysql -e 'CREATE DATABASE IF NOT EXISTS `restaura_new` CHARACTER SET utf8 COLLATE utf8_general_ci;'
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;"

sed -i "s/post_max_size = 8M/post_max_size = 100M/" /etc/php/7.0/apache2/php.ini
sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 100M/" /etc/php/7.0/apache2/php.ini
sed -i "s/;opcache.enable=0/opcache.enable=1/" /etc/php/7.0/apache2/php.ini
sed -i "s/;opcache.enable_cli=0/opcache.enable_cli=1/" /etc/php/7.0/apache2/php.ini
sed -i "s/;gd.jpeg_ignore_warning = 0/gd.jpeg_ignore_warning = 1/" /etc/php/7.0/apache2/php.ini
ln -sfT /dev/stderr "/var/log/apache2/error.log"
ln -sfT /dev/stdout "/var/log/apache2/access.log"
ln -sfT /dev/stdout "/var/log/apache2/other_vhosts_access.log"

find /var/www -type f -exec chmod 644 {} +

#find /var/www/runtime -type d -exec chmod 755 {} +
#find /var/www/web/assets -type d -exec chmod 755 {} +
#cd /var/www
#composer install

service mysql stop
service redis-server stop

sed -i "s/daemonize yes/#daemonize yes/" /etc/redis/redis.conf

cp /root/dev-env/certs/demo.pem /etc/ssl/certs
cp /root/dev-env/certs/demo.key /etc/ssl/private
cp /root/dev-env/apache/apache.conf /etc/apache2/
chmod 644 /etc/apache2/apache.conf
cp /root/dev-env/apache/default.conf /etc/apache2/sites-available/000-default.conf
