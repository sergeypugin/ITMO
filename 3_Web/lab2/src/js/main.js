import { requestCheck } from "./api.js";
import { validateInput } from "./validation.js";
import { renderCanvas } from "./graph.js";
import { renderHistory } from "./results.js";
import { showResultToast, showRequestToast, showValidationToast } from "./toasts.js";

document.addEventListener("DOMContentLoaded", () => {
  const form = document.getElementById("point-form");
  const yInput = document.getElementById("y-val");
  const rInput = document.getElementById("r-val");
  const historyBody = document.getElementById("history");
  const submitButton = form.querySelector(".submit-btn");

  let history = [];

  form.addEventListener("submit", async (event) => {
    event.preventDefault();

    const xInput = form.querySelector('input[name="x"]:checked');
    const check = validateInput({
      x: xInput ? xInput.value : "",
      y: yInput.value,
      r: rInput.value,
    });

    if (!check.valid) {
      showValidationToast(check.message);
      return;
    }

    setLoading(true);

    try {
      const payload = await requestCheck(check.values);
      history = payload.history;
      renderHistory(historyBody, history);
      renderCanvas(history);
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

  renderCanvas(history);

  // Шрифт может загрузиться позже первого кадра: подписи осей перерисовываем.
  document.fonts?.ready.then(() => renderCanvas(history));
});
