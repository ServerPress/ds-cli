# $Id: archive_sites.tcl 116701 2014-02-04 00:31:45Z cal@macports.org $

namespace eval portfetch::mirror_sites { }

set portfetch::mirror_sites::sites(macports_archives) {
    http://packages.macports.org/:nosubdir
    http://lil.fr.packages.macports.org/:nosubdir
    http://nue.de.packages.macports.org/macports/packages/:nosubdir
    http://mse.uk.packages.macports.org/sites/packages.macports.org/:nosubdir
    http://jog.id.packages.macports.org/macports/packages/:nosubdir
}

set portfetch::mirror_sites::archive_type(macports_archives) tbz2
set portfetch::mirror_sites::archive_prefix(macports_archives) /opt/local
set portfetch::mirror_sites::archive_frameworks_dir(macports_archives) /opt/local/Library/Frameworks
set portfetch::mirror_sites::archive_applications_dir(macports_archives) /Applications/MacPorts
