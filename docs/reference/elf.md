# Linux executable files

Executable files on Linux follow the ELF file format.

The ELF format can store many different kinds
of files for different CPUs and operating systems, but we are only interested in executable
programs for x86 Linux.

## ELF Header

An ELF file starts with a `#34`-byte (52-byte) the ELF Header:

offset | length | contents | comment
----: | -----: | :------- | :------
`#0`  | `4` | `$7f 'E 'L 'F` | magic number that identifies ELF files
`#4`  | `1` | `1`   | word size: `1` = 32-bit, `2` = 64-bit
`#5`  | `1` | `1`   | endianness: `1` = little-endian, `2` = big-endian
`#6`  | `1` | `1`   | ELF specification version
`#7`  | `1` | `0`   | operating system ABI: `0` = UNIX System V (this is what is typically used)
`#8`  | `1` | `0`   | operating system ABI version
`#9`  | `7` | `0 0 0 0 0 0 0` | padding
`#10` | `2` | `2 0` | object file type: `2` = executable file
`#12` | `2` | `3 0` | CPU: `3` = x86
`#14` | `4` | `#1`  | ELF specification version `1` (same as entry at `#6`)
`#18` | `4` |       | program entry point (virtual address)
`#1c` | `4` | `#34` | program header table location: `#34` = directly behind the ELF header
`#20` | `4` | `#0`  | section header table location: `0` = none; executable files don't need sections
`#24` | `4` | `#0`  | flags (none are defined for Linux executables)
`#28` | `2` | `$34 0` | ELF header size
`#2a` | `2` | `$20 0` | program header size
`#2c` | `2` |       | number of program headers
`#2e` | `2` | `0 0` | section header size (ignored if there are no sections)
`#30` | `2` | `0 0` | number of section headers (executable files don't need sections)
`#32` | `2` | `0 0` | section name string table index: `0` = none

## Program header

An ELF file contains a number of segments that will be loaded into memory. Those are described by
the Program Header Table with some number of `#20`-byte (32-byte) Program Headers:

offset | length | contents | comment
----: | --: | :------ | :------
`#0`  | `4` | `#1`    | Segment type. `1` = load into memory
`#4`  | `4` |         | file location of the segment
`#8`  | `4` |         | virtual address; typically should be at least `#10000` (64KB)
`#c`  | `4` | `#0`    | physical address (ignored)
`#10` | `4` |         | size in the file
`#14` | `4` |         | size in memory; if larger than the size in the file, the rest is filled with 0 bytes
`#18` | `4` |         | permissions (can be combined): `#1` = execute, `#2` = write, `#4` = read
`#1c` | `4` | `#1000` | memory alignment: one page = 4 KB

The virtual address where a segment is loaded in memory must match its location in the file modulo
memory page size (`#1000`) because that allows mapping the file into memory using the virtual memory
system which works at page size granularity.

## Stack segment

The stack segment is automatically created (normally at the top of memory addresses) for each executable
program.
