FROM ubuntu:16.04

MAINTAINER Serg Nochevny <sergnochevny@engineering.ait.com>

# Initialise

ENV DEBIAN_FRONTEND noninteractive

# Upgrade

RUN apt-get update -y \
	&& apt-get upgrade -y \
	&& apt-get dist-upgrade -y

RUN apt-get install -y pkg-config \
    software-properties-common \
    curl \
    sudo \
    openssl \
    net-tools \
    iputils-ping \
    openssh-client \
    openssh-server \
    openssh-sftp-server \
    openssh-blacklist \
    openssh-blacklist-extra \
    openssh-known-hosts \
    git \
    bash \
    zsh \
    htop \
    locales \
    tzdata \
    wget \
    imagemagick \
    mcrypt \
    libxml2-dev \
    libapache2-modsecurity \
    libcurl4-openssl-dev \
    autoconf \
    bison \
    libxml2 \
    libxml2-dev \
    libssl-dev \
    libbz2-dev \
    libjpeg-dev \
    libpng-dev \
    libxpm-dev \
    libfreetype6-dev \
    libgmp-dev \
    libmcrypt-dev \
    libmysqld-dev \
    libpspell-dev \
    librecode-dev \
    libssl-dev \
    libsslcommon2-dev \
    libmysqlclient-dev \
    libfreetype6-dev \
    libmcrypt-dev \
    libpng12-dev \
    cron \
    nano \
    supervisor

# MySQL
RUN apt-get install -y software-properties-common\
    && add-apt-repository 'deb http://archive.ubuntu.com/ubuntu trusty universe' \
    && apt-get update \
    && apt-get install -y mysql-server-5.6 \
    && apt-get install -y mysql-client-5.6


# Fetch payload
RUN mkdir /root/dev-env/

# Time

RUN echo "Etc/UTC" > /etc/timezone; dpkg-reconfigure -f noninteractive tzdata
RUN export LANGUAGE=en_US.UTF-8 \
	&& export LANG=en_US.UTF-8 \
	&& export LC_ALL=en_US.UTF-8 \
	&& locale-gen en_US.UTF-8 \
	&& DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

# Apache PHP

RUN set -x \
    && apt-get install -yq \
    apache2 \
    apache2-bin \
    apache2-dev \
    apache2-utils \
    php7.0 \
    php7.0-cli \
    php7.0-dev \
    libapache2-mod-php7.0 \
    php-pear \
    php-imagick \
    php-redis \
    php7.0-gmp \
    php7.0-imap \
    php7.0-ps \
    php7.0-bz2 \
    php7.0-readline \
    php7.0-tidy \
    php7.0-xmlrpc \
    php7.0-opcache \
    php7.0-common \
    php7.0-pdo \
    php7.0-mysql \
    php7.0-mysqli \
    php7.0-ftp \
    php7.0-gd \
    php7.0-json \
    php7.0-ldap \
    php7.0-mbstring \
    php7.0-mysql \
    php7.0-xml \
    php7.0-xsl \
    php7.0-zip \
    php7.0-curl \
    php7.0-mcrypt \
    php7.0-iconv \
    php7.0-dom \
    php7.0-soap \
    php7.0-sockets \
    php7.0-exif \
    php7.0-intl \
    php7.0-gettext \
    php7.0-fileinfo

RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/supervisor

#pagespeed

RUN set -x \
	&& cd /tmp \
	&& wget https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_amd64.deb \ 
	&& dpkg -i mod-pagespeed-*.deb \
	&& apt-get -f install

COPY apache/pagespeed.conf /etc/apache2/mods-available/pagespeed.conf

#timezonedb

RUN pecl update-channels \
	&& pecl install timezonedb \
    && echo "extension = timezonedb.so" >> /etc/php/7.0/mods-available/timezonedb.ini

# Xdebug

RUN set -x \
	&& cd /tmp \
	&& wget http://xdebug.org/files/xdebug-2.5.0.tgz \
    && tar -xvzf xdebug-2.5.0.tgz \
    && cd xdebug-2.5.0 \
    && phpize \
    && ./configure \
    && make \
    && cp modules/xdebug.so /usr/lib/php/ \
    && echo "" >> /etc/php/7.0/mods-available/xdebug.ini \
    && echo "[xdebug]" >> /etc/php/7.0/mods-available/xdebug.ini \
    && echo "zend_extension = /usr/lib/php/xdebug.so" >> /etc/php/7.0/mods-available/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /etc/php/7.0/mods-available/xdebug.ini \
    && echo "xdebug.remote_handler=dbgp" >> /etc/php/7.0/mods-available/xdebug.ini \
    && echo "xdebug.remote_mode=req" >> /etc/php/7.0/mods-available/xdebug.ini \
    && echo "xdebug.remote_host=localhost" >> /etc/php/7.0/mods-available/xdebug.ini \
    && echo "xdebug.remote_connect_back=1" >> /etc/php/7.0/mods-available/xdebug.ini \
    && echo "xdebug.scream=0" >> /etc/php/7.0/mods-available/xdebug.ini \
    && echo "xdebug.remote_port=9000" >> /etc/php/7.0/mods-available/xdebug.ini \
    && echo "xdebug.show_local_vars=1" >> /etc/php/7.0/mods-available/xdebug.ini \
    && echo "xdebug.idekey=PHPSTORM" >> /etc/php/7.0/mods-available/xdebug.ini \
    && cd ..

#pdflib

RUN set -x \
	&& cd /tmp \
	&& wget https://www.pdflib.com/binaries/PDFlib/910/PDFlib-9.1.0-Linux-x86_64-php.tar.gz \
    && tar -xvzf PDFlib-9.1.0-Linux-x86_64-php.tar.gz \
    && cp PDFlib-9.1.0-Linux-x86_64-php/bind/php/php-700/php_pdflib.so /usr/lib/php/ \
    && echo "" >> /etc/php/7.0/mods-available/pdflib.ini \
    && echo "extension = /usr/lib/php/php_pdflib.so" >> /etc/php/7.0/mods-available/pdflib.ini \
    && cd ..

# Composer

RUN set -x \
	&& cd /tmp \
	&& curl -sS https://getcomposer.org/installer -o composer-setup.php \
	&& php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && cd ..

# Redis

RUN apt-get install -y redis-server

#clean

RUN set -x \
	&& apt-get clean \
	&& apt-get autoremove -y \
	&& rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/archives/*.deb

RUN a2enmod php7.0 \
	&& a2enmod rewrite \
	&& a2enmod expires \
	&& a2enmod headers \
	&& a2enmod env \
	&& a2enmod proxy \
	&& a2enmod deflate \
	&& a2enmod xml2enc \
	&& a2enmod setenvif \
	&& a2enmod pagespeed \
	&& a2enmod ssl \
	&& a2enmod access_compat \
	&& a2enmod actions \      
	&& a2enmod alias \        
	&& a2enmod allowmethods \ 
	&& a2enmod asis \         
	&& a2enmod auth_basic \   
	&& a2enmod authn_core \   
	&& a2enmod authn_file \   
	&& a2enmod authz_core \   
	&& a2enmod authz_groupfile \
	&& a2enmod authz_host \   
	&& a2enmod authz_user \   
	&& a2enmod autoindex \    
	&& a2enmod buffer \       
	&& a2enmod cache \        
	&& a2enmod cache_disk \   
	&& a2enmod cgi \          
	&& a2enmod data \         
	&& a2enmod dir \          
	&& a2enmod ext_filter \   
	&& a2enmod file_cache \   
	&& a2enmod filter \       
	&& a2enmod include \      
	&& a2enmod info \                
	&& a2enmod log_debug \    
	&& a2enmod mime \         
	&& a2enmod negotiation \  
	&& a2enmod proxy \        
	&& a2enmod proxy_html \   
	&& a2enmod proxy_http \   
	&& a2enmod remoteip \     
	&& a2enmod request \      
	&& a2enmod reqtimeout \   
	&& a2enmod security2 \      
	&& a2enmod session \      
	&& a2enmod session_cookie \   
	&& a2enmod session_crypto \
	&& a2enmod session_dbd \  
	&& a2enmod status \       
	&& a2enmod userdir \      
	&& a2enmod usertrack \         
	&& a2enmod vhost_alias

RUN phpenmod pdo_mysql \
	&& phpenmod mbstring \
	&& phpenmod mcrypt \
	&& phpenmod bz2 \
	&& phpenmod curl \
	&& phpenmod exif \
	&& phpenmod fileinfo \
	&& phpenmod gd \
	&& phpenmod gettext \
	&& phpenmod imap \
	&& phpenmod imagick \
	&& phpenmod intl \
	&& phpenmod mysqli \
	&& phpenmod redis \
	&& phpenmod soap \
	&& phpenmod sockets \
	&& phpenmod simplexml \
	&& phpenmod tidy \
	&& phpenmod xml \
	&& phpenmod xmlrpc \
	&& phpenmod timezonedb \
	&& phpenmod pdflib \
	&& phpenmod xdebug \
	&& phpenmod zip \
	&& phpenmod xsl 

# Run scripts

RUN set -x \
	&& systemctl enable supervisor

VOLUME ["/var/www"]
VOLUME ["/var/lib/mysql"]
VOLUME ["/root/dev-env"]

EXPOSE 80 22 443

COPY payload/init.sh /usr/bin/init.sh
RUN set -x \
    && chown root:root /usr/bin/init.sh \
    && chmod +x /usr/bin/init.sh

RUN sed -i -e 's/\r$//' "/usr/bin/init.sh"

CMD [ "/usr/bin/init.sh" ]







