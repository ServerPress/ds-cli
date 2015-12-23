# et:ts=4
# python25-1.0.tcl
#
# $Id: python25-1.0.tcl 125961 2014-09-30 11:47:49Z jmr@macports.org $
#
# Copyright (c) 2007 Markus W. Weissman <mww@macports.org>,
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of Apple Computer, Inc. nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

pre-fetch {
    ui_error "The $name port is using the obsolete 'python25'\
PortGroup. The maintainer should switch to the 'python' PortGroup."
    error "obsolete PortGroup"
}

set python.branch	2.5
set python.bin		${prefix}/bin/python${python.branch}
set python.lib		${prefix}/lib/libpython${python.branch}.dylib
set python.libdir	${prefix}/lib/python${python.branch}
set python.pkgd		${prefix}/lib/python${python.branch}/site-packages
set python.include	${prefix}/include/python${python.branch}

categories		python

dist_subdir		python

# we want the default universal variant added despite not using configure
use_configure	no
universal_variant yes

build.cmd		${python.bin} setup.py --no-user-cfg
build.target	build
options python.add_archflags
default python.add_archflags yes

destroot.cmd	${python.bin} setup.py --no-user-cfg
destroot.destdir	--prefix=${prefix} --root=${destroot}

options         python.move_binaries python.move_binaries_suffix
default python.move_binaries yes
default python.move_binaries_suffix {-${python.branch}}
