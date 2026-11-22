<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="beans.capacityplanner.LandingStation" %>
<%!
  private String texto(String valor) {
    if (valor == null) return "";

    return valor.replace("&", "&amp;")
      .replace("<", "&lt;")
      .replace(">", "&gt;")
      .replace("\"", "&quot;")
      .replace("'", "&#39;");
  }
%>
<%
  String servlet = request.getContextPath() + "/LandingStationAdminServlet";

  ArrayList<LandingStation> estaciones =
    (ArrayList<LandingStation>) request.getAttribute("listaEstaciones");

  if (estaciones == null) {
    response.sendRedirect(servlet);
    return;
  }

  String[] estados = {"Activa", "Inactiva"};
  String filtro = (String) request.getAttribute("filtroEstado");
  if (filtro == null) filtro = "";
  boolean hayFiltro = !filtro.isEmpty();

  int paginaActual = request.getAttribute("paginaActual") != null
    ? (Integer) request.getAttribute("paginaActual") : 1;
  int totalPaginas = request.getAttribute("totalPaginas") != null
    ? (Integer) request.getAttribute("totalPaginas") : 1;
  int totalRegistros = request.getAttribute("totalRegistros") != null
    ? (Integer) request.getAttribute("totalRegistros") : estaciones.size();
  int registroInicio = request.getAttribute("registroInicio") != null
    ? (Integer) request.getAttribute("registroInicio") : (estaciones.isEmpty() ? 0 : 1);
  int registroFin = request.getAttribute("registroFin") != null
    ? (Integer) request.getAttribute("registroFin") : estaciones.size();

  String filtroCodificado = URLEncoder.encode(filtro, StandardCharsets.UTF_8);
  String urlBase = servlet + "?estado=" + filtroCodificado;
  String urlLista = urlBase + "&pagina=" + paginaActual;
  String msg = request.getParameter("msg");
%>
<%
  String nombreUsuarioSesion = (String) session.getAttribute("nombreUsuario");
  if (nombreUsuarioSesion == null || nombreUsuarioSesion.isBlank()) {
    nombreUsuarioSesion = "<%= nombreUsuarioSesion %>";
  }
  String iniciales = nombreUsuarioSesion.length() >= 2
    ? nombreUsuarioSesion.substring(0, 2).toUpperCase()
    : "AD";
%>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Landing stations | OceanLink</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/barras.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin/landing_stations.css">
</head>
<body>

<jsp:include page="header.jsp" />

<div class="contenedor">

  <jsp:include page="sidebar.jsp">
    <jsp:param name="activePage" value="landing_stations" />
  </jsp:include>

  <main class="contenido-principal pagina-landings">
    <section class="encabezado-pagina">
      <div class="encabezado-panel">
        <h2>Administrador</h2>
        <h1>Landing stations</h1>
      </div>
      <a href="<%= servlet %>?action=formCrear&estado=<%= filtroCodificado %>&pagina=<%= paginaActual %>" class="boton primario">
        + Nueva estación
      </a>
    </section>

    <% if ("guardado".equals(msg)) { %>
    <p class="mensaje-exito" role="status">Estación guardada correctamente.</p>
    <% } else if ("estadoOk".equals(msg)) { %>
    <p class="mensaje-exito" role="status">Estado de la estación actualizado correctamente.</p>
    <% } else if ("eliminado".equals(msg)) { %>
    <p class="mensaje-exito" role="status">Estación eliminada correctamente.</p>
    <% } else if ("asociado".equals(msg)) { %>
    <p class="mensaje-error" role="alert">No se puede eliminar la estación porque está asociada a uno o más segmentos.</p>
    <% } else if ("noExiste".equals(msg)) { %>
    <p class="mensaje-error" role="alert">La estación seleccionada ya no existe.</p>
    <% } %>

    <div class="barra-herramientas">
      <form action="<%= servlet %>" method="get" class="formulario-filtro">
        <label for="filtroEstado">Estado:</label>
        <select id="filtroEstado" name="estado">
          <option value="">Todos</option>
          <% for (String estado : estados) { %>
          <option value="<%= estado %>" <%= estado.equals(filtro) ? "selected" : "" %>><%= estado %></option>
          <% } %>
        </select>
        <button type="submit" class="boton secundario">Filtrar</button>
        <% if (hayFiltro) { %>
        <a href="<%= servlet %>" class="boton secundario">Limpiar</a>
        <% } %>
      </form>
      <span><%= totalRegistros %> estaciones</span>
    </div>

    <section class="contenedor-tabla">
      <table>
        <thead>
        <tr>
          <th>ID</th>
          <th>Nombre</th>
          <th>País</th>
          <th>Ciudad</th>
          <th>Estado</th>
          <th>Acciones</th>
        </tr>
        </thead>
        <tbody>
        <% for (LandingStation estacion : estaciones) {
          boolean activa = "Activa".equals(estacion.getEstado()); %>
        <tr>
          <td><%= estacion.getIdLanding() %></td>
          <td>
            <a href="<%= urlLista %>&detalle=<%= estacion.getIdLanding() %>#detalle"
               class="enlace-estacion">
              <%= texto(estacion.getNombre()) %>
            </a>
          </td>
          <td><%= texto(estacion.getPais()) %></td>
          <td><%= texto(estacion.getCiudad()) %></td>
          <td>
                                <span class="estado <%= activa ? "activa" : "inactiva" %>">
                                    <%= texto(estacion.getEstado()) %>
                                </span>
          </td>
          <td>
            <div class="acciones-tabla">
              <a href="<%= servlet %>?action=editar&id=<%= estacion.getIdLanding() %>&estado=<%= filtroCodificado %>&pagina=<%= paginaActual %>">
                Editar
              </a>
              <% if (activa) { %>
              <a href="<%= servlet %>?action=desactivar&id=<%= estacion.getIdLanding() %>&estado=<%= filtroCodificado %>&pagina=<%= paginaActual %>"
                 class="accion-peligro"
                 onclick="return confirm('¿Seguro que deseas desactivar esta Landing Station?');">
                Desactivar
              </a>
              <% } else { %>
              <a href="<%= servlet %>?action=activar&id=<%= estacion.getIdLanding() %>&estado=<%= filtroCodificado %>&pagina=<%= paginaActual %>">
                Activar
              </a>
              <% } %>
              <a href="<%= servlet %>?action=eliminar&id=<%= estacion.getIdLanding() %>&estado=<%= filtroCodificado %>&pagina=<%= paginaActual %>"
                 class="accion-peligro"
                 onclick="return confirm('¿Eliminar permanentemente esta Landing Station?');">
                Eliminar
              </a>
            </div>
          </td>
        </tr>
        <% } %>

        <% if (estaciones.isEmpty()) { %>
        <tr>
          <td colspan="6" class="celda-vacia">
            <%= hayFiltro ? "No hay estaciones con este estado." : "No hay Landing Stations registradas." %>
          </td>
        </tr>
        <% } %>
        </tbody>
      </table>
    </section>

    <% if (totalRegistros > 0) { %>
    <nav class="pagination-bar" aria-label="Paginación de estaciones">
            <span class="pagination-info">
                Mostrando <%= registroInicio %>–<%= registroFin %> de <%= totalRegistros %> registros (Página <%= paginaActual %> de <%= totalPaginas %>)
            </span>

      <% if (totalPaginas > 1) { %>
      <div class="pagination-links">
        <% if (paginaActual > 1) { %>
        <a href="<%= urlBase %>&pagina=<%= paginaActual - 1 %>" class="boton secundario">Anterior</a>
        <% } %>

        <% for (int p = 1; p <= totalPaginas; p++) {
          boolean esActual = (p == paginaActual); %>
        <a href="<%= urlBase %>&pagina=<%= p %>"
           class="boton <%= esActual ? "primario" : "secundario" %>">
          <%= p %>
        </a>
        <% } %>

        <% if (paginaActual < totalPaginas) { %>
        <a href="<%= urlBase %>&pagina=<%= paginaActual + 1 %>" class="boton secundario">Siguiente</a>
        <% } %>
      </div>
      <% } %>
    </nav>
    <% } %>

    <% LandingStation estacionDetalle = (LandingStation) request.getAttribute("estacionDetalle");
      if (estacionDetalle != null) { %>
    <section class="panel-detalle" id="detalle">
      <div class="encabezado-detalle">
        <h2><%= texto(estacionDetalle.getNombre()) %></h2>
        <a href="<%= urlLista %>" aria-label="Cerrar detalle">×</a>
      </div>

      <div class="datos-detalle">
        <div>
          <span>ID de la estación</span>
          <strong><%= estacionDetalle.getIdLanding() %></strong>
        </div>
        <div>
          <span>País</span>
          <strong><%= texto(estacionDetalle.getPais()) %></strong>
        </div>
        <div>
          <span>Ciudad</span>
          <strong><%= texto(estacionDetalle.getCiudad()) %></strong>
        </div>
        <div>
          <span>Estado</span>
          <strong><%= texto(estacionDetalle.getEstado()) %></strong>
        </div>
      </div>

      <div class="acciones">
        <a href="<%= servlet %>?action=editar&id=<%= estacionDetalle.getIdLanding() %>&estado=<%= filtroCodificado %>&pagina=<%= paginaActual %>"
           class="boton primario">
          Editar estación
        </a>
      </div>
    </section>
    <% } %>
  </main>
</div>

</body>
</html>
