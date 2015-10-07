GENCCODE_ASSEMBLY_TYPE=-a gcc-darwin
SO=dylib
SOBJ=dylib
A=a
LIBPREFIX=lib
LIB_EXT_ORDER=.55.1.dylib
COMPILE=/usr/bin/clang -DU_ATTRIBUTE_DEPRECATED=   -DU_HAVE_ATOMIC=0  -O2 -pipe -Os -std=c99 -Wall -pedantic -Wshadow -Wpointer-arith -Wmissing-prototypes -Wwrite-strings   -fno-common -c
LIBFLAGS=-I/opt/local/include  -dynamic
GENLIB=/usr/bin/clang -dynamiclib -dynamic -O2 -pipe -Os -std=c99 -Wall -pedantic -Wshadow -Wpointer-arith -Wmissing-prototypes -Wwrite-strings    
LDICUDTFLAGS=
LD_SONAME=-Wl,-compatibility_version -Wl,55 -Wl,-current_version -Wl,55.1 -install_name /opt/local/lib/
RPATH_FLAGS=
BIR_LDFLAGS=
AR=ar
ARFLAGS=r -c
RANLIB=ranlib
INSTALL_CMD=/usr/bin/install -c
