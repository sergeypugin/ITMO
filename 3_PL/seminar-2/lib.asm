; (d+(d+a)(a+d))(a+c)*
; Равносильно следующему
; dd+a+d(a+c)*

; Вход:  rdi — указатель на zero-terminated строку
; Выход: rax = 1 / 0

section .text
global dfa_match

dfa_match:
    jmp  .state_start

.state_accept:
    mov  eax, 1
    ret

.state_reject:
    xor  eax, eax
    ret

.state_start:
    mov  al, [rdi]
    test al, al
    jz   .state_reject
    inc  rdi
    cmp  al, 'd'
    jne  .state_reject

.state_D1:
    mov  al, [rdi]
    test al, al; выставляем ZF
    jz   .state_reject
    inc  rdi
    cmp  al, 'd'
    jne  .state_reject

.state_DD:
    mov  al, [rdi]
    test al, al
    jz   .state_reject
    inc  rdi
    cmp  al, 'd'
    je   .state_DD
    cmp  al, 'a'
    jne  .state_reject

.state_DDAA1:
    mov  al, [rdi]
    test al, al
    jz   .state_reject
    inc  rdi
    cmp  al, 'a'
    jne  .state_reject

.state_DDAA:
    mov  al, [rdi]
    test al, al
    jz   .state_reject
    inc  rdi
    cmp  al, 'a'
    je   .state_DDAA
    cmp  al, 'd'
    jne  .state_reject

.state_DDAAD:
    mov  al, [rdi]
    test al, al
    jz   .state_accept
    inc  rdi
    cmp  al, 'a'
    je   .state_DDAADAA
    jmp  .state_reject

.state_DDAADAA:
    mov  al, [rdi]
    test al, al
    jz   .state_reject
    inc  rdi
    cmp  al, 'a'
    je   .state_DDAADAA
    cmp  al, 'c'
    jne  .state_reject
    jmp  .state_DDAAD
