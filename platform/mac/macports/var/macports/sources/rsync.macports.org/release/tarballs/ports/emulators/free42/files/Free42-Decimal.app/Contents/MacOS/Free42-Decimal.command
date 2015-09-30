#!/bin/zsh
############################################################## {{{1 ##########
#   $Author: krischik@macports.org $
#   $Revision: 47203 $
#   $Date: 2009-02-23 05:26:06 -0800 (Mon, 23 Feb 2009) $
#   $HeadURL: http://svn.macports.org/repository/macports/trunk/dports/emulators/free42/files/Free42-Decimal.app/Contents/MacOS/Free42-Decimal.command $
############################################################## }}}1 ##########

local User_Data="${HOME}/.free42"
local System_Data="@PREFIX@/share/free42";

if test ! -d "${User_Data}"; then
    mkdir "${User_Data}";
    ln -s "${System_Data}"/*  "${User_Data}/";
fi;

@PREFIX@/bin/free42dec &

############################################################ {{{1 ###########
# vim: set nowrap tabstop=8 shiftwidth=4 softtabstop=4 noexpandtab :
# vim: set textwidth=0 filetype=zsh foldmethod=marker nospell :
