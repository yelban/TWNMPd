ARG BASE_IMAGE_TAG

FROM alpine:${BASE_IMAGE_TAG}

ARG TIMEZONE=${TIMEZONE}

ENV APP_ROOT=${APP_ROOT:-"/var/www"}
ENV PATH="${PATH}:/home/www-data/.composer/vendor/bin:${APP_ROOT}/html/vendor/bin:${APP_ROOT}/html/bin"

# Add repos
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# Add basics first
RUN set -e \
    && apk add --no-cache tzdata \
        curl ca-certificates openssl git \
        php7 php7-fpm php7-phar php7-json php7-iconv php7-openssl \
    && echo "${TIMEZONE}" > /etc/timezone \
    && mv /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && apk del tzdata

RUN set -e \
    && apk --no-cache add \
    # bash \
    zip \
    unzip \
    msmtp \
    logrotate \
    su-exec \
    # rsync \
    # # php7 \
    # php7-bcmath \
    php7-ctype \
    php7-curl \
    php7-dom \
    php7-exif \
    php7-fileinfo \
    php7-ftp \
    php7-gd \
    # php7-gettext \
    # # php7-iconv \
    # # php7-json \
    php7-mbstring \
    # php7-mcrypt \
    # php7-mysqlnd \
    # php7-pecl-imagick \
    php7-pecl-oauth \
    php7-pecl-protobuf \
    # php7-pecl-redis \
    # php7-pecl-solr \
    php7-pecl-ssh2 \
    # php7-pecl-uuid \
    php7-opcache \
    # # php7-openssl \
    # php7-pcntl \
    php7-pdo \
    php7-pdo_mysql \
    php7-pdo_sqlite \
    php7-pear \
    # # php7-phar \
    # php7-posix \
    php7-session \
    # php7-shmop \
    php7-simplexml \
    php7-sqlite3 \
    php7-sockets \
    php7-sodium \
    # php7-sysvmsg \
    # php7-sysvsem \
    # php7-sysvshm \
    php7-tokenizer \
    # php7-uploadprogress \
    php7-xml \
    php7-xmlreader \
    php7-xmlrpc \
    php7-xmlwriter \
    # php7-xsl \
    php7-zip \
    php7-zlib



RUN set -e \
    # ensure www-data user exists
    && addgroup -g 82 -S www-data \
    && adduser -u 82 -D -S -s /bin/bash -G www-data www-data \
    # 82 is the standard uid/gid for "www-data" in Alpine
    \
    && wget -qO- https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    \
    # && mkdir -p /var/www/html \
    # && echo -e "<?php\n\nphpinfo();\n\n\n?>" > /var/www/html/index.php \
    # && chown -R www-data:www-data /var/www/html \
    && echo 'PS1="\e[1;32m[\w]\\$ \e[0m"' >> /root/.bashrc \
    \
    && pecl update-channels \
    && rm -rf /tmp/pear ~/.pearrc \
    && composer clear-cache \
    && rm -f /var/cache/apk/*



COPY entrypoint.sh /usr/local/bin/

WORKDIR ${APP_ROOT}

# EXPOSE ${EXPOSE_PORT}

ENTRYPOINT ["entrypoint.sh"]

STOPSIGNAL SIGQUIT

CMD ["php-fpm7", "-F"]
