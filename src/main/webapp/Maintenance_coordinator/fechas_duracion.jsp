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
  ArrayList<Mantenimiento> mantenimientos =
    (ArrayList<Mantenimiento>)
      request.getAttribute("mantenimientos");

  Map<Integer, String> segmentos =
    (Map<Integer, String>)
      request.getAttribute("segmentos");

  if (mantenimientos == null || segmentos == null) {
    response.sendRedirect(
      request.getContextPath()
        + "/MantenimientoServlet?accion=listar"
    );
    return;
  }

  Integer segmentoSeleccionado =
    (Integer) request.getAttribute("segmentoSeleccionado");

  String prioridadSeleccionada =
    (String) request.getAttribute("prioridadSeleccionada");

  int paginaActual = request.getAttribute("paginaActual") != null
    ? (Integer) request.getAttribute("paginaActual") : 1;
  int totalPaginas = request.getAttribute("totalPaginas") != null
    ? (Integer) request.getAttribute("totalPaginas") : 1;
  int totalRegistros = request.getAttribute("totalRegistros") != null
    ? (Integer) request.getAttribute("totalRegistros") : mantenimientos.size();
  int registroInicio = request.getAttribute("registroInicio") != null
    ? (Integer) request.getAttribute("registroInicio") : (mantenimientos.isEmpty() ? 0 : 1);
  int registroFin = request.getAttribute("registroFin") != null
    ? (Integer) request.getAttribute("registroFin") : mantenimientos.size();

  // Base de URL conservando los filtros activos para los enlaces de paginación
  StringBuilder basePaginacion = new StringBuilder(
    request.getContextPath() + "/MantenimientoServlet?accion=listar"
  );
  if (segmentoSeleccionado != null) {
    basePaginacion.append("&idSegmento=").append(segmentoSeleccionado);
  }
  if (prioridadSeleccionada != null && !prioridadSeleccionada.isBlank()) {
    basePaginacion.append("&prioridad=")
      .append(URLEncoder.encode(prioridadSeleccionada, StandardCharsets.UTF_8));
  }
  String urlBase = basePaginacion.toString();

  DateTimeFormatter formatoFecha =
    DateTimeFormatter.ofPattern(
      "dd/MM/yyyy",
      Locale.forLanguageTag("es-PE")
    );

  String resultado = request.getParameter("resultado");
  String[] prioridades = {"Leve", "Media", "Alta", "Crítica"};
%>

<!DOCTYPE html>
<html lang="es">

<head>
  <meta charset="UTF-8">
  <meta name="viewport"
        content="width=device-width, initial-scale=1.0">

  <title>OceanLink - Fechas y duración</title>

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
    <jsp:param name="activePage" value="fechas"/>
  </jsp:include>

  <main class="contenido-principal">

    <div class="content-container">

      <div class="card">

        <h2 class="card-title">
          Fechas y duración de mantenimientos
        </h2>

        <!-- MENSAJES DE RESULTADO -->

        <% if ("actualizado".equals(resultado)) { %>

        <p style="color: green; font-weight: bold;">
          El mantenimiento se actualizó correctamente.
        </p>

        <% } else if ("creado".equals(resultado)) { %>

        <p style="color: green; font-weight: bold;">
          El mantenimiento se registró correctamente.
        </p>

        <% } else if ("cancelado".equals(resultado)) { %>

        <p style="color: green; font-weight: bold;">
          El mantenimiento se canceló correctamente.
        </p>

        <% } %>

        <!-- BARRA DE FILTROS (SEGMENTO Y PRIORIDAD) -->
        <form action="${pageContext.request.contextPath}/MantenimientoServlet"
              method="GET"
              class="filters-bar"
              style="align-items: flex-end; flex-wrap: wrap;">

          <input type="hidden" name="accion" value="listar">

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
            <label for="filtroPrioridad">Prioridad</label>
            <select id="filtroPrioridad" name="prioridad">
              <option value="">Todas las prioridades</option>
              <%
                for (String p : prioridades) {
                  boolean seleccionado = p.equals(prioridadSeleccionada);
              %>
              <option value="<%= p %>" <%= seleccionado ? "selected" : "" %>>
                <%= p %>
              </option>
              <%
                }
              %>
            </select>
          </div>

          <div style="display: flex; gap: 10px;">
            <button type="submit" class="btn btn-primary">Filtrar</button>
            <a href="${pageContext.request.contextPath}/MantenimientoServlet?accion=listar"
               class="btn btn-secondary"
               style="text-decoration: none; display: inline-flex; align-items: center;">
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


        <!-- TABLA DE MANTENIMIENTOS -->

        <div class="data-table-wrapper">

          <table class="data-table">

            <thead>
            <tr>
              <th>ID</th>
              <th>Segmento</th>
              <th>Tipo de mantenimiento</th>
              <th>Fecha de inicio</th>
              <th>Fecha de fin</th>
              <th>Prioridad</th>
              <th>Estado</th>
              <th>Notas / Descripción</th>
              <th>Acciones</th>
            </tr>
            </thead>

            <tbody>

            <%
              if (mantenimientos.isEmpty()) {
            %>
            <tr>
              <td colspan="9" style="text-align: center; padding: 20px; color: var(--color-texto-claro);">
                No se encontraron mantenimientos activos con los filtros seleccionados.
              </td>
            </tr>
            <%
            } else {
              for (int i = 0; i < mantenimientos.size(); i++) {

                Mantenimiento m =
                  mantenimientos.get(i);

                String prioridad = m.getPrioridad();
                String badgeClass = "badge-leve";

                if ("Media".equals(prioridad)) {
                  badgeClass = "badge-media";
                } else if ("Alta".equals(prioridad)) {
                  badgeClass = "badge-alta";
                } else if ("Crítica".equals(prioridad)) {
                  badgeClass = "badge-critica";
                }

                String codigoSegmento =
                  segmentos.getOrDefault(
                    m.getIdSegmento(),
                    "Segmento #" + m.getIdSegmento()
                  );

                String fechaInicio =
                  m.getFechaInicio() == null
                    ? "—"
                    : m.getFechaInicio()
                    .format(formatoFecha);

                String fechaFin =
                  m.getFechaFin() == null
                    ? "—"
                    : m.getFechaFin()
                    .format(formatoFecha);

                String estado = m.getEstado();

                String estadoVisible =
                  "En ejecucion".equals(estado)
                    ? "En ejecución"
                    : estado;

                String badgeEstado = "badge-programado";

                if ("En ejecucion".equals(estado)) {
                  badgeEstado = "badge-en-progreso";
                } else if ("Finalizado".equals(estado)) {
                  badgeEstado = "badge-finalizado";
                }

                boolean puedeEditar =
                  "Programado".equals(estado);

                boolean puedeCancelar =
                  "Programado".equals(estado)
                    || "En ejecucion".equals(estado);
            %>

            <tr>

              <!-- ID: ENLACE A ESTADO -->
              <td>
                <a
                  href="${pageContext.request.contextPath}/MantenimientoServlet?accion=estado&idMantenimiento=<%= m.getIdMantenimiento() %>"
                  title="Ver estado del mantenimiento"
                  style="font-weight: bold; text-decoration: underline;">
                  <%= m.getIdMantenimiento() %>
                </a>
              </td>

              <!-- SEGMENTO -->
              <td>
                <%= escaparHtml(codigoSegmento) %>
              </td>

              <!-- TIPO -->
              <td>
                <%= escaparHtml(m.getTipo()) %>
              </td>

              <!-- FECHA INICIO -->
              <td>
                <%= fechaInicio %>
              </td>

              <!-- FECHA FIN -->
              <td>
                <%= fechaFin %>
              </td>

              <!-- PRIORIDAD -->
              <td>
                <span class="badge <%= badgeClass %>">
                  <%= escaparHtml(prioridad) %>
                </span>
              </td>

              <!-- ESTADO -->
              <td>
                <span class="badge <%= badgeEstado %>">
                  <%= escaparHtml(estadoVisible) %>
                </span>
              </td>

              <!-- DESCRIPCIÓN -->
              <td>
                <%= escaparHtml(m.getDescripcionGeneral()) %>
              </td>

              <!-- ACCIONES -->
              <td>
                <div style="display: flex;
                flex-direction: column;
                align-items: flex-start;
                gap: 6px;">

                  <% if (puedeEditar) { %>

                  <a
                    href="${pageContext.request.contextPath}/MantenimientoServlet?accion=editar&idMantenimiento=<%= m.getIdMantenimiento() %>"
                    class="btn btn-primary"
                    style="padding: 8px 20px;
                   font-size: 14px;
                   min-width: 90px;
                   text-align: center;
                   box-sizing: border-box;">
                    Editar
                  </a>

                  <% } %>

                  <% if (puedeCancelar) { %>

                  <form
                    action="${pageContext.request.contextPath}/MantenimientoServlet"
                    method="POST"
                    style="margin: 0;"
                    onsubmit="return confirm('¿Estás seguro de que deseas cancelar el mantenimiento #<%= m.getIdMantenimiento() %>? Esta acción no se puede deshacer.');">

                    <input type="hidden" name="accion" value="cancelar">
                    <input type="hidden" name="idMantenimiento" value="<%= m.getIdMantenimiento() %>">

                    <button
                      type="submit"
                      class="btn btn-primary"
                      style="padding: 8px 20px;
                       font-size: 14px;
                       min-width: 90px;
                       text-align: center;
                       box-sizing: border-box;
                       background-color: #b42318;
                       border-color: #b42318;">
                      Cancelar
                    </button>

                  </form>

                  <% } %>

                </div>
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
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px; margin-top: 16px;">
          <span style="font-size: 13px; color: var(--color-texto-claro);">
            Mostrando <%= registroInicio %>–<%= registroFin %> de <%= totalRegistros %> registros (Página <%= paginaActual %> de <%= totalPaginas %>)
          </span>

          <% if (totalPaginas > 1) { %>
          <div style="display: flex; align-items: center; gap: 6px; flex-wrap: wrap;">
            <% if (paginaActual > 1) { %>
            <a href="<%= urlBase %>&pagina=<%= paginaActual - 1 %>"
               class="btn btn-secondary"
               style="padding: 6px 12px; font-size: 13px; text-decoration: none;">
              Anterior
            </a>
            <% } %>

            <%
              for (int p = 1; p <= totalPaginas; p++) {
                boolean esActual = (p == paginaActual);
            %>
            <a href="<%= urlBase %>&pagina=<%= p %>"
               class="btn <%= esActual ? "btn-primary" : "btn-secondary" %>"
               style="padding: 6px 12px; font-size: 13px; text-decoration: none;">
              <%= p %>
            </a>
            <%
              }
            %>

            <% if (paginaActual < totalPaginas) { %>
            <a href="<%= urlBase %>&pagina=<%= paginaActual + 1 %>"
               class="btn btn-secondary"
               style="padding: 6px 12px; font-size: 13px; text-decoration: none;">
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
