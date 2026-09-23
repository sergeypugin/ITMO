    .data

.org             0
input_addr:      .word  0x80               ; Адрес начала входных данных
output_addr:     .word  0x84               ; Адрес начала выходных данных

error_val:       .word  -1                 ; Некорректный ввод
overflow_val:    .word  0xCCCCCCCC         ; Значение при переполнении

const_1:         .word  1
const_4:         .word  4

count:           .word  0                  ; Число пар (счётчик для вычислений)
total_pairs:     .word  0                  ; Число пар (счётчик для вывода результата)

status:          .word  0                  ; 0 - успех, иначе - значение ошибки (error_val/overflow_val)

base:            .word  0                  ; Текущее основание степени
exp:             .word  0                  ; Текущий показатель степени
res:             .word  0                  ; Промежуточный результат возведения в степень

    ; Указатели на буфер результатов
res_ptr:         .word  0x0300             ; Указатель на буфер результатов (для записи)
out_ptr:         .word  0x0300             ; Указатель на буфер результатов (для чтения)

    ; Из-за таких адресов у нас возникают лимиты
    ; [0x0100; 0x02FF] - секция кода (0x200 = 2 * 256 байт = 2 * 256 / 5 = 102,4 команды для программы)
    ; * но многие команды занимают не 5, а 1 байт, так что это оценка снизу
    ; [0x0300; 0x0FFF] - буфер результатов (0xD00 = 13 * 256 байт = 13 * 256 / 4 = 832 пар можно обработать)

    .text

    .org         0x0100                      ; Важно не залезть на порты input_addr и output_addr
_start:
    ; Загружаем число пар из input_addr ~ 0x80
    ; Можно было бы написать и `load_addr 0x80`, но хардкод - это плохо
    load_addr    input_addr                  ; acc <- input_addr
    load_acc                                 ; acc <- mem[acc] ~ mem[input_addr]
    store_addr   count                       ; count <- acc
    store_addr   total_pairs                 ; total_pairs <- acc

    ; Проверяем, что count <= 0 или нет
    bltz         count_error                 ; if count < 0: return -1
    beqz         count_error                 ; if count == 0: return -1

pair_loop:
    ; Загружаем base
    load_addr    input_addr
    load_acc
    store_addr   base

    ; Загружаем exp
    load_addr    input_addr
    load_acc
    store_addr   exp

    ; if status != 0: skip
    ; (просто считываем оставшиеся числа, чтобы опустошить входной порт 0x80)
    load_addr    status
    bnez         pair_next

    ; Проверяем, что exp < 0 или нет
    load_addr    exp
    bltz         exp_error                   ; отрицательная степень в нашей программе не рассматривается

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
    bvs          set_overflow_status         ; if V = 1: goto set_overflow_status
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
    jmp          pair_next

count_error:
    load_addr    error_val
    store_addr   status
    jmp          pair_next

exp_error:
    load_addr    error_val
    store_addr   status
    jmp          pair_next

set_overflow_status:
    load_addr    overflow_val
    store_addr   status
    jmp          pair_next

pair_next:
    ; count -= 1
    load_addr    count
    sub          const_1
    store_addr   count

    ; if count > 0: goto pair_loop
    bgtz         pair_loop

results:
    ; if status != 0: goto error
    load_addr    status
    bnez         error

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
    ; Вывод значения ошибки из переменной status
    load_addr    status
    store_ind    output_addr
    halt
