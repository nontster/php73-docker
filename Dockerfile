FROM php:7.3-fpm-alpine
COPY   www.conf /usr/local/etc/php-fpm.d
RUN apk --no-cache update && \
    apk --no-cache upgrade && \
    apk --no-cache add \
        libpng-dev \
        libjpeg-turbo-dev \
        freetype-dev \
        bzip2-dev \
        bzip2 \
        libxslt-dev \
        libmcrypt-dev \
        icu-dev \
        libzip-dev \
        && docker-php-ext-configure gd --with-freetype-dir --with-jpeg-dir \
        && docker-php-ext-install -j$(nproc) gd \
        && for module in opcache bz2 exif intl mysqli mcrypt pdo_mysql zip sockets xsl pcntl bcmath; \
        do docker-php-ext-configure $module; \
        docker-php-ext-install -j$(nproc) $module; \
        done \
        && apk add autoconf g++ make libmemcached-dev zlib-dev  --virtual .deps1 \
        && apk add libmemcached \
        && yes "" | pecl install memcached \
        && docker-php-ext-enable memcached \
        && yes "" | pecl install mcrypt \
        && docker-php-ext-enable mcrypt \
        && yes "" | pecl install apcu \
        && docker-php-ext-enable apcu \
        && yes "" | pecl install redis \
        && docker-php-ext-enable redis \
        && apk del .deps1 \
        && chown -R daemon:daemon /var/www/
