IMAGES := \
	images/elf.svg \
	images/elf_ident.svg \
	images/program_header_entry.svg \
	images/program_header_entry_flags.svg

.PHONY: all
all: $(IMAGES)

.PHONY: clean
clean:
	rm -fr build

build:
	mkdir -p build

build/%.dvi: diagrams/%.tex | build
	latex -output-directory=build $<

images/%.svg: build/%.dvi
	dvisvgm -o $@ $<
