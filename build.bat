@echo off

:: Description: DS-CLI build script for Microsoft Windows.
:: DS-CLI is an enhanced, cross-platform, command line interface for
:: professional WordPress developers. Users can easily start working
:: with CLI tools such as WP-CLI, Composer, Git, NodeJS, and NPM that
:: are apart of DesktopServer core.
:: 
:: Author: Stephen J. Carnam

:: Obtain all vendor resources

if exist .\vendor rmdir /q /s .\vendor
mkdir .\vendor\cygwin
cmd /c "PowerShell (New-Object System.Net.WebClient).DownloadFile('http://cygwin.com/setup-x86.exe', './vendor/cygwin/setup-x86.exe');"
.\vendor\cygwin\setup-x86.exe -B -R %cd%\vendor\cygwin -l %cd%\vendor\ -v -q -d -n -N -s http://cygwin.mirror.constant.com -P wget
set PATH=%cd%\vendor\cygwin\bin;%PATH%
wget https://rawgit.com/transcode-open/apt-cyg/master/apt-cyg -P ./vendor/cygwin
install ./vendor/cygwin/apt-cyg /bin
bash apt-cyg install nano
bash apt-cyg install ncurses
bash apt-cyg install curl
bash apt-cyg install lftp
bash apt-cyg install subversion
bash apt-cyg install git
bash apt-cyg install unzip
bash apt-cyg install zip
bash apt-cyg install sqlite3
bash apt-cyg install p7zip
mkdir .\vendor\nodejs
wget https://nodejs.org/dist/v8.12.0/node-v8.12.0-win-x86.zip -P ./vendor/nodejs
unzip -q -o ./vendor/nodejs/node-v8.12.0-win-x86.zip -d ./vendor/nodejs
mkdir .\vendor\composer
wget https://github.com/composer/composer/releases/download/1.7.2/composer.phar -P ./vendor/composer
mkdir .\vendor\wp-cli
wget https://raw.github.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -P ./vendor/wp-cli
mkdir .\vendor\phpunit
wget https://phar.phpunit.de/phpunit-7.phar -P ./vendor/phpunit
mkdir .\vendor\steveorevo
wget https://github.com/Steveorevo/GString/archive/1.1.0.zip -P ./vendor/steveorevo/gstring-temp
unzip -q -o ./vendor/steveorevo/gstring-temp/1.1.0.zip -d ./vendor/steveorevo
mv ./vendor/steveorevo/GString-1.1.0 ./vendor/steveorevo/gstring
rm -rf ./vendor/steveorevo/gstring-temp
wget https://github.com/Steveorevo/wp-hooks/archive/1.1.0.zip -P ./vendor/steveorevo/wp-hooks-temp
unzip -q -o ./vendor/steveorevo/wp-hooks-temp/1.1.0.zip -d ./vendor/steveorevo
mv ./vendor/steveorevo/wp-hooks-1.1.0 ./vendor/steveorevo/wp-hooks
rm -rf ./vendor/steveorevo/wp-hooks-temp
wget https://github.com/ServerPress/symfix/releases/download/1.0.1/symfix.zip -P ./vendor/serverpress/symfix-temp
unzip -q -o ./vendor/serverpress/symfix-temp/symfix.zip -d ./vendor/serverpress
rm -rf ./vendor/serverpress/symfix-temp

:: Create build folder

if exist .\build rmdir /q /s .\build
mkdir .\build\ds-cli\platform\win32\cygwin
xcopy /cheiqy .\vendor\cygwin .\build\ds-cli\platform\win32\cygwin
mkdir .\build\ds-cli\platform\win32\symfix
xcopy /ceiqy .\vendor\serverpress\symfix .\build\ds-cli\platform\win32\symfix
.\vendor\serverpress\symfix\symfix -u .\build\ds-cli\platform\win32\cygwin
mkdir .\build\ds-cli\platform\win32\nodejs
xcopy /ceiqy .\vendor\nodejs\node-v8.12.0-win-x86 .\build\ds-cli\platform\win32\nodejs
mkdir .\build\ds-cli\platform\all
xcopy /ceiqy .\vendor\composer .\build\ds-cli\platform\all
xcopy /ceiqy .\vendor\wp-cli .\build\ds-cli\platform\all
xcopy /ceiqy .\vendor\phpunit .\build\ds-cli\platform\all
xcopy /ceiqy .\src .\build\ds-cli
rm -rf ./build/ds-cli/platform/mac
mkdir .\build\ds-cli\vendor\steveorevo
xcopy /ceiqy .\vendor\steveorevo .\build\ds-cli\vendor\steveorevo
cd build
bash -c "zip -r -y -9 ds-cli-win.zip ./ds-cli"
cd ..
