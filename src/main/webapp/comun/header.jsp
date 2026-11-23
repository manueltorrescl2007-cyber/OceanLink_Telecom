<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="beans.Usuario" %>
<%--
  Barra superior común para los 5 roles.
  El rol se lee de la sesión (lo guarda LoginServlet al iniciar sesión).
--%>
<%
  String ctx = request.getContextPath();

  // Rol del usuario que inició sesión
  Object objUsuario = session.getAttribute("usuarioLogueado");
  int idRol = 0;
  if (session.getAttribute("idRol") instanceof Integer) {
    idRol = (Integer) session.getAttribute("idRol");
  } else if (objUsuario instanceof Usuario && ((Usuario) objUsuario).getRol() != null) {
    idRol = ((Usuario) objUsuario).getRol().getIdRol();
  }

  // Lo único que cambia entre roles: el texto del rol y la página de inicio
  String nombreRol;
  String inicio;
  switch (idRol) {
    case 1:  nombreRol = "Administrador";           inicio = "/DashboardServletAdmin"; break;
    case 2:  nombreRol = "Supervisor";              inicio = "/DashboardServletSuper"; break;
    case 3:  nombreRol = "Capacity Planner";        inicio = "/CapacityPlannerServlet"; break;
    case 4:  nombreRol = "Network Operator";        inicio = "/EstadoRedServlet"; break;
    case 5:  nombreRol = "Maintenance Coordinator"; inicio = "/MantenimientoServlet?accion=listar"; break;
    default: nombreRol = "";                        inicio = "/LoginServlet";
  }

  // Nombre del usuario (si no hay, se muestra el rol)
  String nombreUsuarioSesion = (String) session.getAttribute("nombreUsuario");
  if ((nombreUsuarioSesion == null || nombreUsuarioSesion.isBlank()) && objUsuario instanceof Usuario) {
    nombreUsuarioSesion = ((Usuario) objUsuario).getNombre();
  }
  if (nombreUsuarioSesion == null || nombreUsuarioSesion.isBlank()) {
    nombreUsuarioSesion = nombreRol.isEmpty() ? "Usuario" : nombreRol;
  }

  // Iniciales: primera letra de las dos primeras palabras
  String[] partesNombre = nombreUsuarioSesion.trim().split("\\s+");
  String iniciales = partesNombre.length >= 2
    ? (partesNombre[0].substring(0, 1) + partesNombre[1].substring(0, 1)).toUpperCase()
    : nombreUsuarioSesion.substring(0, Math.min(2, nombreUsuarioSesion.length())).toUpperCase();

  String nombreSeguro = nombreUsuarioSesion.replace("&", "&amp;")
    .replace("<", "&lt;")
    .replace(">", "&gt;");
%>
<!-- Estilos del menú del usuario (se cambia ?v= para que el navegador no use una versión vieja) -->
<link rel="stylesheet" href="<%= ctx %>/css/header.css?v=1">

<!-- Control del menú lateral -->
<input type="checkbox" id="controlMenu" class="control-menu" aria-label="Ocultar menú lateral">

<header class="barra-superior">

  <div class="zona-logo">
    <label for="controlMenu" class="boton-menu" title="Ocultar o mostrar menú">☰</label>
    <a href="<%= ctx + inicio %>" class="logo">OceanLink</a>
  </div>

  <!-- Al hacer clic en el nombre se abre el menú del usuario -->
  <div class="zona-usuario">
    <input type="checkbox" id="controlUsuario" class="control-usuario" aria-label="Opciones del usuario">

    <label for="controlUsuario" class="usuario" title="Opciones del usuario">
      <span class="texto-usuario">
        <span class="nombre-usuario"><%= nombreSeguro %></span>
        <span class="rol-usuario"><%= nombreRol %></span>
      </span>
      <!-- Círculo con iniciales y la flechita en la esquina (como en Facebook) -->
      <span class="foto-usuario">
        <%= iniciales %>
        <span class="flecha-usuario"></span>
      </span>
    </label>

    <div class="menu-usuario">
      <a href="<%= ctx %>/PerfilServlet">Perfil</a>
      <form method="post" action="<%= ctx %>/LogoutServlet">
        <button type="submit" class="cerrar-sesion">Cerrar sesión</button>
      </form>
    </div>
  </div>

</header>
