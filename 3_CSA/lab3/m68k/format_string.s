    ; [0x0000; 0x000B] -- адреса портов и код ошибки (12 байт)
    ; [0x0100; 0x06FF] -- программа
    ; 0x600 = 1536 байт -> 1536/10 команд -> 153 команды в худшем случае, но 10 байт на команду -- редкость
    ; [0x0700; 0x0720] -- буфер формата (33 байта: до 32 символов + `\0`)
    ; [0x0721; 0x072C] -- буфер числа (12 байт: до 10 символов int32 + '-' + `\0`)
    ; [0x072D; 0x0BFF] -- буфер результата (0x4D3 = 1235 байт)
    ; [0x0C00; 0x0FFB] -- стек (0x3FC = 1020 байт)

    .data
.org             0x0

in_port:         .word  0x80
out_port:        .word  0x84
err_code:        .word  -1
buffer_err_code: .word  -2

    .text
    .org     0x100

_start:
    movea.l  0x0FFC, A7                      ; sp = 0x0FFC

    movea.l  in_port, A0
    movea.l  (A0), A1
    movea.l  out_port, A0
    movea.l  (A0), A2

    movea.l  0x0700, A0                      ; a0 = format buffer write pointer
    clr.l    D0                              ; out_len = 0
    clr.l    D2                              ; format_len = 0

read_fmt_loop:
    move.b   (A1), D1                        ; cur_char -> D1
    cmp.b    10, D1                          ; '\n' ~ 10 в ASCII
    beq      read_fmt_done

    cmp.l    32, D2
    bge      error
    move.b   D1, (A0)+                       ; format_buffer.append(cur_char)
    add.l    1, D2
    jmp      read_fmt_loop

read_fmt_done:
    clr.b    (A0)
    movea.l  0x0700, A0                      ; a0 -- format_string_prt
    movea.l  0x072D, A3                      ; a3 -- output_buffer_ptr

scan_loop:
    move.b   (A0)+, D1                       ; *format_string_ptr++ -> D1
    cmp.b    0, D1
    beq      finish

    cmp.l    1235, D0
    bge      buffer_error                    ; result buffer is full

    cmp.b    '%' , D1
    beq      handle_placeholder

    move.b   D1, (A3)+                       ; out_buf.append(D1)
    add.l    1, D0                           ; out_len++
    jmp      scan_loop

handle_placeholder:
    clr.l    D2                              ; width = 0
    clr.l    D3                              ; is_left = 0

    move.b   (A0)+, D1                       ; *format_ptr++ -> D1
    cmp.b    '-' , D1
    bne      sign_anyway
    move.l   1, D3                           ; is_left = 1
    move.b   (A0)+, D1

sign_anyway:
    move.l   D3, -(A7)                       ; sp.push(is_left)
    move.l   10, D3                          ; multiplier = 10

width_loop:
    cmp.b    '0' , D1
    blt      check_specifier
    cmp.b    '9' , D1
    bgt      check_specifier

    sub.b    '0' , D1                        ; digit = ch - '0'
    mul.l    D3, D2                          ; width *= 10
    add.l    D1, D2                          ; width += digit
    move.b   (A0)+, D1
    jmp      width_loop

check_specifier:
    move.l   (A7)+, D3                       ; is_left -> D3
    cmp.b    'd' , D1
    bne      error

    move.l   D2, -(A7)                       ; sp.push(width)
    move.l   D3, -(A7)                       ; sp.push(is_left)
    move.l   D0, -(A7)                       ; sp.push(out_len)
    clr.l    -(A7)                           ; sp.push(sign_flag)

    clr.l    D0                              ; signed accumulator = 0
    clr.l    D2                              ; digit_count = 0
    move.l   10, D3                          ; multiplier = 10

parse_int_loop:
    move.b   (A1), D1                        ; ch = read_char()
    cmp.b    10, D1                          ; '\n' ~ 10 в ASCII
    beq      parse_int_done

    cmp.b    '-' , D1
    beq      parse_minus

    cmp.b    '0' , D1
    blt      parse_error                     ; if ch < '0': error
    cmp.b    '9' , D1
    bgt      parse_error                     ; if ch > '9': error

    sub.b    '0' , D1                        ; digit = ch - '0'
    cmp.l    -214748364, D0
    blt      parse_error                     ; value is out of range
    bgt      accumulate_digit

    move.l   (A7), D3                        ; sign flag
    cmp.l    0, D3
    bne      negative_limit

; positive limit is 2147483647
positive_limit:
    cmp.l    7, D1
    bgt      parse_error
    jmp      accumulate_digit

; negative limit is -2147483648
negative_limit:
    cmp.l    8, D1
    bgt      parse_error

accumulate_digit:
    move.l   10, D3
    mul.l    D3, D0
    sub.l    D1, D0                          ; accumulate as a negative value
    add.l    1, D2                           ; digit_count += 1
    jmp      parse_int_loop

parse_minus:
    cmp.l    0, D2
    bne      parse_error
    move.l   1, (A7)                         ; sign flag = 1
    jmp      parse_int_loop

parse_int_done:
    cmp.l    0, D2                           ; empty line
    beq      parse_error

    move.l   (A7)+, D3                       ; sign flag
    cmp.l    0, D3
    bne      convert_int
    neg.l    D0                              ; positive input = -negative accumulator

convert_int:
    jsr      int_to_str                      ; D1 = num_len, buffer at 0x0721
    move.l   (A7)+, D0                       ; restore out_len
    move.l   (A7)+, D3                       ; restore left_align
    move.l   (A7)+, D2                       ; restore width

    sub.l    D1, D2                          ; space = width - num_len
    bgt      space_ready
    clr.l    D2                              ; space = 0

space_ready:
    cmp.l    0, D3
    bne      print_left_aligned

print_right_aligned:
    jsr      print_spaces
    jsr      print_num_buffer
    jmp      scan_loop

print_left_aligned:
    jsr      print_num_buffer
    jsr      print_spaces
    jmp      scan_loop

finish:
    movea.l  0x072D, A3                      ; a3 = output_buffer_start
    move.l   D0, D2                          ; counter = out_len
    beq      flush_done
flush_loop:
    move.b   (A3)+, D1
    move.b   D1, (A2)                        ; output char
    sub.l    1, D2                           ; counter--
    bne      flush_loop
flush_done:
    halt

parse_error:
    move.l   (A7)+, D3                       ; discard sign flag
    move.l   (A7)+, D0                       ; restore out_len
    jmp      error

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

int_to_str:
    movea.l  0x0721, A4                      ; num_buf_ptr -> A4
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
    movea.l  0x0721, A4
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
