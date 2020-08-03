; --------------------------------------------------------------------------------
; The program only runs on 64-bit macOS.
;
; To run the application:
;
;    nasm -fmacho64 helloworld_inc.asm && gcc helloworld_inc.o && ./a.out
; --------------------------------------------------------------------------------

; - Includes

%include            'functions.asm'

; - Code

          global    _main
          section   .text
_main:
          mov       rax, msg1
          call      sprint

          mov       rax, msg2
          call      sprint

          call      exit


          section   .data
msg1      db        'Hello, brave new world', 10, 0
msg2      db        'This is how we recycle in NASM', 10, 0
