
FROM ubuntu:20.04

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
    php8.0-cli php8.0-curl php8.0-fpm php8.0-mbstring php8.0-pdo php8.0-mysql php8.0-xml php8.0-common php8.0-bcmath php8.0-ctype php8.0-tokenizer php8.0-redis && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

# https://github.com/docker-library/php/blob/e63194a0006848edb13b7eff5a7f9d790d679428/7.1/jessie/fpm/Dockerfile
RUN set -ex \
    && cd /etc/php/8.0/fpm \
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
