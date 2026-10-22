// Двойная точность IEEE-754 хранит около 15--16 значащих десятичных цифр,
// поэтому более длинная дробная часть после Number() уже искажена.
export const MAX_PRECISION = 15;

// Приводит значение из формы к каноническому виду: убирает пробелы и меняет запятую на точку.
export function normalizeNumber(raw) {
  return String(raw ?? "").trim().replace(",", ".");
}

// Число знаков после десятичного разделителя в исходной записи.
export function countDecimalPlaces(raw) {
  const fraction = normalizeNumber(raw).split(".")[1];
  return fraction ? fraction.length : 0;
}

// Разбирает значение формы в число. Number("") даёт 0, поэтому пустая строка проверяется отдельно.
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

// Проверяет одно числовое значение: пустоту, формат, точность и диапазон.
export function validateNumber(raw, { name, min, max, maxPrecision = MAX_PRECISION }) {
  const normalized = normalizeNumber(raw);
  const value = parseNumber(raw);

  if (normalized === "") {
    return { valid: false, value: Number.NaN, message: `Введите значение координаты ${name}.` };
  }

  if (Number.isNaN(value)) {
    return { valid: false, value: Number.NaN, message: `Координата ${name} должна быть числом.` };
  }

  if (countDecimalPlaces(raw) > maxPrecision) {
    return {
      valid: false,
      value,
      message: `Слишком большая точность для координаты ${name}: максимум ${maxPrecision} знаков после запятой / точки.`,
    };
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
