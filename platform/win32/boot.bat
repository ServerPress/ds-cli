@echo off
REM
REM Boot native CLI
REM
SET DS_CLI=c:\xampplite\ds-plugins\ds-cli
SET PHPRC=c:\xampplite\php
SET npm_config_cache=%DS_CLI%\platform\win32\npm-cache
SET npm_config_prefix=%DS_CLI%\platform\win32\npm
SET COMPOSER_HOME=%DS_CLI%\platform\win\composer
SET CYGWIN_HOME=%DS_CLI%\platform\win32\cygwin
PATH=%DS_CLI%\platform\all\pre;%DS_CLI%\platform\win32\pre;%DS_CLI%\platform\win32\cygwin\bin;%DS_CLI%\platform\win32\nodejs;%DS_CLI%\platform\win32\npm;c:\xampplite\php;c:\xampplite\mysql\bin;c:\xampplite\perl\bin;c:\xampplite\apache\bin;c:\xampplite\other;%DS_CLI%\vendor\wp-cli\wp-cli\bin;%DS_CLI%\platform\win32\nodejs\;%PATH%
%*
