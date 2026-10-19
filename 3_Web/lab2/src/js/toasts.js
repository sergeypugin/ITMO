/**
 * Всплывающие уведомления о результате проверки и об ошибках.
 *
 * Новое уведомление встаёт сверху и сдвигает предыдущие вниз, а само исчезает
 * через несколько секунд, чтобы не копилось больше пары сообщений.
 */
const LIFETIME_MS = 5000;
const MAX_TOASTS = 5;
const MAX_TOASTS_NARROW = 2;

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

  // Повтор того же сообщения не должен плодить копии при частых кликах.
  const newest = stack.firstElementChild;

  if (newest?.dataset.signature === `${message.title}|${message.meta}`) {
    return;
  }

  const toast = buildToast(message);
  toast.dataset.signature = `${message.title}|${message.meta}`;
  toast.addEventListener("click", () => dismiss(toast));
  stack.prepend(toast);

  // На узких экранах уведомления закрывают контент, поэтому держим не больше двух.
  const limit = window.matchMedia("(max-width: 1279px)").matches ? MAX_TOASTS_NARROW : MAX_TOASTS;

  while (stack.children.length > limit) {
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
