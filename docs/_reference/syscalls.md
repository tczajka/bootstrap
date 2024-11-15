---
layout: post
title: Linux system calls
---
We write our code for Linux under 32-bit mode. Nowadays everybody has 64-bit computers, but
32-bit mode programs are supported under 64-bit Linuxes, so we use that.

To call an operating system kernel service we use "system calls". Under 32-bit Linux these
are entered via the `int $80` (interrupt 128, or 80 in hexadecimal) machine code instruction.

Parameters are put in registers (eax, ebx, ...), and the return value is returned in the eax register.

The system calls we need are:

| name | description | eax | ebx | ecx | edx | return value
| ---- | ----------- | --- | --- | --- | --- | ------------
| exit | exit the program | 1 | program return code | | | none
| read | read from a file | 3 | file descriptor | buffer address | buffer size | number of bytes read
| write | write to a file | 4 | file descriptor | data address | data length | number of bytes written
| brk | allocate memory | 45 | memory limit request | | | new memory limit

* `exit` never returns. The program return code is a 1-byte code returned to the operating
  system. In `bash` it can be inspected using the `$?` special variable. 0 represents
  a normal exit, non-zero values represent failures.

* `read` reads up to `buffer size` bytes into the provided buffer from a file descriptor.
  File descriptor 0 is the standard input. Fewer bytes may be read than requested (but
  always at least 1, except on errors and end of file). 0 indicates end of file, -1 indicates
  an error.

* `write` writes up to `data length` bytes into a file descriptor. File descriptor 1 is the
  standard output, file descriptor 2 is the standard error stream. Fewer bytes may be written
  than requested (but always at least 1, except on errors). -1 indicates an error.

* `brk` changes the size of heap memory. We may ask to have memory allocated
  up to some limit, and the actual allocation is returned (it may be smaller if our request
  can't be satisfied). We can find out the initial address of (initially empty) heap memory
  by calling `brk(0)`.
