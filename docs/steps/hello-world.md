# Hello, world!

Let's create our first executable program. It will print `Hello, world!` to the console.

But where do we start? We assume that don't have a Python interpreter, a C++ compiler, or even an assembler
available (or don't want to trust them!).

## Outline



## Assembly code

Let start by writing the code in assembly:

## File layout

file offset | virtual address | bytes | assembly | comment
---: | ------: | :-------------- | :-------------- | :------
  #0 |         |                 |                 | ELF header:
  #0 |         | $7f 'E' 'L' 'F' |                 | magic number: ELF file
  #4 |         | 1               |                 | `EI_CLASS` = `ELFCLASS32`: 32-bit code
  #5 |         | 1               |                 | `EI_DATA` = `ELFDATA2LSB`: little-endian
  #6 |         | 1               |                 | `EI_VERSION` = `EV_CURRENT`: ELF version 1
  #7 |         | 0               |                 | `EI_OSABI` = `ELFOSABI_SYSV`: UNIX System V ABI
  #8 |         | 0               |                 | `EI_ABIVERSION` = 0: UNIX System V ABI version
  #9 |         | 0 0 0 0 0 0 0   |                 | padding
 #10 |         | 2 0             |                 | `e_type` = `ET_EXEC`: executable file
 #12 |         | 3 0             |                 | `e_machine` = `EM_386`: Intel 80386 CPU
 #14 |         | #1              |                 | `e_version` = `EV_CURRENT`: ELF version 1
 #18 |         | #100054         | `start`         | `e_entry`: program entry point
 #1c |         | #34             |                 | `e_phoff`: program header table
 #20 |         | #0              |                 | `e_shoff`: section header table offset (none)
 #24 |         | #0              |                 | `e_flags` (none)
 #28 |         | $34 0           |                 | `e_ehsize`: ELF header size
 #2a |         | $20 0           |                 | `e_phentsize`: program header size
 #2c |         | 1 0             |                 | `e_phnum`: number of program headers
 #2e |         | 0 0             |                 | `e_shentsize`: section header size
 #30 |         | 0 0             |                 | `e_shnum`: number of section headers
 #32 |         | 0 0             |                 | `e_shstrndx`: section name string table index (none)
---- | ------- | --------------- | --------------- | ---------------------
 #34 |         |                 |                 | program header: text segment
 #34 |         | #1              |                 | `p_type` = `PT_LOAD`: load into memory
 #38 |         | #54             |                 | `p_offset`: file offset of text segment
 #3c |         | #100054         | `text`          | `p_vaddr`: virtual address of text segment
 #40 |         | #0              |                 | `p_paddr`: physical address (ignored)
 #44 |         | #34             | `text_end - text` | `p_filesz`: file size of text segment
 #48 |         | #34             | `text_end - text` | `p_memsz`: memory size of text segment
 #4c |         | #7              |                 | `p_flags`: permissions, execute + write + read
 #50 |         | #1000           |                 | `p_align`: alignment (page size, 4KB)
---- | ------- | --------------- | --------------- | ---------------------
 #54 | #100054 |                 | `text:`         | start of executable code
 #54 | #100054 |                 | `start:`        | first instruction executed
 #54 | #100054 | %273 #1         | `mov ebx, 1`    | ebx = standard output
 #59 | #100059 | %271 #10007a    | `mov ecx, message` | ecx = message address
 #5e | #10005e | %272 #e         | `mov edx, message_end - message` | edx = message length
 #63 | #100063 |                 | `write_loop:`   |
 #63 | #100063 | %270 #4         | `mov eax, 4`    | eax = write system call
 #68 | #100068 | %315 $80        | `int $80`       | system call
 #6a | #10006a | %205 %300       | `test eax, eax` | check write error
 #6c | #10006c | $7e $6          | `jle exit`      | exit if write error
 #6e | #10006e | %001 %301       | `add ecx, eax`  | move string pointer
 #70 | #100070 | %051 %302       | `sub edx, eax`  | decrease string length
 #72 | #100072 | $75 $ef         | `jnz write_loop` | go back if any string remaining
 #74 | #100074 |                 | `exit:`         |
 #74 | #100074 | %211 %330       | `mov eax, ebx`  | eax = 1 = exit system call
 #76 | #100076 | %061 %333       | `xor ebx, ebx`  | ebx = exit code 0
 #78 | #100078 | %315 $80        | `int $80`       | system call
 #7a | #10007a |                 | `message:`      | start of message
 #7a | #10007a | "Hello, world!" $a | `db "Hello, world!", $a`| the message with a new line
 #88 | #100088 |                 | `message\_end:` | end of message
 #88 | #100088 |                 | `text\_end:`    | end of executable code

## Create the file!
