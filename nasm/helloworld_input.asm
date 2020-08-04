; --------------------------------------------------------------------------------
; The program only runs on 64-bit macOS.
;
; To run the application:
;
;    nasm -fmacho64 helloworld_input.asm && gcc helloworld_input.o && ./a.out
; --------------------------------------------------------------------------------


; - Includes

%include            'functions.asm'

; - Code

          global    _main
          section   .text
_main:
          mov       rax, msg1
          call      sprint

          mov       rdi, 0                          ; write to STDIN file
          mov       rsi, sinput                     ; reserve space to store the input
          mov       rdx, 255                        ; number of bytes to read
          mov       rax, 0x02000003                 ; invoke sys_read
          syscall

          mov       rax, msg2
          call      sprint

          mov       rax, sinput
          call      sprint

          call      exit                            ; exit program


          section   .data
msg1      db        'Please enter your name: ', 0   ; message asking for input
msg2      db        'Hello, ', 0                    ; message to use after get the input


          section   .bss
sinput    resb      255                             ; reserve a 255 byte space for input
