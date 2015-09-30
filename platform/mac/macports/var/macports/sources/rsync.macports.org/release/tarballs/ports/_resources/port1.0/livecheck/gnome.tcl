# $Id: gnome.tcl 104611 2013-03-30 12:40:16Z cal@macports.org $
#
# This file contains the defaults for gnome.

if {${livecheck.name} eq "default"} {
    set livecheck.name ${name}
}
if {!$has_homepage || ${livecheck.url} eq ${homepage}} {
    set livecheck.url "http://ftp.gnome.org/pub/GNOME/sources/${livecheck.name}/cache.json"
}
if {${livecheck.regex} eq ""} {
    set livecheck.regex {LATEST-IS-(\\d+\\.\\d*[02468](?:\\.\\d+)*)}
}
set livecheck.type "regex"
