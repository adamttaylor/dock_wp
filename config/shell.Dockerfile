FROM php:latest

WORKDIR /var/www/html

#Install PHP Modules
RUN set -eux && apt update && apt install -y \
    vim \
    wget \
    unzip \
    cron \
    mysql-shell \
    git \
    libzip-dev \
    zlib1g-dev \
    libnss3-tools \
    golang \
    libmemcached-dev \
    ruby-sass \
    && docker-php-ext-install zip \
    && pecl install memcached \
    && docker-php-ext-enable memcached

#Install WPCLI
RUN curl -Ok https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
&& chmod +x wp-cli.phar \
&& mv wp-cli.phar /usr/local/bin/wp\
&& touch ~/.ssh/config\
&& ls ~/ \
&& ls ~/.ssh \
&& echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config

#Install Composer: needed for yoast
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
