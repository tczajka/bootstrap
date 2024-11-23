SHELL:=/bin/bash
# .DELETE_ON_ERROR:

.PHONY: all
all: bin/hello.2 bin/asm.2

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

bin/hello.2: src/hello.2.asm bin/asm.1 bin/hello.1
	bin/asm.1 < $< > $@
	cmp $@ bin/hello.1
	chmod u+x $@

bin/asm.2: src/asm.2.asm bin/asm.1
	bin/asm.1 < $< > $@
	cmp $@ bin/asm.1
	chmod u+x $@
