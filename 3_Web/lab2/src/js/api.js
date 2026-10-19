/**
 * Слой доступа к FastCGI-серверу.
 *
 * Адреса вынесены в константы: их достаточно поменять в одном месте,
 * если на Helios маршруты будут отличаться от /fcgi-bin/.
 */
export const API_URL = "/fcgi-bin/lab2-server.jar";
export const HISTORY_URL = `${API_URL}?history`;

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

  return requestJson(`${API_URL}?${params.toString()}`);
}

/**
 * Запрашивает накопленную историю проверок.
 *
 * @returns {Promise<object[]>}
 */
export async function requestHistory() {
  const payload = await requestJson(HISTORY_URL);
  return payload.history ?? [];
}

async function requestJson(url) {
  const response = await fetch(url, {
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
