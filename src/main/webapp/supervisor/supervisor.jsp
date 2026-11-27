<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="beans.networkoperator.Incidencia" %>
<%@ page import="beans.maintenance.Mantenimiento" %>
<%@ page import="beans.supervisor.MetricaBarra" %>
<%@ page import="beans.supervisor.ResumenOperativo" %>
<%!
  private String html(String valor) {
    if (valor == null) return "";

    return valor.replace("&", "&amp;")
      .replace("<", "&lt;")
      .replace(">", "&gt;")
      .replace("\"", "&quot;")
      .replace("'", "&#39;");
  }
%>
<%
  if (request.getAttribute("totalIncidencias") == null) {
    response.sendRedirect(request.getContextPath() + "/DashboardServletSuper");
    return;
  }

  List<MetricaBarra> topSegmentos = (List<MetricaBarra>) request.getAttribute("topSegmentos");
  if (topSegmentos == null) topSegmentos = new ArrayList<>();

  List<MetricaBarra> topClientes = (List<MetricaBarra>) request.getAttribute("topClientes");
  if (topClientes == null) topClientes = new ArrayList<>();

  ResumenOperativo resumenOperativo = (ResumenOperativo) request.getAttribute("resumenOperativo");
  if (resumenOperativo == null) resumenOperativo = new ResumenOperativo();

  List<Incidencia> incidenciasRecientes = (List<Incidencia>) request.getAttribute("incidenciasRecientes");
  if (incidenciasRecientes == null) incidenciasRecientes = new ArrayList<>();

  List<Mantenimiento> proximosMantenimientosLista = (List<Mantenimiento>) request.getAttribute("proximosMantenimientosLista");
  if (proximosMantenimientosLista == null) proximosMantenimientosLista = new ArrayList<>();

  Map<Integer, String> mapaCodigosSegmento = (Map<Integer, String>) request.getAttribute("mapaCodigosSegmento");

  String claseUtilizacion = (String) request.getAttribute("claseUtilizacion");
  if (claseUtilizacion == null) claseUtilizacion = "kpi-alerta-normal";

  DateTimeFormatter formatoFecha = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm", Locale.forLanguageTag("es-PE"));
%>

<!doctype html>
<html lang="es">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <title>OceanLink | Dashboard</title>

  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/supervisor/supervisor.css">
  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/barras.css">
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
        <a href="${pageContext.request.contextPath}/DashboardServletSuper"
           class="activo">
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
  <main class="contenido-principal">

    <section class="encabezado-panel">
      <h2>Supervisor</h2>
      <h1>Dashboard general</h1>
    </section>

    <!-- Fila 1: 5 Tarjetas KPI superiores -->
    <section class="tarjetas">
      <article class="tarjeta">
        <div class="information">
          <p>Estado de la red</p>
        </div>
        <div class="information">
          <strong class="<%= html((String) request.getAttribute("claseEstadoRed")) %>">
            <%= html((String) request.getAttribute("estadoRed")) %>
          </strong>
        </div>
        <div class="information">
          <p>Segmentos operativos:
            <b><%= request.getAttribute("disponibilidad") %>%</b>
          </p>
        </div>
      </article>

      <article class="tarjeta">
        <div class="information">
          <p>Incidencias activas</p>
        </div>
        <div class="information">
          <strong><%= request.getAttribute("totalIncidencias") %></strong>
        </div>
        <div class="information">
          <p>Críticas:
            <b><%= request.getAttribute("incidenciasCriticas") %></b>
            Altas:
            <b><%= request.getAttribute("incidenciasAltas") %></b>
            Medias:
            <b><%= request.getAttribute("incidenciasMedias") %></b>
            Leves:
            <b><%= request.getAttribute("incidenciasLeves") %></b>
          </p>
        </div>
      </article>

      <article class="tarjeta">
        <div class="information">
          <p>Clientes afectados</p>
        </div>
        <div class="information">
          <strong><%= request.getAttribute("clientesAfectados") %></strong>
        </div>
        <div class="information">
          <p>
            Servicios afectados:
            <b><%= request.getAttribute("serviciosAfectados") %></b>
          </p>
        </div>
      </article>

      <article class="tarjeta">
        <div class="information">
          <p>Mantenimientos programados</p>
        </div>
        <div class="information">
          <strong><%= request.getAttribute("mantenimientosProgramados") == null ? "—" : request.getAttribute("mantenimientosProgramados") %></strong>
        </div>
        <div class="information">
          <p><%= request.getAttribute("mantenimientosProgramados") == null ? "Consulta no disponible" : "Próximos 7 días" %></p>
        </div>
      </article>

      <article class="tarjeta">
        <div class="information">
          <p>Utilización de la red</p>
        </div>
        <div class="information">
          <strong class="<%= html(claseUtilizacion) %>"><%= request.getAttribute("utilizacion") %>%</strong>
        </div>
        <div class="information">
          <p>Capacidad utilizada / total</p>
        </div>
      </article>
    </section>

    <!-- Fila 2: Cuadrícula central de 3 columnas -->
    <section class="panel-central-dashboard">

      <!-- Columna izquierda: Top 5 Segmentos por capacidad -->
      <article class="panel-dashboard">
        <div class="encabezado-tarjeta-dashboard">
          <div>
            <h3>Capacidad por segmento (Top 5)</h3>
            <p class="subtitulo-tarjeta-dashboard">Porcentaje de utilización en Gbps</p>
          </div>
          <a class="enlace-ver-todo" href="${pageContext.request.contextPath}/TarjetasServletSuper">Ver detalle</a>
        </div>

        <div class="lista-metricas-barras">
          <% if (topSegmentos.isEmpty()) { %>
          <p class="subtitulo-tarjeta-dashboard">No hay segmentos registrados.</p>
          <% } else {
            for (MetricaBarra seg : topSegmentos) { %>
          <div class="item-metrica-barra">
            <div class="fila-etiqueta-barra">
              <span class="codigo-metrica"><%= html(seg.getTitulo()) %></span>
              <span class="valor-metrica"><%= html(seg.getDetalle()) %></span>
            </div>
            <progress class="barra-progreso <%= html(seg.getClaseBarra()) %>"
                      value="<%= html(seg.getAnchoBarra()) %>"
                      max="100"></progress>
            <div class="fila-pie-barra">
              <span>Utilización: <b><%= html(seg.getPorcentaje()) %>%</b></span>
            </div>
          </div>
          <%  }
          } %>
        </div>
      </article>

      <!-- Columna central: Mapa estático enmarcado -->
      <article class="panel-dashboard">
        <div class="encabezado-tarjeta-dashboard">
          <div>
            <h3>Topología de red submarina</h3>
            <p class="subtitulo-tarjeta-dashboard">Red de cable submarino en el Pacífico</p>
          </div>
        </div>

        <div class="contenedor-mapa-dashboard">
          <img class="imagen-mapa-red"
               src="${pageContext.request.contextPath}/img/mapa_red.png"
               alt="Mapa de la red OceanLink: landing stations y segmentos en la costa del Pacífico">
        </div>
      </article>

      <!-- Columna derecha: Capacidad por cliente + Resumen operativo -->
      <div class="columna-derecha-dashboard">

        <article class="panel-dashboard panel-dashboard-crecer">
          <div class="encabezado-tarjeta-dashboard">
            <div>
              <h3>Capacidad contratada por cliente</h3>
              <p class="subtitulo-tarjeta-dashboard">Servicios activos principales</p>
            </div>
            <a class="enlace-ver-todo" href="${pageContext.request.contextPath}/ClienteServletSuper">Clientes</a>
          </div>

          <div class="lista-metricas-barras">
            <% if (topClientes.isEmpty()) { %>
            <p class="subtitulo-tarjeta-dashboard">No hay servicios activos contratados.</p>
            <% } else {
              for (MetricaBarra cli : topClientes) { %>
            <div class="item-metrica-barra">
              <div class="fila-etiqueta-barra">
                <span class="codigo-metrica"><%= html(cli.getTitulo()) %></span>
                <span class="valor-metrica"><%= html(cli.getDetalle()) %></span>
              </div>
              <progress class="barra-progreso <%= html(cli.getClaseBarra()) %>"
                        value="<%= html(cli.getAnchoBarra()) %>"
                        max="100"></progress>
            </div>
            <%  }
            } %>
          </div>
        </article>

        <article class="panel-dashboard">
          <div class="encabezado-tarjeta-dashboard">
            <div>
              <h3>Resumen operativo</h3>
              <p class="subtitulo-tarjeta-dashboard">Servicios, clientes e infraestructura</p>
            </div>
          </div>

          <ul class="lista-resumen-plataforma">
            <li>
              <span>Clientes activos</span>
              <strong><%= resumenOperativo.getClientesActivos() %></strong>
            </li>
            <li>
              <span>Servicios activos</span>
              <strong><%= resumenOperativo.getServiciosActivos() %></strong>
            </li>
            <li>
              <span>Solicitudes pendientes</span>
              <strong><%= resumenOperativo.getSolicitudesPendientes() %></strong>
            </li>
            <li>
              <span>Landing Stations</span>
              <strong><%= resumenOperativo.getTotalLandingStations() %></strong>
            </li>
          </ul>
        </article>

      </div>
    </section>

    <!-- Fila 3: 2 Tablas compactas sin repetir filtros -->
    <section class="panel-inferior-dashboard">

      <!-- Últimas incidencias activas -->
      <article class="panel-dashboard">
        <div class="encabezado-tarjeta-dashboard">
          <div>
            <h3>Últimas incidencias activas</h3>
            <p class="subtitulo-tarjeta-dashboard">Alertas recientes pendientes de cierre</p>
          </div>
          <a class="enlace-ver-todo" href="${pageContext.request.contextPath}/IncidenciaServletSuper">Ver todas</a>
        </div>

        <div class="table-wrapper">
          <table class="data-table">
            <thead>
            <tr>
              <th>ID</th>
              <th>Segmento</th>
              <th>Severidad</th>
              <th>Estado</th>
            </tr>
            </thead>
            <tbody>
            <% if (incidenciasRecientes.isEmpty()) { %>
            <tr>
              <td colspan="4" class="celda-centrada">No hay incidencias activas en este momento.</td>
            </tr>
            <% } else {
              for (Incidencia inc : incidenciasRecientes) { %>
            <tr>
              <td><a href="${pageContext.request.contextPath}/IncidenciaServletSuper?action=detalle&id=<%= inc.getIdIncidencia() %>"><%= html(inc.getCodigo()) %></a></td>
              <td><%= html(inc.getCodigosSegmentos()) %></td>
              <td class="<%= html(inc.getClaseSeveridad()) %>"><%= html(inc.getSeveridadTexto()) %></td>
              <td><%= html(inc.getEstadoTexto()) %></td>
            </tr>
            <%  }
            } %>
            </tbody>
          </table>
        </div>
        <p class="ayuda">Haz clic en el ID para ver el detalle de la incidencia.</p>
      </article>

      <!-- Próximos mantenimientos programados -->
      <article class="panel-dashboard">
        <div class="encabezado-tarjeta-dashboard">
          <div>
            <h3>Próximos mantenimientos</h3>
            <p class="subtitulo-tarjeta-dashboard">Ventanas planificadas en la red</p>
          </div>
          <a class="enlace-ver-todo" href="${pageContext.request.contextPath}/MantenimientoServletSuper?accion=listar">Ver programación</a>
        </div>

        <div class="table-wrapper">
          <table class="data-table">
            <thead>
            <tr>
              <th>ID</th>
              <th>Segmento</th>
              <th>Prioridad</th>
              <th>Inicio</th>
            </tr>
            </thead>
            <tbody>
            <% if (proximosMantenimientosLista.isEmpty()) { %>
            <tr>
              <td colspan="4" class="celda-centrada">No hay mantenimientos próximos programados.</td>
            </tr>
            <% } else {
              for (Mantenimiento m : proximosMantenimientosLista) {
                String codSeg = mapaCodigosSegmento != null
                  ? mapaCodigosSegmento.getOrDefault(m.getIdSegmento(), "Seg #" + m.getIdSegmento())
                  : "Seg #" + m.getIdSegmento();
                String fechaIni = m.getFechaInicio() != null ? m.getFechaInicio().format(formatoFecha) : "—";
            %>
            <tr>
              <td><a href="${pageContext.request.contextPath}/MantenimientoServletSuper?accion=estado&idMantenimiento=<%= m.getIdMantenimiento() %>">MNT-<%= m.getIdMantenimiento() %></a></td>
              <td><%= html(codSeg) %></td>
              <td><%= html(m.getPrioridad()) %></td>
              <td><%= html(fechaIni) %></td>
            </tr>
            <%  }
            } %>
            </tbody>
          </table>
        </div>
        <p class="ayuda">Haz clic en el ID para consultar el estado y bitácora.</p>
      </article>

    </section>

  </main>
</div>
</body>

</html>
