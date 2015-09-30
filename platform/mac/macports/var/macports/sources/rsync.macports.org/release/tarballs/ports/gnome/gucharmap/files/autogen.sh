#!/bin/sh
# Run this to generate all the initial makefiles, etc.

set -e

srcdir=`dirname $0`
test -z "$srcdir" && srcdir=.

cd "$srcdir"
mkdir -p m4 >/dev/null 2>&1 || true
gtkdocize --copy --flavour no-tmpl
autoreconf --verbose --force --install
intltoolize --force
cd -

test -n "$NOCONFIGURE" || "$srcdir/configure" "$@"
