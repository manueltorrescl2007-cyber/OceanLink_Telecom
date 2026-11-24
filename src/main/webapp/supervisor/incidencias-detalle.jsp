<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.networkoperator.Incidencia" %>
<%@ page import="beans.networkoperator.Observacion" %>
<%@ page import="beans.networkoperator.Servicio" %>
<%!
  private String escapar(String valor) {
    if (valor == null) return "";

    return valor.replace("&", "&amp;")
      .replace("<", "&lt;")
      .replace(">", "&gt;")
      .replace("\"", "&quot;")
      .replace("'", "&#39;");
  }
%>
<%
  Incidencia inc = (Incidencia) request.getAttribute("incidencia");
  ArrayList<Servicio> listaServicios = (ArrayList<Servicio>) request.getAttribute("listaServicios");
  ArrayList<Observacion> listaObservaciones = (ArrayList<Observacion>) request.getAttribute("listaObservaciones");
  if (listaServicios == null) { listaServicios = new ArrayList<>(); }
  if (listaObservaciones == null) { listaObservaciones = new ArrayList<>(); }

  boolean cerrada = inc != null && "Cerrada".equals(inc.getEstado());
  String origen = cerrada ? "Historial" : "Visualizar";
  String paginaOrigen = request.getContextPath() + "/IncidenciaServletSuper" + (cerrada ? "?action=historial" : "");

  String[] estados = {"Detectada", "En analisis", "Reparacion programada", "En reparacion", "Servicio restaurado", "Cerrada"};
  String[] pasos   = {"Detectada", "En análisis", "Rep. programada", "En reparación", "Restaurado", "Cerrada"};
  int pasoActual = 0;
  if (inc != null) {
    for (int i = 0; i < estados.length; i++) {
      if (estados[i].equals(inc.getEstado())) {
        pasoActual = i + 1;
        break;
      }
    }
  }
%>
<!doctype html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>OceanLink - <%= inc != null ? escapar(inc.getCodigo()) : "Incidencia no encontrada" %></title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/network_operator/network_operator.css?v=7">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/barras.css">
</head>
<body>

<jsp:include page="header.jsp" />

<div class="contenedor">

  <aside class="menu-lateral">
    <div class="contenido-menu">
      <h2>Menú</h2>
      <nav class="navegacion-lateral" aria-label="Menú principal">

        <a href="${pageContext.request.contextPath}/DashboardServletSuper">
          Dashboard general
        </a>

        <div class="grupo-menu">
          <input type="checkbox" id="control-incidencias" class="control-submenu" checked>
          <label for="control-incidencias" class="titulo-grupo">
            <span>Incidencias</span>
            <span class="flecha-submenu"></span>
          </label>
          <div class="contenido-submenu">
            <a href="${pageContext.request.contextPath}/IncidenciaServletSuper"
               class="subopcion <%= !cerrada ? "activo" : "" %>">
              Visualizar
            </a>
            <a href="${pageContext.request.contextPath}/IncidenciaServletSuper?action=historial"
               class="subopcion <%= cerrada ? "activo" : "" %>">
              Historial de incidencias
            </a>
          </div>
        </div>

        <div class="grupo-menu">
          <input type="checkbox" id="controlEstadoRed" class="control-submenu">
          <label for="controlEstadoRed" class="titulo-grupo">
            <span class="texto-grupo">Estado de la red</span>
            <span class="flecha-submenu"></span>
          </label>
          <div class="contenido-submenu">
            <a href="${pageContext.request.contextPath}/TarjetasServletSuper" class="subopcion">Capacidad</a>
            <a href="${pageContext.request.contextPath}/RutaServletSuper" class="subopcion">Rutas</a>
            <a href="${pageContext.request.contextPath}/SegmentoServletSuper" class="subopcion">Segmentos</a>
            <a href="${pageContext.request.contextPath}/LandingStationServletSuper" class="subopcion">Landing stations</a>
          </div>
        </div>

        <div class="grupo-menu">
          <input type="checkbox" id="control-servicios-clientes" class="control-submenu">
          <label for="control-servicios-clientes" class="titulo-grupo">
            <span class="texto-grupo">Servicios y clientes</span>
            <span class="flecha-submenu"></span>
          </label>
          <div class="contenido-submenu">
            <a href="${pageContext.request.contextPath}/ClienteServletSuper" class="subopcion">Clientes</a>
            <a href="${pageContext.request.contextPath}/ServicioServletSuper" class="subopcion">Servicios</a>
            <a href="${pageContext.request.contextPath}/SolicitudesServletSuper" class="subopcion">Solicitudes</a>
          </div>
        </div>

        <div class="grupo-menu">
          <input type="checkbox" id="control-mantenimientos" class="control-submenu">
          <label for="control-mantenimientos" class="titulo-grupo">
            <span class="texto-grupo">Mantenimientos</span>
            <span class="flecha-submenu"></span>
          </label>
          <div class="contenido-submenu">
            <a href="${pageContext.request.contextPath}/MantenimientoServletSuper?accion=listar" class="subopcion">Programación</a>
            <a href="${pageContext.request.contextPath}/MantenimientoServletSuper?accion=historial" class="subopcion">Historial de mantenimientos</a>
          </div>
        </div>

        <a href="${pageContext.request.contextPath}/ReporteServletSuper">Reportes</a>
        <a href="${pageContext.request.contextPath}/HistoricoServletSuper">Históricos</a>
      </nav>
    </div>

    <div class="configuracion">
      <nav aria-label="Opciones del usuario">
        <a href="${pageContext.request.contextPath}/PerfilServlet">Perfil</a>
        <a href="${pageContext.request.contextPath}/LogoutServlet" class="cerrar-sesion">Cerrar sesión</a>
      </nav>
    </div>
  </aside>

  <main class="contenido-principal">

    <section class="encabezado-panel">
      <h2>Supervisor</h2>
      <h1>Detalle de incidencia</h1>
    </section>

    <% if (inc == null) { %>
    <section class="card">
      <h2 class="card-title">Incidencia no encontrada</h2>
      <p class="ayuda">No se encontró una incidencia en la solicitud.
        <a href="${pageContext.request.contextPath}/IncidenciaServletSuper">Volver a incidencias activas</a>
      </p>
    </section>
    <% } else { %>
    <section class="card">
      <p class="migas">
        Incidencias / <a href="<%= paginaOrigen %>"><%= origen %></a> /
        <%= escapar(inc.getCodigo()) %>
      </p>

      <div class="titulo-incidencia">
        <h3><%= escapar(inc.getCodigo()) %></h3>
        <span class="badge <%= escapar(inc.getClaseSeveridad()) %>"><%= escapar(inc.getSeveridadTexto()) %></span>
      </div>

      <p class="segment-context">
        Segmento: <strong><%= escapar(inc.getCodigosSegmentos()) %></strong>
        <% if (inc.getFechaRegistro() != null) { %> · Detectada el <%= escapar(inc.getFechaRegistro()) %><% } %>
        <% if (inc.getFechaRestauracion() != null) { %> · Restaurada el <%= escapar(inc.getFechaRestauracion()) %><% } %>
        <% if (cerrada && inc.getFechaCierre() != null) { %> · Cerrada el <%= escapar(inc.getFechaCierre()) %><% } %>
      </p>

      <p class="descripcion-incidencia">
        <strong><%= escapar(inc.getTitulo()) %>.</strong> <%= escapar(inc.getDescripcion()) %>
        <% if (inc.getUsuario() != null && inc.getUsuario().getNombre() != null) { %>
        <span class="ayuda">(registrada por <%= escapar(inc.getUsuario().getNombre()) %>)</span>
        <% } %>
      </p>

      <!-- Estado actual de la incidencia: solo consulta para Supervisor -->
      <div class="stepper">
        <% for (int i = 1; i <= pasos.length; i++) {
          String clase = (i < pasoActual || cerrada) ? "completado" : (i == pasoActual ? "actual" : "");
        %>
        <div class="paso <%= clase %>">
          <div class="circulo"><%= "completado".equals(clase) ? "✓" : String.valueOf(i) %></div>
          <p><%= pasos[i - 1] %></p>
        </div>
        <% } %>
      </div>

      <div class="dos-columnas">
        <div class="columna">
          <h4>Servicios y clientes afectados</h4>
          <% if (listaServicios.isEmpty()) { %>
          <p class="ayuda">Ningún servicio activo pasa por los segmentos de esta incidencia.</p>
          <% } else {
            for (Servicio sv : listaServicios) { %>
          <div class="tarjeta">
            <span>SRV-<%= sv.getIdServicio() %></span>
            <span><%= escapar(sv.getSolicitud().getCliente().getNombre()) %></span>
          </div>
          <%   }
          } %>
        </div>

        <div class="columna">
          <h4>Bitácora e historial de cambios</h4>
          <% if (listaObservaciones.isEmpty()) { %>
          <p class="ayuda">Todavía no hay observaciones registradas.</p>
          <% } else {
            for (Observacion o : listaObservaciones) { %>
          <div class="registro">
            <strong><%= escapar(o.getFechaHora()) %> - <%= escapar(o.getUsuario().getNombre()) %></strong>
            <p><%= escapar(o.getMensaje()) %></p>
          </div>
          <%   }
          } %>

          <% if (cerrada) { %>
          <p class="ayuda">Incidencia cerrada.</p>
          <% } %>
        </div>
      </div>
    </section>
    <% } %>
  </main>
</div>
</body>
</html>
