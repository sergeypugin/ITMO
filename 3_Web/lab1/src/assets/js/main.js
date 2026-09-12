import { renderCanvas } from "./graph.js";
import { Storage } from "./storage.js";

document.addEventListener("DOMContentLoaded", () => {
  const form = document.getElementById("point-form");
  const xInput = document.getElementById("x-val");
  const yHiddenInput = document.getElementById("y-val");
  const rSelect = document.getElementById("r-val");
  const yButtons = document.querySelectorAll(".y-btn");
  const errorBox = document.getElementById("error-box");
  const historyTableBody = document.getElementById("history");
  const clearBtn = document.getElementById("clear-btn");

  const dateTimeFormatter = new Intl.DateTimeFormat("ru-RU", {
    dateStyle: "medium",
    timeStyle: "medium",
  });

  yButtons.forEach((btn) => {
    btn.addEventListener("click", () => {
      yButtons.forEach((b) => b.classList.remove("active"));
      btn.classList.add("active");
      yHiddenInput.value = btn.value;
      clearError();
    });
  });

  rSelect.addEventListener("change", () => {
    const currentR = parseFloat(rSelect.value);
    renderCanvas(currentR, Storage.getPoints());
    clearError();
  });

  function showError(message) {
    errorBox.textContent = message;
  }

  function clearError() {
    errorBox.textContent = "";
  }

  function validateForm(xVal, yVal, rVal) {
    if (xVal.trim() === "") {
      showError("Введите значение координаты X.");
      return false;
    }

    const normalizedX = xVal.replace(",", ".");
    const numX = Number(normalizedX);

    if (isNaN(numX)) {
      showError("Координата X должна быть числом.");
      return false;
    }
    if (numX <= -3 || numX >= 3) {
      showError("Координата X должна быть строго в интервале (-3 ... 3).");
      return false;
    }

    if (yVal === "") {
      showError("Выберите значение координаты Y нажатием кнопки.");
      return false;
    }

    if (!rVal || isNaN(Number(rVal))) {
      showError("Выберите радиус R из списка.");
      return false;
    }

    clearError();
    return true;
  }

  function checkHit(x, y, r) {
    // 1-я четверть: круг радиуса R/2
    if (x >= 0 && y >= 0) {
      return x * x + y * y <= (r / 2) * (r / 2);
    }
    // 2-я четверть: треугольник с функцией y <= 2x + R
    if (x <= 0 && y >= 0) {
      return x >= -r / 2 && y <= 2 * x + r;
    }
    // 3-я четверть: пусто
    if (x < 0 && y < 0) {
      return false;
    }
    // 4-я четверть: прямоугольник с x в [0, R] и y в [-R, 0]
    if (x >= 0 && y <= 0) {
      return x <= r && y >= -r;
    }
    return false;
  }

  function addRowToTable(point) {
    const row = document.createElement("tr");
    const dateObj = new Date(point.timestamp);

    row.innerHTML = `
      <td>${point.x}</td>
      <td>${point.y}</td>
      <td>${point.r}</td>
      <td class="${point.hit ? "hit-yes" : "hit-no"}">${point.hit ? "Да" : "Нет"}</td>
      <td>
        <time datetime="${dateObj.toISOString()}">
          ${dateTimeFormatter.format(dateObj)}
        </time>
      </td>
    `;
    historyTableBody.prepend(row);
  }

  function renderHistoryTable() {
    historyTableBody.innerHTML = "";
    const history = Storage.getPoints();
    history.forEach((p) => addRowToTable(p));
  }

  form.addEventListener("submit", (e) => {
    e.preventDefault(); // Запрещаем перезагрузку страницы!

    const rawX = xInput.value;
    const rawY = yHiddenInput.value;
    const rawR = rSelect.value;

    if (!validateForm(rawX, rawY, rawR)) {
      return;
    }

    const x = parseFloat(rawX.replace(",", "."));
    const y = parseFloat(rawY);
    const r = parseFloat(rawR);
    const isHit = checkHit(x, y, r);

    const newPoint = {
      x: x,
      y: y,
      r: r,
      hit: isHit,
      timestamp: Date.now(),
    };

    Storage.addPoint(newPoint);
    addRowToTable(newPoint);
    renderCanvas(r, Storage.getPoints());
  });

  clearBtn.addEventListener("click", () => {
    Storage.clearPoints();
    renderHistoryTable();
    const currentR = parseFloat(rSelect.value) || null;
    renderCanvas(currentR, []);
    clearError();
  });

  const history = Storage.getPoints();

  if (history.length > 0) {
    renderHistoryTable();
    const lastPoint = history[history.length - 1];
    xInput.value = lastPoint.x;
    yButtons.forEach((btn) => {
      if (parseFloat(btn.value) === lastPoint.y) {
        btn.classList.add("active");
        yHiddenInput.value = btn.value;
      } else {
        btn.classList.remove("active");
      }
    });
    rSelect.value = String(lastPoint.r);
    renderCanvas(lastPoint.r, history);
  } else {
    renderCanvas();
  }
});
