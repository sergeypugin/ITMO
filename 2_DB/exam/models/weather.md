# Прогнозирование погоды
## 1. Даталогическая модель

### Сущности предметной области и связь `N:M`
1. **ROLE** — Должность сотрудника.
2. **EMPLOYEE** — Сотрудник (метеоролог, синоптик).
3. **REGION** — Регион/Область.
4. **CITY** — Населенный пункт (город).
5. **STATION** — Физическая метеостанция.
6. **WEATHER_CONDITION** — Погодные условия (ясно, дождь, снег).
7. **FORECAST** — Прогноз погоды (Таблица-связка).

**Реализация связи Многие-ко-Многим (`N:M`):**
В метеорологии одна крупная метеостанция (`STATION`) способна рассчитывать и предоставлять прогнозы погоды для нескольких близлежащих городов (`CITY`), и наоборот — один город может получать метеоданные от нескольких различных станций вокруг него. Таблица `FORECAST` разрешает эту связь `N:M` напрямую, связывая конкретный город и станцию в определенный момент времени.

```mermaid
erDiagram
    ROLE {
        integer id PK
        text title "NN"
    }

    EMPLOYEE {
        integer id PK
        text name "NN"
        text surname "NN"
        integer role_id FK "NN"
    }

    REGION {
        integer id PK
        text name "NN"
        text code UK "NN"
    }

    CITY {
        integer id PK
        text name "NN"
        integer region_id FK "NN"
    }

    STATION {
        integer id PK
        text name "NN"
        boolean is_active "NN DEFAULT true"
    }

    WEATHER_CONDITION {
        integer id PK
        text description "NN"
    }

    %% Таблица-связка (N:M) - сам факт прогноза между городом и станцией
    FORECAST {
        integer id PK
        integer station_id FK "NN"
        integer city_id FK "NN"
        integer condition_id FK "NN"
        integer emp_id FK "NN"
        timestamp target_time "NN"
        numeric temp_celsius "NN"
        integer probability "NN CHECK probability BETWEEN 0 AND 100"
    }

    ROLE ||..o{ EMPLOYEE : "имеет"
    REGION ||..o{ CITY : "включает"
    
    %% Связи Banyak-to-Many к таблице FORECAST
    CITY ||..o{ FORECAST : "получает"
    STATION ||..o{ FORECAST : "генерирует"
    WEATHER_CONDITION ||..o{ FORECAST : "ожидается в"
    EMPLOYEE ||..o{ FORECAST : "подтверждает"
```

## 2. Триггеры

### Предложение триггера

Предположим, что мы не хотим, чтобы в `FORECAST` можно было добавлять прогнозы по прошлому. Сделаем для этого следующий триггер:
``` SQL
CREATE OR REPLACE FUNCTION prevent_past_forecast_updates() 
RETURNS trigger AS $$
BEGIN
    IF NEW.target_time <= current_timestamp THEN
        RAISE EXCEPTION 'Прогноз нельзя давать на время, которое уже прошло!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_past_updates
BEFORE INSERT OR UPDATE ON FORECAST
FOR EACH ROW EXECUTE FUNCTION prevent_past_forecast_updates();
```
### Виды триггеров

Триггеры делятся по разным критериям:
1. По уровню срабатывания:
   * *Строковые* (`FOR EACH ROW`) — выполняются для каждой измененной строки.
   * *Табличные* (`FOR EACH STATEMENT`) — выполняются один раз для всей SQL-команды, независимо от числа затронутых строк.
2. По времени срабатывания:
   * `BEFORE` — до выполнения операции.
   * `AFTER` — после выполнения операции.
   * `INSTEAD OF` — триггеры замещения (применяются только для представлений/VIEW).
3. По перехватываемому событию:
   * *DML-триггеры* (`INSERT`, `UPDATE`, `DELETE`).
   * *DDL-триггеры* (`CREATE`, `ALTER`, `DROP`).

## 3. Запрос с `INNER JOIN`

Предположим, нам нужно получить названия метеостанций, названия их городов, ожидавшуюся температуру, вероятность и время прогноза для всех случаев, в которых прогнозировались аномальные морозы (температура ниже -30 градусов) для этих станций:

```SQL
SELECT S.name AS station_name, C.name AS city_name, F.temp_celsius, F.probability, F.target_time
FROM FORECAST F
INNER JOIN STATION S ON S.id = F.station_id
INNER JOIN CITY C ON C.id = F.city_id
WHERE F.temp_celsius < -30;
```

## 4. План выполнения запроса

Перед выполнением запроса создадим B-tree индекс на столбец температуры, так как в запросе используется фильтрация по диапазону (`< -30`):

```SQL
CREATE INDEX idx_forecast_temp ON FORECAST USING btree(temp_celsius);
```

Эффективный план выполнения будет построен в виде левостороннего дерева (снизу вверх) с применением алгоритма `Index Nested Loop Join` для использования преимуществ индекса и конвейерной обработки:
```mermaid
flowchart BT
    res([Result])
    
    %% Финальная проекция выводит только столбцы из SELECT
    proj_final(["π C.name, S.name, F.temp_celsius, F.probability, F.target_time"])
    
    join2(["⋈ F.city_id = C.id"])
    join1(["⋈ F.station_id = S.id"])
    
    %% Ранняя проекция для города (только ID для связи и Name для вывода)
    proj_city(["π C.id, C.name"])
    city["City (C)"]
    
    %% Ранняя проекция для станции (только ID для связи и Name для вывода)
    proj_station(["π S.id, S.name"])
    station["Station (S)"]
    
    %% Ранняя проекция для прогнозов (только ID связей и нужные в SELECT поля)
    proj_forecast(["π F.station_id, F.city_id, F.temp_celsius, F.probability, F.target_time"])
    sel1(["σ F.temp_celsius < -30"])
    forecast["Forecast (F)"]
    
    forecast --> sel1
    sel1 --> proj_forecast
    
    station --> proj_station
    
    proj_forecast --> join1
    proj_station --> join1
    
    city --> proj_city
    
    join1 --> join2
    proj_city --> join2
    
    join2 --> proj_final
    proj_final --> res
```

**ВАЖНО:**
Тут будет использоваться именно `Index Nested Loop Join`. Почему?
#TODO объяснить + сделать в `README` рассказ про то, какие алгоритмы вообще есть (и воспользоваться конспектом Артёма the практика)