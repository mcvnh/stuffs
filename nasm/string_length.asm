; --------------------------------------------------------------------------------
; This is an OSX console program that calculate a length of a string.
;
; To run the application:
;
;    nasm -fmacho64 string_length.asm && gcc string_length.o && ./a.out
; --------------------------------------------------------------------------------

          global    _main

          section   .text
_main:
          mov       rbx, message            ; move the address of our message into RAX
          mov       rax, rbx                ; move the address in RBX to RAX as well

counter:
          cmp       byte [rax], 0           ; if we have reached to the end of the message
          jz        done                    ; jump to done
          inc       rax                     ; else increase the counter by one
          jmp       counter                 ; continue counting to the end

done:
          sub       rax, rbx                ; rax <- rbx - rax, rax now store the length of the message

write:
          mov       rdx, rax                ; move length of the message to rdx
          mov       rax, 0x02000004         ; system call for write
          mov       rdi, 1                  ; file handle 1 is stdout
          mov       rsi, message            ; address of string to output
          syscall                           ; invoke operating system to do the write

exit:
          mov       rax, 0x02000001         ; system call for exit
          xor       rdi, rdi                ; exit code 0
          syscall

          section   .data
message   db        "This is a message which I lazy to figure out its size.", 10      ; note the newline at the end

