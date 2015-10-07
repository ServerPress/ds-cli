# -*- coding: utf-8; mode: tcl; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- vim:fenc=utf-8:filetype=tcl:et:sw=4:ts=4:sts=4
# macports-autoconf.tcl.in
# $Id: macports_autoconf.tcl.in 113478 2013-11-17 12:54:58Z raimue@macports.org $
#
# Copyright (c) 2006 - 2009, 2011 The MacPorts Project
# Copyright (c) 2002 - 2003 Apple Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of Apple Inc. nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
package provide macports 1.0

namespace eval macports::autoconf {
    variable bzip2_path "/usr/bin/bzip2"
    variable chown_path "/usr/sbin/chown"
    variable gzip_path "/usr/bin/gzip"
    variable macports_conf_path "/opt/local/etc/macports"
    variable macports_version "2.3.4"
    variable macports_user_dir "~/.macports"
    variable macportsuser "macports"
    variable mdfind_path "/usr/bin/mdfind"
    variable mdls_path "/usr/bin/mdls"
    variable open_path "/usr/bin/open"
    variable openssl_path "/usr/bin/openssl"
    variable pax_path "/bin/pax"
    variable rsync_path "/usr/bin/rsync"
    variable tar_command "/usr/bin/gnutar --no-same-owner"
    variable tar_path "/usr/bin/tar"
    variable tar_q "q"
    variable unzip_path "/usr/bin/unzip"
    variable xar_path "/usr/bin/xar"
    variable xcode_select_path "/usr/bin/xcode-select"
    variable xcodebuild_path "/usr/bin/xcodebuild"
    variable os_platform "darwin"
    variable os_major "12"
}
