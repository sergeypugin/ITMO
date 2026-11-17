<!doctype html>
<html lang="ru">
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Лабораторная работа №3 | Веб-программирование" />
<%@ include file="components/head.jspf" %>
<body>
  <%@ include file="components/header.jspf" %>
  <%@ include file="workspace.jspf" %>
  <%@ include file="components/toasts.jspf" %>
  <script type="module" src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
