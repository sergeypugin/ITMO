    .text
_start:
    @p 0x80                  \ dataStack.push(val)
    @p 0x80                  \ dataStack.push(n)
    0x1F and                 \ shift = n & 0x1F

    rotate_n

    !p 0x84                  \ dataStack.pop() -> out

    halt

rotate_n:
    a!                       \ A = shift

loop:
    a                        \ dataStack.push(a)
    if loop_done             \ if a == 0: goto loop_done
    a -1 + a!                \ a -= 1
    rotate_one
    loop ;
loop_done:
    ;
rotate_one:
    dup                      \ Дублируем число для проверки знака
    -if pos                  \ if val >= 0: goto pos
neg:
    \ Добавляем 1 в начало, если в начале был бит знака
    2* 1 +
    ;
pos:
    2*
    ;
