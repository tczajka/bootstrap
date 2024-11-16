---
layout: post
title: First program
---

file offset | virtual address | bytes           | assembly      | comment
----------- | --------------- | --------------- | ------------- | -------
         #0 |                 |                 |               | ELF header:
         #0 |                 | $7f 'E' 'L' 'F' |               | magic number: ELF file
         #4 |                 |               1 |               | ELFCLASS32: 32-bit code
         #5 |                 |               1 |               | ELFDATA2LSB: little-endian
         #6 |                 |               1 |               | EV\_CURRENT: ELF version 1
         #7 |                 |               0 |               | ELFOSABI\_SYSV: UNIX System V ABI
         #8 |                 |               0 |               | UNIX System V ABI version
         #9 |                 |   0 0 0 0 0 0 0 |               | padding
        #10 |                 |             2 0 |               | ET\_EXEC: executable file
        #12 |                 |             3 0 |               | EM\_386: Intel 80386 CPU
        #14 |                 |              #1 |               | EV\_CURRENT: ELF version 1
        #18 |                 |         #100054 |               | program entry point: start
        #1c |                 |             #34 |               | program header table offset
        #20 |                 |              #0 |               | section header table offset (none)
        #24 |                 |              #0 |               | flags (none)
        #28 |                 |           $34 0 |               | ELF header size
        #2a |                 |           $20 0 |               | program header size
        #2c |                 |             1 0 |               | number of program headers
        #2e |                 |             0 0 |               | section header size
        #30 |                 |             0 0 |               | number of section headers
        #32 |                 |             0 0 |               | section name string table index (none)
----------- | --------------- | --------------- | ------------- | ---------------------
        #34 |                 |                 |               | program header: text segment
        #34 |                 |              #1 |               | PT\_LOAD: load into memory
        #38 |                 |             #54 |               | file offset of text segment
        #3c |                 |         #100054 |               | virtual address of text segment
        #40 |                 |              #0 |               | physical address (ignored)
        #44 |                 |              #c |               | file size of text segment
        #48 |                 |              #c |               | memory size of text segment
        #4c |                 |              #7 |               | permissions: execute + write + read
        #50 |                 |           #1000 |               | alignment (page size, 4KB)
----------- | --------------- | --------------- | ------------- | ---------------------
        #54 |         #100054 |                 | text:         | 
        #54 |         #100054 |                 | mov ebx, 1       | ebx = standard output
        #54 |         #100054 |                 | mov ecx, message | ecx = string address
        #54 |         #100054 |                 | mov edx, message\_end - message | edx = string length
        #54 |         #100054 |                 | write\_loop: |
        #54 |         #100054 |                 | mov eax, 4    | eax = write system call
        #5e |         #10005e |        %315 $80 | int $80       | system call
        #54 |         #100054 |                 | add ecx, eax  | move string pointer
        #54 |         #100054 |                 | sub edx, eax  | decrease string length
        #54 |         #100054 |                 | jnz write\_loop  | go back if any string remaining
        #54 |         #100054 | %270 #1         | mov eax, ebx  | eax = 1 = exit system call
        #59 |         #100059 | %273 'H' 0 0 0  | xor ebx, ebx  | ebx = exit code 0
        #5e |         #10005e |        %315 $80 | int $80       | system call
        #60 |         #100060 |                 | message:      |
        #60 |         #100060 | "Hello, world!" $a | string "Hello, world!\n" |
        #60 |         #100060 |                 | message\_end:  |
        #60 |         #100060 |                 | text\_end:  |

