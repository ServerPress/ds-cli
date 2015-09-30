#!/bin/zsh
############################################################## {{{1 ##########
#   $Author: krischik@macports.org $
#   $Revision: 61592 $
#   $Date: 2009-12-16 07:09:14 -0800 (Wed, 16 Dec 2009) $
#   $HeadURL: http://svn.macports.org/repository/macports/trunk/dports/java/glassfishv3/files/Java_5.command $
############################################################## }}}1 ##########

setopt X_Trace;

if test "${USER}" = "root"; then
    pushd "/System/Library/Frameworks/JavaVM.framework/Versions";
	if test -d "A"; then
	    rm "Current";
	    ln -s "A" "Current";   
	fi;
	if test -d "1.5"; then
	    rm "CurrentJDK";
	    ln -s "1.5" "CurrentJDK";
	fi;
    popd;
else
    sudo ${0}
fi;

############################################################ {{{1 ###########
# vim: set nowrap tabstop=8 shiftwidth=4 softtabstop=4 noexpandtab :
# vim: set textwidth=0 filetype=zsh foldmethod=marker nospell :
