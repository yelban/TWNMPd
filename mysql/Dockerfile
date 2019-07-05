ARG BASE_IMAGE_TAG

FROM alpine:${BASE_IMAGE_TAG}

ARG TIMEZONE=${TIMEZONE}

# Add repos
# RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
#     && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
#     && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# Bring in tzdata so users could set the timezones through the environment variables
RUN set -e \
    && apk add --no-cache tzdata \
    && echo "${TIMEZONE}" > /etc/timezone \
    && mv /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && apk del tzdata

RUN set -e \
    && apk add --no-cache mariadb mariadb-client mariadb-server-utils pwgen \
    && rm -f /var/cache/apk/*

RUN mkdir /docker-entrypoint-initdb.d && \
    mkdir -p /scripts/pre-exec.d && \
    mkdir /scripts/pre-init.d && \
    chmod -R 755 /scripts

COPY entrypoint.sh /usr/local/bin/

WORKDIR /var/lib/mysql

ENTRYPOINT ["entrypoint.sh"]

STOPSIGNAL SIGQUIT

CMD ["mysqld", "-V"]
