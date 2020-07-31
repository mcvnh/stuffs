; --------------------------------------------------------------------------------
; Writes "Hello, World" to the console using C library.
; The program only runs on 64-bit macOS.
;
; To run the application:
;
;    nasm -fmacho64 hello_clib.asm && gcc hello.o && ./a.out
; --------------------------------------------------------------------------------

          global    _main
          extern    _puts

          section   .text
_main:    push      rbx                     ; call stack must be aligned
          lea       rdi, [rel message]      ; first argument is address of message
          call      _puts                   ; puts(message)
          pop       rbx                     ; fix up stack before returning
          ret

          section   .data
message   db        "Hello, World", 0       ; C strings need a zero byte at the end

