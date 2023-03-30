#LABEL maintainer="Alex H <alex@gimon.zone>"
#LABEL original_dockerfile_author="Jetsung Chan <jetsungchan@gmail.com>"

ARG PHP_IMAGE_VER="8.2.4-fpm-alpine3.17"
 
# install php
FROM php:$PHP_IMAGE_VER
RUN set -eux ;\
    apk update && \
    apk add --no-cache --virtual \
        ca-certificates \
        mailcap \
        supervisor \
        gd-dev \
        freetype-dev \
        icu-dev \
        libmemcached-dev \
        libzip-dev \
        zip \
        zlib-dev \
        oniguruma \
        libxml2-dev \
        libcurl \
        libwebp \
        libpng \
        libssl3 \
        libcrypto3 \
        libjpeg-turbo \
        autoconf \
        gcc \
        g++ \
        make \
        ;\
    rm /var/cache/apk/*

RUN docker-php-ext-install curl \
        pdo \
        openssl \
        mysqlnd \
        exif \
        opcache \
        intl \
        mbstring \
        zlib \
        ;\
    docker-php-ext-install zip \
        ;\
    docker-php-ext-enable curl \
        pdo \
        openssl \
        mysqlnd \
        exif \
        opcache \
        intl \
        mbstring \
        zlib \
        zip \
        ;\
    docker-php-ext-configure gd \
        --enable-gd \
        --with-freetype \
        --with-jpeg \
        --with-webp \
        ;\
    NUMPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
        ;\
    docker-php-ext-install -j${NUMPROC} gd \
     ;\
    docker-php-ext-install pdo_mysql \
        ;\
    docker-php-source delete ;\
    apk del m4 \
        autoconf \
        binutils \
        libgomp \
        libatomic \
        gmp \
        mpfr4 \
        mpc1 \
        gcc \
        musl-dev \
        libc-dev \
        g++ \
        make \
        ;\
