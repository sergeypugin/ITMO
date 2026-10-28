    .data
    ; [0x0000; 0x00FF] -- порты, коды ошибок и адреса буферов/стека (32 байта)
    ; [0x0100; 0x06FF] -- программа
    ; 0x600 = 1536 байт -> 1536/10 команд -> 153 команды в худшем случае, но 10 байт на команду -- редкость
    ; [0x0700; 0x0720] -- буфер формата (33 байта: до 32 символов + `\0`)
    ; [0x0721; 0x072C] -- буфер числа (12 байт: до 10 символов int32 + '-' + `\0`)
    ; [0x072D; 0x0BFF] -- буфер результата (0x4D3 = 1235 байт)
    ; [0x0C00; 0x0FFB] -- стек (0x3FC = 1020 байт)

.org             0x0

in_port:         .word  0x80
out_port:        .word  0x84
err_code:        .word  -1
buffer_err_code: .word  -2
format_buffer_addr: .word  0x0700
number_buffer_addr: .word  0x0721
output_buffer_addr: .word  0x072D
stack_top_addr:  .word  0x0FFC

    .text
    .org     0x100

_start:
    movea.l  stack_top_addr, A0
    movea.l  (A0), A7

    movea.l  in_port, A0
    movea.l  (A0), A1
    movea.l  out_port, A0
    movea.l  (A0), A2

    movea.l  format_buffer_addr, A0
    movea.l  (A0), A0                        ; A0 = format buffer start
    movea.l  A0, A4                          ; A4 = format buffer write pointer
    clr.l    D0                              ; out_len = 0
    clr.l    D2                              ; format_len = 0

read_fmt_loop:
    move.b   (A1), D1                        ; cur_char -> D1
    cmp.b    10, D1                          ; '\n' ~ 10 в ASCII
    beq      read_fmt_done

    cmp.l    32, D2
    bge      error
    move.b   D1, (A4)+                       ; format_buffer.append(cur_char)
    add.l    1, D2
    jmp      read_fmt_loop

read_fmt_done:
    clr.b    (A4)
    movea.l  output_buffer_addr, A3
    movea.l  (A3), A3                        ; A3 -- output_buffer_ptr

scan_loop:
    move.b   (A0)+, D1                       ; *format_string_ptr++ -> D1
    cmp.b    0, D1
    beq      finish

    cmp.l    1235, D0
    bge      buffer_error                    ; result buffer is full

    cmp.b    '%' , D1
    bne      copy_format_char
    jsr      handle_placeholder
    jmp      scan_loop

copy_format_char:
    move.b   D1, (A3)+                       ; out_buf.append(D1)
    add.l    1, D0                           ; out_len++
    jmp      scan_loop

handle_placeholder:
    link     A6, -16
    ; Local frame: width, alignment, output length, sign flag
    clr.l    -4(A6)
    clr.l    -8(A6)
    move.l   D0, -12(A6)
    clr.l    -16(A6)

    move.b   (A0)+, D1                       ; first character after '%'
    cmp.b    '-' , D1
    bne      format_width
    move.l   1, -8(A6)                       ; left alignment
    move.b   (A0)+, D1

format_width:
    move.l   10, D3
width_loop:
    cmp.b    '0' , D1
    blt      check_specifier
    cmp.b    '9' , D1
    bgt      check_specifier

    sub.b    '0' , D1                        ; digit = ch - '0'
    move.l   -4(A6), D2
    mul.l    D3, D2
    add.l    D1, D2
    move.l   D2, -4(A6)
    move.b   (A0)+, D1
    jmp      width_loop

check_specifier:
    cmp.b    'd' , D1
    bne      error

    clr.l    D0                              ; signed accumulator = 0
    clr.l    D2                              ; digit_count = 0
    move.l   10, D3                          ; multiplier = 10

    move.b   (A1), D1                        ; first character of the integer
    cmp.b    '-' , D1
    bne      parse_int_char
    move.l   1, -16(A6)                      ; sign flag = 1
    move.b   (A1), D1                        ; first digit after '-'

parse_int_char:
    cmp.b    10, D1                          ; '\n' ~ 10 в ASCII
    beq      parse_int_done

    cmp.b    '0' , D1
    blt      error                           ; if ch < '0': error
    cmp.b    '9' , D1
    bgt      error                           ; if ch > '9': error

    sub.b    '0' , D1                        ; digit = ch - '0'
    cmp.l    -214748364, D0
    blt      error                           ; value is out of range
    bgt      accumulate_digit

    move.l   -16(A6), D3                     ; sign flag
    cmp.l    0, D3
    bne      negative_limit

; positive limit is 2147483647
positive_limit:
    cmp.l    7, D1
    bgt      error
    jmp      accumulate_digit

; negative limit is -2147483648
negative_limit:
    cmp.l    8, D1
    bgt      error

accumulate_digit:
    move.l   10, D3
    mul.l    D3, D0
    sub.l    D1, D0                          ; accumulate as a negative value
    add.l    1, D2                           ; digit_count += 1
    move.b   (A1), D1                        ; read the next character
    jmp      parse_int_char

parse_int_done:
    cmp.l    0, D2                           ; empty line
    beq      error

    move.l   -16(A6), D3                     ; sign flag
    cmp.l    0, D3
    bne      convert_int
    neg.l    D0                              ; positive input = -negative accumulator

convert_int:
    jsr      int_to_str                      ; D1 = num_len, buffer at number_buffer
    move.l   -12(A6), D0                     ; restore out_len
    move.l   -4(A6), D2                      ; width
    sub.l    D1, D2                          ; space = width - num_len
    bgt      space_ready
    clr.l    D2                              ; space = 0

space_ready:
    move.l   -8(A6), D3                      ; alignment
    cmp.l    0, D3
    bne      print_left_aligned

print_right_aligned:
    jsr      print_spaces
    jsr      print_num_buffer
    jmp      format_placeholder_done

print_left_aligned:
    jsr      print_num_buffer
    jsr      print_spaces

format_placeholder_done:
    unlk     A6
    rts

error:
    movea.l  err_code, A0
    move.l   (A0), D1
    move.l   D1, (A2)
    halt

buffer_error:
    movea.l  buffer_err_code, A0
    move.l   (A0), D1
    move.l   D1, (A2)
    halt

finish:
    movea.l  output_buffer_addr, A3
    movea.l  (A3), A3                        ; a3 = output_buffer_start
    move.l   D0, D2                          ; counter = out_len
    beq      flush_done
flush_loop:
    move.b   (A3)+, D1
    move.b   D1, (A2)                        ; output char
    sub.l    1, D2                           ; counter--
    bne      flush_loop
flush_done:
    halt


int_to_str:
    movea.l  number_buffer_addr, A4
    movea.l  (A4), A4                        ; num_buf_ptr -> A4
    clr.l    D1                              ; num_len = 0

    ; abs(-2147483648) is not representable as a signed 32-bit value
    cmp.l    -2147483648, D0
    beq      write_min_int

    clr.l    D3                              ; is_negative = 0
    cmp.l    0, D0
    bge      extract_digits
    move.l   1, D3                           ; is_negative = 1
    neg.l    D0                              ; value = -value

extract_digits:
    move.l   D0, D2
    div.l    10, D0
    move.l   D0, -(A7)                       ; sp.push(quotient)
    mul.l    10, D0
    sub.l    D0, D2
    move.l   (A7)+, D0                       ; sp.pop(quotient)
    add.b    '0' , D2
    move.b   D2, -(A7)                       ; sp.push(digit)
    add.l    1, D1                           ; num_len++

    cmp.l    0, D0
    bgt      extract_digits

    cmp.l    1, D3
    bne      copy_digits
    move.b   '-' , -(A7)                     ; sp.push(minus)
    add.l    1, D1                           ; num_len++

copy_digits:
    move.l   D1, D2
copy_digit_loop:
    move.b   (A7)+, (A4)+                    ; sp.pop() -> *num_buf++
    sub.l    1, D2                           ; num_len--
    bgt      copy_digit_loop

    clr.b    (A4)                            ; *num_buf = `\0`
    rts

write_min_int:
    move.b   '-' , (A4)+
    move.b   '2' , (A4)+
    move.b   '1' , (A4)+
    move.b   '4' , (A4)+
    move.b   '7' , (A4)+
    move.b   '4' , (A4)+
    move.b   '8' , (A4)+
    move.b   '3' , (A4)+
    move.b   '6' , (A4)+
    move.b   '4' , (A4)+
    move.b   '8' , (A4)+
    clr.b    (A4)
    move.l   11, D1                          ; length of -2147483648
    rts

print_spaces:
    cmp.l    0, D2
    ble      spaces_done
space_print_loop:
    cmp.l    1235, D0
    bge      error                           ; result buffer is full
    move.b   ' ' , (A3)+
    add.l    1, D0                           ; out_len++
    sub.l    1, D2                           ; spaces_left--
    bgt      space_print_loop
spaces_done:
    rts

print_num_buffer:
    movea.l  number_buffer_addr, A4
    movea.l  (A4), A4
print_buf_loop:
    move.b   (A4)+, D1
    cmp.b    0, D1
    beq      print_buf_done
    cmp.l    1235, D0
    bge      error                           ; result buffer is full
    move.b   D1, (A3)+
    add.l    1, D0                           ; out_len++
    jmp      print_buf_loop
print_buf_done:
    rts
