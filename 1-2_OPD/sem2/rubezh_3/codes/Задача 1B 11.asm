;Задание №1. Разработать программу для работы с элементами массива M, в которой:
;1. Массив имеет следующие характеристики:
;- адрес начала массива в памяти БЭВМ - 0x6df;
;- число измерений исходного массива - 1;
;- количество элементов исходного массива - 14;
;- каждый элемент является знаковым числом с разрядностью 14 бит;
;- нумерация элементов начинается с 1;
;- элементы хранятся в массиве по границам слов, нет необходимости в плотной упаковке;
;2. Для элементов массива необходимо вычислить 32-х битное значение функции:
;- формула функции F(Mi) = 14 * Mi + 4689;
;- 32-битный результат необходимо поместить в другой массив по адресу 0x400
;- Результатом является массив 32-х разрядных чисел равным количеству элементов исходного массива.
;Примечание: все числа представлены в десятичной системе счисления, если явно не указано иное.

START:
CYCLE:
    LD (PTR)+
    PUSH
    CALL EXT
    POP; для чистоты стека
    CALL FUNC
    LD CURL
    ST (NEW_PTR)+
    LD CURH
    ST (NEW_PTR)+
    LOOP LEN
    JUMP CYCLE
    HLT

EXT:
    LD &1
    AND BITM
    BNE EXT_NEG
EXT_POS:
    LD &1
    AND POSM
    ST CURL
    LD ZERO
    ST CURH
    RET
EXT_NEG:
    LD &1
    OR NEGM
    ST CURL
    LD UNO
    ST CURH
    RET

FUNC:
    LD CURH
    ST OLDH
    LD CURL
    ST OLDL
    CALL MULTI2; 2x
    CALL ADD_ONE; 3x
    CALL MULTI2; 6x
    CALL MULTI2; 12x
    CALL ADD_ONE; 13x
    CALL ADD_ONE; 14x, хотя вообще проще было сделать цикл
    CALL ADD_CONST;14x+4689
    RET

MULTI2:
    LD CURL
    ASL
    ST CURL
    LD CURH
    ROL
    ST CURH
    RET

ADD_ONE:
    LD CURL
    ADD OLDL
    ST CURL
    LD CURH
    ADC OLDH
    ST CURH
    RET

ADD_CONST:
    LD CURL
    ADD CONST
    ST CURL
    LD CURH
    ADC #0
    ST CURH
    RET

;DATA

LEN: WORD 4; Исправить в итоге нужно на 14
PTR: WORD 0x6df
NEW_PTR: WORD 0x400
BITM: WORD 0x2000
POSM: WORD 0x1FFF
NEGM: WORD 0xE000
CURL: WORD 0
CURH: WORD 0
ZERO: WORD 0
UNO: WORD 0xFFFF
CONST: WORD 4689
OLDL: WORD 0
OLDH: WORD 0

;TEST DATA
ORG 0x6df
WORD 10
WORD 1
WORD 0x7FFF; -1 с мусором
WORD 0x5FFF; максимум с мусором

; EXPECTED TEST RESULTS:
;
; 0000_12DD
; 0000_125F
; 0000_1243
; 0001_D243