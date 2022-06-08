FROM php:7.2-fpm

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /tmp

RUN mkdir /usr/share/man/man1/

RUN apt-get update
RUN apt-get update && apt-get install -y \ 
    git \
    wget \
    alien \
    libaio1 \
    apt-transport-https \
    curl \
    apt-utils \
    libmcrypt-dev \
    zlib1g-dev \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libxslt-dev \
    libfontconfig \
    ca-certificates \
    gnupg \
    ghostscript \
    tesseract-ocr \
    libtesseract-dev \
    pdftk-java \
    poppler-utils \
    zip \
    unzip \
    gosu \
    ca-certificates \
    sqlite3 \ 
    libcap2-bin \
    python2 \
    && mkdir -p ~/.gnupg \
    && chmod 600 ~/.gnupg \
    && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf \
    && apt-key adv --homedir ~/.gnupg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E5267A6C \
    && apt-key adv --homedir ~/.gnupg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C300EE8C \
    && echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu focal main" > /etc/apt/sources.list.d/ppa_ondrej_php.list \
    && apt-get update \
    && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get install -y nodejs \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y yarn \
    && apt-get -y autoremove \
    && apt-get clean \
    && docker-php-ext-install soap \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Instaling and configuring oracle client
ADD oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm /tmp/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm
ADD oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm /tmp/oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm
RUN alien -i oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm
RUN alien -i oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm
ENV LD_LIBRARY_PATH=/usr/lib/oracle/12.1/client64/lib/${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
RUN echo "/usr/lib/oracle/12.1/client64/lib/" > /etc/ld.so.conf.d/oracle.conf && chmod o+r /etc/ld.so.conf.d/oracle.conf
ENV ORACLE_HOME=/usr/lib/oracle/12.1/client64
ENV C_INCLUDE_PATH=/usr/include/oracle/12.1/client64/
RUN ls -al /usr/include/oracle/12.1/client*/*
RUN ls -al $ORACLE_HOME/lib
RUN ln -s /usr/include/oracle/12.1/client64 $ORACLE_HOME/include

RUN docker-php-ext-install -j$(nproc) oci8 \
                                        pdo \
                                        pdo_oci \
                                        pcntl \
                                        mbstring \
                                        tokenizer \
                                        zip \
                                        mysqli \
                                        pdo_mysql \
                                        xsl \
                                        bcmath \
                                        exif \
                                        gd 

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer