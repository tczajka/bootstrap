# Rewrite the assembler in assembly

Now let's rewrite the [assembler](first-version.md) in assembly! This will make further development easier.

The process of writing a compiler in its own language is called "bootstrapping".

[`src/asm.2.asm`](https://github.com/tczajka/echo-to-tetris/blob/main/src/asm.2.asm)

```nasm
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
#FC         ; text_end - text ; file size                   ; #44
#2000FC     ; zero_initialized_end - text ; memory size     ; #48
#7          ;               ; permissions: execute + write + read ; #4C
#1000       ;               ; memory aligment, 4 KiB        ; #50

; text segment
            ; text:                 ; the program text starts here
            ; start:                ; entry point

            ; ; read input file into `input`
            ; ; ecx points to the end of input
            ; read:
%063 %333   ;     xor ebx, ebx      ; 0 = standard input            ; #100054
%271 #100150 ;    mov ecx, input    ; initialize end of input       ; #100056
%272 #FFFFF ; ; Make sure there is at least 1 byte with value 0     ; #10005B
            ; ; at the end. This helps us deal with end of file later.
            ;     mov edx, input_end - input - 1  ; buffer size
            ; read_loop:
%270 #3     ;     mov eax, #3       ; "read" system call            ; #100060
%315 $80    ;     int $80           ; system call: read bytes starting from ecx ; #100065
            ; ; The adjustments here will not be valid if there is a read error,
            ; ; but that is OK.
%003 %310   ;     add ecx, eax      ; move end of input             ; #100067
%053 %320   ;     sub edx, eax      ; adjust remaining buffer size  ; #100069
%205 %300   ;     test eax, eax     ; check eax                     ; #10006B
%017 $8C #B3 ;     jl long error   ; if eax < 0: error, go to the error handler ; #10006D
$7F $EB     ;     jg read_loop      ; if eax > 0: go back to read more ; #100073

            ; ; assemble `input` into `output`
            ; ; ecx = end of input
            ; assemble:
            ; ; esi points to next character of input
            ; ; ecx points to the end of input
            ; ; edi points to the next byte of output
%276 #100150 ;     mov esi, input   ;                               ; #100075
%277 #200150 ;     mov edi, output  ;                               ; #10007A

            ; ; main assembling loop
            ; assemble_loop:
%073 %361   ;     cmp esi, ecx      ; end of input?                 ; #10007F
$7D $7B     ;     jge write_output  ; if yes, go to write_output    ; #100081
%254        ;     lodsb             ; load next input byte into al  ; #100083
%074 " "    ;     cmp al, " "       ; is it a space?                ; #100084
$74 $F7     ;     je assemble_loop  ; if yes, skip                  ; #100086
%074 $A     ;     cmp al, $A        ; is it a newline?              ; #100088
$74 $F3     ;     je assemble_loop  ; if yes, skip                  ; #10008A
%074 ";"    ;     cmp al, ";"       ; is it a semicolon?            ; #10008C
$74 $15     ;     je comment        ; if yes, go to comment handling ; #10008E
%074 $22    ;     cmp al, $22       ; is it a quote character, "?   ; #100090
$74 $1C     ;     je string         ; if yes, go to string handling ; #100092
%074 "%"    ;     cmp al, "%"       ; is it a percent sign?         ; #100094
$74 $24     ;     je oct_byte       ; if yes, go to octal byte handling ; #100096
%074 "$"    ;     cmp al, "$"       ; is it a dollar sign?          ; #100098
$74 $36     ;     je hex_byte       ; if yes, go to the hex byte handling ; #10009A
%074 "#"    ;     cmp al, "#"       ; is it a hash sign?            ; #10009C
$74 $3A     ;     je hex_dword      ; if yes, go to the hex dword handling ; #10009E
            ; other:
%351 #81    ;     jmp long error    ; otherwise go to the error handler ; #1000A0

            ; comment:
%254        ;     lodsb             ; load next character into al   ; #1000A5
%204 %300   ;     test al, al       ; is it a 0 byte (including EOF)? ; #1000A6
$74 $D5     ;     jz assemble_loop  ; if yes: done                  ; #1000A8
%074 $A     ;     cmp al, $A        ; is it end of line?            ; #1000AA
$74 $D1     ;     je assemble_loop  ; if yes: done                  ; #1000AC
%353 $F5    ;     jmp comment       ; repeat                        ; #1000AE

            ; string:
%254        ;     lodsb             ; load next character into al   ; #1000B0
%204 %300   ;     test al, al       ; is it a 0 byte (including EOF)? ; #1000B1
$74 $71     ;     je error          ; if yes: error                 ; #1000B3
%074 $22    ;     cmp al, $22       ; is it a quote?                ; #1000B5
$74 $C6     ;     je assemble_loop  ; if yes: done                  ; #1000B7
%252        ;     stosb             ; copy the character to output  ; #1000B9
%353 $F4    ;     jmp string        ; repeat                        ; #1000BA

            ; oct_byte:
%063 %333   ;     xor ebx, ebx      ; ebx will contain the octal number ; #1000BC
            ; oct_byte_loop:
%254        ;     lodsb             ; load the next character into al ; #1000BE
%054 "0"    ;     sub al, "0"       ; adjust so that digits '0'-'7' are 0-7 ; #1000BF
%074 $8     ;     cmp al, $8        ; is it below 8?                ; #1000C1
$73 $7      ;     jae oct_byte_done ; no: we are done               ; #1000C3
%301 %343 $3 ;    shl ebx, $3       ; ebx = 8 * ebx                 ; #1000C5
%012 %330   ;     or bl, al         ; add next digit                ; #1000C8
%353 $F2    ;     jmp oct_byte_loop ; read more digits              ; #1000CA
            ; oct_byte_done:
%116        ;     dec esi           ; undo last byte read since it wasn't octal ; #1000CC
%212 %303   ;     mov al, bl        ; al = the byte                 ; #1000CD
%252        ;     stosb             ; store the byte in the output  ; #1000CF
%353 $AD    ;     jmp assemble_loop ; go back to main loop          ; #1000D0

            ; ; a hex byte
            ; hex_byte:
%350 #B     ;     call read_hex     ; read a hex number             ; #1000D2
%252        ;     stosb             ; store the hex byte in the output ; #1000D7
%353 $A5    ;     jmp assemble_loop ; go back to main loop          ; #1000D8

            ; ; a hex dword
            ; hex_dword:
%350 #3     ;     call read_hex     ; read a hex number             ; #1000DA
%253        ;     stosd             ; store the hex dword in the output ; #1000DF
%353 $9D    ;     jmp assemble_loop ; go back to main loop          ; #1000E0

            ; ; reads a hex number into eax
            ; read_hex:
%063 %333   ;     xor ebx, ebx      ; ebx will contain the hex number ; #1000E2
            ; read_hex_loop:
%254        ;     lodsb             ; load the next character into al ; #1000E4
%054 "0"    ;     sub al, "0"       ; '0'-'9' are now 0-9           ; #1000E5
%074 $A     ;     cmp al, $A        ; is it below 10?               ; #1000E7
$72 $8      ;     jb read_hex_have_digit  ; if yes, go to read_hex_have_digit ; #1000E9
%054 $11    ;     sub al, "A" - "0" ; 'A'-'F are now 0-5            ; #1000EB
%074 $6     ;     cmp al, $6        ; is it below 6?                ; #1000ED
$73 $9      ;     jae read_hex_done ; if no, go to read_hex_done    ; #1000EF
%004 $A     ;     add al, $A        ; al is now 10-15               ; #1000F1
            ; read_hex_have_digit:
%301 %343 $4 ;    shl ebx, $4       ; ebx = 16 * ebx                ; #1000F3
%012 %330   ;     or bl, al         ; add next digit                ; #1000F6
%353 $EA    ;     jmp read_hex_loop ; read more digits              ; #1000F8
            ; read_hex_done:
%116        ;     dec esi           ; undo last byte read since it wasn't hexadecimal ; #1000FA
%213 %303   ;     mov eax, ebx      ; put the return value in eax   ; #1000FB
%303        ;     ret               ; return                        ; #1000FD

            ; ; write output to stdout
            ; ; edi = end of output
            ; write_output:
%273 #1     ;     mov ebx, #1       ; standard output               ; #1000FE
%271 #200150 ;    mov ecx, output   ; output bytes                  ; #100103
%213 %327   ;     mov edx, edi      ; calculate length              ; #100108
%053 %321   ;     sub edx, ecx      ; edx = edi - output = output length ; #10010A
            ; write_loop:
%270 #4     ;     mov eax, #4       ; "write" system call           ; #10010C
%315 $80    ;     int $80           ; system call                   ; #100111
%205 %300   ;     test eax, eax     ; check result                  ; #100113
$7C $F      ;     jl error          ; if eax < 0: handle error      ; #100115
%003 %310   ;     add ecx, eax      ; remaining output              ; #100117
%053 %320   ;     sub edx, eax      ; remaining length              ; #100119
$75 $EF     ;     jnz write_loop    ; if edx != 0, go back to write_loop ; #10011B

            ; ; exit with exit code 0
            ; exit_success:
%063 %333   ;     xor ebx, ebx      ; success exit code             ; #10011D

            ; ; ebx = exit code
            ; exit:
%270 #1     ;   mov eax, #1         ; "exit" system call            ; #10011F
%315 $80    ;   int $80             ; system call                   ; #100124

            ; ; print error message and exit with exit code 1
            ; error:
%273 #2     ;     mov ebx, #2         ; standard error              ; #100126
%271 #100149 ;    mov ecx, error_message  ; error message           ; #10012B
%272 #7     ;     mov edx, error_message_end - error_message  ; error message length ; #100130
            ; error_loop:
%270 #4     ;     mov eax, #4         ; "write" system call         ; #100135
%315 $80    ;     int $80             ; system call                 ; #10013A
%205 %300   ;     test eax, eax       ; check result                ; #10013C
$7C $6      ;     jl error_done       ; if eax < 0: give up writing ; #10013E
%003 %310   ;     add ecx, eax        ; remaining error message     ; #100140
%053 %320   ;     sub edx, eax        ; remaining length            ; #100142
$75 $EF     ;     jne error_loop      ; if edx != 0: write more     ; #100144
            ; error_done:
%113        ;     dec ebx             ; exit code 1                 ; #100146
%353 $D6    ;     jmp exit            ; exit                        ; #100147

            ; ; error message
            ; error_message:
"Error!" $A ;     db "Error!", $A     ; "Error!", new line          ; #100149
            ; error_message_end:

            ; text_end:             ; the program text ends here
            ; zero_initialized:     ; zero-initialized data starts here

            ; ; input assembly text
            ; input:
            ;     resb #100000      ; reserve 1 MiB for input       ; #100150
            ; input_end:

            ; ; output binary file
            ; output:
            ;     resb #100000      ; reserve 1 MiB for output      ; #200150

            ; zero_initialized_end: ; zero-initialized data ends here ; #300150
```

## Compile

Let's compile the assembler using the previous version of the assembler. They resulting
file should be identical.

```bash
$ bin/asm.1 < src/asm.2.asm > bin/asm.2
$ cmp bin/asm.2 bin/asm.1
$ chmod u+x bin/asm.2
```

Now we have an assembler that can compile its own source code!
