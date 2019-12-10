
FROM ubuntu:18.04

# Turn off setup script questions
ENV DEBIAN_FRONTEND noninteractive

EXPOSE 9000

RUN apt-get update && \
    apt-get install -y \
    locales apt-utils

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get update && \
    apt-get install -y \
    software-properties-common curl htop zip unzip wget git && \
    add-apt-repository -y ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y \
    libcurl4-openssl-dev pkg-config libssl-dev zlib1g-dev libxml++2.6-dev libcurl3-dev openssh-server \
    php7.4-cli php7.4-curl php7.4-fpm php7.4-mbstring php7.4-pdo php7.4-mysql php7.4-xml php7.4-common php7.4-json php7.4-bcmath php7.4-ctype php7.4-tokenizer php7.4-redis && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

# https://github.com/docker-library/php/blob/e63194a0006848edb13b7eff5a7f9d790d679428/7.1/jessie/fpm/Dockerfile
RUN set -ex \
    && cd /etc/php/7.4/fpm \
    && { \
        echo '[global]'; \
        echo 'error_log = /proc/self/fd/2'; \
        echo; \
        echo '[www]'; \
        echo '; if we send this to /proc/self/fd/1, it never appears'; \
        echo 'access.log = /proc/self/fd/2'; \
        echo; \
        echo 'clear_env = no'; \
        echo; \
        echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
        echo 'catch_workers_output = yes'; \
        echo '[global]'; \
        echo 'daemonize = no'; \
        echo; \
        echo '[www]'; \
        echo 'listen = 9000'; \
    } | tee -a pool.d/www.conf

# Need this directory so fpm can add it's .sock file
RUN mkdir -p /run/php/
