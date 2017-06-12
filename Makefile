SHELL:=/bin/bash

.PHONY: all
all: bin/seven0

bin:
	mkdir -p bin

.PHONY: clean
clean:
	rm -fr bin/

bin/seven0: bin
	echo -en '\x7fELF\x1\x1\x1\0\0\0\0\0\0\0\0\0\x2\0\x3\0\x1\0\0\0\x54\x80\x4\x8\x34\0\0\0\0\0\0\0\0\0\0\0\x34\0\x20\0\x1\0\x28\0\0\0\0\0\x1\0\0\0\x54\0\0\0\x54\x80\x4\x8\0\0\0\0\xc\0\0\0\xc\0\0\0\x5\0\0\0\0\x10\0\0\xb8\x1\0\0\0\xbb\x7\0\0\0\xcd\x80' > bin/seven0
	chmod u+x bin/seven0
