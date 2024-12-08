# Hello, world!

Let's create our first executable program. It will print `Hello, world!` to the console.

But where do we start? We are only going to use basic Linux command line tools.
So we are not going to use a Python interpret, a C++ compiler, or even an assembler!

## Assembly code

Despite the lack of an assembler, we start by writing code in assembly. We will then manually convert it
to [machine code](reference/x86.md).

We want to call the `write` [system call](reference/syscalls.md) to print the message to the
standard output of the process. The operating system automatically opens 3 files for each process:

* file descriptor 0: standard input
* file descriptor 1: standard output
* file descriptor 2: standard error

```nasm
text:                   ; beginning of text segment
start:                  ; entry point to the program
    mov ebx, #1         ; standard output
    mov ecx, message    ; message address
    mov edx, message_end - message  ; message length
write_loop:
    mov eax, #4         ; "write" system call
    int $80             ; system call
```

The `write` system call can fail. For example, if we redirect the output to a file, and we run out
of disk space, it will fail.

It can also write only part of the message for various reasons.

The return value in `eax` tells us what happened:

* `-1` indicates failure
* a positive value indicates the number of bytes actually written

So we need to check. On failure we will just finish the program. If a message has been printed
partially, we will loop around and continue writing. That's why we have put the `write_loop` label
in the code above.

```nasm
  test eax, eax         ; bytes written by "write", or -1 if error
  jl exit               ; exit on failure; ebx = exit code 1
  add ecx, eax          ; remaining message
  sub edx, eax          ; remaining length
  jnz write_loop        ; if edx != 0, go back to write_loop
```

Then we need to call the `exit` system call to finish the program. We will pass 0 in `ebx` to indicate
a successful exit, and 1 to indicate an error. It just so happens that `ebx` already contains 1.

```nasm
; exit the program with exit code 0
exit_success:
  xor ebx, ebx          ; 0 = successful exit

; exit the program
; return value in ebx
exit:                   
  mov eax, #1           ; "exit" system call
  int $80               ; system call
```

Finally we need the message we want to print. `db` defines bytes, and we write the message in ASCII,
including the "new line" character (ASCII `$A`).
Note: `$` indicates [a hexadecimal byte](reference/notation.md).

```nasm
message:
  db "Hello, world!", $A  ; the message with a new line
message_end:            ; end of the message
text_end:               ; end of text segment
```

## ELF header

Our executable file needs to begin with an [ELF header](reference/elf.md).
According to our [conventions](reference/notation.md), `$` indicates a hexadecimal byte,
`#` a hexadecimal 32-bit number, `%` an octal byte, `'` an [ASCII](reference/ascii.md) byte.

offset | contents | comment
----: | :---           | :------
`#0`  | `$7F "ELF"` | magic number that identifies ELF files
`#4`  | `1` | word size: 32-bit
`#5`  | `1` | endianness: little-endian
`#6`  | `1` | ELF specification version
`#7`  | `0` | operating system ABI: UNIX System V
`#8`  | `0` | operating system ABI version
`#9`  | `0 0 0 #0` | padding
`#10` | `2 0` | object file type: executable file
`#12` | `3 0` | CPU: x86
`#14` | `#1`  | ELF specification version again
`#18` | `start` | program entry point (virtual address)
`#1C` | `#34` | program header table location (directly behind the ELF header)
`#20` | `#0` | section header table location: none
`#24` | `#0` | flags (none)
`#28` | `$34 0` | ELF header size
`#2A` | `$20 0` | program header size
`#2C` | `1 0` | number of program headers
`#2E` | `0 0` | section header size (ignored)
`#30` | `0 0` | number of section headers
`#32` | `0 0` | section name string table index: none

We will fill out the address of `start` later.

## Program header

Now we need the program header table describing memory segments: parts of the file that should
be loaded into memory. Normally we want seperate segments for executable code, read-only data and
read-write data, each with appropriate permissions. But for simplicity we define only one
segment that contains both code and read-only data (the message).
Traditionally the code segment is called `text`.

offset | contents | comment
----: | --------- | ------
`#34` | `#1`      | segment type: load into memory
`#38` | `#54`     | location of the segment (immediately after the program header table)
`#3C` | `text`    | virtual address of the text segment
`#40` | `#0`      | physical address (ignored)
`#44` | `text_end - text` | file size of the text segment
`#48` | `text_end - text` | size in memory (same)
`#4C` | `#5`      | permissions: execute + read
`#50` | `#1000`   | memory alignment, 4 KiB

We will need to fill out the address and length of the segment, later.

We need to decide where in virtual memory our code will be stored. Linux won't typically
let us just put things at virtual address 0. The file `/proc/sys/vm/mmap_min_addr` shows
the minimum address: it's typically 64 KiB = `#10000`. It doesn't really matter much where we put
it. Let's put it at 1 MiB = `#100000`.

But we can't quite use `#100000` as the beginning of the segment because of page alignment. Since
we will start at at `#54` in the file, we have to start it at `#100054` in virtual memory. This
way Linux can map pages of the file (of size `#1000`) into virtual memory.

## Machine code

And finally, we put the actual machine code in the file. We translate assembly instructions
into [x86 machine code](reference/x86.md).

offset | virtual address | contents | assembly
----- | --------- | --------------- | --------
`#54` | `#100054` |                 | `text:`
`#54` | `#100054` |                 | `start:`
`#54` | `#100054` | `%273 #1`       | `mov ebx, #1`
`#59` | `#100059` | `%271 message`  | `mov ecx, message`
`#5E` | `#10005e` | `%272 message_end - message` | `mov edx, message_end - message`
`#63` | `#100063` |                 | `write_loop:`
`#63` | `#100063` | `%270 #4`       | `mov eax, #4`
`#68` | `#100068` | `%315 $80`      | `int $80`
`#6A` | `#10006A` | `%205 %300`     | `test eax, eax`
`#6C` | `#10006C` | `$7C $(exit - *)` | `jl exit`
`#6E` | `#10006E` | `%003 %310`     | `add ecx, eax`
`#70` | `#100070` | `%053 %320`     | `sub edx, eax`
`#72` | `#100072` | `$75 $(write_loop - *)` | `jnz write_loop`
`#74` | `#100074` |                 | `exit_success:`
`#76` | `#100074` | `%063 %333`     | `xor ebx, ebx`
`#76` | `#100076` |                 | `exit:`
`#76` | `#100076` | `%270 #1`       | `mov eax, #1`
`#7B` | `#10007B` | `%315 $80`      | `int $80`
`#7D` | `#10007D` |                 | `message:`
`#7D` | `#10007D` | `"Hello, world!" $A` | `db "Hello, world!", $A`
`#8B` | `#10008B` |                 | `message_end:`
`#8B` | `#10008B` |                 | `text_end:`

## Fill in addresses and offsets

Now we need to fill in addresses and offsets into our headers and our code. We used `*` to indicate "next instruction", needed for relative addressing.

offset | expr      | value
----: | --------- | -----
`#18` | `start`   | `#100054`
`#3C` | `text`    | `#100054`
`#44` | `text_end - text` | `#37`
`#48` | `text_end - text` | `#37`
`#5A` | `message` | `#10007D`
`#5F` | `message_end - message` | `#E`
`#6D` | `$(exit - *)` | `$8`
`#73` | `$(write_loop - *)` | `-$11` = `$EF`

## Create the file using `echo`

`echo` is a Linux command that will print out the argument given to it:

```bash
$ echo 'ABC'
ABC
```

Adding an `-e` flag enables escape codes for arbitrary bytes (including non-printable
characters and non-ASCII bytes): `\0ooo` is an octal escape code, `\xhh` is a hexadecimal escape code.
Here, we print ABC again by using [ASCII](reference/ascii.md) codes:

```bash
$ echo -e '\x41\x42\x43'
ABC
```

We know what `#8B` = 139 bytes we want to have in our program. Let's put them in
a single line in a text file in the format expected by `echo` in its argument:

[`src/hello.1.echo`](https://github.com/tczajka/brooklyn/blob/main/src/hello.1.echo)

```text
\x7FELF\x1\x1\x1\0\0\0\0\0\0\0\0\0\x2\0\x3\0\x1\0\0\0\x54\0\x10\0\x34\0\0\0\0\0\0\0\0\0\0\0\x34\0\x20\0\x1\0\0\0\0\0\0\0\x1\0\0\0\x54\0\0\0\x54\0\x10\0\0\0\0\0\x37\0\0\0\x37\0\0\0\x5\0\0\0\x0\x10\0\0\0273\x1\0\0\0\0271\x7d\0\x10\0\0272\xE\0\0\0\0270\x4\0\0\0\0315\x80\0205\0300\x7E\x8\03\0310\053\0320\x75\xEF\063\0333\0270\x1\0\0\0\0315\x80Hello, world!\xA
```

We can redirect that file as the argument to `echo`. The `-n` flag says: don't print an extra
new line character at the end.

```bash
$ mkdir bin
$ echo -en `cat src/hello.1.echo` > bin/hello.1
```

Make sure it has 139 bytes as expected, and mark it as an executable program!
```bash
$ wc -c bin/hello.1
139 bin/hello.1
$ chmod u+x bin/hello.1
```

Let's try it!

```bash
$ bin/hello.1
Hello, world!
```

It works! We have created our first program from scratch, using nothing but command line tools.
