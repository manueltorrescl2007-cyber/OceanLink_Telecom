<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="beans.Usuario" %>
<%@ page import="beans.Rol" %>
<%
  String servlet = request.getContextPath() + "/UsuarioServlet";

  // Datos enviados por UsuarioServlet (case "lista")
  ArrayList<Usuario> listaUsuarios = (ArrayList<Usuario>) request.getAttribute("listaUsuarios");
  if (listaUsuarios == null) {
    response.sendRedirect(servlet);
    return;
  }

  ArrayList<Rol> listaRoles = (ArrayList<Rol>) request.getAttribute("listaRoles");

  // Filtros elegidos (para que los <select> los recuerden)
  Integer filtroIdRol = (Integer) request.getAttribute("filtroIdRol");
  String filtroEstado = (String) request.getAttribute("filtroEstado");
  if (filtroIdRol == null) { filtroIdRol = -1; }
  if (filtroEstado == null) { filtroEstado = ""; }
  boolean hayFiltro = filtroIdRol > 0 || !filtroEstado.isEmpty();

  // Datos de paginación
  int paginaActual = request.getAttribute("paginaActual") != null
    ? (Integer) request.getAttribute("paginaActual") : 1;
  int totalPaginas = request.getAttribute("totalPaginas") != null
    ? (Integer) request.getAttribute("totalPaginas") : 1;
  int totalRegistros = request.getAttribute("totalRegistros") != null
    ? (Integer) request.getAttribute("totalRegistros") : listaUsuarios.size();
  int registroInicio = request.getAttribute("registroInicio") != null
    ? (Integer) request.getAttribute("registroInicio") : (listaUsuarios.isEmpty() ? 0 : 1);
  int registroFin = request.getAttribute("registroFin") != null
    ? (Integer) request.getAttribute("registroFin") : listaUsuarios.size();

  String paramIdRol = filtroIdRol > 0 ? String.valueOf(filtroIdRol) : "";
  String urlBase = servlet
    + "?idRol=" + URLEncoder.encode(paramIdRol, StandardCharsets.UTF_8)
    + "&estado=" + URLEncoder.encode(filtroEstado, StandardCharsets.UTF_8);
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>OceanLink - Usuarios</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/barras.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin/admin.css">
</head>
<body>

<jsp:include page="header.jsp" />

<div class="contenedor">

  <jsp:include page="sidebar.jsp">
    <jsp:param name="activePage" value="usuarios" />
  </jsp:include>

  <main class="contenido-principal">

    <section class="encabezado-panel">
      <h2>Usuarios</h2>
      <h1>Gestión de usuarios</h1>
    </section>

    <section class="card">
      <div class="card-header">
        <h2 class="card-title">Usuarios del sistema</h2>
        <a class="btn-primary" href="<%= servlet %>?action=formCrear">+ Nuevo usuario</a>
      </div>

      <%-- Filtros: se envían por GET al Servlet (?idRol=..&estado=..) --%>
      <form class="filtros" method="GET" action="<%= servlet %>">
        <select name="idRol" aria-label="Filtrar por rol">
          <option value="">Todos los roles</option>
          <% if (listaRoles != null) {
            for (Rol r : listaRoles) { %>
          <option value="<%= r.getIdRol() %>" <%= r.getIdRol() == filtroIdRol ? "selected" : "" %>>
            <%= r.getNombre() %>
          </option>
          <%     }
          } %>
        </select>

        <select name="estado" aria-label="Filtrar por estado">
          <option value="">Todos los estados</option>
          <option value="activo"   <%= "activo".equals(filtroEstado)   ? "selected" : "" %>>Activo</option>
          <option value="inactivo" <%= "inactivo".equals(filtroEstado) ? "selected" : "" %>>Inactivo</option>
        </select>

        <button type="submit" class="btn-primary">Filtrar</button>
        <% if (hayFiltro) { %>
        <a class="btn-secundario" href="<%= servlet %>">Limpiar</a>
        <% } %>

        <span class="contador">
                    <%= totalRegistros %> usuario(s)
                </span>
      </form>

      <div class="table-wrapper">
        <table class="data-table">
          <thead>
          <tr>
            <th>ID</th>
            <th>Nombre</th>
            <th>Correo</th>
            <th>Rol</th>
            <th>Estado</th>
            <th>Acciones</th>
          </tr>
          </thead>
          <tbody>
          <% if (listaUsuarios.isEmpty()) { %>
          <tr>
            <td colspan="6" class="vacio"><%= hayFiltro ? "No hay usuarios que coincidan con el filtro." : "No hay usuarios registrados." %></td>
          </tr>
          <% } else {
            for (Usuario u : listaUsuarios) {
              boolean activo = "activo".equals(u.getEstado()); %>
          <tr>
            <td><%= u.getIdUsuario() %></td>
            <td><%= u.getNombre() %></td>
            <td><%= u.getCorreo() %></td>
            <td><%= u.getRol().getNombre() %></td>
            <td>
                                <span class="badge <%= activo ? "badge-activo" : "badge-inactivo" %>">
                                    <%= activo ? "Activo" : "Inactivo" %>
                                </span>
            </td>
            <td class="acciones">
              <a href="<%= servlet %>?action=editar&id=<%= u.getIdUsuario() %>">Editar</a>
              <% if (activo) { %>
              <a class="accion-peligro"
                 href="<%= servlet %>?action=desactivar&id=<%= u.getIdUsuario() %>&idRol=<%= URLEncoder.encode(paramIdRol, StandardCharsets.UTF_8) %>&estado=<%= URLEncoder.encode(filtroEstado, StandardCharsets.UTF_8) %>&pagina=<%= paginaActual %>"
                 onclick="return confirm('¿Seguro que deseas desactivar este usuario?');">Desactivar</a>
              <% } else { %>
              <a href="<%= servlet %>?action=activar&id=<%= u.getIdUsuario() %>&idRol=<%= URLEncoder.encode(paramIdRol, StandardCharsets.UTF_8) %>&estado=<%= URLEncoder.encode(filtroEstado, StandardCharsets.UTF_8) %>&pagina=<%= paginaActual %>">Activar</a>
              <% } %>
            </td>
          </tr>
          <%     }
          } %>
          </tbody>
        </table>
      </div>

      <% if (totalRegistros > 0) { %>
      <nav class="pagination-bar" aria-label="Paginación de usuarios">
                <span class="pagination-info">
                    Mostrando <%= registroInicio %>–<%= registroFin %> de <%= totalRegistros %> registros (Página <%= paginaActual %> de <%= totalPaginas %>)
                </span>

        <% if (totalPaginas > 1) { %>
        <div class="pagination-links">
          <% if (paginaActual > 1) { %>
          <a href="<%= urlBase %>&pagina=<%= paginaActual - 1 %>" class="btn-secundario">Anterior</a>
          <% } %>

          <% for (int p = 1; p <= totalPaginas; p++) {
            boolean esActual = (p == paginaActual); %>
          <a href="<%= urlBase %>&pagina=<%= p %>"
             class="<%= esActual ? "btn-primary" : "btn-secundario" %>">
            <%= p %>
          </a>
          <% } %>

          <% if (paginaActual < totalPaginas) { %>
          <a href="<%= urlBase %>&pagina=<%= paginaActual + 1 %>" class="btn-secundario">Siguiente</a>
          <% } %>
        </div>
        <% } %>
      </nav>
      <% } %>
    </section>

  </main>
</div>

</body>
</html>
