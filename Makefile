SHELL:=/bin/bash
.DELETE_ON_ERROR:

.PHONY: all
all: bin/hello.1 bin/asm.1

.PHONY: clean
clean:
	rm -fr bin

bin:
	mkdir -p bin

bin/hello.1: src/hello.1.echo | bin
	echo -en `cat $<` > $@
	chmod u+x $@

bin/asm.1: src/asm.1.echo | bin
	echo -en `cat $<` > $@
	chmod u+x $@
