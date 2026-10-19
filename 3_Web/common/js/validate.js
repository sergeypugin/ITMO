/**
 * Клиентская проверка числовых полей формы.
 *
 * Это удобство для пользователя, а не защита: сервер проверяет те же
 * значения независимо.
 */

/**
 * Приводит значение из формы к каноническому виду: убирает пробелы
 * и заменяет десятичную запятую на точку.
 */
export function normalizeNumber(raw) {
  return String(raw ?? "").trim().replace(",", ".");
}

/**
 * Разбирает значение формы в число.
 *
 * Number("") даёт 0, поэтому пустая строка и мусор возвращают NaN.
 */
export function parseNumber(raw) {
  const normalized = normalizeNumber(raw);

  if (normalized === "") {
    return Number.NaN;
  }

  const value = Number(normalized);
  return Number.isFinite(value) ? value : Number.NaN;
}

function rangeLabel(min, max) {
  return `[${min}; ${max}]`;
}

/**
 * Проверяет одно числовое значение: пустоту, формат и диапазон.
 *
 * @param {string} raw значение из формы
 * @param {{name: string, min: number, max: number}} options
 * @returns {{valid: boolean, value: number, message: string}}
 */
export function validateNumber(raw, { name, min, max }) {
  const normalized = normalizeNumber(raw);
  const value = parseNumber(raw);

  if (normalized === "") {
    return { valid: false, value: Number.NaN, message: `Введите значение координаты ${name}.` };
  }

  if (Number.isNaN(value)) {
    return { valid: false, value: Number.NaN, message: `Координата ${name} должна быть числом.` };
  }

  if (value < min || value > max) {
    return {
      valid: false,
      value,
      message: `Координата ${name} должна быть в диапазоне ${rangeLabel(min, max)}.`,
    };
  }

  return { valid: true, value, message: "" };
}
