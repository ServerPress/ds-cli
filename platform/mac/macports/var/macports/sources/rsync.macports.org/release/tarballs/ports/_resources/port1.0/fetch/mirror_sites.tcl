# $Id: mirror_sites.tcl 140417 2015-09-19 15:52:22Z ryandesign@macports.org $
#
# List of master site classes for use in Portfiles
# Most of these are taken shamelessly from FreeBSD.
#
# Appending :nosubdir as a tag to a mirror, means that
# the portfetch target will NOT append a subdirectory to
# the mirror site.
#
# Please keep this list sorted.

namespace eval portfetch::mirror_sites { }

set portfetch::mirror_sites::sites(afterstep) {
    ftp://ftp.kddlabs.co.jp/X11/AfterStep/
    ftp://ftp.dti.ad.jp/pub/X/AfterStep/
    ftp://ftp.afterstep.org/
}

set portfetch::mirror_sites::sites(apache) {
    http://mirrors.ibiblio.org/apache/
    http://www.gtlib.gatech.edu/pub/apache/
    http://apache.mirror.rafal.ca/
    ftp://ftp.infoscience.co.jp/pub/net/apache/dist/
    http://apache.multidist.com/
    http://mirror.internode.on.net/pub/apache/
    http://www.mirrorservice.org/sites/ftp.apache.org/
    http://mirror.aarnet.edu.au/pub/apache/
    http://apache.is.co.za/
    http://mirror.facebook.net/apache/
    http://apache.pesat.net.id/
    http://www.apache.org/dist/
    http://archive.apache.org/dist/
}

# Note that mirror_sites aren't intelligent enough to handle how this should
# work automatically (which is, append first letter of port name, then
# port name) so just use a basic form here and fake it in ports that need
# to use this.
set portfetch::mirror_sites::sites(debian) {
    http://ftp.us.debian.org/debian/pool/main/:nosubdir
    http://ftp.au.debian.org/debian/pool/main/:nosubdir
    http://ftp.bg.debian.org/debian/pool/main/:nosubdir
    http://ftp.cl.debian.org/debian/pool/main/:nosubdir
    http://ftp.cz.debian.org/debian/pool/main/:nosubdir
    http://ftp.de.debian.org/debian/pool/main/:nosubdir
    http://ftp.ee.debian.org/debian/pool/main/:nosubdir
    http://ftp.es.debian.org/debian/pool/main/:nosubdir
    http://ftp.fi.debian.org/debian/pool/main/:nosubdir
    http://ftp.fr.debian.org/debian/pool/main/:nosubdir
    http://ftp.hk.debian.org/debian/pool/main/:nosubdir
    http://ftp.hr.debian.org/debian/pool/main/:nosubdir
    http://ftp.hu.debian.org/debian/pool/main/:nosubdir
    http://ftp.ie.debian.org/debian/pool/main/:nosubdir
    http://ftp.is.debian.org/debian/pool/main/:nosubdir
    http://ftp.it.debian.org/debian/pool/main/:nosubdir
    http://ftp.jp.debian.org/debian/pool/main/:nosubdir
    http://ftp.nl.debian.org/debian/pool/main/:nosubdir
    http://ftp.no.debian.org/debian/pool/main/:nosubdir
    http://ftp.pl.debian.org/debian/pool/main/:nosubdir
    http://ftp.ru.debian.org/debian/pool/main/:nosubdir
    http://ftp.se.debian.org/debian/pool/main/:nosubdir
    http://ftp.si.debian.org/debian/pool/main/:nosubdir
    http://ftp.sk.debian.org/debian/pool/main/:nosubdir
    http://ftp.uk.debian.org/debian/pool/main/:nosubdir
    http://ftp.wa.au.debian.org/debian/pool/main/:nosubdir
    http://ftp2.de.debian.org/debian/pool/main/:nosubdir
}

set portfetch::mirror_sites::sites(fink) {
    http://distfiles.hnd.jp.asi.finkmirrors.net/:nosubdir
    http://distfiles.ber.de.eu.finkmirrors.net/:nosubdir
    http://distfiles.hel.fi.eu.finkmirrors.net/:nosubdir
    http://distfiles.dub.ie.eu.finkmirrors.net/:nosubdir
    http://distfiles.sjc.ca.us.finkmirrors.net/:nosubdir
    http://www.mirrorservice.org/sites/master.us.finkmirrors.net/distfiles/:nosubdir
    http://distfiles.master.finkmirrors.net/:nosubdir
}

# FreeBSD switched to a Geo-IP-based load-balanced distcache.
# Note that FreeBSD's pkg(8) utility does not just stupidly
# download via HTTP, but issues DNS queries to fetch
# SRV records and compute the "best" available server
# given some weighting criteria.
# It probably doesn't matter a bunch, though, and plain
# DNS lookups and HTTP requests are fine.
set portfetch::mirror_sites::sites(freebsd) {
    http://distcache.FreeBSD.org/ports-distfiles/:nosubdir
}

# curl -s http://www.gentoo.org/main/en/mirrors2.xml | sed -n '/(http)\|(ftp)/s/.*"\([^"]*\)".*/    \1\/distfiles\/:nosubdir/p' | sed s@//distfiles@/distfiles@g
set portfetch::mirror_sites::sites(gentoo) {
    http://gentoo.arcticnetwork.ca/distfiles/:nosubdir
    http://gentoo.mirrors.tera-byte.com/distfiles/:nosubdir
    http://gentoo.localhost.net.ar/distfiles/:nosubdir
    http://gentoo.c3sl.ufpr.br/distfiles/:nosubdir
    http://gentoo.inode.at/distfiles/:nosubdir
    http://mirror.bih.net.ba/gentoo/distfiles/:nosubdir
    http://distfiles.gentoo.bg/distfiles/:nosubdir
    http://ftp.fi.muni.cz/pub/linux/gentoo/distfiles/:nosubdir
    http://ftp.klid.dk/ftp/gentoo/distfiles/:nosubdir
    http://trumpetti.atm.tut.fi/gentoo/distfiles/:nosubdir
    ftp://ftp.free.fr/mirrors/ftp.gentoo.org/distfiles/:nosubdir
    http://mirrors.linuxant.fr/distfiles.gentoo.org/distfiles/:nosubdir
    http://de-mirror.org/distro/gentoo/distfiles/:nosubdir
    http://files.gentoo.gr/distfiles/:nosubdir
    http://gentoo.inf.elte.hu/distfiles/:nosubdir
    http://ftp.rhnet.is/pub/gentoo/distfiles/:nosubdir
    http://ftp.heanet.ie/pub/gentoo/distfiles/:nosubdir
    http://mirror.cambrium.nl/pub/os/linux/gentoo/distfiles/:nosubdir
    http://gentoo.tiscali.nl/distfiles/:nosubdir
    http://mirror.gentoo.no/distfiles/:nosubdir
    http://gentoo.prz.rzeszow.pl/distfiles/:nosubdir
    http://darkstar.ist.utl.pt/gentoo/distfiles/:nosubdir
    http://mirrors.evolva.ro/gentoo/distfiles/:nosubdir
    http://gentoo-euetib.upc.es/mirror/gentoo/distfiles/:nosubdir
    http://ftp.ds.karen.hj.se/gentoo/distfiles/:nosubdir
    http://mirror.switch.ch/ftp/mirror/gentoo/distfiles/:nosubdir
    http://ftp.linux.org.tr/gentoo/distfiles/:nosubdir
    http://mirror.bytemark.co.uk/gentoo/distfiles/:nosubdir
    http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/:nosubdir
    http://gentoo.kiev.ua/ftp/distfiles/:nosubdir
    http://ftp.swin.edu.au/gentoo/distfiles/:nosubdir
    http://ftp.iij.ad.jp/pub/linux/gentoo/distfiles/:nosubdir
    http://mirror2.corbina.ru/gentoo-distfiles/distfiles/:nosubdir
    http://ftp.kaist.ac.kr/pub/gentoo/distfiles/:nosubdir
    http://ftp.ncnu.edu.tw/Linux/Gentoo/distfiles/:nosubdir
    http://gentoo.in.th/distfiles/:nosubdir
    http://mirror.isoc.org.il/pub/gentoo/distfiles/:nosubdir
    http://mirror.neolabs.kz/gentoo/pub/distfiles/:nosubdir
    http://mirror.facebook.net/gentoo/distfiles/:nosubdir
}

set portfetch::mirror_sites::sites(gimp) {
    http://ftp.gtk.org/pub/
    http://download.gimp.org/pub/
    http://artfiles.org/gimp.org/
    ftp://ftp.cc.uoc.gr/mirrors/gimp/
    http://ftp.gwdg.de/pub/misc/grafik/gimp/
    http://ftp.heanet.ie/mirrors/ftp.gimp.org/pub/
    ftp://ftp.is.co.za/mirror/ftp.gimp.org/
    http://ftp.iut-bm.univ-fcomte.fr/
    ftp://ftp.mirrorservice.org/sites/ftp.gimp.org/pub/
    http://ftp.nluug.nl/graphics/
    ftp://ftp.nluug.nl/pub/graphics/
    ftp://ftp.piotrkosoft.net/pub/mirrors/ftp.gimp.org/pub/
    ftp://ftp.rediris.es/mirror/
    ftp://ftp.sai.msu.su/pub/unix/graphics/gimp/mirror/
    http://ftp.snt.utwente.nl/pub/software/gimp/
    http://ftp.sunet.se/pub/gnu/
    ftp://ftp.tpnet.pl/pub/graphics/
    ftp://ftp.u-aizu.ac.jp/pub/graphics/tools/gimp/
    http://gimp.cp-dev.com/
    http://gimp.mirrors.hoobly.com/
    http://gimp.parentingamerica.com/
    http://gimp.raffsoftware.com/
    http://gimp.skazkaforyou.com/
    http://mirror.hessmo.com/
    http://mirror.ibcp.fr/pub/
    http://mirror.umd.edu/gimp/
    http://mirrors.dominios.pt/
    ftp://mirrors.fe.up.pt/mirrors/ftp.gimp.org/pub/
    http://mirrors.fe.up.pt/mirrors/ftp.gimp.org/pub/
    http://mirrors.serverhost.ro/
    http://mirrors.xmission.com/gimp/
    http://mirrors.zerg.biz/
    http://piotrkosoft.net/pub/mirrors/ftp.gimp.org/pub/
    ftp://sunsite.icm.edu.pl/pub/graphics/
    http://sunsite.rediris.es/mirror/
    http://www.mirrorservice.org/sites/ftp.gimp.org/pub/
    http://www.ring.gr.jp/pub/graphics/
}

set portfetch::mirror_sites::sites(gnome) {
    http://ftp.gnome.org/pub/GNOME/
    http://artfiles.org/gnome.org/
    http://fr2.rpmfind.net/linux/gnome.org/
    http://ftp.acc.umu.se/pub/GNOME/
    http://ftp.belnet.be/ftp.gnome.org/
    http://ftp.df.lth.se/pub/gnome/
    http://ftp.is.co.za/mirror/ftp.gnome.org/
    ftp://ftp.kddlabs.co.jp/pub/GNOME/
    http://ftp.nara.wide.ad.jp/pub/X11/GNOME/
    http://ftp.rpmfind.net/linux/gnome.org/
    http://ftp.sunet.se/pub/X11/GNOME/
    http://ftp1.nluug.nl/windowing/gnome/
    http://ftp2.nluug.nl/windowing/gnome/
    http://ftp2.uk.freebsd.org/sites/ftp.gnome.org/pub/GNOME/
    http://mirror.internode.on.net/pub/gnome/
    http://mirror.oss.maxcdn.com/gnome/
    http://mirror.umd.edu/gnome/
    http://mirrors.ustc.edu.cn/gnome/
    http://www.gtlib.gatech.edu/pub/gnome/
    http://www.mirrorservice.org/sites/ftp.gnome.org/pub/GNOME/
}

set portfetch::mirror_sites::sites(gnu) {
    http://mirrors.ibiblio.org/gnu/ftp/gnu/
    http://www.mirrorservice.org/sites/ftp.gnu.org/gnu/
    http://mirror.facebook.net/gnu/
    ftp://ftp.funet.fi/pub/gnu/prep/
    ftp://ftp.kddlabs.co.jp/pub/gnu/gnu/
    ftp://ftp.kddlabs.co.jp/pub/gnu/old-gnu/
    ftp://ftp.dti.ad.jp/pub/GNU/
    ftp://ftp.informatik.hu-berlin.de/pub/gnu/gnu/
    ftp://ftp.lip6.fr/pub/gnu/
    http://mirror.internode.on.net/pub/gnu/
    http://mirror.aarnet.edu.au/pub/gnu/
    ftp://ftp.unicamp.br/pub/gnu/
    ftp://ftp.gnu.org/gnu/
    http://ftp.gnu.org/gnu/
    ftp://ftp.gnu.org/old-gnu/
}

set portfetch::mirror_sites::sites(gnupg) {
    http://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/
    ftp://gd.tuwien.ac.at/privacy/gnupg/
    http://ftp.freenet.de/pub/ftp.gnupg.org/gcrypt/
    ftp://ftp.jyu.fi/pub/crypt/gcrypt/
    http://www.ring.gr.jp/pub/net/gnupg/
    ftp://ftp.gnupg.org/gcrypt/
}

set portfetch::mirror_sites::sites(gnustep) {
    http://ftpmain.gnustep.org/pub/gnustep/
    ftp://ftp.gnustep.org/pub/gnustep/
}

set portfetch::mirror_sites::sites(googlecode) {
    http://${name}.googlecode.com/files/
}

set portfetch::mirror_sites::sites(isc) {
    http://www.mirrorservice.org/sites/ftp.isc.org/isc/
    ftp://ftp.nominum.com/pub/isc/
    ftp://gd.tuwien.ac.at/infosys/servers/isc/
    http://ftp.arcane-networks.fr/pub/mirrors/ftp.isc.org/isc/
    ftp://ftp.ciril.fr/pub/isc/
    ftp://ftp.funet.fi/pub/mirrors/ftp.isc.org/isc/
    ftp://ftp.freenet.de/pub/ftp.isc.org/isc/
    ftp://ftp.fsn.hu/pub/isc/
    ftp://ftp.iij.ad.jp/pub/network/isc/
    ftp://ftp.dti.ad.jp/pub/net/isc/
    http://ftp.kaist.ac.kr/pub/isc/
    ftp://ftp.task.gda.pl/mirror/ftp.isc.org/isc/
    ftp://ftp.sunet.se/pub/network/isc/
    ftp://ftp.ripe.net/mirrors/sites/ftp.isc.org/isc/
    ftp://ftp.ntua.gr/pub/net/isc/isc/
    ftp://ftp.metu.edu.tr/pub/mirrors/ftp.isc.org/
    http://mirror.internode.on.net/pub/isc/
    ftp://ftp.isc.org/isc/
}

set portfetch::mirror_sites::sites(kde) {
    http://mirrors.mit.edu/kde/
    http://kde.mirrors.hoobly.com/
    http://ftp.gtlib.gatech.edu/pub/kde/
    http://www.mirrorservice.org/sites/ftp.kde.org/pub/kde/
    http://gd.tuwien.ac.at/kde/
    http://mirrors.isc.org/pub/kde/
    http://kde.mirrors.tds.net/pub/kde/
    ftp://ftp.solnet.ch/mirror/KDE/
    http://mirror.internode.on.net/pub/kde/
    http://mirror.aarnet.edu.au/pub/KDE/
    http://ftp.kddlabs.co.jp/pub/X11/kde/
    ftp://ftp.kde.org/pub/kde/
    http://mirror.facebook.net/kde/
}

set portfetch::mirror_sites::sites(macports) {
    http://svn.macports.org/repository/macports/distfiles/
}

set portfetch::mirror_sites::sites(macports_distfiles) {
    http://distfiles.macports.org/:mirror
    http://aarnet.au.distfiles.macports.org/pub/macports/mpdistfiles/:mirror
    http://cjj.kr.distfiles.macports.org/:mirror
    http://fco.it.distfiles.macports.org/mirrors/macports-distfiles/:mirror
    http://her.gr.distfiles.macports.org/mirrors/macports/mpdistfiles/:mirror
    http://jog.id.distfiles.macports.org/macports/mpdistfiles/:mirror
    http://lil.fr.distfiles.macports.org/:mirror
    http://mse.uk.distfiles.macports.org/sites/distfiles.macports.org/:mirror
    http://nue.de.distfiles.macports.org/macports/distfiles/:mirror
    http://osl.no.distfiles.macports.org/:mirror
    http://sea.us.distfiles.macports.org/macports/distfiles/:mirror
    http://ykf.ca.distfiles.macports.org/MacPorts/mpdistfiles/:mirror
}

set portfetch::mirror_sites::sites(netbsd) {
    http://ftp7.de.NetBSD.org/pub/ftp.netbsd.org/pub/NetBSD/
    http://ftp.fr.NetBSD.org/pub/NetBSD/
    ftp://ftp7.us.NetBSD.org/pub/NetBSD/
    ftp://ftp.uk.NetBSD.org/pub/NetBSD/
    ftp://ftp.tw.NetBSD.org/pub/NetBSD/
    ftp://ftp7.jp.NetBSD.org/pub/NetBSD/
    ftp://ftp.ru.NetBSD.org/pub/NetBSD/
    http://ftp.NetBSD.org/pub/NetBSD/
}

set portfetch::mirror_sites::sites(openbsd) {
    http://www.mirrorservice.org/sites/ftp.openbsd.org/pub/OpenBSD/
    ftp://carroll.cac.psu.edu/pub/OpenBSD/
    ftp://openbsd.informatik.uni-erlangen.de/pub/OpenBSD/
    ftp://gd.tuwien.ac.at/opsys/OpenBSD/
    http://ftp.ch.openbsd.org/pub/OpenBSD/
    ftp://ftp.stacken.kth.se/pub/OpenBSD/
    ftp://ftp3.usa.openbsd.org/pub/OpenBSD/
    ftp://rt.fm/pub/OpenBSD/
    ftp://ftp.openbsd.md5.com.ar/pub/OpenBSD/
    ftp://ftp.jp.openbsd.org/pub/OpenBSD/
    http://mirror.internode.on.net/pub/OpenBSD/
    http://mirror.aarnet.edu.au/pub/OpenBSD/
    ftp://ftp.openbsd.org/pub/OpenBSD/
}

set portfetch::mirror_sites::sites(perl_cpan) {
    http://mirrors.ibiblio.org/CPAN/modules/by-module/
    http://www.mirrorservice.org/sites/cpan.perl.org/CPAN/modules/by-module/
    ftp://ftp.funet.fi/pub/languages/perl/CPAN/modules/by-module/
    ftp://ftp.kddlabs.co.jp/lang/perl/CPAN/modules/by-module/
    ftp://ftp.sunet.se/pub/lang/perl/CPAN/modules/by-module/
    ftp://ftp.auckland.ac.nz/pub/perl/CPAN/modules/by-module/
    ftp://ftp.is.co.za/programming/perl/modules/by-module/
    http://mirror.internode.on.net/pub/cpan/modules/by-module/
    http://cpan.mirror.euserv.net/modules/by-module/
    http://cpan.mirrors.ilisys.com.au/modules/by-module/
    http://mirror.aarnet.edu.au/pub/CPAN/modules/by-module/
    http://mirror.cogentco.com/pub/CPAN/modules/by-module/
    http://mirror.ox.ac.uk/sites/www.cpan.org/modules/by-module/
    http://mirror.uoregon.edu/CPAN/modules/by-module/
    http://mirror.uta.edu/CPAN/modules/by-module/
    http://cpan.cs.utah.edu/modules/by-module/
    http://ftp.carnet.hr/pub/CPAN/modules/by-module/
    http://ftp.wayne.edu/CPAN/modules/by-module/
    ftp://ftp.cpan.org/pub/CPAN/modules/by-module/
}

# http://php.net/mirrors.php
# The country code domains without number suffix are supposed to redirect to
# an available mirror in that country. To update this list use:
# curl -s --compressed http://php.net/mirrors.php | sed -E -n 's,^.*http://([a-z]{2})[0-9]*(\.php\.net)/.*$,\1\2,p' | sort -u | xargs -n 1 -I % sh -c '{ curl -s --compressed --connect-timeout 30 -m 60 http://%/ | grep -iq "php group" && echo "    http://%/:nosubdir"; }' | tee /dev/tty | pbcopy
set portfetch::mirror_sites::sites(php) {
    http://am.php.net/:nosubdir
    http://ar.php.net/:nosubdir
    http://at.php.net/:nosubdir
    http://au.php.net/:nosubdir
    http://bd.php.net/:nosubdir
    http://be.php.net/:nosubdir
    http://bg.php.net/:nosubdir
    http://ca.php.net/:nosubdir
    http://ch.php.net/:nosubdir
    http://cl.php.net/:nosubdir
    http://cz.php.net/:nosubdir
    http://de.php.net/:nosubdir
    http://dk.php.net/:nosubdir
    http://ee.php.net/:nosubdir
    http://es.php.net/:nosubdir
    http://fi.php.net/:nosubdir
    http://fr.php.net/:nosubdir
    http://hk.php.net/:nosubdir
    http://hu.php.net/:nosubdir
    http://id.php.net/:nosubdir
    http://ie.php.net/:nosubdir
    http://il.php.net/:nosubdir
    http://in.php.net/:nosubdir
    http://ir.php.net/:nosubdir
    http://is.php.net/:nosubdir
    http://it.php.net/:nosubdir
    http://jm.php.net/:nosubdir
    http://jp.php.net/:nosubdir
    http://kr.php.net/:nosubdir
    http://li.php.net/:nosubdir
    http://lu.php.net/:nosubdir
    http://lv.php.net/:nosubdir
    http://md.php.net/:nosubdir
    http://mx.php.net/:nosubdir
    http://my.php.net/:nosubdir
    http://nc.php.net/:nosubdir
    http://nl.php.net/:nosubdir
    http://no.php.net/:nosubdir
    http://nz.php.net/:nosubdir
    http://pa.php.net/:nosubdir
    http://pk.php.net/:nosubdir
    http://pl.php.net/:nosubdir
    http://pt.php.net/:nosubdir
    http://ro.php.net/:nosubdir
    http://ru.php.net/:nosubdir
    http://se.php.net/:nosubdir
    http://sg.php.net/:nosubdir
    http://th.php.net/:nosubdir
    http://tr.php.net/:nosubdir
    http://tw.php.net/:nosubdir
    http://tz.php.net/:nosubdir
    http://ua.php.net/:nosubdir
    http://uk.php.net/:nosubdir
    http://us.php.net/:nosubdir
}

set portfetch::mirror_sites::sites(postgresql) {
    http://ftp.postgresql.org/pub/
    http://www.mirrorservice.org/sites/ftp.postgresql.org/
    http://ftp7.de.postgresql.org/ftp.postgresql.org/
    ftp://ftp2.ch.postgresql.org/pub/mirrors/postgresql
    ftp://ftp.de.postgresql.org/mirror/postgresql/
    ftp://ftp.fr.postgresql.org/
    http://mirror.aarnet.edu.au/pub/postgresql/
    ftp://ftp2.au.postgresql.org/pub/postgresql/
    ftp://ftp.ru.postgresql.org/pub/unix/database/pgsql/
    ftp://ftp.postgresql.org/pub/
}

# Note that mirror_sites aren't intelligent enough to handle how this should
# work automatically (which is, append first letter of port name, then
# port name) so just use a basic form here and fake it in ports that need
# to use this.
set portfetch::mirror_sites::sites(pypi) {
    https://pypi.python.org/packages/source/:nosubdir
}

set portfetch::mirror_sites::sites(ruby) {
    http://mirrors.ibiblio.org/ruby/
    http://www.mirrorservice.org/sites/ftp.ruby-lang.org/pub/ruby/
    ftp://xyz.lcs.mit.edu/pub/ruby/
    ftp://ftp.iij.ad.jp/pub/lang/ruby/
    ftp://ftp.fu-berlin.de/unix/languages/ruby/
    ftp://ftp.easynet.be/ruby/ruby/
    ftp://ftp.ntua.gr/pub/lang/ruby/
    ftp://ftp.iDaemons.org/pub/mirror/ftp.ruby-lang.org/ruby/
    http://ftp.ruby-lang.org/pub/ruby/
    ftp://ftp.ruby-lang.org/pub/ruby/
}

set portfetch::mirror_sites::sites(savannah) {
    http://download.savannah.gnu.org/releases-noredirect/
    http://ftp.cc.uoc.gr/mirrors/nongnu.org/
    http://ftp.twaren.net/Unix/NonGNU/
    ftp://ftp.twaren.net/Unix/NonGNU/
    http://mirror.csclub.uwaterloo.ca/nongnu/
    ftp://mirror.csclub.uwaterloo.ca/nongnu/
    http://mirrors.openfountain.cl/savannah/
    http://mirrors.zerg.biz/nongnu/
    http://savannah.c3sl.ufpr.br/
    ftp://savannah.c3sl.ufpr.br/savannah-nongnu/
}
# Alias nongnu to savannah
set portfetch::mirror_sites::sites(nongnu) $portfetch::mirror_sites::sites(savannah)

# https://sourceforge.net/p/forge/documentation/Mirrors/
set portfetch::mirror_sites::sites(sourceforge) {
    http://freefr.dl.sourceforge.net/
    http://heanet.dl.sourceforge.net/
    http://internode.dl.sourceforge.net/
    http://iweb.dl.sourceforge.net/
    http://jaist.dl.sourceforge.net/
    http://kent.dl.sourceforge.net/
    http://liquidtelecom.dl.sourceforge.net/
    http://nbtelecom.dl.sourceforge.net/
    http://nchc.dl.sourceforge.net/
    http://ncu.dl.sourceforge.net/
    http://netassist.dl.sourceforge.net/
    http://netcologne.dl.sourceforge.net/
    http://netix.dl.sourceforge.net/
    http://skylineservers.dl.sourceforge.net/
    http://skylink.dl.sourceforge.net/
    http://superb-dca2.dl.sourceforge.net/
    http://tcpdiag.dl.sourceforge.net/
    http://tenet.dl.sourceforge.net/
    http://ufpr.dl.sourceforge.net/
    http://vorboss.dl.sourceforge.net/
}

set portfetch::mirror_sites::sites(sourceforge_jp) {
    http://iij.dl.sourceforge.jp/
    http://osdn.dl.sourceforge.jp/
    http://jaist.dl.sourceforge.jp/
    http://keihanna.dl.sourceforge.jp/
    http://globalbase.dl.sourceforge.jp/
}

set portfetch::mirror_sites::sites(sunsite) {
    http://www.ibiblio.org/pub/Linux/
    http://www.gtlib.gatech.edu/pub/Linux/
    ftp://sunsite.unc.edu/pub/Linux/
    ftp://ftp.unicamp.br/pub/systems/Linux/
    ftp://ftp.tuwien.ac.at/pub/linux/ibiblio/
    ftp://ftp.cs.tu-berlin.de/pub/linux/Mirrors/sunsite.unc.edu/
    ftp://ftp.lip6.fr/pub/linux/sunsite/
    http://ftp.nluug.nl/pub/sunsite/
    ftp://ftp.nvg.ntnu.no/pub/mirrors/metalab.unc.edu/
    ftp://ftp.icm.edu.pl/vol/rzm1/linux-ibiblio/
    ftp://ftp.cse.cuhk.edu.hk/pub4/Linux/
    ftp://ftp.kddlabs.co.jp/Linux/metalab.unc.edu/
}

set portfetch::mirror_sites::sites(tcltk) {
    http://www.mirrorservice.org/sites/ftp.tcl.tk/pub/tcl/
    ftp://mirror.switch.ch/mirror/tcl.tk/
    ftp://ftp.informatik.uni-hamburg.de/pub/soft/lang/tcl/
    ftp://ftp.funet.fi/pub/languages/tcl/tcl/
    ftp://ftp.kddlabs.co.jp/lang/tcl/ftp.scriptics.com/
    http://www.etsimo.uniovi.es/pub/mirrors/ftp.scriptics.com/
    ftp://ftp.tcl.tk/pub/tcl/
}

set portfetch::mirror_sites::sites(tex_ctan) {
    http://mirrors.ibiblio.org/CTAN/
    http://ctan.math.utah.edu/ctan/tex-archive/
    ftp://ftp.funet.fi/pub/TeX/CTAN/
    http://mirror.internode.on.net/pub/ctan/
    ftp://ctan.unsw.edu.au/tex-archive/
    http://mirror.aarnet.edu.au/pub/CTAN/
    ftp://ftp.kddlabs.co.jp/CTAN/
    ftp://mirror.macomnet.net/pub/CTAN/
    http://ftp.sun.ac.za/ftp/CTAN/
    http://ftp.inf.utfsm.cl/pub/tex-archive/
    ftp://ftp.tex.ac.uk/tex-archive/
    ftp://ftp.dante.de/tex-archive/
    ftp://ctan.tug.org/tex-archive/
}

set portfetch::mirror_sites::sites(trolltech) {
    http://releases.qt-project.org/qt4/source/:nosubdir
    http://ftp.heanet.ie/mirrors/ftp.trolltech.com/pub/qt/source/:nosubdir
    ftp://ftp.informatik.hu-berlin.de/pub1/Mirrors/ftp.troll.no/QT/qt/source/:nosubdir
    http://ftp.iasi.roedu.net/mirrors/ftp.trolltech.com/qt/source/:nosubdir
    http://ftp.ntua.gr/pub/X11/Qt/qt/source/:nosubdir
    http://get.qt.nokia.com/qt/source/:nosubdir
    ftp://ftp.trolltech.com/qt/source/:nosubdir
}

set portfetch::mirror_sites::sites(xcontrib) {
    ftp://ftp.net.ohio-state.edu/pub/X11/contrib/
    http://www.mirrorservice.org/sites/ftp.x.org/contrib/
    ftp://ftp.gwdg.de/pub/x11/x.org/contrib/
    http://mirror.aarnet.edu.au/pub/X11/contrib/
    ftp://ftp2.x.org/contrib/
    ftp://ftp.x.org/contrib/
}

set portfetch::mirror_sites::sites(xfree) {
    http://www.gtlib.gatech.edu/pub/XFree86/
    http://www.mirrorservice.org/sites/ftp.xfree86.org/pub/XFree86/
    http://ftp-stud.fht-esslingen.de/pub/Mirrors/ftp.xfree86.org/XFree86/
    ftp://ftp.fit.vutbr.cz/pub/XFree86/
    ftp://ftp.gwdg.de/pub/xfree86/XFree86/
    ftp://ftp.esat.net/pub/X11/XFree86/
    ftp://ftp.physics.uvt.ro/pub/XFree86/
    http://mirror.aarnet.edu.au/pub/xfree86/
    ftp://ftp.xfree86.org/pub/XFree86/
}

set portfetch::mirror_sites::sites(xorg) {
    http://mirror.csclub.uwaterloo.ca/x.org/
    http://www.mirrorservice.org/sites/ftp.x.org/pub/
    http://mirror.switch.ch/ftp/mirror/X11/pub/
    ftp://ftp.gwdg.de/pub/x11/x.org/pub/
    http://ftp.cica.es/mirrors/X/pub/
    ftp://ftp.ntua.gr/pub/X11/X.org/
    ftp://ftp.cs.cuhk.edu.hk/pub/X11/
    http://mi.mirror.garr.it/mirrors/x.org/
    http://ftp.nara.wide.ad.jp/pub/X11/x.org/
    ftp://sunsite.uio.no/pub/X11/
    ftp://ftp.sunet.se/pub/X11/ftp.x.org/
    http://x.cs.pu.edu.tw/
    ftp://ftp.is.co.za/pub/x.org/pub/
    http://xorg.freedesktop.org/archive/
    http://xorg.freedesktop.org/releases/
    http://www.x.org/pub/
    ftp://ftp.x.org/pub/
}

# MySQL Mirrors
# To update this list use:
# $ curl -s http://dev.mysql.com/downloads/mirrors.html | grep -E '>HTTP<' | sed -e 's,.*href="\(.*\)">.*,    \1/Downloads/:nosubdir,g' -e 's,//Downloads/:nosubdir,/Downloads/:nosubdir,g' | sort -u
# To remove bad mirrors look at this inexpensive output:
# $ for port in mysql{5,51,55,56} ; do echo "port: ${port}" ; for mirror in $(port distfiles $port | grep -v macports | grep -E "^ *(http|ftp)://") ; do echo $mirror ; curl -sI $mirror | grep -E "(^213|Content-Length)" | sed -e '/Content-Length/ s/.*: //' -e '/213/ s/.* //' ; done ; done
set portfetch::mirror_sites::sites(mysql) {
    http://artfiles.org/mysql/Downloads/:nosubdir
    http://ftp.arnes.si/mysql/Downloads/:nosubdir
    http://ftp.gwdg.de/pub/misc/mysql/Downloads/:nosubdir
    http://ftp.heanet.ie/mirrors/www.mysql.com/Downloads/:nosubdir
    http://ftp.iij.ad.jp/pub/db/mysql/Downloads/:nosubdir
    http://ftp.jaist.ac.jp/pub/mysql/Downloads/:nosubdir
    http://ftp.ntua.gr/pub/databases/mysql/Downloads/:nosubdir
    http://ftp.sunet.se/pub/unix/databases/relational/mysql/Downloads/:nosubdir
    http://gd.tuwien.ac.at/db/mysql/Downloads/:nosubdir
    http://linorg.usp.br/mysql/Downloads/:nosubdir
    http://mirror.csclub.uwaterloo.ca/mysql/Downloads/:nosubdir
    http://mirror.leaseweb.com/mysql/Downloads/:nosubdir
    http://mirror.switch.ch/ftp/mirror/mysql/Downloads/:nosubdir
    http://mirror.trouble-free.net/mysql_mirror/Downloads/:nosubdir
    http://mirrors.dedipower.com/www.mysql.com/Downloads/:nosubdir
    http://mirrors.dotsrc.org/mysql/Downloads/:nosubdir
    http://mirrors.ircam.fr/pub/mysql/Downloads/:nosubdir
    http://mirrors.ukfast.co.uk/sites/ftp.mysql.com/Downloads/:nosubdir
    http://mirrors.xservers.ro/mysql/Downloads/:nosubdir
    http://mysql.he.net/Downloads/:nosubdir
    http://mysql.infocom.ua/Downloads/:nosubdir
    http://mysql.inspire.net.nz/Downloads/:nosubdir
    http://mysql.linux.cz/Downloads/:nosubdir
    http://mysql.mirror.ac.za/Downloads/:nosubdir
    http://mysql.mirror.kangaroot.net/Downloads/:nosubdir
    http://mysql.mirrors.arminco.com/Downloads/:nosubdir
    http://mysql.mirrors.crysys.hit.bme.hu/Downloads/:nosubdir
    http://mysql.mirrors.hoobly.com/Downloads/:nosubdir
    http://mysql.mirrors.ovh.net/ftp.mysql.com/Downloads/:nosubdir
    http://mysql.mirrors.pair.com/Downloads/:nosubdir
    http://mysql.spd.co.il/Downloads/:nosubdir
    http://na.mirror.garr.it/mirrors/MySQL/Downloads/:nosubdir
    http://sunsite.icm.edu.pl/mysql/Downloads/:nosubdir
    http://www.linorg.usp.br/mysql/Downloads/:nosubdir
    http://www.mirrorservice.org/sites/ftp.mysql.com/Downloads/:nosubdir
}
