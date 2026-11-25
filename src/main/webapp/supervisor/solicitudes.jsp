<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="beans.capacityplanner.Solicitud" %>
<%!
  private String texto(String valor) {
    if (valor == null) return "";

    return valor.replace("&", "&amp;")
      .replace("<", "&lt;")
      .replace(">", "&gt;")
      .replace("\"", "&quot;")
      .replace("'", "&#39;");
  }

  private static final DateTimeFormatter FORMATO_FECHA =
          DateTimeFormatter.ofPattern("dd/MM/uuuu HH:mm");

  private String mostrarEstado(String estado) {
      return "En evaluacion".equals(estado) ? "En evaluación" : texto(estado);
  }

  private String color(String estado) {
      if ("Rechazada".equals(estado)) return "rechazada";
      if ("Aprobada".equals(estado) || "Provisionada".equals(estado)
              || "Activa".equals(estado)) return "aprobada";
      return "pendiente";
  }
%>
<%
  String servlet = request.getContextPath() + "/SolicitudesServletSuper";
  ArrayList<Solicitud> solicitudes = (ArrayList<Solicitud>) request.getAttribute("listaSolicitudes");
  if (solicitudes == null) {
    response.sendRedirect(servlet);
    return;
  }
  Solicitud seleccionada = (Solicitud) request.getAttribute("solicitudSeleccionada");
  String filtro = (String) request.getAttribute("filtroEstado");
  if (filtro == null) filtro = "";
  String filtroUrl = java.net.URLEncoder.encode(filtro, "UTF-8");
  int paginaActual = (Integer) request.getAttribute("paginaActual");
  String urlPagina = servlet + "?estado=" + filtroUrl + "&pagina=";
  String[] estados = {"Registrada", "En evaluacion", "Aprobada", "Provisionada",
    "Activa", "Rechazada", "Pendiente por capacidad"};
%>

<!doctype html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Solicitudes | OceanLink</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/supervisor/solicitudes.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/barras.css">
</head>
<body>
<jsp:include page="header.jsp" />
<div class="contenedor">
  <aside class="menu-lateral">
    <div class="contenido-menu">
      <h2>Menú</h2>
      <nav class="navegacion-lateral" aria-label="Menú principal">
        <a href="${pageContext.request.contextPath}/DashboardServletSuper">Dashboard general</a>

        <div class="grupo-menu">
          <input type="checkbox" id="control-incidencias" class="control-submenu">
          <label for="control-incidencias" class="titulo-grupo">
            <span>Incidencias</span>
            <span class="flecha-submenu"></span>
          </label>
          <div class="contenido-submenu">
            <a href="${pageContext.request.contextPath}/IncidenciaServletSuper" class="subopcion">Visualizar</a>
            <a href="${pageContext.request.contextPath}/IncidenciaServletSuper?action=historial" class="subopcion">Historial de incidencias</a>
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
          <input type="checkbox" id="control-servicios-clientes" class="control-submenu" checked>
          <label for="control-servicios-clientes" class="titulo-grupo">
            <span class="texto-grupo">Servicios y clientes</span>
            <span class="flecha-submenu"></span>
          </label>
          <div class="contenido-submenu">
            <a href="${pageContext.request.contextPath}/ClienteServletSuper" class="subopcion">Clientes</a>
            <a href="${pageContext.request.contextPath}/ServicioServletSuper" class="subopcion">Servicios</a>
            <a href="${pageContext.request.contextPath}/SolicitudesServletSuper" class="subopcion activo">Solicitudes</a>
          </div>
        </div>

        <div class="grupo-menu">
          <input type="checkbox" id="control-mantenimientos" class="control-submenu">
          <label for="control-mantenimientos" class="titulo-grupo">
            <span class="texto-grupo">Mantenimientos</span>
            <span class="flecha-submenu"></span>
          </label>
          <div class="contenido-submenu">
            <a href="${pageContext.request.contextPath}/MantenimientoServletSuper" class="subopcion">Programación</a>
            <a href="${pageContext.request.contextPath}/MantenimientoServletSuper?accion=historial" class="subopcion">Historial de programados</a>
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
      <div><h2>Supervisor</h2><h1>Solicitudes</h1></div>
    </section>

    <section class="barra-filtros">
      <form method="get" action="<%= servlet %>" class="formulario-filtro">
        <label for="filtroEstado">Estado:</label>
        <select id="filtroEstado" name="estado">
          <option value="">Todos</option>
          <% for (String estado : estados) { %>
          <option value="<%= estado %>" <%= estado.equals(filtro) ? "selected" : "" %>><%= mostrarEstado(estado) %></option>
          <% } %>
        </select>
        <button class="boton secundario" type="submit">Filtrar</button>
      </form>
      <span class="cantidad-solicitudes">${totalRegistros} solicitudes</span>
    </section>

    <section class="tabla-contenedor">
      <table class="tabla-solicitudes">
        <thead><tr><th>ID</th><th>Cliente</th><th>Origen</th><th>Destino</th><th>Capacidad</th><th>Estado</th></tr></thead>
        <tbody>
        <% for (Solicitud s : solicitudes) { %>
        <tr class="fila-solicitud <%= seleccionada != null && seleccionada.getIdSolicitud() == s.getIdSolicitud() ? "fila-seleccionada" : "" %>">
          <td><a class="id-solicitud" href="<%= urlPagina %><%= paginaActual %>&id=<%= s.getIdSolicitud() %>#detalle-solicitud">SOL-<%= s.getIdSolicitud() %></a></td>
          <td><%= texto(s.getNombreCliente()) %></td>
          <td><%= texto(s.getNombreOrigen()) %></td>
          <td><%= texto(s.getNombreDestino()) %></td>
          <td><%= s.getCapacidadSolicitada() %> Gbps</td>
          <td><span class="etiqueta-estado <%= color(s.getEstado()) %>"><%= mostrarEstado(s.getEstado()) %></span></td>
        </tr>
        <% } %>
        <% if (solicitudes.isEmpty()) { %><tr><td colspan="6" class="sin-resultados">No hay solicitudes con este estado.</td></tr><% } %>
        </tbody>
      </table>
    </section>

    <%
      int totalPaginado = (Integer) request.getAttribute("totalRegistros");
      int paginaPaginada = (Integer) request.getAttribute("paginaActual");
      int paginasPaginadas = (Integer) request.getAttribute("totalPaginas");
      if (totalPaginado > 0) {
    %>
    <nav class="pagination-bar" aria-label="Paginación de resultados">
            <span class="pagination-info">
                Mostrando <%= request.getAttribute("registroInicio") %>–<%= request.getAttribute("registroFin") %>
                de <%= totalPaginado %> registros (Página <%= paginaPaginada %> de <%= paginasPaginadas %>)
            </span>
      <% if (paginasPaginadas > 1) { %>
      <div class="pagination-links">
        <% if (paginaPaginada > 1) { %>
        <a class="boton secundario" href="<%= urlPagina %><%= paginaPaginada - 1 %>">Anterior</a>
        <% } %>
        <% for (int numero = 1; numero <= paginasPaginadas; numero++) { %>
        <% if (numero == paginaPaginada) { %>
        <span class="boton primario" aria-current="page"><%= numero %></span>
        <% } else { %>
        <a class="boton secundario" href="<%= urlPagina %><%= numero %>"
           aria-label="Página <%= numero %>"><%= numero %></a>
        <% } %>
        <% } %>
        <% if (paginaPaginada < paginasPaginadas) { %>
        <a class="boton secundario" href="<%= urlPagina %><%= paginaPaginada + 1 %>">Siguiente</a>
        <% } %>
      </div>
      <% } %>
    </nav>
    <% } %>

    <% if (seleccionada != null) {
      Solicitud s = seleccionada;
      String estadoActual = s.getEstado();
    %>
    <section class="panel-detalle" id="detalle-solicitud">
      <div class="encabezado-detalle">
        <div><span>Detalle de solicitud</span><h2>SOL-<%= s.getIdSolicitud() %></h2></div>
        <a href="<%= urlPagina %><%= paginaActual %>" class="cerrar-detalle" aria-label="Cerrar detalle">×</a>
      </div>
      <div class="cuadricula-detalle">
        <div><span>Cliente</span><strong><%= texto(s.getNombreCliente()) %></strong></div>
        <div><span>Fecha de registro</span><strong><%= s.getFechaRegistro() == null ? "" : s.getFechaRegistro().toLocalDateTime().format(FORMATO_FECHA) %></strong></div>
        <div><span>Registrada por</span><strong><%= s.getNombreUsuario() == null ? "Usuario ID " + s.getIdUsuario() : texto(s.getNombreUsuario()) %></strong></div>
        <div><span>Origen</span><strong><%= texto(s.getNombreOrigen()) %></strong></div>
        <div><span>Destino</span><strong><%= texto(s.getNombreDestino()) %></strong></div>
        <div><span>Capacidad solicitada</span><strong><%= s.getCapacidadSolicitada() %> Gbps</strong></div>
      </div>
      <div class="justificacion-detalle"><span>Justificación</span><p><%= texto(s.getJustificacion()) %></p></div>
      <p class="aviso-solicitud">Estado actual: <strong><%= mostrarEstado(s.getEstado()) %></strong></p>
      <% if ("Provisionada".equals(estadoActual) || "Activa".equals(estadoActual)) { %>
      <p class="aviso-solicitud"><a class="enlace-detalle-relacionado" href="${pageContext.request.contextPath}/ServicioServletSuper">Ver servicio →</a></p>
      <% } %>
    </section>
    <% } %>
  </main>
</div>
</body>
</html>
