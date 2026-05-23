;Задание №1. Разработать программу для работы с элементами массива M, в которой:
;1. Массив имеет следующие характеристики:
;- адрес начала массива в памяти БЭВМ - 0x6e1;
;- число измерений исходного массива - 1;
;- количество элементов исходного массива - 13;
;- каждый элемент является знаковым числом с разрядностью 22 бит;
;- нумерация элементов начинается с 3;
;- элементы хранятся в массиве по границам слов, нет необходимости в плотной упаковке;
;2. Для элементов массива необходимо вычислить одно значение по правилам:
;- агрегировать необходимо только для элементы массива с кратными 3-м i-индексами;
;- из выбранных элементов необходимо вычислить cумму значений и записать результат в память по адресу 0x400.
;- Результатом является одно 32-х разрядное число!
;Примечание: все числа представлены в десятичной системе счисления, если явно не указано иное.

START:
CYCLE:
    LD CURID
    CALL IS_D3
    BEQ SIMPLE_SUM
SKIP:
    LD (PTR)+
    LD (PTR)+
    JUMP NEXT
SIMPLE_SUM:
    LD (PTR)+
    ST CURL
    LD (PTR)+
    ST CURH
    CALL EXT
    LD SUML
    ADD CURL
    ST SUML
    LD SUMH
    ADC CURH
    ST SUMH
NEXT:
    LD (CURID)+
    LOOP LEN
    JUMP CYCLE
; Запись по адресу
    LD SUML
    ST (NEW_PTR)+
    LD SUMH
    ST (NEW_PTR)+
    HLT

IS_D3:
    SUB #3
    BEQ IS_D3_RET
    BMI IS_D3_RET
    JUMP IS_D3
IS_D3_RET: RET

EXT:
    LD CURH
    AND SIGNM
    BNE EXT_NEG
EXT_POS:
    LD CURH
    AND POSM
    ST CURH
    RET
EXT_NEG:
    LD CURH
    OR NEGM
    ST CURH
    RET

;DATA:
PTR: WORD 0x6e1
NEW_PTR: WORD 0x400
LEN: WORD 7; Исправить в итоге нужно на 13
CURID: WORD 3
CURH: WORD 0
CURL: WORD 0
SIGNM: WORD 0x0020;  причём маска для старшего слова
POSM: WORD 0x001F
NEGM: WORD 0xFFE0
SUMH: WORD 0
SUML: WORD 0

;TEST DATA
ORG 0x6e1
X3: WORD 13
    WORD 0
X4: WORD 2 DUP(0)
X5: WORD 0xFFFF
    WORD 0; 2 числа для скипа
X6: WORD 31
    WORD 0
    WORD 4 DUP(0); 2 числа для скипа
X9: WORD 0xFF
    WORD 0

; EXPECTED TEST RESULTS:
;
; 0000_012B