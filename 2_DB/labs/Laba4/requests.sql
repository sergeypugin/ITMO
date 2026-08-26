--Запрос 1
SELECT Н_ТИПЫ_ВЕДОМОСТЕЙ.НАИМЕНОВАНИЕ, Н_ВЕДОМОСТИ.ИД FROM Н_ТИПЫ_ВЕДОМОСТЕЙ
RIGHT JOIN Н_ВЕДОМОСТИ ON Н_ТИПЫ_ВЕДОМОСТЕЙ.ИД = Н_ВЕДОМОСТИ.ТВ_ИД
WHERE 1=1
  AND Н_ТИПЫ_ВЕДОМОСТЕЙ.НАИМЕНОВАНИЕ < 'Перезачет'
  AND Н_ВЕДОМОСТИ.ЧЛВК_ИД > 153285
  AND Н_ВЕДОМОСТИ.ЧЛВК_ИД < 142390;

--Индексы
CREATE INDEX index_vedomosti_chlv_id ON Н_ВЕДОМОСТИ USING btree (ЧЛВК_ИД);
CREATE INDEX index_vedomosti_tv_id ON Н_ВЕДОМОСТИ USING btree(ТВ_ИД);
CREATE INDEX index_types_name ON Н_ТИПЫ_ВЕДОМОСТЕЙ USING btree (НАИМЕНОВАНИЕ);

--Запрос 2
SELECT Н_ЛЮДИ.ИД, Н_ОБУЧЕНИЯ.НЗК, Н_УЧЕНИКИ.ИД
FROM Н_ЛЮДИ
RIGHT JOIN Н_ОБУЧЕНИЯ ON Н_ЛЮДИ.ИД = Н_ОБУЧЕНИЯ.ЧЛВК_ИД
RIGHT JOIN Н_УЧЕНИКИ ON Н_ЛЮДИ.ИД = Н_УЧЕНИКИ.ЧЛВК_ИД
WHERE Н_ЛЮДИ.ИМЯ > 'Ярослав'
  AND Н_ОБУЧЕНИЯ.ЧЛВК_ИД > 163484;

--Индексы
CREATE INDEX index_obucheniya_chlv_id ON Н_ОБУЧЕНИЯ USING btree (ЧЛВК_ИД);
CREATE INDEX index_people_name ON Н_ЛЮДИ USING btree (ИМЯ);