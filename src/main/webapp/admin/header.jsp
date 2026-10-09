<%--
    header.jsp - Barra superior del Administrador
    (El nombre de usuario es estático por ahora; luego vendrá de la sesión).
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!-- Control del menú lateral -->
<input type="checkbox" id="controlMenu" class="control-menu">

<header class="barra-superior">

  <div class="zona-logo">
    <label for="controlMenu" class="boton-menu">☰</label>
    <a href="${pageContext.request.contextPath}/admin/admin.jsp" class="logo">OceanLink</a>
  </div>

  <div class="usuario">
    <div class="foto-usuario">AD</div>
    <div>
      <p class="nombre-usuario">Username</p>
      <p class="rol-usuario">Administrador</p>
    </div>
  </div>

</header>
