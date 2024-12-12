IMAGES := \
	images/elf.svg \
	images/elf_ident.svg \
	images/program_header_entry.svg \
	images/program_header_entry_flags.svg \
	images/mov.svg \
	images/modrm_00.svg \
	images/modrm_00_example.svg \
	images/modrm_01.svg \
	images/modrm_10.svg \
	images/modrm_11.svg \

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
	dvisvgm -b 1pt -o $@ $<
