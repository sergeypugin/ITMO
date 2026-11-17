import { renderGraph } from "../common/js/graph.js";
import { validateNumber } from "../common/js/validate.js";
import { showResultToast, showRequestToast, showValidationToast } from "../common/js/toasts.js";
import { drawShape } from "./shape.js";

const X_VALUES = [-2, -1.5, -1, -0.5, 0, 0.5, 1, 1.5, 2];

const form = document.getElementById("point-form");
const canvas = document.getElementById("graph");

// Ячейка времени приходит пустой: сервер не знает часовой пояс посетителя.
// JS заполняет её локальным временем из epoch-метки data-ts. Таблица истории
// есть и на странице формы, и на странице результата.
function localizeDateCells() {
  const pad = (n) => String(n).padStart(2, "0");
  document.querySelectorAll("#history-body tr[data-ts] .time-cell").forEach((cell) => {
    const ts = Number(cell.closest("tr").dataset.ts);
    if (!ts) return;
    const d = new Date(ts);
    cell.textContent =
      pad(d.getDate()) + "." + pad(d.getMonth() + 1) + "." + d.getFullYear() +
      " " + pad(d.getHours()) + ":" + pad(d.getMinutes()) + ":" + pad(d.getSeconds());
  });
}

localizeDateCells();

if (form && canvas) {
  const xField = document.getElementById("selected-x");
  const rField = document.getElementById("selected-r");
  const yField = document.getElementById("y-val");
  const submitButton = form.querySelector('[type="submit"]');
  const historyBody = document.getElementById("history-body");
  let pending = false;
  let pendingPoint = null;

  function readHistory() {
    return Array.from(historyBody.rows, (row) => ({
      x: Number(row.dataset.x),
      y: Number(row.dataset.y),
      r: Number(row.dataset.r),
      hit: row.dataset.hit === "true",
    }));
  }

  function currentRadius() {
    const value = parseFloat(rField.value);
    return !isNaN(value) && value >= 1 && value <= 5 ? value : NaN;
  }

  function draw() {
    const radius = currentRadius();
    const scale = renderGraph({
      canvasId: "graph",
      radius,
      points: readHistory(),
      drawShape,
    });

    if (pendingPoint && !isNaN(radius)) {
      drawPendingPoint(scale, pendingPoint, radius);
    }

    return scale;
  }

  // Маркер появляется сразу после клика, не дожидаясь ответа сервера.
  function drawPendingPoint(scale, point, radius) {
    const ctx = canvas.getContext("2d");
    const x = canvas.width / 2 + (point.x / radius) * scale;
    const y = canvas.height / 2 - (point.y / radius) * scale;
    const accent = getComputedStyle(document.documentElement)
      .getPropertyValue("--accent")
      .trim() || "#b0524a";

    ctx.beginPath();
    ctx.arc(x, y, 11, 0, 2 * Math.PI);
    ctx.strokeStyle = accent;
    ctx.globalAlpha = 0.35;
    ctx.lineWidth = 2;
    ctx.stroke();
    ctx.globalAlpha = 1;

    ctx.beginPath();
    ctx.arc(x, y, 6, 0, 2 * Math.PI);
    ctx.fillStyle = accent;
    ctx.fill();
    ctx.strokeStyle = "#ffffff";
    ctx.lineWidth = 2;
    ctx.stroke();
  }

  function selectButton(groupId, field, value) {
    field.value = value;
    const container = document.getElementById(groupId);
    if (!container) return;

    container.querySelectorAll("button").forEach((button) => {
      const selected = button.dataset.value === String(value);
      button.classList.toggle("active", selected);
      button.setAttribute("aria-pressed", String(selected));
    });
  }

  document.getElementById("x-choices")?.addEventListener("click", (event) => {
    const button = event.target.closest("button[data-value]");
    if (button) selectButton("x-choices", xField, button.dataset.value);
  });

  document.getElementById("r-choices")?.addEventListener("click", (event) => {
    const button = event.target.closest("button[data-value]");
    if (button) {
      selectButton("r-choices", rField, button.dataset.value);
      draw();
    }
  });

  function validateForm() {
    const xResult = validateNumber(xField.value, { name: "X", min: -2, max: 2, maxPrecision: 1 });
    if (xResult.valid && !X_VALUES.includes(xResult.value)) {
      return "Выберите одно из предложенных значений X.";
    }

    const yResult = validateNumber(yField.value, { name: "Y", min: -3, max: 5, maxPrecision: 15 });
    const rResult = validateNumber(rField.value, { name: "R", min: 1, max: 5, maxPrecision: 0 });
    return [xResult, yResult, rResult].find((result) => !result.valid)?.message ?? "";
  }

  form.addEventListener("submit", (event) => {
    const validationMessage = validateForm();
    if (validationMessage) {
      event.preventDefault();
      showValidationToast(validationMessage);
    }
  });

  async function submitPoint(parameters) {
    if (pending) return;
    pending = true;
    submitButton.disabled = true;

    try {
      const response = await fetch(form.action, {
        method: "POST",
        body: parameters,
        credentials: "same-origin",
      });
      const html = await response.text();
      const resultDocument = new DOMParser().parseFromString(html, "text/html");
      const result = resultDocument.getElementById("check-result");
      const newRows = resultDocument.getElementById("history-body");

      if (!result || !newRows) {
        throw new Error("Сервер вернул ответ в неожиданном формате.");
      }
      if (result.dataset.kind === "error") {
        const errorText = result.querySelector("p")?.textContent.trim();
        throw new Error(errorText || "Не удалось проверить точку.");
      }

      pendingPoint = null;
      historyBody.replaceChildren(...Array.from(newRows.children));
      localizeDateCells();
      draw();
      showResultToast({
        x: Number(result.dataset.x),
        y: Number(result.dataset.y),
        r: Number(result.dataset.r),
        hit: result.dataset.kind === "hit",
      });
    } catch (error) {
      pendingPoint = null;
      draw();
      showRequestToast(
        error instanceof Error ? error.message : "Не удалось отправить запрос.",
        error instanceof TypeError,
      );
    } finally {
      pending = false;
      submitButton.disabled = false;
    }
  }

  canvas.addEventListener("click", (event) => {
    if (pending) return;
    const radius = currentRadius();
    if (isNaN(radius)) {
      showValidationToast("Сначала выберите радиус R, чтобы определить координаты точки по графику.");
      return;
    }

    const rect = canvas.getBoundingClientRect();
    const pixelX = (event.clientX - rect.left - canvas.clientLeft) * canvas.width / canvas.clientWidth;
    const pixelY = (event.clientY - rect.top - canvas.clientTop) * canvas.height / canvas.clientHeight;

    const scale = draw();
    const x = (pixelX - canvas.width / 2) * radius / scale;
    const y = (canvas.height / 2 - pixelY) * radius / scale;

    pendingPoint = { x, y, r: radius };
    draw();
    void submitPoint(new URLSearchParams({ x: String(x), y: String(y), r: String(radius), source: "graph" }));
  });

  const xContainer = document.getElementById("x-choices");
  for (const value of X_VALUES) {
    const button = document.createElement("button");
    button.type = "button";
    button.dataset.value = String(value);
    button.textContent = String(value);
    button.setAttribute("aria-pressed", "false");
    xContainer.append(button);
  }

  const history = readHistory();
  const lastPoint = history.at(-1);
  if (lastPoint) {
    selectButton("r-choices", rField, lastPoint.r);
    if (X_VALUES.includes(lastPoint.x)) selectButton("x-choices", xField, lastPoint.x);
    yField.value = String(Number(lastPoint.y.toFixed(15)));
  }
  draw();
  document.fonts?.ready.then(draw);
}
