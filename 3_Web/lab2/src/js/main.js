import { createApi } from "./api.js";
import { renderGraph } from "/common/js/graph.js";
import { formatServerTime, renderHistory } from "./results.js";
import { showResultToast, showRequestToast, showValidationToast } from "./toasts.js";
import { parseNumber, validateNumber } from "/common/js/validate.js";

const RANGES = {
  x: { min: -4, max: 4 },
  y: { min: -3, max: 5 },
  r: { min: 2, max: 5 },
};

const { requestCheck, requestHistory } = createApi({ endpoint: "/fcgi-bin/lab2-server.jar" });

const X_SELECT_MESSAGE = `Выберите координату X в диапазоне [${RANGES.x.min}; ${RANGES.x.max}].`;

const HISTORY_COLUMNS = [
  { key: "x" },
  { key: "y" },
  { key: "r" },
  {
    key: "hit",
    format: (hit) => (hit ? "Да" : "Нет"),
    className: (hit) => (hit ? "hit-yes" : "hit-no"),
  },
  { key: "serverTime", format: formatServerTime },
  { key: "executionTimeMs", format: (ms) => ms.toFixed(3) },
];

// Область варианта 8679: четверть круга во II, квадрат в III, треугольник в IV.
function drawShape(ctx, { centerX, centerY, scale, getStyleColor }) {
  ctx.fillStyle = getStyleColor("--graph-figure");

  // II четверть: четверть круга радиуса R
  ctx.beginPath();
  ctx.moveTo(centerX, centerY);
  ctx.arc(centerX, centerY, scale, Math.PI, 1.5 * Math.PI);
  ctx.closePath();
  ctx.fill();

  // III четверть: квадрат со стороной R
  ctx.fillRect(centerX - scale, centerY, scale, scale);

  // IV четверть: треугольник (0, 0), (R/2, 0), (0, -R)
  ctx.beginPath();
  ctx.moveTo(centerX, centerY);
  ctx.lineTo(centerX + scale / 2, centerY);
  ctx.lineTo(centerX, centerY + scale);
  ctx.closePath();
  ctx.fill();
}

document.addEventListener("DOMContentLoaded", () => {
  const form = document.getElementById("point-form");
  const yInput = document.getElementById("y-val");
  const rInput = document.getElementById("r-val");
  const historyBody = document.getElementById("history");
  const submitButton = form.querySelector(".submit-btn");

  let history = [];

  // Действующий радиус: допустимое значение из формы, иначе радиус
  // последней точки истории, иначе символический R.
  function currentRadius() {
    const formR = parseNumber(rInput.value);
    if (Number.isFinite(formR) && formR >= RANGES.r.min && formR <= RANGES.r.max) {
      return formR;
    }
    const last = history.length > 0 ? history[history.length - 1] : null;
    return last ? Number(last.r) : Number.NaN;
  }

  function draw() {
    renderGraph({ radius: currentRadius(), points: history, drawShape });
  }

  rInput.addEventListener("input", draw);

  form.addEventListener("submit", async (event) => {
    event.preventDefault();

    const xInput = form.querySelector('input[name="x"]:checked');
    const checkX = xInput
      ? validateNumber(xInput.value, { name: "X", ...RANGES.x })
      : { valid: false, value: Number.NaN, message: X_SELECT_MESSAGE };
    const checkY = validateNumber(yInput.value, { name: "Y", ...RANGES.y });
    const checkR = validateNumber(rInput.value, { name: "R", ...RANGES.r });

    const firstInvalid = [checkX, checkY, checkR].find((check) => !check.valid);

    if (firstInvalid) {
      showValidationToast(firstInvalid.message);
      return;
    }

    setLoading(true);

    try {
      const payload = await requestCheck({ x: checkX.value, y: checkY.value, r: checkR.value });
      history = payload.history;
      renderHistory(historyBody, history, { columns: HISTORY_COLUMNS });
      draw();
      showResultToast(payload.point);
    } catch (error) {
      showRequestToast(error.message, error instanceof TypeError);
    } finally {
      setLoading(false);
    }
  });

  function setLoading(isLoading) {
    submitButton.disabled = isLoading;
    submitButton.textContent = isLoading ? "Отправка..." : "Проверить";
  }

  draw();
  loadHistory();

  // Шрифт может загрузиться позже первого кадра: подписи осей перерисовываем.
  document.fonts?.ready.then(draw);

  // Восстанавливаем историю с сервера при загрузке страницы.
  async function loadHistory() {
    try {
      history = await requestHistory();
      renderHistory(historyBody, history, { columns: HISTORY_COLUMNS });
      draw();
    } catch (error) {
      showRequestToast(error.message, error instanceof TypeError);
    }
  }
});
