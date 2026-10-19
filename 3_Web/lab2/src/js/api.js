/**
 * Слой доступа к FastCGI-серверу.
 *
 * Адрес вынесен в одну константу: его достаточно поменять в одном месте,
 * если на Helios маршрут будет отличаться от /fcgi-bin/lab2-server.jar.
 */
export const API_URL = "/fcgi-bin/lab2-server.jar";

/**
 * Отправляет GET-запрос на сервер и возвращает разобранный ответ.
 *
 * @param {{x: number, y: number, r: number}} point
 * @returns {Promise<{status: string, point: object, history: object[]}>}
 */
export async function requestCheck({ x, y, r }) {
  const params = new URLSearchParams({
    x: String(x),
    y: String(y),
    r: String(r),
  });

  const response = await fetch(`${API_URL}?${params.toString()}`, {
    method: "GET",
    headers: { Accept: "application/json" },
  });

  let payload;
  try {
    payload = await response.json();
  } catch {
    throw new Error(`Сервер вернул некорректный ответ (HTTP ${response.status}).`);
  }

  if (!response.ok || payload.status !== "ok") {
    throw new Error(payload?.message || `Ошибка сервера (HTTP ${response.status}).`);
  }

  return payload;
}
