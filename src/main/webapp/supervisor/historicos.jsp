<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="beans.supervisor.HistoricoGeneral" %>

<%
  List<HistoricoGeneral> listaHistorico = (List<HistoricoGeneral>) request.getAttribute("listaHistorico");
  if (listaHistorico == null) listaHistorico = new ArrayList<>();

  List<String> listaSegmentos = (List<String>) request.getAttribute("listaSegmentos");
  if (listaSegmentos == null) listaSegmentos = new ArrayList<>();

  String desdeSeleccionado = (String) request.getAttribute("desdeSeleccionado");
  if (desdeSeleccionado == null) desdeSeleccionado = "";

  String hastaSeleccionado = (String) request.getAttribute("hastaSeleccionado");
  if (hastaSeleccionado == null) hastaSeleccionado = "";

  String origenSeleccionado = (String) request.getAttribute("origenSeleccionado");
  if (origenSeleccionado == null) origenSeleccionado = "";

  String segmentoSeleccionado = (String) request.getAttribute("segmentoSeleccionado");
  if (segmentoSeleccionado == null) segmentoSeleccionado = "";

  Integer paginaActualObj = (Integer) request.getAttribute("paginaActual");
  int paginaActual = (paginaActualObj != null) ? paginaActualObj : 1;

  Integer totalPaginasObj = (Integer) request.getAttribute("totalPaginas");
  int totalPaginas = (totalPaginasObj != null) ? totalPaginasObj : 1;

  Integer totalRegistrosObj = (Integer) request.getAttribute("totalRegistros");
  int totalRegistros = (totalRegistrosObj != null) ? totalRegistrosObj : 0;

  String queryFiltros = "&desde=" + URLEncoder.encode(desdeSeleccionado, StandardCharsets.UTF_8)
    + "&hasta=" + URLEncoder.encode(hastaSeleccionado, StandardCharsets.UTF_8)
    + "&origen=" + URLEncoder.encode(origenSeleccionado, StandardCharsets.UTF_8)
    + "&segmento=" + URLEncoder.encode(segmentoSeleccionado, StandardCharsets.UTF_8);
%>

<!doctype html>
<html lang="es">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <title>OceanLink | Históricos</title>

  <link rel="stylesheet"
        href="<%= request.getContextPath() %>/css/barras.css">
  <link rel="stylesheet"
        href="<%= request.getContextPath() %>/css/supervisor/historicos.css?v=2">
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
        <a href="<%= request.getContextPath() %>/DashboardServletSuper">
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
            <a href="<%= request.getContextPath() %>/IncidenciaServletSuper"
               class="subopcion">
              Visualizar
            </a>

            <a href="<%= request.getContextPath() %>/IncidenciaServletSuper?action=historial"
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
            <a href="<%= request.getContextPath() %>/TarjetasServletSuper"
               class="subopcion">
              Capacidad
            </a>
            <a href="<%= request.getContextPath() %>/RutaServletSuper"
               class="subopcion">
              Rutas
            </a>
            <a href="<%= request.getContextPath() %>/SegmentoServletSuper"
               class="subopcion">
              Segmentos
            </a>
            <a href="<%= request.getContextPath() %>/LandingStationServletSuper"
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

            <a href="<%= request.getContextPath() %>/ClienteServletSuper"
               class="subopcion">
              Clientes
            </a>

            <a href="<%= request.getContextPath() %>/ServicioServletSuper"
               class="subopcion">
              Servicios
            </a>
            <a href="<%= request.getContextPath() %>/SolicitudesServletSuper"
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
          >

          <label
            for="control-mantenimientos"
            class="titulo-grupo">

            <span class="texto-grupo">
                Mantenimientos
            </span>

            <span class="flecha-submenu"></span>

          </label>

          <div class="contenido-submenu">

            <a href="<%= request.getContextPath() %>/MantenimientoServletSuper?accion=listar"
               class="subopcion">
              Programación
            </a>

            <a href="<%= request.getContextPath() %>/MantenimientoServletSuper?accion=historial"
               class="subopcion">
              Historial de programados
            </a>
          </div>
        </div>

        <!-- Reportes -->
        <a href="<%= request.getContextPath() %>/ReporteServletSuper">
          Reportes
        </a>

        <!-- Históricos -->
        <a href="<%= request.getContextPath() %>/HistoricoServletSuper"
           class="activo">
          Históricos
        </a>
      </nav>
    </div>

    <!-- Parte baja -->
    <div class="configuracion">
      <nav aria-label="Opciones del usuario">
        <a href="${pageContext.request.contextPath}/PerfilServlet">Perfil</a>
        <a href="<%= request.getContextPath() %>/LogoutServlet"
           class="cerrar-sesion">
          Cerrar sesión
        </a>
      </nav>
    </div>
  </aside>

  <!-- Contenido principal -->
  <main class="contenido-principal">
    <section class="encabezado-panel">
      <h2>Supervisor</h2>
      <h1>Histórico general</h1>
    </section>

    <section class="card">
      <h2 class="card-title">Filtrar</h2>

      <form method="get" action="<%= request.getContextPath() %>/HistoricoServletSuper" class="filtros">
        <input type="date" name="desde" title="Fecha desde" value="<%= desdeSeleccionado %>">
        <input type="date" name="hasta" title="Fecha hasta" value="<%= hastaSeleccionado %>">

        <select name="origen">
          <option value="" <%= "".equals(origenSeleccionado) ? "selected" : "" %>>Origen / Registro</option>
          <option value="Incidencia" <%= "Incidencia".equals(origenSeleccionado) ? "selected" : "" %>>Incidencia</option>
          <option value="Mantenimiento" <%= "Mantenimiento".equals(origenSeleccionado) ? "selected" : "" %>>Mantenimiento</option>
        </select>

        <select name="segmento">
          <option value="" <%= "".equals(segmentoSeleccionado) ? "selected" : "" %>>Segmento</option>
          <%
            for (int i = 0; i < listaSegmentos.size(); i++) {
              String seg = listaSegmentos.get(i);
          %>
          <option value="<%= seg %>" <%= seg.equals(segmentoSeleccionado) ? "selected" : "" %>><%= seg %></option>
          <%
            }
          %>
        </select>

        <button type="submit" class="boton-filtrar">Filtrar</button>
        <a href="<%= request.getContextPath() %>/HistoricoServletSuper" class="boton-limpiar">Limpiar</a>
      </form>

      <div class="table-wrapper">
        <table class="data-table">
          <thead>
          <tr>
            <th>ID</th>
            <th>Registro</th>
            <th>Segmento</th>
            <th>Tipo</th>
            <th>Fecha de cierre</th>
            <th>Estado / Severidad</th>
          </tr>
          </thead>
          <tbody>
          <%
            if (listaHistorico.isEmpty()) {
          %>
          <tr>
            <td colspan="6" style="text-align: center; color: var(--color-texto-claro); padding: 20px;">
              No se encontraron registros históricos para los filtros seleccionados.
            </td>
          </tr>
          <%
          } else {
            for (int i = 0; i < listaHistorico.size(); i++) {
              HistoricoGeneral reg = listaHistorico.get(i);
              String tipoReg = reg.getTipoRegistro();
              String claseBadge = reg.getClaseBadge();
          %>
          <tr>
            <td>
              <% if ("Incidencia".equals(tipoReg)) { %>
              <a href="<%= request.getContextPath() %>/IncidenciaServletSuper?action=detalle&id=<%= reg.getIdNumerico() %>">
                <%= reg.getCodigoMostrar() %>
              </a>
              <% } else { %>
              <a href="<%= request.getContextPath() %>/MantenimientoServletSuper?accion=estado&idMantenimiento=<%= reg.getIdNumerico() %>">
                <%= reg.getCodigoMostrar() %>
              </a>
              <% } %>
            </td>
            <td><span class="badge badge-registro"><%= tipoReg %></span></td>
            <td><span class="badge badge-segmento"><%= reg.getSegmento() %></span></td>
            <td><%= reg.getDetalleTipo() %></td>
            <td><%= reg.getFechaFormateada() %></td>
            <td>
              <% if ("Mantenimiento".equals(tipoReg)) { %>
              <span class="badge <%= claseBadge %>"><%= reg.getEstadoSeveridad() %></span>
              <% } else { %>
              <span class="<%= claseBadge %>"><%= reg.getEstadoSeveridad() %></span>
              <% } %>
            </td>
          </tr>
          <%
              }
            }
          %>
          </tbody>
        </table>
      </div>

      <!-- Paginación -->
      <div class="paginacion">
        <span>Mostrando página <strong><%= paginaActual %></strong> de <strong><%= totalPaginas %></strong> (<%= totalRegistros %> registros en total)</span>

        <div class="paginacion-controles">
          <% if (paginaActual > 1) { %>
          <a href="<%= request.getContextPath() %>/HistoricoServletSuper?pagina=<%= paginaActual - 1 %><%= queryFiltros %>">Anterior</a>
          <% } else { %>
          <span class="deshabilitado">Anterior</span>
          <% } %>

          <%
            for (int p = 1; p <= totalPaginas; p++) {
              if (p == paginaActual) {
          %>
          <span class="pagina-activa"><%= p %></span>
          <%
          } else {
          %>
          <a href="<%= request.getContextPath() %>/HistoricoServletSuper?pagina=<%= p %><%= queryFiltros %>"><%= p %></a>
          <%
              }
            }
          %>

          <% if (paginaActual < totalPaginas) { %>
          <a href="<%= request.getContextPath() %>/HistoricoServletSuper?pagina=<%= paginaActual + 1 %><%= queryFiltros %>">Siguiente</a>
          <% } else { %>
          <span class="deshabilitado">Siguiente</span>
          <% } %>
        </div>
      </div>

      <p class="ayuda">Haz clic en el ID del registro para ver su detalle.</p>
    </section>
  </main>

</div>
</body>
</html>
