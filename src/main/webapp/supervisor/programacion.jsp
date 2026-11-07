<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="beans.maintenance.Mantenimiento" %>
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
  ArrayList<Mantenimiento> mantenimientos =
    (ArrayList<Mantenimiento>)
      request.getAttribute("mantenimientos");

  Map<Integer, String> segmentos =
    (Map<Integer, String>)
      request.getAttribute("segmentos");

  // Esta vista debe recibir los datos del Servlet.
  if (mantenimientos == null || segmentos == null) {
    response.sendRedirect(
      request.getContextPath()
        + "/MantenimientoServlet?accion=listar"
    );
    return;
  }

  DateTimeFormatter formatoFecha =
    DateTimeFormatter.ofPattern(
      "dd/MM/yyyy",
      Locale.forLanguageTag("es-PE")
    );

  // Mantener al menos 10 filas.
  int totalFilas = Math.max(10, mantenimientos.size());

  String resultado = request.getParameter("resultado");
%>
<!doctype html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>OceanLink | Dashboard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/styles_MC">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/barras.css">
</head>

<body>

<!-- Control para abrir/cerrar el menú -->
<input
  type="checkbox"
  id="controlMenu"
  class="control-menu"
  aria-label="Ocultar menú lateral">

<!-- Barra superior -->
<header class="barra-superior">

  <div class="zona-logo">

    <label
            for="controlMenu"
            class="boton-menu"
            title="Ocultar o mostrar menú">☰</label>

    <a href="${pageContext.request.contextPath}/DashboardServletSuper"
       class="logo">
        OceanLink
    </a>
  </div>

  <div class="usuario">
    <div class="foto-usuario">SU</div>
    <div>
        <p class="nombre-usuario">Username</p>
        <p class="rol-usuario">Supervisor</p>
    </div>
  </div>
</header>

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
          <!-- Controla la apertura del submenú -->
          <input
            type="checkbox"
            id="control-incidencias"
            class="control-submenu"
          >
          <!-- Al hacer clic, marca o desmarca el checkbox -->
          <label for="control-incidencias"
                 class="titulo-grupo">
            <span>Incidencias</span>
            <span class="flecha-submenu"></span>
          </label>
          <!-- Opciones que aparecen al desplegar -->
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
          <!-- Controla la apertura del submenú -->
          <input
            type="checkbox"
            id="controlEstadoRed"
            class="control-submenu">

          <!-- Al hacer clic, marca o desmarca el checkbox -->
          <label for="controlEstadoRed"
                 class="titulo-grupo">
            <span class="texto-grupo">
                Estado de la red
            </span>
            <span class="flecha-submenu"></span>
          </label>

          <!-- Opciones que aparecen al desplegar -->
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
            <a
              href="${pageContext.request.contextPath}/SolicitudesServletSuper"
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

            <a
              href="${pageContext.request.contextPath}/MantenimientoServletSuper"
              class="subopcion">
              Programación
            </a>

            <a
              href="${pageContext.request.contextPath}/MantenimientoServletSuper"
              class="subopcion">
              Historial de programados
            </a>
          </div>
        </div>

        <!-- Reportes -->
        <a href="${pageContext.request.contextPath}/supervisor/reportes.jsp">
            Reportes
        </a>
        <!-- Históricos -->
        <a href="${pageContext.request.contextPath}/supervisor/historicos.jsp">
            Históricos
        </a>
      </nav>
    </div>
    <!-- parte baja -->
    <div class="configuracion">
      <nav aria-label="Opciones del usuario">
          <a href="#">Perfil</a>
          <a href="${pageContext.request.contextPath}/login.jsp"
             class="cerrar-sesion">
              Cerrar sesión
          </a>
      </nav>
    </div>
  </aside>

  <!-- Contenido principal -->
  <main class="contenido-principal">

    <div class="content-container">

      <div class="card">
        <h2 class="card-title">Supervisor</h2>
        <h1 class="card-title">Utilización de la red</h1>

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


        <!-- BARRA SUPERIOR -->

        <div class="table-toolbar">

          <div class="table-toolbar-left">
            <span>&#9638;</span>
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
              for (int i = 0; i < totalFilas; i++) {

                if (i < mantenimientos.size()) {

                  Mantenimiento m =
                    mantenimientos.get(i);

                  // PRIORIDAD
                  String prioridad = m.getPrioridad();

                  String badgeClass = "badge-leve";

                  if ("Media".equals(prioridad)) {
                    badgeClass = "badge-media";

                  } else if ("Alta".equals(prioridad)) {
                    badgeClass = "badge-alta";

                  } else if ("Crítica".equals(prioridad)) {
                    badgeClass = "badge-critica";
                  }

                  // SEGMENTO
                  String codigoSegmento =
                    segmentos.getOrDefault(
                      m.getIdSegmento(),
                      "Segmento #" + m.getIdSegmento()
                    );

                  // FECHAS
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

                  // ESTADO CALCULADO POR EL DAO
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
                  href="${pageContext.request.contextPath}/MantenimientoServletSuper?accion=estado&idMantenimiento=<%= m.getIdMantenimiento() %>"
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
                <%= escaparHtml(
                  m.getDescripcionGeneral()
                ) %>
              </td>

              <!-- ACCIONES -->
              <td>
                <div style="display: flex;
                flex-direction: column;
                align-items: flex-start;
                gap: 6px;">

                  <% if (puedeEditar) { %>

                  <a
                    href="${pageContext.request.contextPath}/MantenimientoServletSuper?accion=editar&idMantenimiento=<%= m.getIdMantenimiento() %>"
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
                    action="${pageContext.request.contextPath}/MantenimientoServletSuper"
                    method="POST"
                    style="margin: 0;"
                    onsubmit="return confirm('¿Estás seguro de que deseas cancelar el mantenimiento #<%= m.getIdMantenimiento() %>? Esta acción no se puede deshacer.');">

                    <input
                      type="hidden"
                      name="accion"
                      value="cancelar">

                    <input
                      type="hidden"
                      name="idMantenimiento"
                      value="<%= m.getIdMantenimiento() %>">

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

              <!-- FILAS VACÍAS DEL DISEÑO ORIGINAL -->
            <tr class="row-empty">
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
            </tr>

            <%
                }
              }
            %>

            </tbody>

          </table>

        </div>

      </div>

    </div>

  </main>

</div>
</body>
</html>
