package app;

import app.model.ResultsBean;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

public final class ControllerServlet extends HttpServlet {
    private static final String RESULTS_ATTRIBUTE = "resultsBean";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        prepareRequest(request, response);
        showForm(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        prepareRequest(request, response);
        if (!hasPointParameters(request)) {
            showForm(request, response);
            return;
        }

        RequestDispatcher areaCheck = getServletContext().getNamedDispatcher("AreaCheckServlet");
        if (areaCheck == null) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "AreaCheckServlet не настроен");
            return;
        }
        areaCheck.forward(request, response);
    }

    private boolean hasPointParameters(HttpServletRequest request) {
        return request.getParameter("x") != null
                || request.getParameter("y") != null
                || request.getParameter("r") != null;
    }

    private void prepareRequest(HttpServletRequest request, HttpServletResponse response) {
        response.setHeader("Cache-Control", "no-store");
        HttpSession session = request.getSession();
        synchronized (session) {
            ResultsBean results = (ResultsBean) session.getAttribute(RESULTS_ATTRIBUTE);
            if (results == null) {
                results = new ResultsBean();
                session.setAttribute(RESULTS_ATTRIBUTE, results);
            }
            request.setAttribute(RESULTS_ATTRIBUTE, results);
        }
    }

    private void showForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/index.jsp").forward(request, response);
    }
}
