<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="beans.Usuario" %>
<%
  Usuario usuario = (Usuario) request.getAttribute("usuarioPerfil");

  // Si abren el JSP directo, pasamos primero por el servlet
  if (usuario == null) {
    response.sendRedirect(request.getContextPath() + "/PerfilServlet");
    return;
  }

  // Cada rol tiene su carpeta con su header y su sidebar
  String carpeta;
  switch (usuario.getRol().getIdRol()) {
    case 1:  carpeta = "admin"; break;
    case 2:  carpeta = "supervisor"; break;
    case 3:  carpeta = "capacity_planner"; break;
    case 4:  carpeta = "network_operator"; break;
    default: carpeta = "Maintenance_coordinator";
  }
  String rutaHeader = "/" + carpeta + "/header.jsp";
  String rutaSidebar = "/" + carpeta + "/sidebar.jsp";

  String errorMsg = (String) request.getAttribute("errorMsg");
  String mensajeOk = (String) request.getAttribute("mensajeOk");
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>OceanLink - Mi perfil</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/barras.css?v=2">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/perfil.css?v=2">
</head>
<body>

<jsp:include page="<%= rutaHeader %>" />

<div class="contenedor">

  <jsp:include page="<%= rutaSidebar %>">
    <jsp:param name="activePage" value="perfil" />
  </jsp:include>

  <main class="contenido-principal">

    <section class="encabezado-panel">
      <h2><c:out value="${usuarioPerfil.rol.nombre}" /></h2>
      <h1>Mi perfil</h1>
    </section>

    <!-- Datos del usuario (solo lectura) -->
    <section class="tarjeta-perfil">
      <h3>Mis datos</h3>
      <dl class="datos-perfil">
        <dt>Nombre</dt>
        <dd><c:out value="${usuarioPerfil.nombre}" /></dd>

        <dt>Correo</dt>
        <dd><c:out value="${usuarioPerfil.correo}" /></dd>

        <dt>Rol</dt>
        <dd><c:out value="${usuarioPerfil.rol.nombre}" /></dd>

        <dt>Estado</dt>
        <dd class="estado-perfil"><c:out value="${usuarioPerfil.estado}" /></dd>
      </dl>
    </section>

    <!-- Cambio de contraseña -->
    <section class="tarjeta-perfil">
      <h3>Cambiar contraseña</h3>

      <% if (errorMsg != null) { %>
        <p class="mensaje-perfil mensaje-error" role="alert"><%= errorMsg %></p>
      <% } %>
      <% if (mensajeOk != null) { %>
        <p class="mensaje-perfil mensaje-ok" role="status"><%= mensajeOk %></p>
      <% } %>

      <form class="form-perfil" method="post"
            action="${pageContext.request.contextPath}/PerfilServlet">

        <label for="contrasenaActual">Contraseña actual</label>
        <input type="password" id="contrasenaActual" name="contrasenaActual" required>

        <label for="contrasenaNueva">Contraseña nueva</label>
        <input type="password" id="contrasenaNueva" name="contrasenaNueva" required>

        <label for="contrasenaRepetir">Repetir contraseña nueva</label>
        <input type="password" id="contrasenaRepetir" name="contrasenaRepetir" required>

        <button type="submit">Guardar contraseña</button>
      </form>
    </section>

  </main>
</div>

</body>
</html>
