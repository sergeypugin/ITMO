# Сервис по аренде самокатов

## 1. Даталогическая модель

**Список сущностей:**
1. **ROLE** — Роль/Должность сотрудника.
2. **EMPLOYEE** — Сотрудник (техник, менеджер).
3. **STATION** — Парковка/Станция.
4. **SCOOTER** — Самокат.
5. **CLIENT** — Клиент.
6. **DEVICE** — Устройство (смартфон клиента).
7. **TARIFF** — Тариф (стоимость аренды).
8. **TRIP** — Поездка (Таблица-связка).

**Реализация связи Многие-ко-Многим (`N:M`):**
Один и тот же клиент (`CLIENT`) за всё время пользования сервисом может совершить множество поездок на самых разных самокатах. И наоборот — один конкретный самокат (`SCOOTER`) за время своей эксплуатации используется в поездках множеством различных клиентов. Сущность `TRIP` (Поездка) разрешает эту связь `N:M`, объединяя клиента, выбранный самокат и примененный тариф в единую запись транзакции.

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

    STATION {
        integer id PK
        text address "NN"
        integer emp_id FK
    }

    SCOOTER {
        integer id PK
        integer station_id FK "NN"
        integer battery "NN CHECK battery BETWEEN 0 AND 100"
        boolean in_use "NN DEFAULT false"
    }

    CLIENT {
        integer id PK
        text name "NN"
        text surname "NN"
        text phone_number UK "NN"
    }

    DEVICE {
        integer id PK
        integer cli_id FK "NN"
        text os_type "NN"
        text app_version "NN"
    }

    TARIFF {
        integer id PK
        text title "NN"
        numeric price_per_min "NN CHECK price_per_min > 0"
    }

    %% Новая объединенная сущность "Поездка" (M:M)
    TRIP {
        integer id PK
        integer cli_id FK "NN"
        integer scooter_id FK "NN"
        integer tariff_id FK "NN"
        timestamp start "NN"
        timestamp end "CHECK end>=start"
        integer duration_min "NN DEFAULT 0 CHECK duration_min>=0"
        numeric cost "NN DEFAULT 0 CHECK cost>=0"
    }
    
    SCOOTER ||..o{ TRIP : "используется в"
    TARIFF ||..o{ TRIP : "применяется к"
    CLIENT ||..o{ DEVICE : "использует"
    CLIENT ||..o{ TRIP : "совершает"
	ROLE ||..o{ EMPLOYEE : "имеет"
    EMPLOYEE ||..o{ STATION : "обслуживает"
    STATION ||..o{ SCOOTER : "хранит"
```

## 2. Триггеры

### Предложение триггера

Предположим, что необходимо ввести правило: нельзя брать в аренду самокат, у которого заряд менее 10% или который уже используется.

Создадим триггер:
``` SQL
CREATE OR REPLACE FUNCTION check_scooter_status() 
RETURNS trigger AS $$
DECLARE
    scooter_battery integer;
    scooter_is_used boolean;
BEGIN
    SELECT battery, in_use INTO scooter_battery, scooter_is_used
    FROM SCOOTER
    WHERE id = NEW.scooter_id;
    IF scooter_battery < 10 THEN
        RAISE EXCEPTION 'Самокат разряжен! Уровень заряда: %', scooter_battery;
    END IF;
    IF scooter_is_used = true THEN
        RAISE EXCEPTION 'Данный самокат уже находится в аренде!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```
Воспользуемся им:
``` SQL
CREATE TRIGGER trg_check_scooter
BEFORE INSERT ON TRIP
FOR EACH ROW EXECUTE FUNCTION check_scooter_status();
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

Предположим, что нам нужно знать, кто из клиентов имел поездки за более, чем 500 рублей.

``` SQL
SELECT C.name, C.surname, T.cost, S.id FROM TRIP T
INNER JOIN CLIENT C ON C.id = T.cli_id
INNER JOIN SCOOTER S ON S.id = T.scooter_id
WHERE T.cost > 500;
```

## 4. План выполнения запроса

Перед выполнением запроса создадим индекс на `cost` в `TRIP`:

```SQL
CREATE INDEX idx_trip_cost ON TRIP USING btree(cost);
```

Теперь эффективный план будет такой (использовался алгоритм `Index Nested Loop Join`):

``` mermaid
flowchart BT
    res([result])
    
    %% Финальная проекция выводит только то, что просили в SELECT
    proj_final(["π C.name, C.surname, T.cost, S.id"])
    
    join2(["⋈ T.scooter_id = S.id"])
    join1(["⋈ T.cli_id = C.id"])
    
    %% Ранняя проекция для самоката (оставляем только ID)
    proj_scooter(["π S.id"])
    %%scooter["Scooter (S)"]%%
	scooter["Index Scan <br> SCOOTER (scooter_pkey)"]
    
    %% Ранняя проекция для клиента (только имя, фамилия и ID для связи)
    proj_client(["π C.id, C.name, C.surname"])
    %%client["Client (C)"]%%
    client["Index Scan <br> CLIENT (client_pkey)"]
	
    %% Ранняя проекция для поездки (только нужные для связей и фильтра поля)
    proj_trip(["π T.scooter_id, T.cli_id, T.cost"])
    sel1(["σ T.cost > 500"])
    %%trip["Trip (T)"]%%
	trip["Index Scan <br> TRIP (idx_trip_cost)"]
    
    %% Связи
    trip --> sel1
    sel1 --> proj_trip
    
    client --> proj_client
    
    %% Соединяем уже обрезанные таблицы
    proj_trip --> join1
    proj_client --> join1
    
    scooter --> proj_scooter
    
    join1 --> join2
    proj_scooter --> join2
    
    join2 --> proj_final
    proj_final --> res
```
