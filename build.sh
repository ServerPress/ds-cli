#!/bin/bash
#
# Description: DS-CLI build script for macOS.
# Gather the distributed runtimes of the latest CLI based
# for use in DesktopServer 5.X
# 
# Author: Stephen J. Carnam

curl -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar --output bin/wp
chmod +x bin/wp
echo "php -f wp %*" > bin/wp.bat
curl -L https://getcomposer.org/download/latest-stable/composer.phar --output bin/composer
chmod +x bin/composer
echo "php -f composer %*" > bin/composer.bat
curl -L https://phar.phpunit.de/phpunit-nightly.phar --output bin/phpunit
chmod +x bin/phpunit
echo "php -f phpunit %*" > bin/phpunit.bat

