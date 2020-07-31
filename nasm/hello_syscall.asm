; --------------------------------------------------------------------------------
; Writes "Hello, World" to the console using only system calls.
; The program only runs on 64-bit macOS.
;
; To run the application:
;
;    nasm -fmacho64 hello_syscall.asm && gcc hello_syscall.o && ./a.out
; --------------------------------------------------------------------------------

          global    _main

          section   .text
_main:    mov       rax, 0x02000004         ; system call for write
          mov       rdi, 1                  ; file handle 1 is stdout
          mov       rsi, message            ; address of string to output
          mov       rdx, 13                 ; number of bytes
          syscall                           ; invoke operating system to do the write
          mov       rax, 0x02000001         ; system call for exit
          xor       rdi, rdi                ; exit code 0
          syscall

          section   .data
message   db        "Hello, World", 10      ; note the newline at the end

