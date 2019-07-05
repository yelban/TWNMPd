#!/usr/bin/env sh

# set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
    set -- date "$@"
fi

# # setup $HOST that containers can use to connect to services on the host
# HOST=${HOST:-"host.docker.internal"}

# # docker host for mac and windows
# ping -c 1 ${HOST} >/dev/null 2>&1

# EXIST_HOST_DOCKER_INTERNAL=$(echo $?)

# if [ "$EXIST_HOST_DOCKER_INTERNAL" != "0" ]; then
#     # retrieve host ip for linux
#     HOST=$(ip route show default | awk '/default/ {print $3}')
# fi

# export HOST=$HOST


# Remove possible old pid file.
rm -f /var/run/rsyslogd.pid

{ \
  echo ''; \
  echo 'module(load="imudp")'; \
  echo 'input('; \
  echo '       type="imudp"'; \
  echo '       port="514"'; \
  echo ')'; \
  echo ''; \
  echo '$template webaccess,"/var/log/docker/web/access/%timereported:0:10:date-rfc3339%.log"'; \
  echo '$template weberror,"/var/log/docker/web/error/%timereported:0:10:date-rfc3339%.log"'; \
  echo '$template php,"/var/log/docker/php/access/%timereported:0:10:date-rfc3339%.log"'; \
  echo '$template phperror,"/var/log/docker/php/error/%timereported:0:10:date-rfc3339%.log"'; \
  echo '$template mysql,"/var/log/docker/mysql/%timereported:0:10:date-rfc3339%.log"'; \
  echo ''; \
  echo '# Nginx'; \
  echo 'if $programname == "web" and $syslogseverity-text == "info" then ?webaccess'; \
  echo '& stop'; \
  echo 'if $programname == "web" and $syslogseverity-text == "error" then ?weberror'; \
  echo '& stop'; \
  echo ''; \
  echo '# PHP'; \
  echo 'if $programname == "php" and $syslogseverity-text == "info" then ?php'; \
  echo '& stop'; \
  echo 'if $programname == "php" and $syslogseverity-text == "error" then ?phperror'; \
  echo '& stop'; \
  echo ''; \
  echo '# MySQL'; \
  echo 'if $programname == "db" then ?mysql'; \
  echo '& stop'; \
  echo ''; \
} >> /etc/rsyslog.conf



exec "$@"
