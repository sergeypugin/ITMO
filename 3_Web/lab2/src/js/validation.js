/**
 * Клиентская проверка формы.
 *
 * Это удобство для пользователя, а не защита: сервер проверяет те же
 * значения независимо.
 */
export const RANGES = {
  x: { min: -4, max: 4 },
  y: { min: -3, max: 5 },
  r: { min: 2, max: 5 },
};

function normalizeNumber(raw) {
  return String(raw ?? "").trim().replace(",", ".");
}

function rangeLabel(range) {
  return `[${range.min}; ${range.max}]`;
}

function checkNumber(raw, name, range) {
  const normalized = normalizeNumber(raw);
  let message = "";
  let value = Number.NaN;

  if (normalized === "") {
    message = `Введите значение координаты ${name}.`;
  } else {
    value = Number(normalized);
    if (!Number.isFinite(value)) {
      message = `Координата ${name} должна быть числом.`;
    } else if (value < range.min || value > range.max) {
      message = `Координата ${name} должна быть в диапазоне ${rangeLabel(range)}.`;
    }
  }

  return { message, value };
}

export function validateInput({ x, y, r }) {
  const xValue = Number(normalizeNumber(x));
  const checkedY = checkNumber(y, "Y", RANGES.y);
  const checkedR = checkNumber(r, "R", RANGES.r);

  let message = "";
  if (!Number.isFinite(xValue) || xValue < RANGES.x.min || xValue > RANGES.x.max) {
    message = `Выберите координату X в диапазоне ${rangeLabel(RANGES.x)}.`;
  } else {
    message = checkedY.message || checkedR.message;
  }

  return {
    valid: message === "",
    message,
    values: { x: xValue, y: checkedY.value, r: checkedR.value },
  };
}
