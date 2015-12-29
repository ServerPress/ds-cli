@echo off
REM
REM Boot native CLI
REM
SET DS_CLI=c:\xampplite\ds-plugins\ds-cli
PATH=%DS_CLI%\platform\all\pre;%DS_CLI%\platform\win32\pre;%DS_CLI%\platform\win32\cygwin\bin;c:\xampplite\php;c:\xampplite\mysql\bin;c:\xampplite\perl\bin;c:\xampplite\apache\bin;c:\xampplite\other;%DS_CLI%\vendor\wp-cli\wp-cli\bin;%DS_CLI%\platform\win32\nodejs\;%PATH%
%*
