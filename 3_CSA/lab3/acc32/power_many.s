    .data

.org             0
input_addr:      .word  0x80               ; Адрес начала входных данных
output_addr:     .word  0x84               ; Адрес начала выходных данных

error_val:       .word  -1                 ; Некорректный ввод
overflow_val:    .word  0xCCCCCCCC         ; Значение при переполнении

const_0:         .word  0
const_1:         .word  1
const_4:         .word  4

count:           .word  0                  ; Число пар (счётчик для вычислений)
total_pairs:     .word  0                  ; Число пар (счётчик для вывода результата)
words_to_read:   .word  0                  ; Чисел после count поступит (вычислится как count * 2, для чтения всех пар чисел)

base:            .word  0                  ; Текущее основание степени
exp:             .word  0                  ; Текущий показатель степени
res:             .word  0                  ; Промежуточный результат возведения в степень

    ; Указатели на буфер результатов
buf_write_ptr:   .word  0xA00              ; Указатель на буфер входных данных (для записи)
buf_read_ptr:    .word  0xA00              ; Указатель на буфер входных данных (для чтения)
res_ptr:         .word  0x400              ; Указатель на буфер результатов (для записи)
out_ptr:         .word  0x400              ; Указатель на буфер результатов (для чтения)

    ; Из-за таких адресов у нас возникают лимиты
    ; 1. Максимум 0x400 - 0x100 = 0x300 = 3 * 256 байт = 3 * 256 / 5 команды = 153,6 команды для программы
    ; (но многие команды занимают не 5, а 1 байт, так что это оценка снизу).
    ;
    ; 2. Максимум 0xA00 - 0x400 = 0x600 = 6 * 256 байт = 6 * 256 / 4 слова = 384 слов для результатов
    ; Откуда возникает логичное ограничение - максимум 384 пар входных данных, которые
    ; будут располагаться в адресах 0xA00-0xFFFF (0x600 слов = 384 слова).

    .text

    .org         0x0100                      ;  Важно не залезть на порты input_addr и output_addr
_start:
    ; Загружаем число пар из input_addr ~ 0x80
    ; Можно было бы написать и `load_addr 0x80`, но хардкод - это плохо
    load_addr    input_addr                  ; acc <- input_addr
    load_acc                                 ; acc <- mem[acc] ~ mem[input_addr]
    store_addr   count                       ; count <- acc
    store_addr   total_pairs                 ; total_pairs <- acc

    ; Проверяем, что count <= 0 или нет
    load_addr    count
    bltz         error                       ; если count < 0, то выводим ошибку
    beqz         error                       ; если count == 0, то выводим ошибку

    ; Вычисляем words_to_read = count * 2
    load_addr    count
    add          count
    store_addr   words_to_read

read_all_inputs:
    ; Считываем слово из input_addr
    load_addr    input_addr
    load_acc
    ; Увы, но тут аналога store_ind нет

    ; Сохраняем в in_buf
    store_ind    buf_write_ptr

    ; buf_write_ptr += 4
    load_addr    buf_write_ptr
    add          const_4
    store_addr   buf_write_ptr

    ; words_to_read--
    load_addr    words_to_read
    sub          const_1
    store_addr   words_to_read

    ; Проверяем, все ли входные данные загружены
    load_addr    words_to_read
    beqz         pair_loop

    jmp          read_all_inputs

pair_loop:
    ; Загружаем base
    load_addr    buf_read_ptr
    load_acc
    store_addr   base

    ; buf_read_ptr += 4
    load_addr    buf_read_ptr
    add          const_4
    store_addr   buf_read_ptr

    ; Загружаем exp
    load_addr    buf_read_ptr
    load_acc
    store_addr   exp

    ; buf_read_ptr += 4
    load_addr    buf_read_ptr
    add          const_4
    store_addr   buf_read_ptr

    ; Проверяем, что exp < 0 или нет
    load_addr    exp
    bltz         error                       ; отрицательная степень в нашей программе не рассматривается

    ; res = 1
    load_addr    const_1
    store_addr   res

exp_loop:
    ; Если exp == 0, то оставляем res = 1
    load_addr    exp
    beqz         exp_done

    ; res = res * base
    clv                                      ; сбрасываем флаг переполнения
    load_addr    res
    mul          base                        ; acc = res * base
    bvs          overflow                    ; если V = 1, то переходим к обработке ошибки
    store_addr   res                         ; res = acc

    ; exp--
    load_addr    exp
    sub          const_1
    store_addr   exp
    jmp          exp_loop

exp_done:
    ; mem[res_ptr] = res
    load_addr    res
    store_ind    res_ptr

    ; Сдвигаем указатель записи на следующее слово: res_ptr += 4
    load_addr    res_ptr
    add          const_4
    store_addr   res_ptr

    ; Уменьшаем счётчик пар: count = count - 1
    load_addr    count
    sub          const_1
    store_addr   count

    ; Если остались ещё пары (count > 0), переходим к следующей
    bgtz         pair_loop

    ; Вывод в порт output_addr
results:
    load_addr    total_pairs
    beqz         finish

results_loop:
    ; Загружаем результат для каждой пары из буфера: acc = mem[out_ptr]
    load_addr    out_ptr
    load_acc

    ; mem[output_addr] <- acc
    store_ind    output_addr

    ; out_ptr += 4
    load_addr    out_ptr
    add          const_4
    store_addr   out_ptr

    ; total_pairs--
    load_addr    total_pairs
    sub          const_1
    store_addr   total_pairs
    bgtz         results_loop

finish:
    halt

error:
    ; Вывод значения -1 при некорректном вводе
    load_addr    error_val
    store_ind    output_addr
    halt

overflow:
    ; Вывод значения 0xCCCCCCCC при переполнении
    load_addr    overflow_val
    store_ind    output_addr
    halt

    .data

    ; .org 0x400; Буфер для хранения результатов.
    ; .org 0xA00; Буфер для хранения входных данных.
