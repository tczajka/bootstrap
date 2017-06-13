SHELL:=/bin/bash

.PHONY: all
all: bin/nothing.0 bin/hello.0

bin:
	mkdir -p bin

.PHONY: clean
clean:
	rm -fr bin/

bin/nothing.0: bin
	echo -en '\x7fELF\x1\x1\x1\0\0\0\0\0\0\0\0\0\x2\0\x3\0\x1\0\0\0\x54\0\x1\0\x34\0\0\0\0\0\0\0\0\0\0\0\x34\0\x20\0\x1\0\x28\0\0\0\0\0\x1\0\0\0\x54\0\0\0\x54\0\x1\0\0\0\0\0\xc\0\0\0\xc\0\0\0\x5\0\0\0\0\x10\0\0\xb8\x1\0\0\0\xbb\x7\0\0\0\xcd\x80' > bin/nothing.0
	chmod u+x bin/nothing.0

bin/hello.0: bin
	echo -en '\x7fELF\x1\x1\x1\0\0\0\0\0\0\0\0\0\x2\0\x3\0\x1\0\0\0\x54\0\x1\0\x34\0\0\0\0\0\0\0\0\0\0\0\x34\0\x20\0\x1\0\x28\0\0\0\0\0\x1\0\0\0\x54\0\0\0\x54\0\x1\0\0\0\0\0\x40\0\0\0\x40\0\0\0\x5\0\0\0\0\x10\0\0\xbe\x86\0\x1\0\xb8\0\0\0\0\x8a\x6\x23\xc0\x74\x16\xb8\x4\0\0\0\xbb\x1\0\0\0\x8b\xce\xba\x1\0\0\0\xcd\x80\x46\xeb\xdf\xb8\x1\0\0\0\xbb\0\0\0\0\xcd\x80Hello World!\n\0' > bin/hello.0
	chmod u+x bin/hello.0
