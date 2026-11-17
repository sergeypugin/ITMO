package app;

import app.model.CheckResult;
import app.model.Point;
import app.model.ResultsBean;
import app.service.AreaChecker;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Date;

public final class AreaCheckServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        long startedAt = System.nanoTime();
        ResultsBean results = (ResultsBean) request.getSession().getAttribute(ResultsBean.SESSION_ATTRIBUTE);
        try {
            Point point = parsePoint(request);
            boolean hit = AreaChecker.contains(point);
            double executionTimeMs = (System.nanoTime() - startedAt) / 1_000_000.0;
            CheckResult result = new CheckResult(point, hit, new Date(), executionTimeMs);

            results.add(result);
            request.setAttribute("checkResult", result);
            request.setAttribute("valid", true);
        } catch (IllegalArgumentException exception) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("errorMessage", exception.getMessage());
            request.setAttribute("valid", false);
        }

        request.getRequestDispatcher("/WEB-INF/views/result.jsp").forward(request, response);
    }

    private Point parsePoint(HttpServletRequest request) {
        double x = parseFinite(request.getParameter("x"), "X");
        double y = parseFinite(request.getParameter("y"), "Y");
        double r = parseFinite(request.getParameter("r"), "R");

        String source = request.getParameter("source");
        switch (source == null ? "form" : source) {
            case "form" -> validateFormRanges(x, y);
            case "graph" -> {
            }
            default -> throw new IllegalArgumentException("Неизвестный способ выбора точки.");
        }
        if (r < 1 || r > 5 || r != Math.rint(r)) {
            throw new IllegalArgumentException("R должен быть целым числом от 1 до 5.");
        }
        return new Point(x, y, r);
    }

    private void validateFormRanges(double x, double y) {
        if (x < -2 || x > 2 || Math.rint(x * 2) != x * 2) {
            throw new IllegalArgumentException("X должен быть одним из значений от -2 до 2 с шагом 0,5.");
        }
        if (y < -3 || y > 5) {
            throw new IllegalArgumentException("Y должен находиться в диапазоне от -3 до 5.");
        }
    }

    private double parseFinite(String raw, String name) {
        if (raw == null || raw.trim().isEmpty()) {
            throw new IllegalArgumentException("Укажите значение " + name + ".");
        }

        String normalized = raw.trim().replace(',', '.');
        if (!normalized.matches("[+-]?\\d*\\.?\\d+")) {
            throw new IllegalArgumentException(name + " должно быть числом.");
        }

        double value = Double.parseDouble(normalized);
        if (!Double.isFinite(value)) {
            throw new IllegalArgumentException(name + " должно быть конечным числом.");
        }
        return value;
    }
}
