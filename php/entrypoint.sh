#!/usr/bin/env sh

set -x

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php "$@"
fi

# php-fpm settings
if [ -e "/etc/php7/php-fpm.conf" ]; then
    sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php7/php-fpm.conf
fi

# php-fpm.d/www.conf settings
if [ -e "/etc/php7/php-fpm.d/www.conf" ]; then
    sed -i -e "s/listen\s*=\s*127.0.0.1:9000/listen = 9000/g" /etc/php7/php-fpm.d/www.conf
    sed -i -e "s/pm.max_children\s*=.*/pm.max_children = ${PM_MAX_CHILDREN}/g" /etc/php7/php-fpm.d/www.conf
    sed -i -e "s/user\s*=\s*nobody/user = www-data/g" /etc/php7/php-fpm.d/www.conf
    sed -i -e "s/group\s*=\s*nobody/group = www-data/g" /etc/php7/php-fpm.d/www.conf
fi

# php.ini settings
if [ -e "/etc/php7/php.ini" ]; then
    # sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php7/php.ini
    sed -i "s#;date.timezone =.*#date.timezone = ${TIMEZONE}#g" /etc/php7/php.ini
    sed -i "s/memory_limit =.*/memory_limit = ${PHP_MEMORY_LIMIT}/g" /etc/php7/php.ini
    sed -i "s/max_execution_time =.*/max_execution_time = ${PHP_MAX_EXECUTION_TIME}/g" /etc/php7/php.ini
    sed -i "s/upload_max_filesize =.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/g" /etc/php7/php.ini
    sed -i "s/max_file_uploads =.*/max_file_uploads = ${PHP_MAX_FILE_UPLOADS}/g" /etc/php7/php.ini
    sed -i "s/post_max_size =.*/post_max_size = ${PHP_POST_MAX_SIZE}/g" /etc/php7/php.ini

    MAILHOG_HOST=${MAILHOG_HOST:-"mailhog"}
    MAILHOG_PORT=${MAILHOG_PORT:-"1025"}
    WITH_MAILHOG=${WITH_MAILHOG:-"no"}

    if [ "$WITH_MAILHOG" != "yes" ]; then
        sed -i 's#;sendmail_path =.*#sendmail_path = "/usr/bin/msmtp -C /etc/php7/.msmtprc --logfile=/var/log/docker/msmtp/access.log -a gmail -t"#g' /etc/php7/php.ini
    else
        sed -i "s#;sendmail_path =.*#sendmail_path = \"\/usr\/sbin\/sendmail -S ${MAILHOG_HOST}:${MAILHOG_PORT}\"#g" /etc/php7/php.ini
    fi
fi

# opcache settings
if [ ! -e "/etc/php7/conf.d/03_opcache-recommended.ini" ]; then

    { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /etc/php7/conf.d/03_opcache-recommended.ini
fi

# gmail relay settings
if [ ! -e "/etc/php7/.msmtprc" ]; then
    touch /etc/php7/.msmtprc
    chmod 600 /etc/php7/.msmtprc
    chown www-data:www-data /etc/php7/.msmtprc
    mkdir -p /var/log/docker/msmtp
    chown www-data:www-data /var/log/docker/msmtp

    { \
        echo 'account gmail'; \
        echo 'tls on'; \
        echo 'tls_certcheck off'; \
        echo 'auth on'; \
        echo "host ${RELAY_HOST}"; \
        echo "port ${RELAY_PORT}"; \
        echo "user ${RELAY_USER}"; \
        echo "from ${RELAY_FROM}"; \
        echo "password ${RELAY_SECRETS}";
    } >> /etc/php7/.msmtprc
fi

# logrotate settings
if [ ! -e "/etc/logrotate.d/msmtp" ]; then
    { \
        echo '/var/log/docker/msmtp/*.log {'; \
        echo '  rotate 12'; \
        echo '  weekly'; \
        echo '  compress'; \
        echo '  missingok'; \
        echo '  notifempty'; \
        echo '  dateext'; \
        echo '}'; \
        echo '';
    } >> /etc/logrotate.d/msmtp
fi

# setup log to stderr using by rsyslog
sed -i -e "s#\(^;error_log\s*=\s*log/php7/error\.log$\)#\1\nerror_log = /proc/self/fd/2#g" /etc/php7/php-fpm.conf
sed -i -e "s#\(^;syslog\.facility\s*=\s*daemon$\)#\1\nsyslog\.facility = local2#g" /etc/php7/php-fpm.conf
sed -i -e "s#\(^;log_level\s*=\s*notice$\)#\1\nlog_level = notice#g" /etc/php7/php-fpm.conf
sed -i -e "s#\(^;access\.log\s*=\s*log/php7/\$pool\.access\.log$\)#\1\naccess\.log = /proc/self/fd/2#g" /etc/php7/php-fpm.d/www.conf
sed -i -e "s#^;access\.format#access\.format#g" /etc/php7/php-fpm.d/www.conf

DRUPAL_VERSION=${DRUPAL_VERSION:-"8.7.3"}
APP_ROOT=${APP_ROOT:-"/var/www"}
chown www-data:www-data ${APP_ROOT}
WWW_ROOT="${APP_ROOT}/html/web"

if [ ! -e "${WWW_ROOT}/index.php" ]; then
    if [ "$WITH_DRUPAL" != "yes" ]; then
        mkdir -p ${WWW_ROOT}
        echo -e "<?php\n\nphpinfo();\n\n\n?>" > ${WWW_ROOT}/index.php
    else
        SETTINGS="${WWW_ROOT}/sites/default/settings.php"

        if [ "$WITH_DRUPAL_COMPOSER" != "yes" ]; then
            # Download the source code if drupal not exist.
            # Should replace '^.+\.docker\.localhost$' with the domain name.
            mkdir -p ${WWW_ROOT}
            curl -fSL "https://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o ${WWW_ROOT}/drupal.tar.gz
            tar -xz --strip-components=1 -f ${WWW_ROOT}/drupal.tar.gz -C ${WWW_ROOT}
            rm ${WWW_ROOT}/drupal.tar.gz
            chown -R www-data:www-data sites modules themes

            if [ -e "${WWW_ROOT}/sites/default/default.settings.php" ]; then
                cp ${WWW_ROOT}/sites/default/default.settings.php ${SETTINGS}
            fi
        else
            mkdir -p ${WWW_ROOT}
            HINTS_ING="Drupal codebase is preparing... Please wait!"
            echo "<html><head><meta http-equiv='refresh' content='5' /><title>TWNMPd</title></head><body><h3>${HINTS_ING}</h3>It would take some time (about 6 minutes). This page will redirect to Drupal Installation when ready.<p><img src='https://upload.wikimedia.org/wikipedia/commons/9/92/Loading_icon_cropped.gif' /></p></body></html>" > ${WWW_ROOT}/index.html
            touch "${APP_ROOT}/$HINTS_ING"

            DRUPAL_SRC="/var/www/drupal"
            su-exec www-data composer create-project drupal-composer/drupal-project:8.x-dev ${DRUPAL_SRC} --stability dev --no-interaction --no-install
            sed -i -e 's#"drupal\/core":.+?8\..+?",?#"drupal/core": "'"${DRUPAL_VERSION}"'",#' ${DRUPAL_SRC}/composer.json

            cd ${DRUPAL_SRC}
            su-exec www-data composer install --prefer-dist
            cd ${APP_ROOT}

            mv "${APP_ROOT}/html" "${APP_ROOT}/html.bak"
            mv "${DRUPAL_SRC}" "/var/www/html"
            rm -rf "${APP_ROOT}/html.bak"
            rm "${APP_ROOT}/$HINTS_ING"
            # su-exec www-data composer clear-cache
        fi

        IFS="."
        export IFS;
        TRUSTED_HOST_PATTERNS=""

        for word in $PROJECT_BASE_URL; do
            TRUSTED_HOST_PATTERNS=${TRUSTED_HOST_PATTERNS}#${word}
        done

        TRUSTED_HOST_PATTERNS=$(echo "${TRUSTED_HOST_PATTERNS}" | sed -e 's/#/\\\./g')

        unset IFS

        if [ ! -e "${SETTINGS}" ]; then
            cp ${WWW_ROOT}/sites/default/default.settings.php ${SETTINGS}
        fi

        { \
            echo ''; \
            echo '$settings['"'"'trusted_host_patterns'"'"'] = ['; \
            echo "  '^.+${TRUSTED_HOST_PATTERNS}\$',"; \
            echo '  "^localhost$",'; \
            echo '  "^127\.0\.0\..+$",'; \
            echo '];'; \
            echo ''; \
        } >> ${SETTINGS}

        # setup $HOST that containers can use to connect to services on the host
        HOST=${MYSQL_HOST:-"host.docker.internal"}

        # docker host for mac and windows
        ping -c 1 ${HOST} >/dev/null 2>&1

        # get return code to judge ping result
        EXIST_HOST_DOCKER_INTERNAL=$(echo $?)

        if [ "$EXIST_HOST_DOCKER_INTERNAL" != "0" ]; then
            # retrieve host ip for linux
            HOST=$(ip route show default | awk '/default/ {print $3}')
        fi

        PORT=${MYSQL_PORT:-"3306"}
        PREFIX=${MYSQL_PREFIX:-""}

        { \
            echo ''; \
            echo '$databases["default"]["default"] = array ('; \
            echo "  'database' => '${MYSQL_DATABASE}',"; \
            echo "  'username' => '${MYSQL_USER}',"; \
            echo "  'password' => '${MYSQL_PASSWORD}',"; \
            echo "  'prefix' => '${PREFIX}',"; \
            echo "  'host' => '${HOST}',"; \
            echo "  'port' => '${PORT}',"; \
            echo '  "namespace" => "Drupal\\Core\\Database\\Driver\\mysql",'; \
            echo "  'driver' => 'mysql',"; \
            echo ');'; \
            echo '';
        } >> ${SETTINGS}
    fi

    chown -R www-data:www-data ${WWW_ROOT}

fi


exec "$@"
