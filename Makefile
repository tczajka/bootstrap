SHELL:=/bin/bash
.DELETE_ON_ERROR:

.PHONY: all
all: bin/hello.2 bin/octal.2

.PHONY: clean
clean:
	rm -fr bin

bin:
	mkdir -p bin

bin/hello.1: src/hello.1.echo | bin
	echo -en `cat $<` > $@
	chmod u+x $@

bin/octal.1: | bin
	echo -en "\
\x7fELF\x1\x1\x1\0\0\0\0\0\0\0\0\0\x2\0\x3\0\x1\0\0\0\
\x54\0\x10\0\x34\0\0\0\0\0\0\0\0\0\0\0\x34\0\x20\0\x1\0\0\0\0\0\0\0\
\x1\0\0\0\x54\0\0\0\x54\0\x10\0\0\0\0\0\x97\0\0\0\x98\0\0\0\x7\0\0\0\x0\x10\0\0\
\0271\x97\0\x10\0\0272\x1\0\0\0\063\0377\0270\x3\0\0\0\063\0333\0315\x80\
\0205\0300\x7f\x9\0270\x1\0\0\0\063\0333\0315\x80\
\0212\01\00540\074\010\x73\x7\0301\0347\x3\03\0370\0353\xdb\
\0213\0307\0210\01\0270\x4\0\0\0\0273\x1\0\0\0\0315\x80\0353\xc7" > $@
	chmod u+x $@

bin/hello.2: bin/octal.1 src/hello.2.octal bin/hello.1 | bin
	bin/octal.1 < src/hello.2.octal > $@
	cmp $@ bin/hello.1
	chmod u+x $@

bin/octal.2: bin/octal.1 src/octal.2.octal | bin
	bin/octal.1 < src/octal.2.octal > $@
	cmp $@ bin/octal.1
	chmod u+x $@

