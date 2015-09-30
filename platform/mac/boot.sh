#!/bin/bash
#
# Boot native CLI
#
unset HISTFILE;
export DYLD_FALLBACK_LIBRARY_PATH="/Applications/XAMPP/ds-plugins/ds-cli/platform/mac/macports/lib:/Applications/XAMPP/xamppfiles/lib:/usr/lib"
export PATH="/Applications/XAMPP/ds-plugins/ds-cli/vendor/bin:/Applications/XAMPP/ds-plugins/ds-cli/platform/mac/macports/bin:/Applications/XAMPP/xamppfiles/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:$PATH"
export TERMINFO="/Applications/XAMPP/ds-plugins/ds-cli/platform/mac/macports/share/terminfo"
unset DYLD_LIBRARY_PATH
"$@"
