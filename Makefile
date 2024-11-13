SHELL:=/bin/bash
.DELETE_ON_ERROR:

.PHONY: all
all: hello.1.0

.PHONY: clean
clean:
	rm -f hello.?.?

hello.1.0: Makefile
	echo -en "\
\x7fELF\x1\x1\x1\x4\0\0\0\0\0\0\0\0\x2\0\x3\0\x1\0\0\0\
\x54\0\x1\0\x34\0\0\0\0\0\0\0\0\0\0\0\x34\0\x20\0\x1\0\0\0\0\0\0\0\
\x1\0\0\0\x54\0\0\0\x54\0\x1\0\0\0\0\0\x60\0\0\0\x60\0\0\0\x7\0\0\0\x0\x10\0\0\
\0270\x1\0\0\0\0273\x11\0\0\0\0315\x80" > hello.1.0
	chmod u+x hello.1.0
