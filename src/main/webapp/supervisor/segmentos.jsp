<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="beans.capacityplanner.Segmento" %>
<%!
  private String html(String valor) {
    if (valor == null) return "";

    return valor.replace("&", "&amp;")
      .replace("<", "&lt;")
      .replace(">", "&gt;")
      .replace("\"", "&quot;")
      .replace("'", "&#39;");
  }

  private String claseEstado(String estado) {
    if ("Operativo".equals(estado)) return "operativo";
    if ("Degradado".equals(estado)) return "degradado";
    if ("En mantenimiento".equals(estado)) return "mantenimiento";
    return "fuera";
  }

  private double porcentajeUso(Segmento s) {
    if (s.getCapacidadTotal() <= 0) return 0.0;
    long usada = s.getCapacidadOcupada() + s.getCapacidadReservada();
    return (usada * 100.0) / s.getCapacidadTotal();
  }

  private String claseUso(double pct) {
    if (pct > 95.0) return "uso-critica";
    if (pct >= 80.0) return "uso-alta";
    return "uso-normal";
  }

  private String claseNivel(double pct) {
    if (pct > 95.0) return "critica";
    if (pct >= 80.0) return "alta";
    return "normal";
  }

  private String textoNivel(double pct) {
    if (pct > 95.0) return "Crítica";
    if (pct >= 80.0) return "Alta";
    return "Normal";
  }
%>
<%
  List<Segmento> segmentos = (List<Segmento>) request.getAttribute("listaSegmentos");
  if (segmentos == null) {
    response.sendRedirect(request.getContextPath() + "/SegmentoServletSuper");
    return;
  }

  String estadoSeleccionado = (String) request.getAttribute("estadoSeleccionado");
  if (estadoSeleccionado == null) estadoSeleccionado = "";

  String nivelSeleccionado = (String) request.getAttribute("nivelSeleccionado");
  if (nivelSeleccionado == null) nivelSeleccionado = "";

  int paginaActual = request.getAttribute("paginaActual") != null
    ? (Integer) request.getAttribute("paginaActual") : 1;
  int totalPaginas = request.getAttribute("totalPaginas") != null
    ? (Integer) request.getAttribute("totalPaginas") : 1;
  int totalRegistros = request.getAttribute("totalRegistros") != null
    ? (Integer) request.getAttribute("totalRegistros") : segmentos.size();
  int registroInicio = request.getAttribute("registroInicio") != null
    ? (Integer) request.getAttribute("registroInicio") : (segmentos.isEmpty() ? 0 : 1);
  int registroFin = request.getAttribute("registroFin") != null
    ? (Integer) request.getAttribute("registroFin") : segmentos.size();

  Segmento segmentoDetalle = (Segmento) request.getAttribute("segmentoDetalle");
  List<?> historialSegmento = (List<?>) request.getAttribute("historialSegmento");
  if (historialSegmento == null) historialSegmento = new ArrayList<>();

  String queryFiltros = "";
  if (!estadoSeleccionado.isEmpty()) {
    queryFiltros += "&estado=" + URLEncoder.encode(estadoSeleccionado, StandardCharsets.UTF_8);
  }
  if (!nivelSeleccionado.isEmpty()) {
    queryFiltros += "&nivel=" + URLEncoder.encode(nivelSeleccionado, StandardCharsets.UTF_8);
  }

  String urlBase = request.getContextPath() + "/SegmentoServletSuper?pagina=" + paginaActual + queryFiltros;
  String[] estadosPosibles = {"Operativo", "Degradado", "En mantenimiento", "Fuera de servicio"};
%>
<!doctype html>
<html lang="es">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <title>OceanLink | Segmentos</title>

  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/barras.css">
  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/supervisor/segmentos.css">
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
            class="control-submenu">
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
            class="control-submenu"
            checked>

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
               class="subopcion activo">
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
            class="control-submenu">

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
            class="control-submenu">

          <label
            for="control-mantenimientos"
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
               class="subopcion">
              Historial de programados
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
  <main class="contenido-principal pagina-segmentos">

    <section class="encabezado-pagina">
      <div class="encabezado-panel">
        <h2>Supervisor</h2>
        <h1>Segmentos</h1>
      </div>
    </section>

    <!-- Barra de filtros plana (estilo Capacity Planner) -->
    <section class="barra-herramientas">
      <form method="get"
            action="${pageContext.request.contextPath}/SegmentoServletSuper"
            class="formulario-filtro">

        <label for="filtroEstado">Estado:</label>
        <select id="filtroEstado" name="estado">
          <option value="">Todos</option>
          <% for (String est : estadosPosibles) { %>
          <option value="<%= est %>" <%= est.equals(estadoSeleccionado) ? "selected" : "" %>>
            <%= est %>
          </option>
          <% } %>
        </select>

        <label for="filtroNivel">Nivel de utilización:</label>
        <select id="filtroNivel" name="nivel">
          <option value="">Todos</option>
          <option value="normal" <%= "normal".equals(nivelSeleccionado) ? "selected" : "" %>>Normal (< 80%)</option>
          <option value="alta" <%= "alta".equals(nivelSeleccionado) ? "selected" : "" %>>Alta (80% – 95%)</option>
          <option value="critica" <%= "critica".equals(nivelSeleccionado) ? "selected" : "" %>>Crítica (> 95%)</option>
        </select>

        <button type="submit" class="boton secundario">Filtrar</button>

        <% if (!estadoSeleccionado.isEmpty() || !nivelSeleccionado.isEmpty()) { %>
        <a href="${pageContext.request.contextPath}/SegmentoServletSuper"
           class="boton secundario">
          Limpiar
        </a>
        <% } %>
      </form>

      <span class="contador-registros"><%= totalRegistros %> segmentos</span>
    </section>

    <!-- Tabla de segmentos -->
    <section class="contenedor-tabla">
      <table>
        <thead>
        <tr>
          <th>Código</th>
          <th>Inicio</th>
          <th>Final</th>
          <th>Total</th>
          <th>Ocupada</th>
          <th>Reservada</th>
          <th>Disponible</th>
          <th>Utilización</th>
          <th>Estado</th>
        </tr>
        </thead>
        <tbody>
        <% if (segmentos.isEmpty()) { %>
        <tr>
          <td colspan="9" class="celda-vacia">
            No se encontraron segmentos con los filtros seleccionados.
          </td>
        </tr>
        <% } else {
          for (Segmento s : segmentos) {
            double pct = porcentajeUso(s);
            String pctTexto = String.format(Locale.US, "%.1f", pct);
            String pctBarra = String.format(Locale.US, "%.0f", Math.min(pct, 100.0));
            boolean esSeleccionado = segmentoDetalle != null
              && segmentoDetalle.getIdSegmento() == s.getIdSegmento();
        %>
        <tr class="<%= esSeleccionado ? "fila-seleccionada" : "" %>">
          <td>
            <a class="enlace-segmento"
               href="<%= urlBase %>&detalle=<%= s.getIdSegmento() %>#detalle">
              <%= html(s.getCodigo()) %>
            </a>
          </td>
          <td><%= html(s.getNombreInicial()) %></td>
          <td><%= html(s.getNombreFinal()) %></td>
          <td><%= s.getCapacidadTotal() %> Gbps</td>
          <td><%= s.getCapacidadOcupada() %> Gbps</td>
          <td><%= s.getCapacidadReservada() %> Gbps</td>
          <td class="disponible-destacado"><%= s.getCapacidadDisponible() %> Gbps</td>
          <td>
            <div class="celda-uso">
              <div class="fila-uso-texto">
                <span><%= pctTexto %>%</span>
                <span class="estado <%= claseNivel(pct) %>"><%= textoNivel(pct) %></span>
              </div>
              <progress class="barra-uso <%= claseUso(pct) %>"
                        value="<%= pctBarra %>"
                        max="100"></progress>
            </div>
          </td>
          <td>
            <span class="estado <%= claseEstado(s.getEstado()) %>">
              <%= html(s.getEstado()) %>
            </span>
          </td>
        </tr>
        <%  }
        } %>
        </tbody>
      </table>
    </section>

    <!-- Pie de tabla: ayuda + paginación -->
    <div class="pie-tabla">
      <span>
        <% if (totalRegistros > 0) { %>
        Mostrando <%= registroInicio %>–<%= registroFin %> de <%= totalRegistros %> registros (Página <%= paginaActual %> de <%= totalPaginas %>) · Haz clic en un código para ver detalle e historial.
        <% } else { %>
        Haz clic en un código para ver detalle e historial.
        <% } %>
      </span>

      <% if (totalPaginas > 1) { %>
      <div class="controles-paginacion">
        <% if (paginaActual > 1) { %>
        <a class="boton secundario"
           href="${pageContext.request.contextPath}/SegmentoServletSuper?pagina=<%= paginaActual - 1 %><%= queryFiltros %>">
          Anterior
        </a>
        <% } else { %>
        <span class="pagina-deshabilitada">Anterior</span>
        <% } %>

        <% for (int p = 1; p <= totalPaginas; p++) {
          if (p == paginaActual) { %>
        <span class="boton primario"><%= p %></span>
        <%   } else { %>
        <a class="boton secundario"
           href="${pageContext.request.contextPath}/SegmentoServletSuper?pagina=<%= p %><%= queryFiltros %>">
          <%= p %>
        </a>
        <%   }
        } %>

        <% if (paginaActual < totalPaginas) { %>
        <a class="boton secundario"
           href="${pageContext.request.contextPath}/SegmentoServletSuper?pagina=<%= paginaActual + 1 %><%= queryFiltros %>">
          Siguiente
        </a>
        <% } else { %>
        <span class="pagina-deshabilitada">Siguiente</span>
        <% } %>
      </div>
      <% } %>
    </div>

    <!-- Panel de detalle e historial (#detalle) -->
    <% if (segmentoDetalle != null) {
      double pctDet = porcentajeUso(segmentoDetalle);
      String pctDetTexto = String.format(Locale.US, "%.1f", pctDet);
      String pctDetBarra = String.format(Locale.US, "%.0f", Math.min(pctDet, 100.0));
    %>
    <section class="panel-detalle" id="detalle">
      <div class="encabezado-detalle">
        <div>
          <h2>Detalle del segmento <%= html(segmentoDetalle.getCodigo()) %></h2>
          <p><%= html(segmentoDetalle.getNombreInicial()) %> — <%= html(segmentoDetalle.getNombreFinal()) %></p>
        </div>
        <a href="<%= urlBase %>" class="cerrar-detalle" title="Cerrar detalle">×</a>
      </div>

      <div class="datos-detalle">
        <div>
          <span>Estado operativo</span>
          <strong><%= html(segmentoDetalle.getEstado()) %></strong>
        </div>
        <div>
          <span>Capacidad total</span>
          <strong><%= segmentoDetalle.getCapacidadTotal() %> Gbps</strong>
        </div>
        <div>
          <span>Capacidad ocupada</span>
          <strong><%= segmentoDetalle.getCapacidadOcupada() %> Gbps</strong>
        </div>
        <div>
          <span>Capacidad reservada</span>
          <strong><%= segmentoDetalle.getCapacidadReservada() %> Gbps</strong>
        </div>
        <div>
          <span>Capacidad disponible</span>
          <strong><%= segmentoDetalle.getCapacidadDisponible() %> Gbps</strong>
        </div>
      </div>

      <div class="utilizacion-detalle">
        <div class="fila-utilizacion-detalle">
          <span>Utilización comprometida (Ocupada + Reservada)</span>
          <strong><%= pctDetTexto %>% — <%= textoNivel(pctDet) %></strong>
        </div>
        <progress class="barra-uso <%= claseUso(pctDet) %>"
                  value="<%= pctDetBarra %>"
                  max="100"></progress>
      </div>

      <div class="historial-segmento">
        <h3>Historial de eventos en este segmento</h3>

        <div class="contenedor-tabla">
          <table>
            <thead>
            <tr>
              <th>Registro</th>
              <th>Código</th>
              <th>Detalle</th>
              <th>Fecha</th>
              <th>Estado</th>
            </tr>
            </thead>
            <tbody>
            <% if (historialSegmento.isEmpty()) { %>
            <tr>
              <td colspan="5" class="celda-vacia">
                Este segmento no registra incidencias ni mantenimientos asociados.
              </td>
            </tr>
            <% } else {
              for (Object obj : historialSegmento) {
                java.lang.reflect.Field fDatos = obj.getClass().getDeclaredField("datos");
                fDatos.setAccessible(true);
                String[] ev = (String[]) fDatos.get(obj);
            %>
            <tr>
              <td><span class="badge-origen"><%= html(ev[0]) %></span></td>
              <td>
                <a class="enlace-segmento"
                   href="${pageContext.request.contextPath}<%= html(ev[5]) %>">
                  <%= html(ev[1]) %>
                </a>
              </td>
              <td><%= html(ev[2]) %></td>
              <td><%= html(ev[3]) %></td>
              <td><%= html(ev[4]) %></td>
            </tr>
            <%  }
            } %>
            </tbody>
          </table>
        </div>
      </div>
    </section>
    <% } %>

  </main>
</div>
</body>
</html>
