## **HTTP** - _HyperText Transfer Protocol_
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
* [Основы форм в HTML](https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Structuring_content/HTML_forms) – структура тега `<form>`, атрибуты и организация полей.
* [Базовые элементы управления](https://developer.mozilla.org/en-US/docs/Learn_web_development/Extensions/Forms/Basic_native_form_controls) – как работают текстовые поля ввода `<input type="text">`, выпадающие списки `<select>` и кнопки.
* [Валидация форм](https://developer.mozilla.org/en-US/docs/Learn_web_development/Extensions/Forms/Form_validation) – концепция перехвата и проверки данных перед отправкой.

#### CSS - _Cascading Style Sheets_
* [Базовые селекторы](https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Styling_basics/Basic_selectors) – селекторы по классу (`.class`) и идентификатору (`#id`).
* [Комбинаторы](https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Styling_basics/Combinators) – как работает селектор дочерних элементов (`parent > child`), который строго требует ваш вариант.
* [Псевдоклассы](https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Styling_basics/Pseudo_classes_and_elements) – как использовать псевдоэлементы `::before` и `::after` (тоже обязательное требование).
* [Каскад](https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Styling_basics/Handling_conflicts) – приоритеты правил, наследование стилей от предков к потомкам.
* [Блочная модель](https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Styling_basics/Box_model) – как работают `margin`, `padding` и почему размеры задаются в процентах.

#### Canvas API
* [Рисование на Canvas](https://developer.mozilla.org/en-US/docs/Games/Tutorials/2D_Breakout_game_pure_JavaScript/Create_the_Canvas_and_draw_on_it) – практичный пошаговый пример создания холста, рисования линий, прямоугольников и дуг.
* [Учебник по Canvas API](https://developer.mozilla.org/ru/docs/Web/API/Canvas_API/Tutorial) – подробный справочник методов рисования.

#### JavaScript
* [DOM](https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Scripting/DOM_scripting) – как находить элементы на странице и менять их содержимое.
* [События](https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Scripting/Events) – перехват кликов по кнопкам и события отправки формы `submit`.
* [localStorage](https://developer.mozilla.org/ru/docs/Web/API/Window/localStorage) – сохранение истории проверок между перезагрузками страницы.
* [Intl](https://developer.mozilla.org/ru/docs/Web/JavaScript/Reference/Global_Objects/Intl/DateTimeFormat) – встроенный инструмент браузера для форматирования даты и времени с учётом часового пояса и русской локализации (`ru-RU`).
