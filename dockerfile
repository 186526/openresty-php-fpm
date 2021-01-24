FROM debian:10
LABEL mantainer="186526 <i@186526.xyz>"

## Start install openresty
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates \
    gettext-base \
    gnupg2 \
    lsb-base \
    lsb-release \
    software-properties-common \
    wget \
    && wget -qO /tmp/pubkey.gpg https://openresty.org/package/pubkey.gpg \
    && DEBIAN_FRONTEND=noninteractive apt-key add /tmp/pubkey.gpg \
    && rm /tmp/pubkey.gpg \
    && DEBIAN_FRONTEND=noninteractive add-apt-repository -y "deb http://openresty.org/package/debian $(lsb_release -sc) openresty" \
    && DEBIAN_FRONTEND=noninteractive apt-get remove -y --purge \
    gnupg2 \
    lsb-release \
    software-properties-common \
    wget \
    && DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    openresty \
    && DEBIAN_FRONTEND=noninteractive apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/run/openresty \
    && ln -sf /dev/stdout /usr/local/openresty/nginx/logs/access.log \
    && ln -sf /dev/stderr /usr/local/openresty/nginx/logs/error.log

COPY conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY conf/nginx.vh.default.conf /etc/nginx/conf.d/default.conf

ENV PATH="$PATH:/usr/local/openresty/luajit/bin:/usr/local/openresty/nginx/sbin:/usr/local/openresty/bin:"

## Start install php7.2

RUN DEBIAN_FRONTEND=noninteractive apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y php-cli php-fpm php-json php-pdo php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath \
    && DEBIAN_FRONTEND=noninteractive apt-get autoremove -y \
    && rm -rf /var/lib/lists/* \
    && mkdir /run/php/

COPY conf/php-fpm.conf /etc/php/7.3/fpm/pool.d/www.conf
COPY conf/test.php /usr/local/openresty/nginx/html/test.php

CMD mkdir /run/php/ && mkdir /var/run/openresty/ && /usr/sbin/php-fpm7.3 --nodaemonize --fpm-config /etc/php/7.3/fpm/php-fpm.conf & /usr/bin/openresty -g "daemon off;"
