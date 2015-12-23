# $Id: Makefile 73040 2010-11-01 23:21:19Z ryandesign@macports.org $

.PHONY: all clean

all: clit/clit

clean:
	$(MAKE) clean -C lib
	$(MAKE) clean -C clit

lib/openclit.a:
	$(MAKE) -C lib

clit/clit: lib/openclit.a
	$(MAKE) -C clit
