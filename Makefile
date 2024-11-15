SHELL:=/bin/bash
# .DELETE_ON_ERROR:

.PHONY: all
all: hello.2 octal.2

.PHONY: clean
clean:
	find . -type f -executable -delete

hello.1:
	echo -en "\
\x7fELF\x1\x1\x1\0\0\0\0\0\0\0\0\0\x2\0\x3\0\x1\0\0\0\
\x54\0\x10\0\x34\0\0\0\0\0\0\0\0\0\0\0\x34\0\x20\0\x1\0\0\0\0\0\0\0\
\x1\0\0\0\x54\0\0\0\x54\0\x10\0\0\0\0\0\x60\0\0\0\x60\0\0\0\x7\0\0\0\x0\x10\0\0\
\0270\x1\0\0\0\0273\x11\0\0\0\0315\x80" > hello.1
	chmod u+x hello.1

octal.1:
	echo -en "\
\x7fELF\x1\x1\x1\0\0\0\0\0\0\0\0\0\x2\0\x3\0\x1\0\0\0\
\x54\0\x10\0\x34\0\0\0\0\0\0\0\0\0\0\0\x34\0\x20\0\x1\0\0\0\0\0\0\0\
\x1\0\0\0\x54\0\0\0\x54\0\x10\0\0\0\0\0\x97\0\0\0\x98\0\0\0\x7\0\0\0\x0\x10\0\0\
\0271\x97\0\x10\0\0272\x1\0\0\0\063\0377\0270\x3\0\0\0\063\0333\0315\x80\
\0205\0300\x7f\x9\0270\x1\0\0\0\063\0333\0315\x80\
\0212\01\00540\074\010\x73\x7\0301\0347\x3\03\0370\0353\xdb\
\0213\0307\0210\01\0270\x4\0\0\0\0273\x1\0\0\0\0315\x80\0353\xc7" > octal.1
	chmod u+x octal.1

hello.2: octal.1 hello.2.octal hello.1
	./octal.1 < hello.2.octal > hello.2
	cmp hello.2 hello.1
	chmod u+x hello.2

octal.2.bootstrap: octal.1 octal.2.octal
	./octal.1 < octal.2.octal > octal.2.bootstrap
	cmp octal.2.bootstrap octal.1
	chmod u+x octal.2.bootstrap

octal.2: octal.2.bootstrap octal.2.octal
	./octal.2.bootstrap < octal.2.octal > octal.2
	cmp octal.2 octal.2.bootstrap
	chmod u+x octal.2

