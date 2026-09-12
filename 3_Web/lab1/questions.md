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
### HTML - _HyperText Markup Language_

- [Базовый синтаксис HTML — Изучите веб-разработку | MDN](https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Structuring_content/Basic_HTML_syntax)
- Шпоргалки по синтаксису
	- [HTML-шпаргалка для синтаксиса и распространённых задач - HTML | MDN](https://developer.mozilla.org/en-US/docs/Web/HTML/Guides/Cheatsheet)
	* [Базовые элементы управления](https://developer.mozilla.org/en-US/docs/Learn_web_development/Extensions/Forms/Basic_native_form_controls)
### CSS - _Cascading Style Sheets_
- [Начало работы с CSS — изучение веб-разработки | MDN](https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Styling_basics/Getting_started)
- [Селекторы CSS - Изучение веб-разработки | MDN](https://developer.mozilla.org/ru/docs/Learn_web_development/Core/Styling_basics/Basic_selectors)
- [Блочная модель - Изучение веб-разработки | MDN](https://developer.mozilla.org/ru/docs/Learn_web_development/Core/Styling_basics/Box_model)
- [Псевдоклассы, псевдоэлементы - Изучение веб-разработки | MDN](https://developer.mozilla.org/ru/docs/Learn_web_development/Core/Styling_basics/Pseudo_classes_and_elements)

> Статьи [Селекторы CSS - Изучение веб-разработки | MDN](https://developer.mozilla.org/ru/docs/Learn_web_development/Core/Styling_basics/Basic_selectors) и [Комбинаторы - Изучение веб-разработки | MDN](https://developer.mozilla.org/ru/docs/Learn_web_development/Core/Styling_basics/Combinators) ещё сыроваты, поэтому ответ пришлось искать самому

#### Селекторы

* **По типу (`h1`):** стилизует все теги данного типа
* **Класс (`.card`):** многократно используемый класс
* **Идентификатор (`#header`):** уникальный элемент страницы
* **Атрибут (`input[type="text"]`):** точечная стилизация по наличию или значению атрибута
* **Универсальный (`*`):** выбирает абсолютно все узлы документа

#### Selector Specificity

Когда к одному и тому же тегу подходят несколько правил CSS с разными цветами, браузер не гадает — он считает для каждого селектора **числовой вес** по строгому алгоритму.

Этот вес записывается как кортеж из трёх чисел: **(ID, Class, Type)**
1. **ID:** количество в селекторе `#id` (весит условно по 100 очков)
2. **Class:** количество классов `.class`, селекторов-атрибутов (`[type="text"]` и пр.) и псевдоклассов `:hover`, `:focus` и т.п. (весит условно по 10 очков)    
3. **Type:** количество тегов (`h1`, `div`, ...) и псевдоэлементов (`::before`, ...) (весит условно по 1 очку).

Так, селектор `#header .form-row > input[type="text"]` имеет вес **(1, 2, 1)**. Причём важно:
- Инлайн-стиль прямо в HTML (`style="..."`) весит условные 1000 очков ~ (1, 0, 0, 0)
- Селектор с пометкой `important!` весит условные 10000 ~ (1, 0, 0, 0, 0)

#### Комбинаторы

* `A B` **(Потомок / пробел):** любой элемент B на любой глубине вложенности внутри A.
* `A > B` **(Дочерний / прямой ребёнок):** только элемент B, являющийся непосредственным сыном A (строго 1-й уровень вложенности).
* `A + B` **(Смежный сосед):** единственный элемент B, расположенный непосредственно сразу за A на одном уровне.
* `A ~ B` **(Общий сосед):** любые элементы B, идущие после A в том же родителе.

#### Псевдоклассы `:` против Псевдоэлементов `::`
* [Псевдоклассы - CSS | MDN](https://developer.mozilla.org/ru/docs/Web/CSS/Pseudo-classes)
  **Одинарное двоеточие (`:`)** — описывает состояние существующего элемента:
  * `:hover` — наведение мыши;
  * `:focus` — поле получило фокус ввода;
  * `:active` — кнопка в момент нажатия (клик зажат).
* [Псевдоэлементы - CSS | MDN](https://developer.mozilla.org/ru/docs/Web/CSS/Pseudo-elements)
  **Двойное двоеточие (`::`)** — создаёт виртуальную сущность, которой нет в HTML-разметке:
  * `::before` — вставляет декоративный контент ПЕРЕД содержимым тега (требует свойства `content: ""`).
  * `::after` — вставляет декоративный контент ПОСЛЕ содержимого тега.

#### Способы подписки на события:
1. **Современный стандарт — `addEventListener`:**  
   `btn.addEventListener('click', (event) => { ... });`  
   *Позволяет вешать сколько угодно независимых обработчиков на одно событие.*
2. **Устаревший способ через свойства — `onclick`:**  
   `btn.onclick = function() { ... };`  
   *Минус: каждое новое присваивание затирает предыдущий обработчик.*
3. **Антипаттерн в HTML — инлайн-атрибуты:**  
   `<button onclick="doSomething()">`  
   *Грубо нарушает принцип разделения разметки и логики.*

#### Ключевые события в проекте:
* **`click`:** возникает при нажатии левой кнопки мыши (выбор значения координаты Y, кнопка «Очистить»).
* **`change`:** возникает у `<select>` или `<input>` в момент подтверждения выбора нового значения (выбор радиуса R).
* **`submit`:** возникает у тега `<form>` при попытке отправить данные.
* **`event.preventDefault()`:** [MDN](https://developer.mozilla.org/ru/docs/Web/API/Event/preventDefault) — отменяет стандартное поведение браузера (предотвращает перезагрузку страницы при событии `submit`).

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

### JavaScript

Общее:
- [Первое погружение в JavaScript - Изучение веб-разработки | MDN](https://developer.mozilla.org/ru/docs/Learn_web_development/Core/Scripting/A_first_splash)
- [Управление документами - Изучение веб-разработки | MDN](https://developer.mozilla.org/ru/docs/Learn_web_development/Core/Scripting/DOM_scripting)
- [Введение в события - Изучение веб-разработки | MDN](https://developer.mozilla.org/ru/docs/Learn_web_development/Core/Scripting/Events)

Специально для лабы:
- Хранение истории
	- [Window.localStorage - Интерфейсы веб API | MDN](https://developer.mozilla.org/ru/docs/Web/API/Window/localStorage)
	- [Intl.DateTimeFormat - JavaScript | MDN](https://developer.mozilla.org/ru/docs/Web/JavaScript/Reference/Global_Objects/Intl/DateTimeFormat)
- События в JavaScript
	* [Введение в события - Изучение веб-разработки | MDN](https://developer.mozilla.org/ru/docs/Learn_web_development/Core/Scripting/Events)
	* [EventTarget.addEventListener() - Веб API | MDN](https://developer.mozilla.org/ru/docs/Web/API/EventTarget/addEventListener)
-  Canvas API
	- [Создание Canvas и рисование на нём - Разработка игр | MDN](https://developer.mozilla.org/ru/docs/Games/Tutorials/2D_Breakout_game_pure_JavaScript/Create_the_Canvas_and_draw_on_it)
