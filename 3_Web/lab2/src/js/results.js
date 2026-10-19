/**
 * Отрисовка таблицы результатов.
 *
 * История приходит с сервера в хронологическом порядке, поэтому для показа
 * разворачиваем её: последняя проверка должна быть сверху.
 */
const dateTimeFormatter = new Intl.DateTimeFormat("ru-RU", {
  dateStyle: "medium",
  timeStyle: "medium",
});

function buildRow(point) {
  const row = document.createElement("tr");

  const xCell = document.createElement("td");
  xCell.textContent = point.x;

  const yCell = document.createElement("td");
  yCell.textContent = point.y;

  const rCell = document.createElement("td");
  rCell.textContent = point.r;

  const hitCell = document.createElement("td");
  hitCell.textContent = point.hit ? "Да" : "Нет";
  hitCell.className = point.hit ? "hit-yes" : "hit-no";

  const date = new Date(point.serverTime);
  const timeCell = document.createElement("td");
  const time = document.createElement("time");
  time.dateTime = date.toISOString();
  time.textContent = dateTimeFormatter.format(date);
  timeCell.append(time);

  const durationCell = document.createElement("td");
  durationCell.textContent = point.executionTimeMs.toFixed(3);

  row.append(xCell, yCell, rCell, hitCell, timeCell, durationCell);
  return row;
}

export function renderHistory(tableBody, history) {
  const rows = [...history].reverse().map(buildRow);
  tableBody.replaceChildren(...rows);
}
