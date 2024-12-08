SHELL:=/bin/bash
# .DELETE_ON_ERROR:

.PHONY: all
all: build/hello.2 build/asm.2

.PHONY: clean
clean:
	rm -fr build

build:
	mkdir -p build

build/hello.1: src/hello.1.echo | build
	echo -en `cat $<` > $@
	chmod u+x $@

build/asm.1: src/asm.1.echo | build
	echo -en `cat $<` > $@
	chmod u+x $@

build/hello.2: src/hello.2.asm build/asm.1 build/hello.1
	build/asm.1 < $< > $@
	cmp $@ build/hello.1
	chmod u+x $@

build/asm.2: src/asm.2.asm build/asm.1
	build/asm.1 < $< > $@
	cmp $@ build/asm.1
	chmod u+x $@
