FROM php:7.4-fpm-buster AS base

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx supervisor curl ssl-cert vim unzip libzip-dev libmpdec-dev \
    && rm -rf /var/lib/apt/lists/*

RUN usermod -u 1000 www-data && groupmod -g 1000 www-data && usermod -d /var/www www-data

ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Use the default development configuration
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

FROM base AS deps
RUN echo "$(curl -sS https://composer.github.io/installer.sig) -" > setup.php.sig \
    && curl -sS https://getcomposer.org/installer | tee setup.php | sha384sum -c setup.php.sig \
    && php setup.php --install-dir=/usr/bin --filename=composer \
    && rm setup.php setup.php.sig;

RUN pecl install xdebug-2.9.0 decimal-1.3.0 ast-1.0.5

FROM base AS release
COPY --from=deps \
    /usr/bin/composer \
    /usr/bin/composer

COPY --from=deps \
    /usr/local/lib/php/extensions/no-debug-non-zts-20190902 \
    /usr/local/lib/php/extensions/no-debug-non-zts-20190902

RUN docker-php-ext-install pdo_mysql zip
RUN docker-php-ext-enable decimal

# override defaults
COPY ./php/fpm.conf /usr/local/etc/php-fpm.d/zzz_custom.conf
COPY ./php/conf.d/ $PHP_INI_DIR/conf.d/


# Configure nginx
COPY ./nginx/ /etc/nginx

# Configure supervisord
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

WORKDIR /var/www/html

EXPOSE 80 443
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
