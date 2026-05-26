;Задание №1. Разработать программу для работы с элементами массива M, в которой:
;1. Массив имеет следующие характеристики:
;- адрес начала массива в памяти БЭВМ - 0x6cc;
;- число измерений исходного массива - 1;
;- количество элементов исходного массива - 21;
;- каждый элемент является знаковым числом с разрядностью 19 бит;
;- нумерация элементов начинается с 3;
;- элементы хранятся в массиве по границам слов, нет необходимости в плотной упаковке;
;2. Для элементов массива необходимо вычислить одно значение по правилам:
;- агрегировать необходимо только для элементы массива с кратными 2-м i-индексами;
;- из выбранных элементов необходимо вычислить исключающее 'ИЛИ' значений и записать результат в память по адресу 0x400.
;- Результатом является одно 32-х разрядное число!
;Примечание: все числа представлены в десятичной системе счисления, если явно не указано иное.

ORG 0
START:
CYCLE:
    LD CURID
    AND #1; нужен лишь последний бит для чётности
    BEQ PROCESS; если чётный, то ксорим
SKIP:;иначе скип хода
    LD (PTR)+
    LD (PTR)+; это мы прочитали данные, которые мы не будем использовать
    JUMP NEXT
PROCESS:
    LD (PTR)+
    ST CURL
    LD (PTR)+
    ST CURH
    CALL EXT
; XOR(A,B)=(A ИЛИ B) И НЕ(A И B)
XORINGL:
    LD CURL
    OR XORL
    ST TMP
    LD CURL
    AND XORL
    NOT
    AND TMP
    ST XORL
XORINGH:
    LD CURH
    OR XORH
    ST TMP
    LD CURH
    AND XORH
    NEG
    AND TMP
    ST XORH
NEXT:
    LD (CURID)+; индекс++
    LOOP LEN
    JUMP CYCLE
    LD XORL
    ST (NEW_PTR)+
    LD XORH
    ST (NEW_PTR)+
    HLT

EXT:
    LD CURH
    AND BITM; узнаём знак числа
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

LEN: WORD 21
PTR: WORD 0x6CC
NEW_PTR: WORD 0x400
CURL: WORD 0x0
CURH: WORD 0x0
XORL: WORD 0x0; изначально ставим ноль, с 1-м числом ксор даст само число
XORH: WORD 0x0
TMP: WORD 0x0
CURID: WORD 0x11;3
BITM: WORD 0x0004; причём маска для старшего слова
POSM: WORD 0x0003
NEGM: WORD 0xFFFA

; TEST DATA
;ORG 0x6CC
;WORD 2 DUP (243); X3 SKIP
;X4: WORD 0x7800
;    WORD 0x2233
;WORD 2 DUP (243); X5 SKIP
;X6: WORD 0x5555
;    WORD 0x6666