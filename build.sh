#!/bin/bash
#
# Description: DS-CLI build script for macOS.
# Gather the distributed runtimes of the latest CLI based
# for use in DesktopServer 5.X
# 
# Author: Stephen J. Carnam

rm -rf ./bin
mkdir ./bin

curl -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar --output bin/wp.phar
chmod +x bin/wp.phar
echo -e -n '#!/bin/bash\nwp.phar "$@"' > bin/wp
chmod +x bin/wp
echo -e -n 'php -f %~dp0wp.phar %*' > bin/wp.bat

curl -L https://getcomposer.org/download/latest-stable/composer.phar --output bin/composer.phar
chmod +x bin/composer.phar
echo -e -n '#!/bin/bash\ncomposer.phar "$@"' > bin/composer
chmod +x bin/composer
echo -e -n 'php -f %~dp0composer.phar %*' > bin/composer.bat

curl -L https://phar.phpunit.de/phpunit-nightly.phar --output bin/phpunit.phar
chmod +x bin/phpunit.phar
echo -e -n '#!/bin/bash\nphpunit.phar "$@"' > bin/phpunit
chmod +x bin/phpunit
echo -e -n 'php -f %~dp0phpunit.phar %*' > bin/phpunit.bat

curl -L https://clue.engineering/phar-composer-latest.phar --output bin/phar-composer.phar
echo -e -n '#!/bin/bash\nphp --define phar.readonly=0 -f phar-composer.phar "$@"' > bin/phar-composer
chmod +x bin/phar-composer
echo -e -n 'php --define phar.readonly=0 -f %~dp0phar-composer.phar %*' > bin/phar-composer.bat
