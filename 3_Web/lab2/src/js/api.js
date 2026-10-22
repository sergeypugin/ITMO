// Слой доступа к FastCGI-серверу.
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

  // Отправляет GET-запрос проверки точки на сервер.
  function requestCheck({ x, y, r }) {
    const params = new URLSearchParams({
      x: String(x),
      y: String(y),
      r: String(r),
    });

    return requestJson(`${endpoint}?${params.toString()}`);
  }

  // Запрашивает накопленную историю проверок.
  async function requestHistory() {
    const payload = await requestJson(historyUrl);
    return payload.history ?? [];
  }

  return { requestCheck, requestHistory };
}
