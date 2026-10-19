/**
 * Слой доступа к FastCGI-серверу.
 *
 * createApi принимает endpoint конкретной лабы, поэтому общий код не зависит
 * от имени jar-файла: достаточно передать /fcgi-bin/labN-server.jar.
 */
export function createApi({ endpoint }) {
  const historyUrl = `${endpoint}?history`;

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

  /**
   * Отправляет GET-запрос на сервер и возвращает разобранный ответ.
   *
   * @param {{x: number, y: number, r: number}} point
   * @returns {Promise<{status: string, point: object, history: object[]}>}
   */
  function requestCheck({ x, y, r }) {
    const params = new URLSearchParams({
      x: String(x),
      y: String(y),
      r: String(r),
    });

    return requestJson(`${endpoint}?${params.toString()}`);
  }

  /**
   * Запрашивает накопленную историю проверок.
   *
   * @returns {Promise<object[]>}
   */
  async function requestHistory() {
    const payload = await requestJson(historyUrl);
    return payload.history ?? [];
  }

  return { requestCheck, requestHistory };
}
