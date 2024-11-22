# Numbers and strings

The first version of our assembler will implement our [notation](../reference/notation.md) for
octal bytes, hexadecimal bytes and dwords, and strings. In particular:

* `%xxx` is an octal byte, e.g. `%101`
* `$xx` is a hexadecimal byte using upper-case letters, e.g. `$1C`
* `#xx` is a hexadecimal dword (32 bits) using upper-case letters, e.g. `#1234CDEF`
* `"xxxx"` is a string of characters, e.g. `"hello"`
* `; xxxx` is a comment until the end of the line, e.g. `; this is a comment`
* spaces and new lines are ignored

Let's start writing our code in assembly. We will have to manually translate it to machine
code just like we did with [`hello.1`](../hello-world.md).

## Reserve space for input and output

We will store the input and output in memory. We could do all processing online in one pass,
reading and writing one byte at a time without storing anything in memory. But soon we will want
to do two passes over the input to add support for forward references. So let's store the input
and output in memory from the beginning.
The memory buffering also makes the I/O more performant.

Let's reserve 1 MiB of memory for the input and 1 MiB for the output at the end of our program.

These large buffers don't have to be stored in the executable file:
[ELF files](../reference/elf.md) support reserving more memory than we have in the file,
and this extra memory is initialized to 0. Let's call it `zero_initialized_data`. The more
common name is "bss segment", but that's obscure.

A bonus is that such zero initialized memory is only allocated as needed using virtual memory.
We reserve 2 MiB in virtual memory, but the actual amount of physical memory used will only
depend on how much is ever needed. Sweet!

```nasm
text_end:               ; the program text ends here
zero_initialized:       ; zero-initialized data starts here

; input assembly text
input:
    resb #100000        ; reserve 1 MiB for input
input_end:

; output binary file
output:
    resb #100000        ; reserve 1 MiB for output

zero_initialized_end:   ; zero-initialized data ends here
```

## Read the source code

We begin our program by reading the source code. For this, we use the `read`
[system call](../reference/syscalls.md). Each time we call it, it may read only part of the input,
so we have to read in a loop.

```nasm
text:                   ; the program text starts here
start:

; read input file into `input`
; ecx points to the end of input
read:
    xor ebx, ebx        ; 0 = standard input
    mov ecx, input      ; initialize end of input
    ; Make sure there is at least 1 byte with value 0 at the end.
    ; This helps us deal with end of file later.
    mov edx, input_end - input - 1   ; buffer size
read_loop:
    mov eax, #3         ; "read" system call
    int $80             ; system call: read bytes starting from ecx
    ; The adjustments here will not be valid if there is a read error,
    ; but that is OK.
    add ecx, eax        ; move end of input
    sub edx, eax        ; adjust remaining buffer size
    test eax, eax       ; check eax
    jl error            ; if eax < 0: error, go to the error handler
    jg read_loop        ; if eax > 0: go back to read more
```

## The main loop

In the main loop, the invariant is:

* `esi` points to the next character of input
* `ecx` points to the end of input
* `edi` points to the next byte of output

```nasm
; assemble `input` into `output`
; ecx = end of input
assemble:
    ; esi points to next character of input
    ; ecx points to the end of input
    ; edi points to the next byte of output
    mov esi, input
    mov edi, output

; main assembling loop
assemble_loop:
    cmp esi, ecx        ; check if we have reached end of input
    je write_output     ; if yes, go to write_output
    lodsb               ; load next input byte into al; increment esi
    cmp al, " "         ; is it a space?
    je assemble_loop    ; if yes, skip
    cmp al, $A          ; is it a newline?
    je assemble_loop    ; if yes, skip
    cmp al, ";"         ; is it a semicolon?
    je comment          ; if yes, go to comment handling
    cmp al, $22         ; is it a quote character, "?
    je string           ; if yes, go to string handling
    cmp al, "%'         ; is it a percent sign?
    je oct_byte         ; if yes, go to octal byte handling
    cmp al, "$"         ; is it a dollar sign?
    je hex_byte         ; if yes, go to the hex byte handling
    cmp al, "#"         ; is it a hash sign?
    je hex_dword        ; if yes, go to the hex dword handling
other:
    jmp error           ; otherwise go to the error handler
```

## Comments

Comments start with `";"` and continue until end of line. We consider any 0 byte in a comment
as an error: this catches unfinished comments because we made sure that after the end of file
there is at least one 0 byte.

```nasm
comment:
    lodsb               ; load next character into al
    test al, al         ; is it a 0 byte (including EOF)?
    je error            ; if yes: error
    cmp al, $0a         ; is it end of line?
    je assemble_loop    ; if yes: done
    jmp comment         ; repeat
```

## Strings

Strings start and end with a quote `'"'` ([ASCII `$22`](../reference/ascii.md).
Again we consider 0 bytes inside a string as errors,
which automatically catches strings that are unclosed until the end of file. Copy each character
to the output pointed to by `edi`.

```nasm
string:
    lodsb               ; load next character into al
    test al, al         ; is it a 0 byte (including EOF)?
    je error            ; if yes: error
    cmp al, $22         ; is it a quote?
    je assemble_loop    ; if yes: done
    stosb               ; copy the character to output
    jmp string          ; repeat
```

## Octal bytes

Parse octal bytes after a `%` character. We calculate the value in `ebx` and ignore overflow.

```nasm
oct_byte:
    xor ebx, ebx        ; ebx will contain the octal number
oct_byte_loop:
    lodsb               ; load the next character into al
    sub al, '0'         ; adjust so that digits '0'-'7' are 0-7
    cmp al, $8          ; is it below 8?
    jae oct_byte_done   ; no: we are done
    shl ebx, $3         ; ebx = 8 * ebx
    or bl, al           ; add next digit
    jmp oct_byte_loop   ; read more digits
oct_byte_done:
    dec esi             ; undo last byte read since it wasn't octal
    mov al, bl          ; al = the byte
    stosb               ; store the byte in the output
    jmp assemble_loop   ; go back to main loop
```

## Hexadecimal bytes and dwords

Hexadecimal numbers are similar. Create a helper function `read_hex` that is used by
both `hex_byte` and `hex_dword`.

```nasm
; a hex byte
hex_byte:
    call read_hex       ; read a hex number
    stosb               ; store the hex byte in the output
    jmp assemble_loop   ; go back to main loop

; a hex dword
hex_dword:
    call read_hex       ; read a hex number
    stosd               ; store the hex dword in the output
    jmp assemble_loop   ; go back to main loop

; reads a hex number into eax
read_hex:
    xor ebx, ebx        ; ebx will contain the hex number
read_hex_loop:
    lodsb               ; load the next character into al
    sub al, '0'         ; '0'-'9' are now 0-9
    cmp al, $A          ; is it below 10?
    jb read_hex_have_digit  ; if yes, go to read_hex_have_digit
    sub al, 'A' - '0'   ; 'A'-'F are now 0-5
    cmp al, $6          ; is it below 6?
    jae read_hex_done   ; if no, go to read_hex_done
    add al, $A          ; al is now 10-15
read_hex_have_digit:
    shl ebx, $4         ; ebx = 16 * ebx
    or bl, al           ; add next digit
    jmp read_hex_loop   ; read more digits
read_hex_done:
    dec esi             ; undo last byte read since it wasn't hexadecimal
    mov eax, ebx        ; put the return value in eax
    ret                 ; return
```

## Write the output

When we are done with all of the source code, we write the generated output.
We already did this in [`hello.1`](../hello-world.md).

```nasm
; write output to stdout
; edi = end of output
write_output:
    mov ebx, #1         ; standard output
    mov ecx, output     ; output bytes
    mov edx, edi        ; calculate length
    sub edx, ecx        ; edx = edi - output = output length
write_loop:
    mov eax, 4          ; "write" system call
    int $80             ; system call
    test eax, eax       ; check result
    jl error            ; if eax < 0: handle error
    add ecx, eax        ; remaining output
    sub edx, eax        ; remaining length
    jnz write_loop      ; if edx != 0, go back to write_loop
```

## Exit

After we are done writing the output, we exit the program.

```nasm
; exit with exit code 0
exit_success:
    xor ebx, ebx        ; success exit code

; exit
; ebx = exit code
exit:
  mov eax, #1           ; "exit" system call
  int $80               ; system call
```

## Error handling

On error, we print an error message to standard error (file descriptor 2). This is similar
to `write`, except if there is any problem with writing to standard error, we just give up
and exit. We don't want an infinite recursion when trying to print an error message.

```nasm
; print error message and exit with exit code 1
error:
    mov ebx, 2          ; standard error
    mov ecx, error_message  ; error message
    mov edx, error_message_end - error_message  ; error message length
error_loop:
    mov eax, 4          ; "write" system call
    int $80             ; system call
    test eax, eax       ; check result
    jl error_done       ; if eax < 0: give up writing
    add ecx, eax        ; remaining error message
    sub edx, eax        ; remaining length
    jne error_loop      ; if edx != 0: write more
error_done:
    dec ebx             ; exit code 1
    jmp exit            ; exit

; error message
error_message:
    db "Error!", $0A    ; "Error!", new line
error_message_end:
```

## ELF header

We have all the code we need. Like before, we now have to translate this to an executable
file.

We start with the [ELF header](../reference/elf.md).

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

## Program header table

Now we need the program header table. Again, for simplicity, we use just 1 segment that
contains all our code and data.

This time we have to include 2 MiB of zero-initialized buffers (`input` and `output`), so
the size in memory is going to be larger than the file size of the segment.

We now also have to include the *write* permission for the segment so that we can write into
the buffers.

offset | contents | comment
----: | --------- | ------
`#34` | `#1`      | segment type: load into memory
`#38` | `#54`     | location of the segment (immediately after the program header table)
`#3C` | `text`    | virtual address of the text segment
`#40` | `#0`      | physical address (ignored)
`#44` | `text_end - text` | file size of the text segment
`#48` | `zero_initialized_end - text` | size in memory
`#4C` | `#1 + #2 + #4` | permissions: execute + write + read
`#50` | `#1000`   | memory alignment, 4 KiB

## Machine code

Now it's time to translate all the code in [x86 machine code](../reference/x86.md). Like
before, we put `text` at virtual address `#100054`.

offset | virtual address | contents | assembly
----- | --------- | --------------- | --------
`#54` | `#100054` |                 | `text:`
`#54` | `#100054` |                 | `start:`
`#54` | `#100054` |                 | `read:`
`#54` | `#100054` | `%063 %333`     | `xor ebx, ebx`
`#56` | `#100056` | `%271 input`    | `xor ecx, input` 
`#5B` | `#10005B` | `%272 #FFFFF`   | `mov edx, input_end - input - 1`
`#60` | `#100060` |                 | `read_loop:`
`#60` | `#100060` | `%270 #3`       | `mov eax, #3`
`#65` | `#100065` | `%315 $80`      | `int $80`
`#67` | `#100067` | `%003 %310`     | `add ecx, eax`
`#69` | `#100069` | `%053 %320`     | `sub edx, eax`
`#6B` | `#10006B` | `%205 %300`     | `test eax, eax`
`#6D` | `#10006D` | `%017 $8C error - *` | `jl long error`
`#73` | `#100073` | `$7F $(read_loop - *)` | `jg read_loop`
`#75` | `#100075` |                 | `assemble:`
`#75` | `#100075` | `%276 input`    | `mov esi, input`
`#7A` | `#10007A` | `%277 output`   | `mov esi, input`
`#7F` | `#10007F` | `%073 %316`     | `cmp ecx, esi`
`#81` | `#100081` | `$74 $(write_output - *)` | `je write_output`
`#83` | `#100083` | `%254`          | `lodsb`
`#84` | `#100084` | `%074 " "`      | `cmp al, " "`
`#86` | `#100086` | `$74 $(assemble_loop - *)` | `je assemble_loop`
`#88` | `#100088` | `%074 $A`       | `cmp al, $A`
`#8A` | `#10008A` | `$74 $(assemble_loop - *)` | `je assemble_loop`
`#8C` | `#10008C` | `%074 ";"`      | `cmp al, ";"`
`#8E` | `#10008E` | `$74 $(comment - *)` | `je comment`
`#90` | `#100090` | `%074 $22`      | `cmp al, $22`
`#92` | `#100092` | `$74 $(string - *)`  | `je string`
`#94` | `#100094` | `%074 "%"`      | `cmp al, "%"`
`#96` | `#100096` | `$74 $(oct_byte - *)`  | `je oct_byte`
`#98` | `#100098` | `%074 "$"`      | `cmp al, "$"`
`#9A` | `#10009A` | `$74 $(hex_byte - *)`  | `je hex_byte`
`#9C` | `#10009C` | `%074 "#"`      | `cmp al, "#"`
`#9E` | `#10009E` | `$74 $(hex_dword - *)` | `je hex_dword`
`#A0` | `#1000A0` |                 | `other:`
`#A0` | `#1000A0` | `%351 error - *` | `jmp long error`
`#A5` | `#1000A5` |                 | `comment:`
`#A5` | `#1000A5` | `%254`          | `lodsb`
`#A6` | `#1000A6` | `%204 %300`     | `test al, al`
`#A8` | `#1000A8` | `$74 $(error - *)` | `je error`
`#AA` | `#1000AA` | `%074 $A`       | `cmp al, $A`
`#AC` | `#1000AC` | `%074 $(assemble_loop - *)` | `ja assemble_loop`
`#AE` | `#1000AE` | `%377 $(comment - *)` | `jmp comment`
`#B0` | `#1000B0` |                 | `string:`
`#B0` | `#1000B0` | `%254`          | `lodsb`
`#B1` | `#1000B1` | `%204 %300`     | `test al, al`
`#B3` | `#1000B3` | `$74 $(error - *)` | `je error`
`#B5` | `#1000B5` | `%074 $22`      | `cmp al, $22`
`#B7` | `#1000B7` | `$74 $(assemble_loop - *)` | `je assemble_loop`
`#B9` | `#1000B9` | `%252`          | `stosb`
`#BA` | `#1000BA` | `%377 $(string - *)` | `jmp string`
`#BC` | `#1000BC` |                      | `oct_byte:`

TODO

## Fill in addresses and offsets

...

We needed to make the jumps at `#6D` and `#A0` to be **long** jumps because the distances from there
to `error` are larger than `$7F` so they wouldn't fit in a single byte.

How did I know this before calculating the jump offsets? Well, on the first iteration I didn't.
After calculating the jump offsets I realized the offsets are too large.
And so I went back and fixed them, which shifted all the subsequent offsets.
Compiling assembly is an iterative process.
