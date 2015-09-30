#!/bin/zsh
############################################################## {{{1 ##########
#   $Author: krischik@macports.org $
#   $Revision: 61592 $
#   $Date: 2009-12-16 07:09:14 -0800 (Wed, 16 Dec 2009) $
#   $HeadURL: http://svn.macports.org/repository/macports/trunk/dports/java/glassfishv3/files/Start_Glassfish_Domain1.command $
############################################################## }}}1 ##########

setopt X_Trace;

if test "${USER}" = "root"; then
    typeset -r in_User="${1}"

    if test -d "@PREFIX@/share/java/glassfishv3/glassfish/domains/domain1"; then
	gchown -R "${in_User}" "@PREFIX@/share/java/glassfishv3/glassfish/domains/domain1"
    fi;
else
    sudo ${0} ${USER}

    if test -d "@PREFIX@/share/java/glassfishv3"; then
	typeset -U path
	typeset -x -g -U -T CLASSPATH classpath ":";
	typeset -x -g JAVA_HOME="/System/Library/Frameworks/JavaVM.framework/Versions/1.6/Home";

	path=("/System/Library/Frameworks/JavaVM.framework/Versions/1.6/Commands" ${path})
        path+="@PREFIX@/share/java/glassfishv3/bin";
    fi;
    
    asadmin start-domain domain1
fi;

############################################################ {{{1 ###########
# vim: set nowrap tabstop=8 shiftwidth=4 softtabstop=4 noexpandtab :
# vim: set textwidth=0 filetype=zsh foldmethod=marker nospell :
