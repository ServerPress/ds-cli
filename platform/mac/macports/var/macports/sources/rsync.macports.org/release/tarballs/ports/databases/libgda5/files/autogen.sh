#!/bin/sh
# Run this to generate all the initial makefiles, etc.

srcdir=`dirname $0`
test -z "$srcdir" && srcdir=.

PKG_NAME="GNOME Data Access"

(test -f $srcdir/configure.ac \
  && test -d $srcdir/libgda \
  && test -f $srcdir/libgda/gda-config.h) || {
    echo -n "**Error**: Directory "\`$srcdir\'" does not look like the"
    echo " top-level GDA directory"
    exit 1
}

which gnome-autogen.sh || {
    echo "You need to install gnome-common package"
    exit 1
}

# Work around usage of gettext macros (AM_ICONV) without calling gettextize.
# intltoolize is used intead. https://bugzilla.gnome.org/show_bug.cgi?id=660537
touch config.rpath

USE_GNOME2_MACROS=1 USE_COMMON_DOC_BUILD=yes . gnome-autogen.sh
