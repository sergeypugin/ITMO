package app;

import app.model.ResultsBean;

import jakarta.servlet.http.HttpSessionEvent;
import jakarta.servlet.http.HttpSessionListener;

public class SessionBootstrap implements HttpSessionListener {
    @Override
    public void sessionCreated(HttpSessionEvent event) {
        event.getSession().setAttribute(ResultsBean.SESSION_ATTRIBUTE, new ResultsBean());
    }
}
