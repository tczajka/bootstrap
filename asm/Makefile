.DELETE_ON_ERROR:

.PHONY: all clean
all: hello.1.list

clean:
	rm -f *.list

%.list: %.asm
	nasm -l $@ $<
