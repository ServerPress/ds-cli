#!/bin/bash
#
# Boot native CLI
#
unset HISTFILE;
export DS_CLI="/Applications/XAMPP/ds-plugins/ds-cli"
export DYLD_FALLBACK_LIBRARY_PATH="$DS_CLI/platform/mac/macports/lib:/Applications/XAMPP/xamppfiles/lib:/usr/lib"
export PATH="$DS_CLI/platform/all/pre:$DS_CLI/platform/mac/pre:$DS_CLI/vendor/bin:$DS_CLI/platform/mac/git/bin:$DS_CLI/platform/mac/macports/bin:/Applications/XAMPP/xamppfiles/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:$PATH"
export TERMINFO="$DS_CLI/platform/mac/macports/share/terminfo"
unset DYLD_LIBRARY_PATH
"$@"
