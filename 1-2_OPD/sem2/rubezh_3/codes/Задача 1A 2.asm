;Задание №1. Разработать программу для работы с элементами массива M, в которой:
;1. Массив имеет следующие характеристики:
;- адрес начала массива в памяти БЭВМ - 0x6e6;
;- число измерений исходного массива - 1;
;- количество элементов исходного массива - 13;
;- каждый элемент является знаковым числом с разрядностью 12 бит;
;- нумерация элементов начинается с 1;
;- элементы хранятся в массиве по границам слов, нет необходимости в плотной упаковке;
;2. Для элементов массива необходимо вычислить 32-х битное значение функции:
;- формула функции F(Mi) = 13 * Mi + 1425;
;- 32-битный результат необходимо поместить в другой массив по адресу 0x400
;- Результатом является массив 32-х разрядных чисел равным количеству элементов исходного массива.
;Примечание: все числа представлены в десятичной системе счисления, если явно не указано иное.

START:
CYCLE:
    LD (PTR)+
    ST CURL
    CALL EXT_L
    CALL FUNC
    LD CURL
    ST (NEW_PTR)+
    CALL EXT_H
    LD CURH
    ST (NEW_PTR)+
    LOOP LEN
    JUMP CYCLE
    HLT

EXT_L:
    AND SIGN_MASK
    BNE EXT_L_NEG
EXT_L_POS:
    LD CURL
    AND POS_MASK
    ST CURL
    RET
EXT_L_NEG:
    LD CURL
    OR NEG_MASK
    ST CURL
    RET

EXT_H:
     LD CURL
     AND MASK_FOR_H
     BNE EXT_H_NEG
EXT_H_POS:
    LD ZERO
    ST CURH
    RET
EXT_H_NEG:
    LD UNO
    ST CURH
    RET

FUNC:
    LD CURL
    ASL; 2x
    ADD CURL; 3x
    ASL; 6x
    ASL; 12x
    ADD CURL; 13x
    ADD CONST; 13x+1425
    ST CURL
    RET

;DATA:

NEW_PTR: WORD 0x400
PTR: WORD 0x6e6
LEN: WORD 5; Исправить в итоге нужно на 13
MASK: WORD 0xF000
SIGN_MASK: WORD 0x0800
MASK_FOR_H: WORD 0x8000
POS_MASK: WORD 0x07FF
NEG_MASK: WORD 0xF800
ZERO: WORD 0x0
UNO: WORD 0xFFFF
CONST: WORD 1425
CURL: WORD 0
CURH: WORD 0

;TEST DATA
ORG 0x6e6
WORD 1
WORD 10
WORD 0x0FFF; -1
WORD 0x7800; минимум c мусором
WORD 0x7777; максимум с мусором

; EXPECTED TEST RESULTS:
;
; 0000_059E
; 0000_0613
; 0000_0584
; FFFF_9D91
; 0000_669C