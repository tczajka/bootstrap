IMAGES := $(patsubst diagrams/%.tex,images/%.svg,$(wildcard diagrams/*/*.tex))

.PHONY: all
all: $(IMAGES)

.PHONY: clean
clean:
	rm -fr build

build:
	mkdir -p build build/elf build/x86-64

build/%.dvi: diagrams/%.tex | build
	latex -output-directory=$(dir $@) $<

images/%.svg: build/%.dvi
	dvisvgm -b 1pt -o $@ $<
