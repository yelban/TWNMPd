#!/usr/bin/env sh

# set -x

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- nginx "$@"
fi

APP_ROOT=${APP_ROOT:-"/var/www"}

if [ "$APP_ROOT" != "/var/www" ]; then
    sed -i -e "s#root\s*/var/www/html/web#root  ${APP_ROOT}/html/web#g" /etc/nginx/conf.d/www.conf
fi

# setup $HOST that containers can use to connect to services on the host
HOST=${HOST:-"host.docker.internal"}

# docker host for mac and windows
ping -c 1 ${HOST} >/dev/null 2>&1

EXIST_HOST_DOCKER_INTERNAL=$(echo $?)

if [ "$EXIST_HOST_DOCKER_INTERNAL" != "0" ]; then
    # retrieve host ip for linux
    HOST=$(ip route show default | awk '/default/ {print $3}')
fi

export HOST=$HOST

# update server_name directive within the www.conf
if [ "${SERVER_NAME}" != "localhost" ]; then
        sed -i -e "s/server_name\s*localhost/server_name  ${SERVER_NAME}/g" /etc/nginx/conf.d/www.conf
fi

if [ "${FASTCGI_PASS_HOST}" != "host.docker.internal" ]; then
    if [ "${FASTCGI_PASS_PORT}" != "9000" ]; then
            sed -i -e "s/fastcgi_pass\s*host\.docker\.internal:9000/fastcgi_pass    ${FASTCGI_PASS_HOST}:${FASTCGI_PASS_PORT}/g" /etc/nginx/conf.d/www.conf
    else
            sed -i -e "s/fastcgi_pass\s*host\.docker\.internal:/fastcgi_pass    ${FASTCGI_PASS_HOST}:/g" /etc/nginx/conf.d/www.conf
    fi
else
    if [ "${FASTCGI_PASS_PORT}" != "9000" ]; then
            sed -i -e "s/host\.docker\.internal:9000/host\.docker\.internal:${FASTCGI_PASS_PORT}/g" /etc/nginx/conf.d/www.conf
    fi

    if [ "${HOST}" != "host.docker.internal" ]; then
        sed -i -e "s/fastcgi_pass\s*host\.docker\.internal:/fastcgi_pass    ${HOST}:/g" /etc/nginx/conf.d/www.conf
    fi
fi

exec "$@"
