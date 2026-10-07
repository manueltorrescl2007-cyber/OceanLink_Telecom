<%--
    header.jsp
    Barra superior reutilizable del área de contenido principal.
    Recibe el parámetro "pageTitle" con el título a mostrar.
    (El nombre de usuario y rol son estáticos por ahora; en producción
    deberían leerse de la sesión, p. ej. session.getAttribute("username")).
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    String pageTitle = request.getParameter("pageTitle");
    if (pageTitle == null) {
        pageTitle = "Oceanlink";
    }
%>
<header class="topbar">
    <meta charset="UTF-8">
    <h1 class="topbar-title"><%= pageTitle %></h1>
    <div class="user-badge">
        <span class="avatar-circle"></span>
        <div class="user-info">
            <span class="user-name">Username</span>
            <span class="user-role">Maintenance coordinator</span>
        </div>
    </div>
</header>
