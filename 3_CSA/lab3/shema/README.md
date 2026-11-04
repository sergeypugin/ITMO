# Схема, или как понятную вещь делать вообще непонятно

## Overview

Ох, как же трудно делать схему в отличие от обычного написания кода на ассемблере с отличной докой. Приходится лазить по интернету в поисках примеров. Нашёл только один -- [evgrart | acc32-harv](https://github.com/evgrart/ITMOlabs/blob/master/computer-system-architecture/lab3/acc32-harv.svg), зато какой! Браво, Артём, браво!

> [!note]
> Из тулов выбора нет соверешнно: только [drawio](https://www.drawio.com/) и ничего больше (возможно я недостаточно хорошо искал)

> [!note]
> ; Точные правила по разбивке команды на байты можно посмотреть [в коде самих архитектур](https://github.com/ryukzak/wrench/tree/master/src/wrench/Wrench/Isa)

> [!tip]
> Как гласит принцип **KISS**: ***Keep It Simple, Stupid***.
> Именно это от вас ожидают: не нужны "осминоги" из шин, не нужен Verilog (да, был парень, который 2 недели мастерил процессор, чтобы услышать "Не, это слишком сложно") -- просто нарисуйте схему.

## Моя схема -- m68k-neumann-cache

[m68k-neumann-cache](m68k-neumann-cache.md)

> [!tip]
> О том, как реализовать кэш (не только в m68k, архитектура может быть любой), было написано [на Хабре](https://habr.com/ru/articles/179647)

### Перевод в бинарник

Увы, но почему-то экспорт в SVG от draw.io работает ооочень плохо, так что пришлось экспортировать в PNG. Использовал следующие команды (предварительно надо сделать `cd 3_CSA/lab3/shema`):

#### Bash

Тёмная тема:
```bash
& "/c/Program Files/draw.io/draw.io.exe" --export --format png --theme dark --scale 3 --border 20 --output m68k-neumann-cache-dark.png m68k-neumann-cache.drawio
```

Светлая тема:
```bash
"/c/Program Files/draw.io/draw.io.exe" --export --format png --theme light --scale 3 --border 20 --output m68k-neumann-cache-light.png m68k-neumann-cache.drawio
```

### PowerShell

Тёмная тема:
```bash
& "C:\Program Files\draw.io\draw.io.exe" --export --format png --theme dark --scale 3 --border 20 --output m68k-neumann-cache-dark.png m68k-neumann-cache.drawio
```

Светлая тема:
```bash
& "C:\Program Files\draw.io\draw.io.exe" --export --format png --theme light --scale 3 --border 20 --output m68k-neumann-cache-light.png m68k-neumann-cache.drawio
```
