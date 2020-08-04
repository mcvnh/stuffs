; --------------------------------------------------------------------------------
; int slen(message)
;
; given a string and return its lengh
; --------------------------------------------------------------------------------

slen:
          push      rbx               ; push the message to the stack to preserve
          mov       rbx, rax          ; create a copy of the message
                                      ; rax store the original message

counter:
          cmp       byte [rax], 0     ; compare if the byte is the string termination
          jz        done              ; if true, then go to done
          inc       rax               ; or else increase the rax by 1
          jmp       counter           ; keep counting

done:
          sub       rax, rbx          ; rax <- rax - rbx
          pop       rbx               ; pop back the value of rbx
          ret                         ; exit the function


; --------------------------------------------------------------------------------
; int sprint(message)
;
; given a string and print it to the stdout device
; --------------------------------------------------------------------------------

sprint:
          push      rdi                ; push the value of rdi to stack to preserve
          push      rsi                ; push the value of rsi to stack to preserve
          push      rdx                ; push the value of rdx to stack to preserve
          push      rax                ; push the value of rax to stack to preserve

          call      slen
          mov       rdx, rax           ; store the length of rax into rdx

          pop       rax                ; pop the message back to rax
          mov       rsi, rax           ; address of string to output
          push      rax

          mov       rax, 0x02000004    ; system call for write
          mov       rdi, 1             ; file handle 1 is stdout
          syscall                      ; invoke operating system to do the write

          pop       rax
          pop       rdx                ; pop the value on the stack back to rdx
          pop       rsi                ; pop the value on the stack back to rsi
          pop       rdi                ; pop the value on the stack back to rdi
          ret


; --------------------------------------------------------------------------------
; int sprint(message)
;
; given a string and print it to the stdout device with line feed function
; --------------------------------------------------------------------------------

sprintlf:
          call      sprint             ; print out the message
          push      rax                ; push rax onto the stack to preserve
          mov       rax, 10            ; move line feed character into rax
          push      rax                ; push linefeed onto the stack so we can get the address
          mov       rax, rsp           ; move the address of current stack pointer into rax
          call      sprint             ; print out the linefeed
          pop       rax                ; remove our linefeed character from stack to rax
          pop       rax                ; restore the original value of rax
          ret                          ; exit function


; --------------------------------------------------------------------------------
; void exit()
;
; exit program and restore resources
; --------------------------------------------------------------------------------

exit:
          mov       rax, 0x02000001    ; system call for exit
          xor       rdi, rdi           ; exit code 0
          syscall                      ; in
          ret
