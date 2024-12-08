# Rewrite "Hello, world!" in assembly

Now that we have created an (very simple) assembler, let's rewrite our
first program, ["Hello, world!"](../hello-world.md), in this new language!

[`src/hello.2.asm`](https://github.com/tczajka/brooklyn/blob/main/src/hello.2.asm)

```text
; ELF header
$7F "ELF"   ;               ; magic number                  ;  #0
$1 $1       ;               ; 32-bit little-endian          ;  #4
$1 $0 $0    ;               ; ELF v1, Unix v0               ;  #6
$0 $0 $0 #0 ;               ; padding                       ;  #9
$2 $0 $3 $0 ;               ; executable, x86               ; #10
#1          ;               ; ELF v1                        ; #14
#100054     ; start         ; entry point                   ; #18
#34         ;               ; program headers               ; #1C
#0          ;               ; section headers               ; #20
#0          ;               ; flags                         ; #24
$34 $0      ;               ; ELF header size               ; #28
$20 $0      ;               ; program header size           ; #2A
$1 $0       ;               ; number of program headers     ; #2C
$0 $0       ;               ; section header size           ; #2E
$0 $0       ;               ; number of section headers     ; #30
$0 $0       ;               ; section name table index      ; #32

; program header: text segment
#1          ;               ; segment type: load            ; #34
#54         ;               ; file location                 ; #38
#100054     ; text          ; virtual address               ; #3C
#0          ;               ; physical address              ; #40
#37         ; text_end - text ; file size                   ; #44
#37         ; text_end - text ; memory size                 ; #48
#5          ;               ; permissions: execute + read   ; #4C
#1000       ;               ; memory aligment, 4 KiB        ; #50

; text segment
                ; text:                 ; beginning of text segment
                ; start:                ; entry point
%273 #1         ;     mov ebx, #1       ; standard output           ; #100054
%271 #10007D    ;     mov ecx, message  ; message address           ; #100059
%272 #E         ;     mov edx, message_end - message ; message length  ; #10005E
                ; write_loop:
%270 #4         ;     mov eax, #4       ; "write" system call       ; #100063
%315 $80        ;     int $80           ; system call               ; #100068
%205 %300       ;     test eax, eax     ; bytes written by "write", or -1 if error ; #10006A
$7C $8          ;     jl exit           ; exit on failure; ebx = exit code 1  ; #10006C
%003 %310       ;     add ecx, eax      ; remaining message         ; #10006E
%053 %320       ;     sub edx, eax      ; remaining length          ; #100070
$75 $EF         ;     jnz write_loop    ; if edx != 0, go back to write_loop  ; #100072

                ;                       ; exit the program with exit code 0
                ; exit_success:         ;
%063 %333       ;     xor ebx, ebx      ; 0 = successful exit       ; #100074

                ;                       ; exit the program
                ;                       ; return value in ebx
                ; exit:                 ;
%270 #1         ;     mov eax, #1       ; "exit" system call        ; #100076
%315 $80        ;     int $80           ; system call               ; #10007B
                
                ; message:              ; the message
"Hello, world!" $A ;  db "Hello, world!", $A                        ; #10007D
                ; message_end:          ; end of the message
                ; text_end:             ; end of text segment       ; #10008B
```

The actual code is in the left column. We write regular assembly mnemonics
in the comments. On the right are the offsets / virtual addresses.

## The process

The process we follow is:

1. Write pseudo-code in assembly mnemonics.
2. Translate to machine code.
3. Compute virtual addresses.
4. Fill out missing addresses and offsets in machine code.

It would be nice if steps 2-4 were done automatically because it is a rather
painful and error-prone process. We will do that later.

## Compile

Let's compile it using our assembler:

```bash
$ bin/asm.1 < src/hello.2.asm > bin/hello.2
```

It should actually be identical to `hello.1`:

```bash
$ cmp bin/hello.2 bin/hello.1
$ chmod u+x bin/hello.2
$ bin/hello.2
Hello, world!
```
