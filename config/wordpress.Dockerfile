FROM wordpress:latest

RUN mkdir bash

#Install PHP Modules
RUN set -eux && apt-get update && apt-get install -y \
    vim \
    wget \
    unzip \
    git \
    libzip-dev \
    zlib1g-dev \
    libnss3-tools \
    golang \
    ca-certificates \
    libmemcached-dev \
    ruby-sass \
    && docker-php-ext-install zip \
    && pecl install memcached \
    && docker-php-ext-enable memcached

#Install WPCLI
RUN curl -Ok https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
&& chmod +x wp-cli.phar \
&& mv wp-cli.phar /usr/local/bin/wp
