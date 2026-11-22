<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="beans.Usuario" %>
<%
  String nombreUsuarioSesion = (String) session.getAttribute("nombreUsuario");
  Object objUsuario = session.getAttribute("usuarioLogueado");
  if ((nombreUsuarioSesion == null || nombreUsuarioSesion.isBlank()) && objUsuario instanceof Usuario) {
    nombreUsuarioSesion = ((Usuario) objUsuario).getNombre();
  }
  if (nombreUsuarioSesion == null || nombreUsuarioSesion.isBlank()) {
    nombreUsuarioSesion = "Administrador";
  }

  String[] partesNombre = nombreUsuarioSesion.trim().split("\\s+");
  String iniciales = partesNombre.length >= 2
    ? (partesNombre[0].substring(0, 1) + partesNombre[1].substring(0, 1)).toUpperCase()
    : (nombreUsuarioSesion.length() >= 2 ? nombreUsuarioSesion.substring(0, 2).toUpperCase() : "AD");

  String nombreSeguro = nombreUsuarioSesion.replace("&", "&")
    .replace("<", "<")
    .replace(">", ">");
%>
<!-- Control del menú lateral -->
<input type="checkbox" id="controlMenu" class="control-menu" aria-label="Ocultar menú lateral">

<header class="barra-superior">

  <div class="zona-logo">
    <label for="controlMenu" class="boton-menu" title="Ocultar o mostrar menú">☰</label>
    <a href="${pageContext.request.contextPath}/DashboardServletAdmin" class="logo">OceanLink</a>
  </div>

  <div class="usuario">
    <div class="foto-usuario"><%= iniciales %></div>
    <div>
      <p class="nombre-usuario"><%= nombreSeguro %></p>
      <p class="rol-usuario">Administrador</p>
    </div>
  </div>

</header>
