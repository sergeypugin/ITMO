// Отрисовка таблицы результатов. Последняя проверка отображается сверху.
const dateTimeFormatter = new Intl.DateTimeFormat("ru-RU", {
  dateStyle: "medium",
  timeStyle: "medium",
});

// Время сервера в виде элемента <time> с атрибутом dateTime.
export function formatServerTime(value) {
  const date = new Date(value);
  const time = document.createElement("time");
  time.dateTime = date.toISOString();
  time.textContent = dateTimeFormatter.format(date);
  return time;
}

function resolve(value, point, option) {
  return typeof option === "function" ? option(value, point) : option;
}

function buildCell(point, column) {
  const value = point[column.key];
  const cell = document.createElement("td");

  const content = column.format ? resolve(value, point, column.format) : value;

  if (content instanceof Node) {
    cell.append(content);
  } else {
    cell.textContent = content ?? "";
  }

  if (column.className) {
    cell.className = resolve(value, point, column.className);
  }

  return cell;
}

// Рендерит строки таблицы результатов по переданному списку колонок.
export function renderHistory(tableBody, history, { columns }) {
  const rows = [...history].reverse().map((point) => {
    const row = document.createElement("tr");
    columns.forEach((column) => row.append(buildCell(point, column)));
    return row;
  });

  tableBody.replaceChildren(...rows);
}
