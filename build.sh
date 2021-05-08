#!/bin/bash
#
# Description: DS-CLI build script for macOS.
# Gather the distributed runtimes of the latest CLI based
# for use in DesktopServer 5.X
# 
# Author: Stephen J. Carnam

curl -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar --output bin/wp-cli.phar
chmod +x bin/wp-cli.phar
curl -L https://getcomposer.org/download/latest-stable/composer.phar --output bin/composer.phar
chmod +x bin/composer.phar
curl -L https://phar.phpunit.de/phpunit-nightly.phar --output bin/phpunit.phar
chmod +x bin/phpunit.phar

## TODO: get mysql2json.phar, json2mysql.phar