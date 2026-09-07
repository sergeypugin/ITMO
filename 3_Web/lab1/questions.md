## HTTP - _HyperText Transfer Protocol_
### URI, URL и URN

| Термин                            | Определение                                                                               | Вид                                                                                 |
| --------------------------------- | ----------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| URI (Uniform Resource Identifier) | уникальный идентификатор ресурса - символьная строка, позволяющая идентифицировать ресурс | `<схема> :< идентификатор - в - зависимости - от - схемы>`                          |
| URL (Uniform Resource Locator)    | URI, позволяющий определить местонахождение ресурса                                       | `https://se.ifmo.ru/courses/web .. /task.shtml`, `mailto:Joe.Bloggs@somedomain.com` |
| URN (Uniform Resource Name)       | URI, содержащий единообразное имя ресурса (не указывает на его местонахождение)           | `urn: isbn: 5170224575`, `urn: sha1: YNCKHTQCWBTRNJIV4WNAE52SJUQCZ05C`              |

### Методы HTTP

| Метод     | Назначение                                                                       | Безопасный? |                              Идемпотентный?                               |   Тело    |
| :-------- | :------------------------------------------------------------------------------- | :---------: | :-----------------------------------------------------------------------: | :-------: |
| `GET`     | Запрашивает ресурс с сервера.                                                    |   **Да**    |                                  **Да**                                   | Не реком. |
| `HEAD`    | Точно такой же, как GET, но ответ без тела сообщения                             |   **Да**    |                                  **Да**                                   |    Нет    |
| `POST`    | Передаёт данные на сервер для обработки                                          |   **Нет**   |                 **Нет** (10 запросов создадут 10 записей)                 |  **Да**   |
| `PUT`     | Полностью заменяет / создаёт ресурс по указанному URI                            |   **Нет**   |     **Да** (повторная перезапись тем же самым даст тот же результат)      |  **Да**   |
| `PATCH`   | Частично обновляет ресурс                                                        |   **Нет**   | **Нет** (в общем случае, хотя некоторые операции могут быть идемпотентны) |  **Да**   |
| `DELETE`  | Удаляет указанный ресурс                                                         |   **Нет**   |  **Да** (удалить ресурс 1 раз или 5 раз — итог один: ресурса больше нет)  | Не реком. |
| `OPTIONS` | Запрашивает у сервера список поддерживаемых методов и параметров для данного URI |   **Да**    |                                  **Да**                                   | Не реком. |
| `CONNECT` | Устанавливает туннель к серверу через прокси                                     |   **Нет**   |                                  **Нет**                                  |    Нет    |
| `TRACE`   | Сервер возвращает клиенту обратно ровно то, что получил                          |   **Да**    |                                  **Да**                                   |    Нет    |

### Коды состояния
Состоят из 3-х цифр. Первая цифра - класс состояния:
- «1» – Informational – информационный;
- «2» – Success – успешно;
- «3» – Redirection – перенаправление;
- «4» – Client error – ошибка клиента;
- «5» – Server error – ошибка сервера.

## Code

>Ниже приведены ссылки на то, что стоит прочитать
#### HTML - _HyperText Markup Language_

- [Базовый синтаксис HTML — Изучите веб-разработку | MDN](https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Structuring_content/Basic_HTML_syntax)
- Шпоргалки по синтаксису
	- [HTML-шпаргалка для синтаксиса и распространённых задач - HTML | MDN](https://developer.mozilla.org/en-US/docs/Web/HTML/Guides/Cheatsheet)
	* [Базовые элементы управления](https://developer.mozilla.org/en-US/docs/Learn_web_development/Extensions/Forms/Basic_native_form_controls)
#### CSS - _Cascading Style Sheets_
- [Начало работы с CSS — изучение веб-разработки | MDN](https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Styling_basics/Getting_started)
- [Селекторы CSS - Изучение веб-разработки | MDN](https://developer.mozilla.org/ru/docs/Learn_web_development/Core/Styling_basics/Basic_selectors)
- [Блочная модель - Изучение веб-разработки | MDN](https://developer.mozilla.org/ru/docs/Learn_web_development/Core/Styling_basics/Box_model)
- [Псевдоклассы, псевдоэлементы - Изучение веб-разработки | MDN](https://developer.mozilla.org/ru/docs/Learn_web_development/Core/Styling_basics/Pseudo_classes_and_elements)

>Также важно где-то бы узнать, что такое селекторы и комбинаторы, но на MDN статьи ещё не готовы. Это вам на самостоятельное изучение.

По поводу стилей очень удобна следующая схема, чтобы разобраться во всяких `padding`:
```text
+------------------------------------+
|               MARGIN               |  <- Внешний отступ (отталкивает соседей)
|   +----------------------------+   |
|   |           BORDER           |   |  <- Рамка (граница элемента)
|   |   +--------------------+   |   |
|   |   |      PADDING       |   |   |  <- "Набивка" (отступ вокруг текста)
|   |   |   +------------+   |   |   |
|   |   |   |  CONTENT   |   |   |   |  <- Сам текст или картинка
|   |   |   +------------+   |   |   |
|   |   +--------------------+   |   |
|   +----------------------------+   |
+------------------------------------+
```

#### JavaScript

- [Первое погружение в JavaScript - Изучение веб-разработки | MDN](https://developer.mozilla.org/ru/docs/Learn_web_development/Core/Scripting/A_first_splash)
- [Управление документами - Изучение веб-разработки | MDN](https://developer.mozilla.org/ru/docs/Learn_web_development/Core/Scripting/DOM_scripting)
- [Введение в события - Изучение веб-разработки | MDN](https://developer.mozilla.org/ru/docs/Learn_web_development/Core/Scripting/Events)
- Специально для лабы:
	- [Window.localStorage - Интерфейсы веб API | MDN](https://developer.mozilla.org/ru/docs/Web/API/Window/localStorage)
	- [Intl.DateTimeFormat - JavaScript | MDN](https://developer.mozilla.org/ru/docs/Web/JavaScript/Reference/Global_Objects/Intl/DateTimeFormat)

##### Canvas API
- [Создание Canvas и рисование на нём - Разработка игр | MDN](https://developer.mozilla.org/ru/docs/Games/Tutorials/2D_Breakout_game_pure_JavaScript/Create_the_Canvas_and_draw_on_it)

