# Микроконтрольная №4

Тема: Servlets, JSP, JSTL, MVC

#### Вопрос 1. Какой элемент web.xml задаёт параметры инициализации для сервлета?

- [ ] creation-param
- [x] init-param
- [ ] param
- [ ] context-param

#### Вопрос 2. Какие утверждения о диспетчеризации через RequestDispatcher являются верными?

- [ ] RequestDispatcher доступен только для статических ресурсов
- [ ] RequestDispatcher всегда выполняет HTTP-редирект
- [x] RequestDispatcher можно получить через HttpServletRequest.getRequestDispatcher()
- [x] RequestDispatcher можно получить через ServletContext.getRequestDispatcher()

#### Вопрос 3. Какой метод жизненного цикла JSP вызывается контейнером для инициализации экземпляра страницы?

- [ ] constructor
- [x] jspInit()
- [ ] _jspInit()
- [ ] jspConstruct()

#### Вопрос 4. Какие теги JSTL Core используются для организации циклов и условий?

- [x] c:if
- [x] c:forEach
- [ ] c:if-else
- [ ] c:while

#### Вопрос 5. Архитектурный шаблон "MVC"

MVC (Model-View-Controller) разделяет приложение на три части:

- **Model** -- данные и бизнес-логика
- **View** -- представление, пользовательский интерфейс (HTML, JSP)
- **Controller** -- обрабатывает запросы пользователя, взаимодействует с моделью и выбирает представление для отображения
