#!/bin/bash
#
# Discription: DS-CLI build script for Apple MacOS.
# DS-CLI is an enhanced, cross-platform, command line interface for
# professional WordPress developers. Users can easily start working
# with CLI tools such as WP-CLI, Composer, Git, NodeJS, and NPM that
# are apart of DesktopServer core.
# 
# Author: Stephen J. Carnam

# Obtain all vendor resources

[[ -e './vendor' ]] || rm -rf ./vendor
mkdir -p ./vendor/homebrew
curl -L https://github.com/Homebrew/brew/tarball/master -o ./vendor/homebrew.tar
tar -xvf ./vendor/homebrew.tar --strip 1 -C ./vendor/homebrew
./vendor/homebrew/bin/brew install wget
export PATH="$PWD/vendor/homebrew/bin:$PATH"
brew install lftp
brew install p7zip
mkdir -p ./vendor/nodejs
wget https://nodejs.org/dist/v8.12.0/node-v8.12.0-darwin-x64.tar.gz -P ./vendor
tar -xzf ./vendor/node-v8.12.0-darwin-x64.tar.gz --strip 1 -C ./vendor/nodejs
mkdir -p ./vendor/composer
wget https://github.com/composer/composer/releases/download/1.7.2/composer.phar -P ./vendor/composer
mkdir -p ./vendor/wp-cli
wget https://raw.github.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -P ./vendor/wp-cli
mkdir -p ./vendor/phpunit
wget https://phar.phpunit.de/phpunit-7.phar -P ./vendor/phpunit
mkdir ./vendor/steveorevo
wget https://github.com/Steveorevo/GString/archive/1.1.0.zip -P ./vendor/steveorevo/gstring-temp
unzip -q -o ./vendor/steveorevo/gstring-temp/1.1.0.zip -d ./vendor/steveorevo
mv ./vendor/steveorevo/GString-1.1.0 ./vendor/steveorevo/gstring
rm -rf ./vendor/steveorevo/gstring-temp
wget https://github.com/Steveorevo/wp-hooks/archive/1.1.0.zip -P ./vendor/steveorevo/wp-hooks-temp
unzip -q -o ./vendor/steveorevo/wp-hooks-temp/1.1.0.zip -d ./vendor/steveorevo
mv ./vendor/steveorevo/wp-hooks-1.1.0 ./vendor/steveorevo/wp-hooks
rm -rf ./vendor/steveorevo/wp-hooks-temp

# Create build folder

[[ -e './build' ]] || rm -rf ./build
mkdir -p ./build/ds-cli/platform/mac/homebrew
rsync -a ./vendor/homebrew/ ./build/ds-cli/platform/mac/homebrew
mkdir -p ./build/ds-cli/platform/all
rsync -a ./vendor/composer/ ./build/ds-cli/platform/all
rsync -a ./vendor/phpunit/ ./build/ds-cli/platform/all
rsync -a ./vendor/wp-cli/ ./build/ds-cli/platform/all
rsync -a ./src/ ./build/ds-cli
mkdir -p ./build/ds-cli/vendor/steveorevo
rsync -a ./vendor/steveorevo/ ./build/ds-cli/vendor/steveorevo
cd build
zip -r ds-cli-mac.zip ./ds-cli
cd ..
