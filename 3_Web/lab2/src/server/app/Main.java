package app;

import com.fastcgi.FCGIInterface;

import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.time.OffsetDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

public final class Main {
    private static final List<Point> HISTORY = new ArrayList<>();
    private static final DateTimeFormatter TIME_FORMAT = DateTimeFormatter.ISO_OFFSET_DATE_TIME;

    private Main() {
    }

    public static void main(String[] args) {
        FCGIInterface fcgi = new FCGIInterface();
        System.err.println("FastCGI стартует, порт " + System.getProperty("FCGI_PORT"));

        // FCGIaccept при первом вызове открывает порт: отрицательный код
        // означает, что порт занят или -DFCGI_PORT не задан
        if (fcgi.FCGIaccept() < 0) {
            System.err.println("Не удалось открыть порт FastCGI. Проверьте -DFCGI_PORT и что порт свободен.");
            System.exit(1);
        }

        do {
            handleRequest();
        } while (fcgi.FCGIaccept() >= 0);
    }

    private static void handleRequest() {
        long startedAt = System.nanoTime();
        try {
            Properties environment = FCGIInterface.request == null ? null : FCGIInterface.request.params;
            String method = environment == null ? null : environment.getProperty("REQUEST_METHOD");
            String query = environment == null ? null : environment.getProperty("QUERY_STRING");

            if (method == null || !"GET".equalsIgnoreCase(method.trim())) {
                sendJson(405, "Method Not Allowed", errorBody("Поддерживается только метод GET."));
            } else {
                Map<String, String> params = parseQuery(query);

                // Отдельный параметр вместо проверки точки: иначе пустой запрос
                // не отличить от запроса истории.
                if (params.containsKey("history")) {
                    sendJson(200, "OK", historyBody());
                    return;
                }

                double x = number(params, "x", "X", -4, 4);
                double y = number(params, "y", "Y", -3, 5);
                double r = number(params, "r", "R", 2, 5);
                double executionTimeMs = (System.nanoTime() - startedAt) / 1_000_000.0;

                Point point = new Point(x, y, r, AreaChecker.isHit(x, y, r),
                        OffsetDateTime.now().format(TIME_FORMAT), executionTimeMs);
                synchronized (HISTORY) {
                    HISTORY.add(point);
                }
                sendJson(200, "OK", successBody(point));
            }
        } catch (IllegalArgumentException e) {
            sendJson(400, "Bad Request", errorBody(e.getMessage()));
        } catch (Exception e) {
            sendJson(500, "Internal Server Error", errorBody("Внутренняя ошибка сервера."));
        }
    }

    private static Map<String, String> parseQuery(String query) {
        Map<String, String> params = new HashMap<>();
        if (query != null && !query.isBlank()) {
            for (String pair : query.split("&")) {
                if (!pair.isEmpty()) {
                    int separator = pair.indexOf('=');
                    String key = separator < 0 ? pair : pair.substring(0, separator);
                    String value = separator < 0 ? "" : pair.substring(separator + 1);
                    params.put(URLDecoder.decode(key, StandardCharsets.UTF_8),
                            URLDecoder.decode(value, StandardCharsets.UTF_8));
                }
            }
        }
        return params;
    }

    private static double number(Map<String, String> params, String key, String name, double min, double max) {
        String raw = params.get(key);
        if (raw == null || raw.isBlank()) {
            throw new IllegalArgumentException("Параметр " + name + " обязателен.");
        }

        double value;
        try {
            value = Double.parseDouble(raw.trim().replace(',', '.'));
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Параметр " + name + " должен быть числом.");
        }
        if (!Double.isFinite(value)) {
            throw new IllegalArgumentException("Параметр " + name + " должен быть числом.");
        }
        if (value < min || value > max) {
            throw new IllegalArgumentException(
                    "Координата " + name + " должна быть в диапазоне [" + min + "; " + max + "].");
        }
        return value;
    }

    private static String successBody(Point point) {
        StringBuilder json = new StringBuilder("{\"status\":\"ok\",\"point\":");
        json.append(point.toJson()).append(",\"history\":[");
        appendHistory(json);
        return json.append("]}").toString();
    }

    private static String historyBody() {
        StringBuilder json = new StringBuilder("{\"status\":\"ok\",\"history\":[");
        appendHistory(json);
        return json.append("]}").toString();
    }

    private static void appendHistory(StringBuilder json) {
        synchronized (HISTORY) {
            for (int i = 0; i < HISTORY.size(); i++) {
                if (i > 0) {
                    json.append(',');
                }
                json.append(HISTORY.get(i).toJson());
            }
        }
    }

    private static String errorBody(String message) {
        return "{\"status\":\"error\",\"message\":" + Point.jsonString(message) + "}";
    }

    private static void sendJson(int status, String reason, String body) {
        byte[] bytes = body.getBytes(StandardCharsets.UTF_8);
        String headers = "HTTP/1.1 " + status + " " + reason + "\r\n"
                + "Content-Type: application/json; charset=utf-8\r\n"
                + "Content-Length: " + bytes.length + "\r\n\r\n";
        System.out.print(headers);
        System.out.write(bytes, 0, bytes.length);
        System.out.flush();
    }
}
