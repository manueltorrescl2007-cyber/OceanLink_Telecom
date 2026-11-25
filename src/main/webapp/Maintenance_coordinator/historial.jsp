<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ page import="beans.maintenance.Mantenimiento" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%!
  private String escaparHtml(String valor) {
    if (valor == null) return "";

    return valor.replace("&", "&amp;")
      .replace("<", "&lt;")
      .replace(">", "&gt;")
      .replace("\"", "&quot;")
      .replace("'", "&#39;");
  }
%>

<%
  ArrayList<Mantenimiento> historial =
    (ArrayList<Mantenimiento>)
      request.getAttribute("historialMantenimientos");

  Map<Integer, String> segmentos =
    (Map<Integer, String>)
      request.getAttribute("segmentos");

  if (historial == null || segmentos == null) {
    response.sendRedirect(
      request.getContextPath()
        + "/MantenimientoServlet?accion=historial"
    );
    return;
  }

  Integer segmentoSeleccionado =
    (Integer) request.getAttribute("segmentoSeleccionado");

  String estadoSeleccionado =
    (String) request.getAttribute("estadoSeleccionado");

  int paginaActual = request.getAttribute("paginaActual") != null
    ? (Integer) request.getAttribute("paginaActual") : 1;
  int totalPaginas = request.getAttribute("totalPaginas") != null
    ? (Integer) request.getAttribute("totalPaginas") : 1;
  int totalRegistros = request.getAttribute("totalRegistros") != null
    ? (Integer) request.getAttribute("totalRegistros") : historial.size();
  int registroInicio = request.getAttribute("registroInicio") != null
    ? (Integer) request.getAttribute("registroInicio") : (historial.isEmpty() ? 0 : 1);
  int registroFin = request.getAttribute("registroFin") != null
    ? (Integer) request.getAttribute("registroFin") : historial.size();

  // Base de URL conservando los filtros activos para los enlaces de paginación
  StringBuilder basePaginacion = new StringBuilder(
    request.getContextPath() + "/MantenimientoServlet?accion=historial"
  );
  if (segmentoSeleccionado != null) {
    basePaginacion.append("&idSegmento=").append(segmentoSeleccionado);
  }
  if (estadoSeleccionado != null && !estadoSeleccionado.isBlank()) {
    basePaginacion.append("&estado=")
      .append(URLEncoder.encode(estadoSeleccionado, StandardCharsets.UTF_8));
  }
  String urlBase = basePaginacion.toString();

  DateTimeFormatter formatoFecha =
    DateTimeFormatter.ofPattern(
      "dd/MM/yyyy HH:mm", Locale.forLanguageTag("es-PE")
    );

  String[] estadosHistorial = {"Finalizado", "Cancelado"};
%>

<!DOCTYPE html>
<html lang="es">

<head>
  <meta charset="UTF-8">
  <meta name="viewport"
        content="width=device-width, initial-scale=1.0">

  <title>OceanLink - Historial</title>

  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/barras.css">

  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/styles_MC.css">
</head>

<body>

<jsp:include page="header.jsp">
  <jsp:param name="pageTitle"
             value="Registro y actualización de actividades de mantenimiento"/>
</jsp:include>

<div class="contenedor">

  <jsp:include page="sidebar.jsp">
    <jsp:param name="activePage" value="historial"/>
  </jsp:include>

  <main class="contenido-principal">

    <div class="content-container">

      <div class="card">

        <h2 class="card-title">
          Historial de mantenimientos
        </h2>

        <!-- BARRA DE FILTROS (SEGMENTO Y ESTADO) -->
        <form action="${pageContext.request.contextPath}/MantenimientoServlet"
              method="GET"
              class="filters-bar">

          <input type="hidden" name="accion" value="historial">

          <div class="form-field">
            <label for="filtroSegmento">Segmento</label>
            <select id="filtroSegmento" name="idSegmento">
              <option value="">Todos los segmentos</option>
              <%
                for (Map.Entry<Integer, String> entry : segmentos.entrySet()) {
                  boolean seleccionado = segmentoSeleccionado != null
                    && segmentoSeleccionado.equals(entry.getKey());
              %>
              <option value="<%= entry.getKey() %>" <%= seleccionado ? "selected" : "" %>>
                <%= escaparHtml(entry.getValue()) %>
              </option>
              <%
                }
              %>
            </select>
          </div>

          <div class="form-field">
            <label for="filtroEstado">Estado</label>
            <select id="filtroEstado" name="estado">
              <option value="">Todos los estados</option>
              <%
                for (String est : estadosHistorial) {
                  boolean seleccionado = est.equals(estadoSeleccionado);
              %>
              <option value="<%= est %>" <%= seleccionado ? "selected" : "" %>>
                <%= est %>
              </option>
              <%
                }
              %>
            </select>
          </div>

          <div class="filters-actions">
            <button type="submit" class="btn btn-primary">Filtrar</button>
            <a href="${pageContext.request.contextPath}/MantenimientoServlet?accion=historial"
               class="btn btn-secondary">
              Limpiar
            </a>
          </div>

        </form>

        <!-- BARRA SUPERIOR -->
        <div class="table-toolbar">

          <div class="table-toolbar-left">
            <span>▦</span>
            Vista de Tabla
          </div>

        </div>

        <!-- TABLA DE HISTORIAL -->
        <div class="data-table-wrapper">

          <table class="data-table">

            <thead>
            <tr>
              <th>ID</th>
              <th>Segmento</th>
              <th>Tipo</th>
              <th>Fecha de fin</th>
              <th>Estado</th>
            </tr>
            </thead>

            <tbody>

            <%
              if (historial.isEmpty()) {
            %>
            <tr>
              <td colspan="5" class="table-empty-cell">
                No se encontraron registros en el historial con los filtros seleccionados.
              </td>
            </tr>
            <%
            } else {
              for (int i = 0; i < historial.size(); i++) {

                Mantenimiento m = historial.get(i);

                String codigoSegmento =
                  segmentos.getOrDefault(
                    m.getIdSegmento(),
                    "Segmento #" + m.getIdSegmento()
                  );

                String fechaFin =
                  m.getFechaFin() == null
                    ? "—"
                    : m.getFechaFin().format(formatoFecha);

                String estado = m.getEstado();

                String badgeClass =
                  "Finalizado".equals(estado)
                    ? "badge-finalizado"
                    : "badge-cancelado";
            %>

            <tr>

              <!-- ID CON ENLACE A ESTADO.JSP -->
              <td>
                <a
                  href="${pageContext.request.contextPath}/MantenimientoServlet?accion=estado&idMantenimiento=<%= m.getIdMantenimiento() %>">
                  <%= m.getIdMantenimiento() %>
                </a>
              </td>

              <!-- SEGMENTO -->
              <td>
                <span class="badge badge-segmento">
                  <%= escaparHtml(codigoSegmento) %>
                </span>
              </td>

              <!-- TIPO -->
              <td>
                <%= escaparHtml(m.getTipo()) %>
              </td>

              <!-- FECHA FIN -->
              <td>
                <%= fechaFin %>
              </td>

              <!-- ESTADO -->
              <td>
                <span class="badge <%= badgeClass %>">
                  <%= escaparHtml(estado) %>
                </span>
              </td>

            </tr>

            <%
                }
              }
            %>

            </tbody>

          </table>

        </div>

        <!-- BARRA DE PAGINACIÓN -->
        <% if (totalRegistros > 0) { %>
        <div class="pagination-bar">
          <span class="pagination-info">
            Mostrando <%= registroInicio %>–<%= registroFin %> de <%= totalRegistros %> registros (Página <%= paginaActual %> de <%= totalPaginas %>)
          </span>

          <% if (totalPaginas > 1) { %>
          <div class="pagination-links">
            <% if (paginaActual > 1) { %>
            <a href="<%= urlBase %>&pagina=<%= paginaActual - 1 %>"
               class="btn btn-secondary">
              Anterior
            </a>
            <% } %>

            <%
              for (int p = 1; p <= totalPaginas; p++) {
                boolean esActual = (p == paginaActual);
            %>
            <a href="<%= urlBase %>&pagina=<%= p %>"
               class="btn <%= esActual ? "btn-primary" : "btn-secondary" %>">
              <%= p %>
            </a>
            <%
              }
            %>

            <% if (paginaActual < totalPaginas) { %>
            <a href="<%= urlBase %>&pagina=<%= paginaActual + 1 %>"
               class="btn btn-secondary">
              Siguiente
            </a>
            <% } %>
          </div>
          <% } %>
        </div>
        <% } %>

      </div>

    </div>

  </main>

</div>

</body>
</html>
