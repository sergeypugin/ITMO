<!doctype html>
<html lang="ru">
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:useBean id="resultsBean" class="app.model.ResultsBean" scope="session" />
<jsp:useBean id="checkResult" class="app.model.CheckResult" scope="request" />
<c:set var="pageTitle" value="Результат проверки | Лабораторная работа №3" />
<%@ include file="components/head.jspf" %>
<body>
  <%@ include file="components/header.jspf" %>

  <main class="content">
    <section id="check-result" class="check-result ${valid ? (checkResult.hit ? 'is-hit' : 'is-miss') : 'is-error'}"
             data-kind="${valid ? (checkResult.hit ? 'hit' : 'miss') : 'error'}"
             data-x="${valid ? checkResult.x : ''}" data-y="${valid ? checkResult.y : ''}" data-r="${valid ? checkResult.r : ''}">
      <h2>
        <c:choose>
          <c:when test="${valid}"><c:out value="${checkResult.hit ? 'Точка попала в область' : 'Точка не попала в область'}" /></c:when>
          <c:otherwise>Не удалось проверить точку</c:otherwise>
        </c:choose>
      </h2>
      <c:choose>
        <c:when test="${valid}">
          <table class="point-result">
            <tbody>
              <tr><th>X</th><td><fmt:formatNumber value="${checkResult.x}" maxFractionDigits="5" /></td></tr>
              <tr><th>Y</th><td><fmt:formatNumber value="${checkResult.y}" maxFractionDigits="5" /></td></tr>
              <tr><th>R</th><td><fmt:formatNumber value="${checkResult.r}" maxFractionDigits="0" /></td></tr>
              <tr><th>Результат</th><td><c:out value="${checkResult.hit ? 'Попадание' : 'Промах'}" /></td></tr>
            </tbody>
          </table>
          <p>Время проверки: <fmt:formatNumber value="${checkResult.executionTimeMs}" minFractionDigits="3" maxFractionDigits="3" /> мс</p>
        </c:when>
        <c:otherwise><p><c:out value="${errorMessage}" /></p></c:otherwise>
      </c:choose>
      <a class="back-link" href="${pageContext.request.contextPath}/">Вернуться к форме</a>
    </section>
  </main>

  <section class="results">
    <div class="toolbar">
      <h2>Результаты проверок</h2>
    </div>
    <table>
      <thead>
        <tr><th>X</th><th>Y</th><th>R</th><th>Попадание</th><th>Время проверки</th><th>Время работы, мс</th></tr>
      </thead>
      <tbody id="history-body">
        <%@ include file="components/history-rows.jspf" %>
      </tbody>
    </table>
  </section>

  <script type="module" src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
