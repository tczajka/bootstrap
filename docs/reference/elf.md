# ELF file format

[TOC]

Executable files on Linux follow the ELF file format.

ELF files describe several types of files (executable programs, shared libraries,
linkable object files, etc) for various architectures and operating systems. We are interested
in x86-64 executable programs for Linux.

# ELF Header

A 64-bit ELF file starts with a header containing `#40` = 64 bytes:

![ELF header](../images/elf/elf.svg)

`e_ident`:
![`e\_ident`](../images/elf/elf_ident.svg)

The fields are:

* `e_ident`: 16-byte file type identifier:
    * A 4-byte magic number `#7F "ELF"`: this identifies ELF files.
    * `EI_CLASS` = `ELFCLASS64` = 2: 64-bit architecture.
    * `EI_DATA` = `ELFDATA2LSB` = 1: little-endian architecture.
    * `EI_VERSION` = 1: ELF specification version.
    * `EI_OSABI` = `ELFOSABI_SYSV` = 0: UNIX System V ABI.
    * `EI_ABIVERSION` = 0: version 0 for UNIX System V ABI.
    * 7 bytes of 0 padding.
* `e_type` = `ET_EXEC` = 2: executable program.
* `e_machine` = `EM_X86_64` = `#3E`: x86-64 CPU.
* `e_entry`: Program entry point (virtual address).
* `e_phoff`: Program header table file location.
* `e_shoff` = 0: Section header table file location (none).
* `e_flags` = 0: CPU-specific flags (none).
* `e_ehsize` = `#40`: ELF header size.
* `e_phentsize` = `#38`: Program header table entry size.
* `e_phnum`: Number of program header table entries.
* `e_shentsize` = `#40`: Section header table entry size.
* `e_shnum` = 0: Number of section header table entries (we don't need those).
* `e_shstrndx`: Section header table index of the section name string table (0 = none).

# Program header table

An ELF file contains a number of segments that will be loaded into memory. Each
must be described in the program header table. Each program header entry contains
`#38` = 56 bytes that look like this:

![Program header entry](../images/elf/program_header_entry.svg)

`p_flags`: ![`p_flags`](../images/elf/program_header_entry_flags.svg)

The fields are:

* `p_type` = `PT_LOAD` = 1: Load into memory
* `p_flags`: Segment permissions.
    * `R`: Read access.
    * `W`: Write access.
    * `X`: Executable.
* `p_offset`: File location.
* `p_vaddr`: Virtual address.
* `p_paddr` = 0: Physical address (ignored).
* `p_filesz`: Size in the file.
* `p_memsz`: Size in memory. If greater than `p_filesz` the rest is filled with zeros.
* `p_align` = `#1000`: Alignment of segments in memory, must be a multiple of page
    size. We must have `p_offset` ≡ `p_vaddr` (mod `p_align`).

# Section header table

The section header table is not required for executable programs, so we are going to
ignore this.
