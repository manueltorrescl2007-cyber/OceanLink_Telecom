<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
        + "/MantenimientoServletSuper?accion=historial"
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

  StringBuilder basePaginacion = new StringBuilder(
    request.getContextPath() + "/MantenimientoServletSuper?accion=historial"
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
      "dd/MM/yyyy",
      Locale.forLanguageTag("es-PE")
    );

  String[] estados = {"Finalizado", "Cancelado"};
%>

<!doctype html>
<html lang="es">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <title>OceanLink | Historial de mantenimientos</title>

  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/barras.css">
  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/styles_MC.css">
  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/supervisor/mantenimientos.css">
</head>

<body>
<!-- Barra superior -->
<jsp:include page="header.jsp" />

<div class="contenedor">

  <!-- Barra lateral -->
  <aside class="menu-lateral">

    <div class="contenido-menu">

      <h2>Menú</h2>

      <nav class="navegacion-lateral"
           aria-label="Menú principal">

        <!-- Dashboard -->
        <a href="${pageContext.request.contextPath}/DashboardServletSuper">
          Dashboard general
        </a>

        <!-- Incidencias -->
        <div class="grupo-menu">
          <input
            type="checkbox"
            id="control-incidencias"
            class="control-submenu"
          >
          <label for="control-incidencias"
                 class="titulo-grupo">
            <span>Incidencias</span>
            <span class="flecha-submenu"></span>
          </label>
          <div class="contenido-submenu">
            <a href="${pageContext.request.contextPath}/IncidenciaServletSuper"
               class="subopcion">
              Visualizar
            </a>

            <a href="${pageContext.request.contextPath}/IncidenciaServletSuper?action=historial"
               class="subopcion">
              Historial de incidencias
            </a>
          </div>
        </div>

        <!-- Estado de la red -->
        <div class="grupo-menu">
          <input
            type="checkbox"
            id="controlEstadoRed"
            class="control-submenu">

          <label for="controlEstadoRed"
                 class="titulo-grupo">
            <span class="texto-grupo">
              Estado de la red
            </span>
            <span class="flecha-submenu"></span>
          </label>

          <div class="contenido-submenu">
            <a href="${pageContext.request.contextPath}/TarjetasServletSuper"
               class="subopcion">
              Capacidad
            </a>
            <a href="${pageContext.request.contextPath}/RutaServletSuper"
               class="subopcion">
              Rutas
            </a>
            <a href="${pageContext.request.contextPath}/SegmentoServletSuper"
               class="subopcion">
              Segmentos
            </a>
            <a href="${pageContext.request.contextPath}/LandingStationServletSuper"
               class="subopcion">
              Landing stations
            </a>
          </div>
        </div>

        <!-- Servicios y clientes -->
        <div class="grupo-menu">
          <input
            type="checkbox"
            id="control-servicios-clientes"
            class="control-submenu"
          >

          <label for="control-servicios-clientes"
                 class="titulo-grupo">
            <span class="texto-grupo">
              Servicios y clientes
            </span>
            <span class="flecha-submenu"></span>
          </label>
          <div class="contenido-submenu">
            <a href="${pageContext.request.contextPath}/ClienteServletSuper"
               class="subopcion">
              Clientes
            </a>

            <a href="${pageContext.request.contextPath}/ServicioServletSuper"
               class="subopcion">
              Servicios
            </a>
            <a href="${pageContext.request.contextPath}/SolicitudesServletSuper"
               class="subopcion">
              Solicitudes
            </a>
          </div>
        </div>

        <!-- Mantenimientos -->
        <div class="grupo-menu">
          <input
            type="checkbox"
            id="control-mantenimientos"
            class="control-submenu"
            checked
          >

          <label for="control-mantenimientos"
                 class="titulo-grupo">
            <span class="texto-grupo">
              Mantenimientos
            </span>
            <span class="flecha-submenu"></span>
          </label>

          <div class="contenido-submenu">
            <a href="${pageContext.request.contextPath}/MantenimientoServletSuper?accion=listar"
               class="subopcion">
              Programación
            </a>

            <a href="${pageContext.request.contextPath}/MantenimientoServletSuper?accion=historial"
               class="subopcion activo">
              Historial de mantenimientos
            </a>
          </div>
        </div>

        <!-- Reportes -->
        <a href="${pageContext.request.contextPath}/ReporteServletSuper">
          Reportes
        </a>
        <!-- Históricos -->
        <a href="${pageContext.request.contextPath}/HistoricoServletSuper">
          Históricos
        </a>
      </nav>
    </div>

    <!-- parte baja -->
    <div class="configuracion">
      <nav aria-label="Opciones del usuario">
        <a href="${pageContext.request.contextPath}/PerfilServlet">Perfil</a>
        <a href="${pageContext.request.contextPath}/LogoutServlet"
           class="cerrar-sesion">
          Cerrar sesión
        </a>
      </nav>
    </div>
  </aside>

  <!-- Contenido principal -->
  <main class="contenido-principal">

    <section class="encabezado-panel">
      <div>
        <h2>Supervisor</h2>
        <h1>Historial de mantenimientos</h1>
      </div>
    </section>

    <div class="content-container">

      <div class="card">

        <h2 class="card-title">
          Mantenimientos finalizados y cancelados
        </h2>

        <!-- BARRA DE FILTROS (SEGMENTO Y ESTADO) -->
        <form action="${pageContext.request.contextPath}/MantenimientoServletSuper"
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
                for (String est : estados) {
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
            <a href="${pageContext.request.contextPath}/MantenimientoServletSuper?accion=historial"
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
              <th>Tipo de mantenimiento</th>
              <th>Fecha de inicio</th>
              <th>Fecha de cierre</th>
              <th>Prioridad</th>
              <th>Estado</th>
              <th>Notas / Descripción</th>
            </tr>
            </thead>

            <tbody>

            <%
              if (historial.isEmpty()) {
            %>
            <tr>
              <td colspan="8" class="table-empty-cell">
                No se encontraron mantenimientos en el historial con los filtros seleccionados.
              </td>
            </tr>
            <%
            } else {
              for (int i = 0; i < historial.size(); i++) {

                Mantenimiento m = historial.get(i);

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
                    : m.getFechaInicio().format(formatoFecha);

                String fechaFin =
                  m.getFechaFin() == null
                    ? "—"
                    : m.getFechaFin().format(formatoFecha);

                String estado = m.getEstado();
                String badgeEstado = "Cancelado".equalsIgnoreCase(estado)
                  ? "badge-cancelado"
                  : "badge-finalizado";
            %>

            <tr>

              <!-- ID: ENLACE A ESTADO -->
              <td>
                <a
                  href="${pageContext.request.contextPath}/MantenimientoServletSuper?accion=estado&idMantenimiento=<%= m.getIdMantenimiento() %>"
                  title="Ver estado del mantenimiento"
                  class="table-id-link">
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

              <!-- FECHA CIERRE -->
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
                  <%= escaparHtml(estado) %>
                </span>
              </td>

              <!-- DESCRIPCIÓN -->
              <td>
                <%= escaparHtml(m.getDescripcionGeneral()) %>
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
