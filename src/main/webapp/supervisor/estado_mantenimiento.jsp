<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="beans.maintenance.Mantenimiento" %>
<%@ page import="beans.maintenance.ActividadMantenimiento" %>
<%@ page import="java.util.*" %>
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
  Mantenimiento m =
    (Mantenimiento) request.getAttribute("mantenimiento");

  List<ActividadMantenimiento> actividades =
    (List<ActividadMantenimiento>) request.getAttribute("actividades");

  Map<Integer, String> segmentos =
    (Map<Integer, String>) request.getAttribute("segmentos");

  if (m == null) {
    response.sendRedirect(
      request.getContextPath()
        + "/MantenimientoServletSuper?accion=listar"
    );
    return;
  }

  if (actividades == null) {
    actividades = new ArrayList<>();
  }

  String codigoSegmento = segmentos != null
    ? segmentos.getOrDefault(m.getIdSegmento(), "Segmento #" + m.getIdSegmento())
    : "Segmento #" + m.getIdSegmento();

  DateTimeFormatter formatoFecha =
    DateTimeFormatter.ofPattern(
      "dd/MM/yyyy HH:mm",
      Locale.forLanguageTag("es-PE")
    );

  String fechaInicio = m.getFechaInicio() == null
    ? "—" : m.getFechaInicio().format(formatoFecha);

  String fechaFin = m.getFechaFin() == null
    ? "—" : m.getFechaFin().format(formatoFecha);

  String estado = m.getEstado() == null ? "Programado" : m.getEstado();
  boolean esCancelado = "Cancelado".equalsIgnoreCase(estado);
  boolean enEjecucion = "En ejecucion".equalsIgnoreCase(estado);
  boolean finalizado = "Finalizado".equalsIgnoreCase(estado);

  String urlVolver = (finalizado || esCancelado)
    ? request.getContextPath() + "/MantenimientoServletSuper?accion=historial"
    : request.getContextPath() + "/MantenimientoServletSuper?accion=listar";
%>

<!doctype html>
<html lang="es">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <title>OceanLink | Estado de mantenimiento</title>

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
               class="subopcion <%= (!finalizado && !esCancelado) ? "activo" : "" %>">
              Programación
            </a>

            <a href="${pageContext.request.contextPath}/MantenimientoServletSuper?accion=historial"
               class="subopcion <%= (finalizado || esCancelado) ? "activo" : "" %>">
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
        <h1>Estado del mantenimiento #<%= m.getIdMantenimiento() %></h1>
      </div>
    </section>

    <div class="content-container">

      <div class="card">

        <div class="card-header-row">
          <h2 class="card-title">
            Seguimiento de actividad
          </h2>
          <a href="<%= urlVolver %>"
             class="btn btn-secondary">
            Volver
          </a>
        </div>

        <% if (esCancelado) { %>
        <div class="estado-cancelado-wrapper">
          <span class="badge badge-cancelado">Cancelado</span>
        </div>
        <% } else { %>
        <!-- STEPPER -->
        <div class="stepper">
          <div class="stepper-step <%= (enEjecucion || finalizado) ? "completed" : "active" %>">
            <div class="stepper-circle"></div>
            <span class="stepper-label">Programado</span>
          </div>

          <div class="stepper-step <%= finalizado ? "completed" : (enEjecucion ? "active" : "") %>">
            <div class="stepper-circle"></div>
            <span class="stepper-label">En ejecución</span>
          </div>

          <div class="stepper-step <%= finalizado ? "active" : "" %>">
            <div class="stepper-circle"></div>
            <span class="stepper-label">Finalizado</span>
          </div>
        </div>
        <% } %>

        <!-- DATOS DEL MANTENIMIENTO -->
        <div class="form-grid">

          <div class="form-field">
            <label>Segmento</label>
            <input type="text" value="<%= escaparHtml(codigoSegmento) %>" readonly>
          </div>

          <div class="form-field">
            <label>Tipo de mantenimiento</label>
            <input type="text" value="<%= escaparHtml(m.getTipo()) %>" readonly>
          </div>

          <div class="form-field">
            <label>Prioridad</label>
            <input type="text" value="<%= escaparHtml(m.getPrioridad()) %>" readonly>
          </div>

          <div class="form-field">
            <label>Estado</label>
            <input type="text" value="<%= "En ejecucion".equals(estado) ? "En ejecución" : escaparHtml(estado) %>" readonly>
          </div>

          <div class="form-field">
            <label>Fecha de inicio</label>
            <input type="text" value="<%= fechaInicio %>" readonly>
          </div>

          <div class="form-field">
            <label>Fecha de fin</label>
            <input type="text" value="<%= fechaFin %>" readonly>
          </div>

          <div class="form-field full-width">
            <label>Notas / Descripción</label>
            <textarea readonly><%= escaparHtml(m.getDescripcionGeneral()) %></textarea>
          </div>

        </div>

        <!-- BITÁCORA DE INTERVENCIÓN (SOLO LECTURA) -->
        <div class="bitacora">
          <strong>Bitácora de intervención</strong>

          <% if (actividades.isEmpty()) { %>
          <p class="bitacora-empty">
            No hay actividades registradas en la bitácora.
          </p>
          <% } else {
            for (int i = 0; i < actividades.size(); i++) {
              ActividadMantenimiento act = actividades.get(i);
              String fechaAct = act.getFechaHora() == null
                ? "" : act.getFechaHora().format(formatoFecha);
          %>
          <div class="actividad-bitacora">
            <p>
              <strong><%= escaparHtml(act.getTipoActividad()) %></strong>
              <span><%= fechaAct %></span>
            </p>
            <p><%= escaparHtml(act.getDescripcionBitacora()) %></p>
            <small><%= escaparHtml(act.getTipoActividad()) %></small>
          </div>
          <%   }
          } %>
        </div>

      </div>

    </div>

  </main>

</div>

</body>
</html>
