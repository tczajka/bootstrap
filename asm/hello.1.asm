  bits 32
text:
start:
  mov ebx, 1        ; ebx = standard output
  mov ecx, message  ; ecx = message address
  mov edx, message_end - message ; edx = message length
write_loop:
  mov eax, 4        ; eax = "write" system call
  int $80           ; system call
  test eax, eax     ; eax = bytes written by "write", or -1 if error
  jle exit          ; exit if error
  add ecx, eax      ; ecx = remaining message
  sub edx, eax      ; edx = remaining length
  jnz write_loop    ; if edx != 0, go back to write_loop
exit:
  mov eax, ebx      ; eax = 1 = "exit" system call
  xor ebx, ebx      ; ebx = 0 = successful exit
  int $80           ; system call
message:
  db "Hello, world!", $0a ; the message with a new line
message_end:
text_end:
