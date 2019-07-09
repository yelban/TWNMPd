# TWNMPd

Tiny Well Linux Nginx MySQL PHP Docker w//o Drupal

## Intro
TWNMPd provides pre-configured docker-compose.yml to spin up PHP Application Environments on Linux, macOS and Windows.

* Alpine based docker images. *( 10x smaller than Debian )*
* Automatic Let's Encrypt SSL certificates renewal.
* Complete PHP requirements for Drupal 8.
* Three choices Drupal installation type:
  * no Drupal
  * tarball installation
  * composer require *( with Drush and Drupal Console )*
* Pre-configured MailHog and MSMTP Gmail relay.
* Rsyslog collect all logs.


## Usage

#### Clone this repository

```sh
git clone https://github.com/yelban/TWNMPd

```

#### Start stack

```sh
cd TWNMPd

docker-composer up -d

```

#### Stop stack

```sh
docker-composer down

```


#### Visit Your site

http://**localhost**/

http://nginx.docker.localhost *( needs edit /etc/hosts )*

or

http://www.example.com/ *( your own host name )*


#### Dispensable Drupal
Set values in the ***.env*** to change options before start the stack.

ex. There are 3 options to install Drupal

1. Simple PHP environment without Drupal
   ```javascript
   WITH_DRUPAL=no
   ```

2. Installed from Drupal.tar.gz
   ```javascript
   WITH_DRUPAL=yes
   ```

3. Drupal with CLI by `composer install` *( default* )*
   ```javascript
   WITH_DRUPAL=yes
   WITH_DRUPAL_COMPOSER=yes
   ```


ex. Enabel Automatic Let's Encrypt SSL certificates renewal

1. *Remark line in* **docker-compose.yml**
    ```javascript
    command: -c /dev/null --web --web.address=:3000 --docker --logLevel=INFO
    ```
    *to*
    ```sh
    # command: -c /dev/null --web --web.address=:3000 --docker --logLevel=INFO
    ```

    **and** *Uncomment following lines*
    ```sh
        # command:
        #   - "--api"
        #   - "--entrypoints=Name:http Address::80 Redirect.EntryPoint:https"
        #   - "--entrypoints=Name:https Address::443 TLS"
        #   - "--defaultentrypoints=http,https"
        #   - "--acme"
        #   - "--acme.storage=/etc/traefik/acme/acme.json"
        #   - "--acme.entryPoint=https"
        #   - "--acme.httpChallenge.entryPoint=http"
        #   - "--acme.onHostRule=true"
        #   - "--acme.onDemand=false"
        #   - "--acme.email=${EMAIL}"
        #   - "--docker"
        #   - "--docker.watch"
    ```
    *to*
    ```javascript
        command:
           - "--api"
           - "--entrypoints=Name:http Address::80 Redirect.EntryPoint:https"
           - "--entrypoints=Name:https Address::443 TLS"
           - "--defaultentrypoints=http,https"
           - "--acme"
           - "--acme.storage=/etc/traefik/acme/acme.json"
           - "--acme.entryPoint=https"
           - "--acme.httpChallenge.entryPoint=http"
           - "--acme.onHostRule=true"
           - "--acme.onDemand=false"
           - "--acme.email=${EMAIL}"
           - "--docker"
           - "--docker.watch"
    ```

    **and**
    ```javascript
        ports:
           - '80:80'
           # - '443:443'
           - '8080:3000' # Dashboard
    ```
    *to*
    ```
        ports:
           - '80:80'
           - '443:443'
           # - '8080:3000' # Dashboard
    ```

2. *Setup FQDN, for example the site URL is* **www**.example.com

    edit ***.env***
    ```javascript
    PROJECT_BASE_URL=example.com
    ```

    edit ***docker-compose.yml***
    ```sh
        nginx:
            ...
            - 'traefik.frontend.rule=Host:www.${PROJECT_BASE_URL}'
    ```

## Persistent Volumes

* `codebase`: /var/www
* `database`: /usr/lib/mysql
* `logbase`: /var/log/docker


## Hints

#### PROJECT_BASE_URL and /etc/hosts
You should edit /etc/hosts to fulfill the DNS query for docker service

sudo vi **/etc/hosts** *(* **/private/etc/hosts** *for masOS )*
```
127.0.0.1 nginx.docker.localhost

127.0.0.1 mailhog.docker.localhost
```

#### *MYSQL_PASSWORD* is the only field that needs to be entered manually at Database configutation step.

<p align="center">
<kbd><img src="https://images2.imgbox.com/88/8f/0YwtAeDb_o.png" /></kbd>
</p>

#### Temporary Preparing Page

Because composer installation takes a long time ( **about 6 minutes** ), You will see preparing page until the installation is complete.
<p align="center">
<kbd><img src="https://images2.imgbox.com/81/10/YZiUpusH_o.png" /></kbd>
</p>

<p align="center">
↓↓↓↓↓
</p>

<p align="center">
<kbd><img src="https://images2.imgbox.com/50/72/YyCzRo1J_o.png" /></kbd>
</p>

#### Green Drupal status report
Automatic setting up Trusted Host Patterns in settings.php.

<p align="center">
<kbd><img src="https://images2.imgbox.com/7e/fc/0u8n86vH_o.png" /></kbd>
</p>



## Environment Variables
#### Global Settings
|Variable               |Default Value      |Description
|---                    |---                |---
|PROJECT_NAME           |ab10               |
|PROJECT_BASE_URL       |docker.localhost   |
|BASE_IMAGE_TAG         |3.9                |
|TIMEZONE               |Asia/Taipei        |
|HOST_IP                |172.17.0.1         |
|RSYSLOG_PORT           |514                |
|HOST_IP                |172.17.0.1         |


#### PHP Settings
|Variable               |Default Value      |Description
|---                    |---                |---
|WITH_DRUPAL            |yes                |
|WITH_DRUPAL_COMPOSER   |yes                |
|DRUPAL_VERSION         |8.7.3              |
|PHP_VERSION            |7.3                |
|PHP_ROOT               |/var/www           |
|PHP_MEMORY_LIMIT       |128M               |
|PHP_MAX_EXECUTION_TIME |60                 |
|PHP_UPLOAD_MAX_FILESIZE|1G                 |
|PHP_POST_MAX_SIZE      |1G                 |
|PHP_MAX_FILE_UPLOADS   |25                 |
|PM_MAX_CHILDREN        |5                  |


#### Nginx Settings
|Variable               |Default Value      |Description
|---                    |---                |---
|NGINX_VERSION          |1.6                |
|NGINX_ROOT             |/var/www           |
|SERVER_NAME            |localhost          |
|FASTCGI_PASS_HOST      |php                |
|FASTCGI_PASS_PORT      |9000               |


#### MySQL Settings
|Variable               |Default Value      |Description
|---                    |---                |---
|MYSQL_VERSION          |10.3               |
|MYSQL_DATABASE         |drupal             |
|MYSQL_USER             |drupal             |
|MYSQL_PASSWORD         |passwd             |
|MYSQL_ROOT_PASSWORD    |rootpasswd         |
|MYSQL_PREFIX           |                   |
|MYSQL_HOST             |mysql              |
|MYSQL_PORT             |                   |


#### SMTP Relay Settings
|Variable               |Default Value      |Description
|---                    |---                |---
|RELAY_HOST             |smtp.gmail.com     |
|RELAY_PORT             |587                |
|RELAY_USER             |YOUR@gmail.com     |
|RELAY_FROM             |YOUR@gmail.com     |
|RELAY_SECRETS          |YOUR_APP_PASSWORD  |
|MAILHOG_HOST           |mailhog            |
|MAILHOG_PORT           |                   |


#### Rsyslog Settings
|Variable               |Default Value      |Description
|---                    |---                |---
|RSYSLOG_VERSION        |8.4                |


## Stack Size
|REPOSITORY     |SIZE
|---            |---:
|ab10/nginx     |19.3MB
|ab10/php       |64.6MB
|ab10/mysql     |228MB
|ab10/rsyslog   |6.7MB
|mailhog/mailhog|71.7MB
|traefik        |19.2MB
|alpine         |5.5MB
