#!/bin/sh
TOMCATPREFIX=
TOMCATCTL=${TOMCATPREFIX}/bin/tomcatctl

case "$1" in
start)
    [ -x ${TOMCATCTL} ] && ${TOMCATCTL} start >/dev/null && echo -n ' tomcat6'
    ;;
stop)
    [ -x ${TOMCATCTL} ] && ${TOMCATCTL} stop >/dev/null && echo -n ' tomcat6'
    ;;
*)
    echo "Usage: `basename $0` {start|stop}" >&2
    ;;
esac

exit 0
