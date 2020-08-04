; --------------------------------------------------------------------------------
; The program only runs on 64-bit macOS.
;
; To run the application:
;
;    nasm -fmacho64 helloworld_lf.asm && gcc helloworld_lf.o && ./a.out
; --------------------------------------------------------------------------------

; - Includes

%include            'functions.asm'

; - Code

          global    _main
          section   .text
_main:
          mov       rax, msg1
          call      sprintlf

          mov       rax, msg2
          call      sprintlf

          call      exit


          section   .data
msg1      db        'Hello, brave new world', 0
msg2      db        'This is how we recycle in NASM', 0
