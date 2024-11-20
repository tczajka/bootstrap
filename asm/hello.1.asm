  bits 32
text:               ; beginning of text segment
start:              ; entry point to the program
  mov ebx, 1        ; ebx = standard output
  mov ecx, message  ; ecx = message address
  mov edx, message_end - message ; edx = message length
write_loop:
  mov eax, 4        ; eax = "write" system call
  int $80           ; system call
  test eax, eax     ; eax = bytes written by "write", or -1 if error
  jle exit          ; exit on failure; ebx = exit code 1
  add ecx, eax      ; ecx = remaining message
  sub edx, eax      ; edx = remaining length
  jnz write_loop    ; if edx != 0, go back to write_loop
exit_success:
  xor ebx, ebx      ; ebx = 0 = successful exit
exit:               ; return value in ebx
  mov eax, 1        ; eax = "exit" system call
  int $80           ; system call
message:
  db "Hello, world!", $0a ; the message with a new line
message_end:
text_end:
