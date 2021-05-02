ARG PHP_VERSION=8.0
ARG NGINX_VERSION=1.19

FROM php:${PHP_VERSION}-fpm-alpine AS sf5_php

LABEL maintainer="rafiousitou90@gmail.com"

ARG WORKDIR=/var/www/app

WORKDIR ${WORKDIR}

RUN rm -rf /var/www/html

RUN apk --no-cache update && apk --no-cache add \
    bash \
    autoconf \
    g++ \
    make \
    pcre-dev \
    icu-dev \
    openssl-dev \
    libxml2-dev \
    libmcrypt-dev \
    icu-dev \
    zlib-dev \
    icu \
    git

RUN set -eux; \
	addgroup -g 1000 -S 1000; \
	adduser -u 1000 -D -S -G 1000 1000

RUN mkdir -p /var/www
RUN chown -R 1000:1000 /var/www

# Install MySQL
RUN docker-php-ext-install mysqli pdo pdo_mysql \
    && docker-php-ext-enable pdo_mysql \
    && rm -rf /tmp/*

# Install PostgreSQL
RUN set -ex \
    && apk add --no-cache postgresql-dev \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo_pgsql pgsql \
    && rm -rf /tmp/*

# Install XDebug, Opcache, Apcu
RUN apk add --no-cache \
    && pecl install xdebug apcu opcache \
    && docker-php-ext-enable xdebug apcu opcache \
    && rm -rf /tmp/*

# Install gd, iconv, mcrypt
RUN apk add --no-cache \
    freetype-dev \
    libjpeg-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
	&& docker-php-ext-install gd \
    && rm -rf /tmp/*

# Install intl
RUN set -xe \
    && apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && docker-php-ext-enable intl \
    && { find /usr/local/lib -type f -print0 | xargs -0r strip --strip-all -p 2>/dev/null || true; } \
    && apk del .build-deps \
    && rm -rf /tmp/* /usr/local/lib/php/doc/*

# Install Redis
RUN apk add --no-cache \
    pcre-dev ${PHPIZE_DEPS} \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apk del pcre-dev ${PHPIZE_DEPS} \
    && rm -rf /tmp/pear

# Install NodeJS, Yarn
RUN apk add --no-cache \
    nodejs yarn npm \
    && rm -rf /tmp/pear

# Add xdebug.ini, php.ini, and php-cli.ini files
COPY docker/php/dev/php.ini $PHP_INI_DIR/conf.d/php.ini
COPY docker/php/dev/php-cli.ini $PHP_INI_DIR/conf.d/php-cli.ini
COPY docker/php/dev/xdebug.ini $PHP_INI_DIR/conf.d/xdebug.ini

# Remove cache
RUN rm -rf /var/cache/apk/*

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer

# Install Symfony CLI
RUN curl -sS https://get.symfony.com/cli/installer | bash \
   && mv /root/.symfony/bin/symfony /usr/local/bin/symfony

# Prevent the reinstallation of vendors at every changes in the source code
COPY composer.json composer.lock symfony.lock ./
RUN set -eux; \
	composer install --prefer-dist --no-autoloader --no-scripts  --no-progress --no-suggest; \
	composer clear-cache

RUN set -eux \
	&& mkdir -p var/cache var/log \
	&& composer dump-autoload --classmap-authoritative

COPY docker/php/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

USER 1000
RUN mkdir /var/www/.composer

ENTRYPOINT ["docker-entrypoint"]
CMD ["php-fpm"]


FROM nginx:${NGINX_VERSION}-alpine AS sf5_nginx

ARG WORKDIR=/var/www/app

RUN rm -rf /etc/nginx/conf.d/default.conf

COPY docker/nginx/conf.d/default.conf /etc/nginx/conf.d/

WORKDIR ${WORKDIR}
