lib_LTLIBRARIES = libturing.la
libturing_la_SOURCES = turing.l turingGram.y parseTuringConfig.c
libturing_la_LDFLAGS = -version-info 1:0:0
include_HEADERS = ../include/turingParserTypes.h ../include/parseTuringConfig.h ../include/tokenDef.h ../include/turingGram.h

AM_YFLAGS = --defines=$(PWD)/../include/turingGram.h

clean-local:
	-rm -rf turing.c turingGram.c 


