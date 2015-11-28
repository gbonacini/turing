lib_LTLIBRARIES = libturing.la
libturing_la_SOURCES = turing.l turingGram.y parseTuringConfig.c
libturing_la_LDFLAGS = -version-info 1:0:0
include_HEADERS = ../include/turingParserTypes.h ../include/parseTuringConfig.h ../include/tokenDef.h 

#AM_YFLAGS = --defines=$(PWD)/../include/turingGram.h
#AM_YFLAGS = -d turingGram.y -o ../include/turingGram.h

BUILT_SOURCES = turingGram.h

turingGram.h: turingGram.y Makefile
	${YACC} -d turingGram.y -o ../include/turingGram.h

clean-local:
	-rm -rf turing.c turingGram.c ../include/turingGram.h
