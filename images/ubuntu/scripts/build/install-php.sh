#!/bin/bash -e
################################################################################
##  File:  install-php.sh
##  Desc:  Install php
################################################################################
# Source the helpers for use with the script
source $HELPER_SCRIPTS/etc-environment.sh
source $HELPER_SCRIPTS/os.sh
source $HELPER_SCRIPTS/install.sh

# add repository for old Ubuntu images
# details in thread: https://github.com/actions/runner-images/issues/6331
if is_ubuntu20; then
    apt-add-repository ppa:ondrej/php -y
    update_dpkgs
fi

# Install PHP
php_versions=$(get_toolset_value '.php.versions[]')

for version in $php_versions; do
    echo "Installing PHP $version"
    install_dpkgs --no-install-recommends \
        php$version \
        php$version-amqp \
        php$version-apcu \
        php$version-bcmath \
        php$version-bz2 \
        php$version-cgi \
        php$version-cli \
        php$version-common \
        php$version-curl \
        php$version-dba \
        php$version-dev \
        php$version-enchant \
        php$version-fpm \
        php$version-gd \
        php$version-gmp \
        php$version-igbinary \
        php$version-imagick \
        php$version-imap \
        php$version-interbase \
        php$version-intl \
        php$version-ldap \
        php$version-mbstring \
        php$version-memcache \
        php$version-memcached \
        php$version-mongodb \
        php$version-mysql \
        php$version-odbc \
        php$version-opcache \
        php$version-pgsql \
        php$version-phpdbg \
        php$version-pspell \
        php$version-readline \
        php$version-redis \
        php$version-snmp \
        php$version-soap \
        php$version-sqlite3 \
        php$version-sybase \
        php$version-tidy \
        php$version-xdebug \
        php$version-xml \
        php$version-xsl \
        php$version-yaml \
        php$version-zip \
        php$version-zmq

        install_dpkgs --no-install-recommends php$version-pcov

        # Disable PCOV, as Xdebug is enabled by default
        # https://github.com/krakjoe/pcov#interoperability
        phpdismod -v $version pcov

    if [[ $version == "7.2" || $version == "7.3" || $version == "7.4" ]]; then
        install_dpkgs --no-install-recommends php$version-recode
    fi

    if [[ $version != "8.0" && $version != "8.1" && $version != "8.2" && $version != "8.3" ]]; then
        install_dpkgs --no-install-recommends php$version-xmlrpc php$version-json
    fi
done

install_dpkgs --no-install-recommends php-pear

install_dpkgs --no-install-recommends snmp

# Install composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === file_get_contents('https://composer.github.io/installer.sig')) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
sudo mv composer.phar /usr/bin/composer
php -r "unlink('composer-setup.php');"

# Add composer bin folder to path
prepend_etc_environment_path '$HOME/.config/composer/vendor/bin'

#Create composer folder for user to preserve folder permissions
mkdir -p /etc/skel/.composer

# Install phpunit (for PHP)
wget -q -O phpunit https://phar.phpunit.de/phpunit-8.phar
install phpunit /usr/local/bin/phpunit

# ubuntu 20.04 libzip-dev is libzip5 based and is not compatible libzip-dev of ppa:ondrej/php
# see https://github.com/actions/runner-images/issues/1084
if is_ubuntu20; then
    rm /etc/apt/sources.list.d/ondrej-*.list
    update_dpkgs
fi
