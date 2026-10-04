section .text


; Принимает код возврата и завершает текущий процесс
global exit
exit:
    mov rax, 60
    syscall

; Принимает указатель на нуль-терминированную строку, возвращает её длину
global string_length
string_length:
    xor rax, rax
.loop:
    cmp byte [rdi + rax], 0
    je .end
    inc rax
    jmp .loop
.end:
    ret

; Принимает указатель на нуль-терминированную строку, выводит её в stdout
global print_string
print_string:
    push rdi
    call string_length
    pop rsi      ; rsi = адрес строки
    mov rdx, rax ; rdx = длина строки для sys_write
    mov rdi, 1
    mov rax, 1
    syscall
    ret

; Принимает код символа и выводит его в stdout
global print_char
print_char:
    push rdi
    mov rax, 1
    mov rdi, 1
    mov rsi, rsp
    mov rdx, 1
    syscall
    pop rdi
    ret

; Переводит строку (выводит символ с кодом 0xA)
global print_newline
print_newline:
    mov rdi, 10
    jmp print_char

; Выводит беззнаковое 8-байтовое число в десятичном формате
; Для беззнакового uint64 максимум 2^64 - 1 = 18446744073709551615 (20 цифр).
; С учетом нуль-терминатора нужно 21 байт, выделим 24 на стеке.
global print_uint
print_uint:
    mov rax, rdi
    mov rcx, 10
    sub rsp, 24
    mov byte [rsp + 23], 0
    lea r8, [rsp + 23]

.loop:
    xor rdx, rdx
    div rcx
    add dl, '0'
    dec r8
    mov byte [r8], dl
    test rax, rax
    jnz .loop

    mov rdi, r8
    call print_string
    add rsp, 24
    ret

; Выводит знаковое 8-байтовое число в десятичном формате
global print_int
print_int:
    cmp rdi, 0
    jge .positive

    push rdi
    mov rdi, '-'
    call print_char
    pop rdi
    neg rdi; делаем число положительным, чтобы сохранить знак

.positive:
    jmp print_uint

; Принимает два указателя на нуль-терминированные строки, возвращает 1 если они равны, 0 иначе
global string_equals
string_equals:
.loop:
    mov al, byte [rdi]
    mov cl, byte [rsi]
    cmp al, cl
    jne .not_equal
    test al, al
    jz .equal
    inc rdi
    inc rsi
    jmp .loop
.equal:
    mov rax, 1
    ret
.not_equal:
    xor rax, rax
    ret

; Читает один символ из stdin и возвращает его. Возвращает 0 если достигнут конец потока
global read_char
read_char:
    push 0
    mov rax, 0
    mov rdi, 0
    mov rsi, rsp
    mov rdx, 1
    syscall
    test rax, rax
    jle .eof
    pop rax
    jmp .done
.eof:
    pop rax
    xor rax, rax
.done:
    ret

; Принимает: адрес начала буфера, размер буфера
; Читает в буфер слово из stdin, пропуская пробельные символы в начале.
; Пробельные символы -- это пробел 0x20, табуляция 0x9 и перевод строки 0xA.
; Останавливается и возвращает 0 если слово слишком большое для буфера
; При успехе возвращает адрес буфера в rax, длину слова в rdx.
; При неудаче возвращает 0 в rax
; Эта функция должна дописывать к слову нуль-терминатор
global read_word
read_word:
    push r12
    push r13
    push r14

    mov r12, rdi
    mov r13, rsi
    xor r14, r14

    test r13, r13
    jz .overflow

.skip_whitespace:
    call read_char
    test al, al
    jz .success
    cmp al, ' '; ' ' имеет код 0x20, так что "<= ' '" - условие непечатаемого символа
    jbe .skip_whitespace

.process_char:
    lea rcx, [r14 + 1]
    cmp rcx, r13
    jge .overflow
    mov byte [r12 + r14], al
    inc r14

.read_loop:
    call read_char
    test al, al
    jz .success
    cmp al, ' '
    jbe .success
    jmp .process_char

.success:
    mov byte [r12 + r14], 0
    mov rax, r12
    mov rdx, r14
    jmp .done

.overflow:
    xor rax, rax

.done:
    pop r14
    pop r13
    pop r12
    ret


; Принимает указатель на строку, пытается
; прочитать из её беззнаковое число.
; Возвращает в rax: число, rdx : его длину в символах
; rdx = 0 если число прочитать не удалось
global parse_uint
parse_uint:
    xor rax, rax
    xor rdx, rdx
    mov r8, 10
.loop:
    movzx rcx, byte [rdi + rdx]
    cmp cl, '0'
    jb .done
    cmp cl, '9'
    ja .done
    sub cl, '0'
    imul rax, r8; imul - знаковое умножение
    add rax, rcx
    inc rdx
    jmp .loop
.done:
    ret




; Принимает указатель на строку, пытается
; прочитать из её знаковое число.
; Если есть знак, пробелы между ним и числом не разрешены.
; Возвращает в rax: число, rdx : его длину в символах (включая знак, если он был)
; rdx = 0 если число прочитать не удалось
global parse_int
parse_int:
    cmp byte [rdi], '-'
    jne parse_uint

    inc rdi
    push rdi
    call parse_uint
    pop rdi

    test rdx, rdx
    jz .fail
    neg rax
    inc rdx
    jmp .done
.fail:
    xor rax, rax
    xor rdx, rdx
.done:
    ret

; Принимает указатель на строку, указатель на буфер и длину буфера
; Копирует строку в буфер
; Возвращает длину строки если она умещается в буфер, иначе 0
global string_copy
string_copy:
    push rdi
    push rsi
    push rdx
    call string_length
    pop rdx
    pop rsi
    pop rdi

    mov r8, rax; r8 = string length
    lea rcx, [rax + 1]
    cmp rcx, rdx
    ja .too_long

    xor rcx, rcx
.copy_loop:
    mov dl, byte [rdi + rcx]
    mov byte [rsi + rcx], dl
    test dl, dl
    jz .done
    inc rcx
    jmp .copy_loop

.done:
    mov rax, r8; return length
    ret

.too_long:
    xor rax, rax
    ret
