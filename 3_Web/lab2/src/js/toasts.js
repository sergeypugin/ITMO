/**
 * Всплывающие уведомления о результате проверки и об ошибках.
 *
 * Новое уведомление встаёт сверху и сдвигает предыдущие вниз, а само исчезает
 * через несколько секунд; одновременно показывается не больше трёх.
 */
const LIFETIME_MS = 5000;
const MAX_TOASTS = 3;

const formatter = new Intl.NumberFormat("ru-RU", { maximumFractionDigits: 2 });

function buildToast({ variant, title, meta }) {
  const toast = document.createElement("div");
  toast.className = `toast toast-${variant}`;
  toast.setAttribute("role", "status");

  const dot = document.createElement("span");
  dot.className = "toast-dot";

  const body = document.createElement("div");
  body.className = "toast-body";

  const titleNode = document.createElement("span");
  titleNode.className = "toast-title";
  titleNode.textContent = title;

  const metaNode = document.createElement("span");
  metaNode.className = "toast-meta";
  metaNode.textContent = meta;

  body.append(titleNode, metaNode);
  toast.append(dot, body);

  return toast;
}

function dismiss(toast) {
  if (toast.classList.contains("toast-out")) {
    return;
  }

  toast.classList.add("toast-out");
  toast.addEventListener("animationend", () => toast.remove(), { once: true });
}

function showToast(message) {
  const stack = document.getElementById("toasts");

  if (!stack) {
    return;
  }

  const toast = buildToast(message);

  toast.addEventListener("click", () => dismiss(toast));
  stack.prepend(toast);

  while (stack.children.length > MAX_TOASTS) {
    stack.lastElementChild.remove();
  }

  setTimeout(() => dismiss(toast), LIFETIME_MS);
}

export function showResultToast(point) {
  if (!point) {
    return;
  }

  showToast({
    variant: point.hit ? "hit" : "miss",
    title: point.hit ? "Попадание" : "Мимо",
    meta: `x = ${formatter.format(point.x)}, y = ${formatter.format(point.y)}, R = ${formatter.format(point.r)}`,
  });
}

export function showValidationToast(message) {
  showToast({ variant: "error", title: "Проверьте ввод", meta: message });
}

export function showRequestToast(message, isNetworkError) {
  showToast({
    variant: "error",
    title: isNetworkError ? "Сервер недоступен" : "Ошибка проверки",
    meta: isNetworkError
      ? "Запрос не дошёл до FastCGI. Проверьте, что сервер запущен."
      : message,
  });
}
