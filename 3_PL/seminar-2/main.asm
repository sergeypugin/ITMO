%include "lib.asm"; подключаем dfa_match
global _start

section .data
    test_str: db "ddaad", 0
    msg_yes:  db "YES", 10
    msg_no:   db "NO", 10
    ; Динамическое вычисление длины сообщения
    len_yes   equ $ - msg_yes
    len_no    equ $ - msg_no

section .text
_start:
    mov  rdi, test_str
    call dfa_match
    test rax, rax
    jz   .print_no

    mov  rax, 1
    mov  rdi, 1
    mov  rsi, msg_yes
    mov  rdx, len_yes
    syscall
    jmp  .exit

.print_no:
    mov  rax, 1
    mov  rdi, 1
    mov  rsi, msg_no
    mov  rdx, len_no
    syscall

.exit:
    mov  rax, 60
    xor  rdi, rdi
    syscall
