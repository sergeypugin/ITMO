;Задание №1. Разработать программу для работы с элементами массива M, в которой:
;1. Массив имеет следующие характеристики:
;- адрес начала массива в памяти БЭВМ - 0x6ce;
;- число измерений исходного массива - 1;
;- количество элементов исходного массива - 18;
;- каждый элемент является знаковым числом с разрядностью 25 бит;
;- нумерация элементов начинается с 2;
;- элементы хранятся в массиве по границам слов, нет необходимости в плотной упаковке;
;2. Для элементов массива необходимо вычислить одно значение по правилам:
;- агрегировать необходимо только для элементы массива с кратными 2-м i-индексами;
;- из выбранных элементов необходимо вычислить минимальное значение и записать результат в память по адресу 0x400.
;- Результатом является одно 32-х разрядное число!
;Примечание: все числа представлены в десятичной системе счисления, если явно не указано иное.

START:
CYCLE:
    LD (PTR)+
    ST CURL
    LD (PTR)+
    ST CURH
    CALL EXT
    LD CURID
    CALL IS_D2
    BNE NEXT
MIN_PROCESS:
HTOH:
    LD CURH
    CMP MINH
    BEQ LTOL
    BLT CUR_BETTER; c-m<0 <=> c<m
    JUMP NEXT
LTOL:
    LD CURL
    CMP MINL
    ; BEQ очевидно скип
    BLO CUR_BETTER
    JUMP NEXT
CUR_BETTER:
    LD CURL
    ST MINL
    LD CURH
    ST MINH
NEXT:
    LD (CURID)+
    LOOP LEN
    JUMP CYCLE
SAVING:
    LD MINL
    ST (NEW_PTR)+
    LD MINH
    ST (NEW_PTR)+
    HLT

IS_D2:
    SUB #2
    BEQ IS_D2_RETURN
    BMI IS_D2_RETURN
    JUMP IS_D2
IS_D2_RETURN: RET

EXT:
    LD CURH
    AND BITM
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

;DATA
LEN: WORD 7; Исправить в итоге нужно на 18
PTR: WORD 0x6ce
NEW_PTR: WORD 0x400
CURID: WORD 2
CURL: WORD 0
CURH: WORD 0
MINL: WORD 0xFFFF
MINH: WORD 0x00FF
BITM: WORD 0x0100
POSM: WORD 0x00FF
NEGM: WORD 0xFF00

;TEST DATA
ORG 0x6ce
X2: WORD 0xFFFF
    WORD 0x06FF; без мусора 0xFF
    WORD 2 DUP (0)
X4: WORD 0xF00F
    WORD 0x05FF; без мусора 0x1FF
    WORD 0
    WORD 0x0100; абсолютный мин, который должны скипнуть
X6: WORD 0xF
    WORD 0x0100; по идее это ответ (т.е. будет FF00_000F)
    WORD 2 DUP (0)
X8: WORD 0xFFFF
    WORD 0x01FF

; EXPECTED TEST RESULTS:
;
; FF00_000F