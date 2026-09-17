    .text
    ; Распределение в памяти:
    ; [0x0080;0x0087] - порты ввода/вывода
    ; [0x0100;0x03FF] - секция кода - до 0x300 = 3 * 256 байт = 3 * 256 / 4 команд = 192 команд
    ; [0x0400;0x05FF] - буфер входной строки in_buf - до 0x200 = 2 * 256 байт = 512 байт = 512 символов
    ; [0x0600;0x07FF] - буфер результата out_buf - до 0x200 = 2 * 256 байт = 512 байт = 512 символов
    ; [0x0800;0x0FFF] - стек: вершина sp = 0x0FFC, растёт вниз до 0x0800
    ;
    ; Для того, чтобы превращать символы в цифры, вычитаем '0' из символа. Например, '5' - '0' = 5.
    ; Также для обработки перевода строки (`\n`, он же LF) использовался код 10.
    ; Код в таблице ASCII был взят с https://www.industrialnets.ru/files/misc/ascii.pdf
    .org     0x0100
_start:
    ; инициализируем указатель стека на верхнюю границу памяти (4096 - 4 = 0xFFFC)
    lui      sp, %hi(0x0FFC)                 ; sp - указатель стека
    addi     sp, sp, %lo(0x0FFC)

    ; Константы
    addi     s1, zero, 0x80                  ; s1 - порт ввода
    addi     s2, zero, 0x84                  ; s2 - порт вывода
    ; s3 - текущий символ (используется при шифровании)
    ; s4 - величина сдвига
    addi     s5, zero, '0'                   ; s5 - '0'
    addi     s6, zero, 'a'                   ; s6 - 'a'
    addi     s7, zero, 'z'                   ; s7 - 'z'
    addi     s8, zero, 'A'                   ; s8 - 'A'
    addi     s9, zero, 'Z'                   ; s9 - 'Z'
    addi     s10, zero, 10                   ; s10 - 10 ('\n', он же LF)
    addi     s11, zero, 26                   ; s11 - размер алфавита

    jal      ra, parse_shift
    mv       s4, a0                          ; s4 - сохранённая величина сдвига

    jal      ra, encrypt_message

finish:
    halt

error:
    ; вывод значения минус один при некорректном сдвиге
    addi     t0, zero, -1                    ; t0 - код ошибки
    sw       t0, 0(s2)
    halt

parse_shift:
    addi     t0, zero, 0                     ; t0 - итоговое число сдвига
    addi     t1, zero, 0                     ; t1 - флаг наличия минуса
    addi     t2, zero, 0                     ; t2 - флаг наличия цифр

    ; читаем первый символ и проверяем знак минус
    lb       t3, 0(s1)                       ; t3 - текущий прочитанный символ
    addi     t4, zero, '-'                   ; t4 - для сравнения 1-го символа с минусом
    bne      t3, t4, parse_digits            ; if sym != '-': parse_digits()
    addi     t1, zero, 1                     ; t1 - запоминаем, что число отрицательное
    lb       t3, 0(s1)                       ; t3 - читаем символ после минуса

parse_digits:
    ; проверяем завершение первой строки
    beq      t3, s10, check_digits_existing  ; if sym == '\n': check_digits_existing()

    ; Используем push/pop для сохранения ra и t0-t3
    mv       a0, ra
    jal      ra, push
    mv       a0, t3
    jal      ra, push

    mv       a0, t3                          ; передаем символ в a0
    jal      ra, is_digit                    ; вызываем подпрограмму проверки цифры
    mv       t4, a0                          ; сохраняем результат проверки is_digit

    jal      ra, pop
    mv       t3, a0
    jal      ra, pop
    mv       ra, a0

    ; Если не цифра, переходим к ошибке
    beq      t4, zero, error

    ; переводим символ в цифру и накапливаем число
    sub      t5, t3, s5                      ; t5 - значение текущей цифры
    mul      t0, t0, s10                     ; t0 *= 10
    add      t0, t0, t5
    addi     t2, zero, 1                     ; подтверждаем наличие цифры

    lb       t3, 0(s1)
    j        parse_digits

check_digits_existing:
    beq      t2, zero, error                 ; if not has_digits: error()

parse_done:
    beq      t1, zero, normalize_shift       ; if not has_minus: normalize_shift()
    sub      t0, zero, t0

normalize_shift:
    ; shift %= 26
    rem      a0, t0, s11                     ; a0 - возвращаемый нормализованный сдвиг
    bgt      zero, a0, make_positive
    jr       ra
make_positive:
    add      a0, a0, s11
    jr       ra

is_digit:
    ; Проверяем, является ли a0 символом цифры ('0'..'9')
    ; Записываем 1 в a0 если да, 0 если нет.
    ; Записываем 1 в a0 если да, 0 если нет.
    bgt      s5, a0, not_digit               ; if '0' > a0: return 0
    addi     t6, zero, '9'
    bgt      a0, t6, not_digit               ; if a0 > '9': return 0
    addi     a0, zero, 1                     ; return 1
    jr       ra
not_digit:
    addi     a0, zero, 0
    jr       ra

encrypt_message:
    ; Сохраняем ra и s3 через push
    mv       a0, ra
    jal      ra, push

msg_loop:
    ; читаем символ текста и проверяем условие завершения
    lb       s3, 0(s1)                       ; s3 - текущий символ
    beq      s3, s10, msg_done               ; if sym == '\n': msg_done()

    mv       a0, s3                          ; a0 - символ, который будет двигаться
    mv       a1, s4                          ; a1 - сдвиг, который будет уменьшаться
    jal      ra, shift_char

    ; выводим результат в порт
    sb       a0, 0(s2)
    j        msg_loop

msg_done:

    jal      ra, pop
    mv       ra, a0
    jr       ra

shift_char:
    ; Сохраняем ra через push перед вложенным вызовом
    mv       t0, a0                          ; t0 = входящий символ
    mv       a0, ra
    jal      ra, push                        ; сохраняем ra на стек
    mv       a0, t0                          ; восстанавливаем символ в a0

    ; if sym not in ['A'; 'Z']: check_lower()
    bgt      s8, a0, check_lower             ; if 'A' > sym: check_lower()
    bgt      a0, s9, check_lower             ; if sym > 'Z': check_lower()

    ; сдвигаем заглавную букву
    mv       a2, s8                          ; a2 = 'A'
    j        shift

check_lower:
    ; if sym not in ['a'; 'z']: shift_char_done()
    bgt      s6, a0, shift_done              ; if 'a' > sym: shift_done()
    bgt      a0, s7, shift_done              ; if sym > 'z': shift_done()

    ; сдвигаем строчную букву
    mv       a2, s6                          ; a2 = 'a'

shift:
    ; Вариант 1: передача аргументов (char, shift, base) в shift_in_range через стек!
    jal      ra, push                        ; push char (a0)
    mv       a0, a1
    jal      ra, push                        ; push shift (a1)
    mv       a0, a2
    jal      ra, push                        ; push base (a2)

    jal      ra, shift_in_range

shift_done:
    mv       t4, a0                          ; t4 = итоговый символ
    jal      ra, pop
    mv       ra, a0
    mv       a0, t4
    jr       ra

shift_in_range:
    ; Функция сдвига с получением со стека base, shift, char
    mv       t4, ra                          ; сохраняем ra во временный регистр t4

    jal      ra, pop
    mv       t3, a0                          ; t3 = base ('A' или 'a')

    jal      ra, pop
    mv       t2, a0                          ; t2 = shift

    jal      ra, pop
    mv       t1, a0                          ; t1 = char

    ; Вычисление сдвига: (char - base + shift) % 26 + base
    sub      t0, t1, t3                      ; t0 = char - base (0-25)
    add      t0, t0, t2                      ; t0 += shift
    rem      t0, t0, s11                     ; t0 %= 26
    add      a0, t0, t3                      ; a0 = t0 + base

    mv       ra, t4                          ; восстанавливаем ra
    jr       ra

push:
    ; Помещаем значение из a0 на стека
    addi     sp, sp, -4
    sw       a0, 0(sp)
    jr       ra

pop:
    ; Извлекаем значение с стека в a0
    lw       a0, 0(sp)
    addi     sp, sp, 4
    jr       ra

    .data

    ; .org 0x0400  ; буфер входных данных
    ; .org 0x0600  ; буфер результатов
    ; .org 0x0800  ; максимум для стека
    ; .org 0x0FFC  ; верхушка стека, растет вниз к 0x0800
