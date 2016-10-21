FROM php:5.6-apache
# 作者
MAINTAINER lic@goodrain.com
# 时区设置
RUN echo "Asia/Shanghai" > /etc/timezone;dpkg-reconfigure -f noninteractive tzdata

# 安装软件
RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev libpq-dev \
	&& rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install mysql mysqli gd mbstring pdo pdo_mysql pdo_pgsql

ENV DRUPAL_VERSION 7.51

COPY config/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY config/apache2.conf /etc/apache2/apache2.conf
COPY config/ports.conf /etc/apache2/ports.conf

RUN mkdir -p /app/drupal
WORKDIR /app/drupal

RUN curl -fSL "http://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
	&& tar -xz --strip-components=1 -f drupal.tar.gz \
	&& rm -rf /app/drupal/includes/database/pgsql/ \
    && rm -rf /app/drupal/includes/database/sqlite/

COPY drupal-7.51.zh-hans.po /app/drupal/profiles/standard/translations/drupal-7.51.zh-hans.po
COPY civicrm-4.7.12-drupal.tar.gz /app/drupal/sites/all/modules/civicrm-4.7.12-drupal.tar.gz

RUN tar -zxf /app/drupal/sites/all/modules/civicrm-4.7.12-drupal.tar.gz \
    && rm /app/drupal/sites/all/modules/civicrm-4.7.12-drupal.tar.gz \
    && mv /app/drupal/civicrm /app/drupal/sites/all/modules/civicrm \
    && rm drupal.tar.gz \
    && chmod -R 777 /app/drupal/sites/default/ \
	&& chown -R www-data:www-data sites
COPY config/index.php /app/drupal/sites/all/modules/civicrm/install/index.php
COPY config/install.inc /app/drupal/includes/install.inc
COPY config/install.core.inc /app/drupal/includes/install.core.inc


COPY l10n /app/drupal/sites/all/modules/civicrm/l10n
COPY script/ /app/script
RUN chmod +x /app/script/run.sh
RUN chmod +x /app/script/docker-entrypoint.sh

EXPOSE 5000
VOLUME /data
#ENTRYPOINT ["/app/script/run.sh"]
ENTRYPOINT ["/app/script/docker-entrypoint.sh"]