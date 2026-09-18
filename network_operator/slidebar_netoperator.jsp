<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%-- 1. Inclusión automática de estilos de la barra lateral --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/estado_red.css">

<%-- 2. Estructura HTML de la barra lateral basada en las clases de estado_red.css --%>
<aside class="sidebar">
  <div class="sidebar-logo">OceanLink</div>

  <nav class="sidebar-nav">

    <%-- Sección: Menú Principal --%>
    <div>
      <div class="nav-section-title">Menú</div>
      <ul class="nav-list">
        <li class="nav-item ${activePage == 'estado_red' ? 'active' : ''}">
          <a href="${pageContext.request.contextPath}/network_operator/estado_red.jsp">Estado de la Red</a>
        </li>
      </ul>
    </div>

    <%-- Sección: Incidencias --%>
    <div>
      <div class="nav-section-title">Incidencias</div>
      <ul class="nav-list nav-sublist">
        <li class="nav-item ${activePage == 'registrar_incidencia' ? 'active' : ''}">
          <a href="${pageContext.request.contextPath}/network_operator/registrar_incidencia.jsp">Registrar</a>
        </li>
        <li class="nav-item ${activePage == 'incidencias-visualizar' ? 'active' : ''}">
          <a href="${pageContext.request.contextPath}/network_operator/incidencias-visualizar.jsp">Visualizar</a>
        </li>
      </ul>
    </div>

    <%-- Sección: Historial --%>
    <div>
      <div class="nav-section-title">Historial</div>
      <ul class="nav-list nav-sublist">
        <li class="nav-item ${activePage == 'historial' ? 'active' : ''}">
          <a href="${pageContext.request.contextPath}/network_operator/historial.jsp">Historial de Red</a>
        </li>
      </ul>
    </div>

    <%-- Sección: Configuración (al final) --%>
    <div>
      <div class="nav-section-title">Configuración</div>
      <ul class="nav-list nav-sublist">
        <li class="nav-item ${activePage == 'perfil' ? 'active' : ''}">
          <a href="#">Perfil</a>
        </li>
        <li class="nav-item">
          <a href="../login.jsp">Cerrar sesión</a>
        </li>
      </ul>
    </div>

  </nav>
</aside>
