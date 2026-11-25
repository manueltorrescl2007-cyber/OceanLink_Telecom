<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.capacityplanner.Servicio" %>
<%@ page import="beans.capacityplanner.Ruta" %>
<%@ page import="beans.capacityplanner.Segmento" %>
<%!
  private String texto(String valor) {
    if (valor == null) return "";

    return valor.replace("&", "&amp;")
      .replace("<", "&lt;")
      .replace(">", "&gt;")
      .replace("\"", "&quot;")
      .replace("'", "&#39;");
  }

  private Ruta buscarRuta(ArrayList<Ruta> rutas, int idRuta) {
      for (Ruta ruta : rutas) {
          if (ruta.getIdRuta() == idRuta) {
              return ruta;
          }
      }
      return null;
  }
%>
<%
  String servlet = request.getContextPath() + "/ServicioServletSuper";

  ArrayList<Servicio> servicios =
    (ArrayList<Servicio>) request.getAttribute("listaServicios");

  ArrayList<Ruta> rutas =
    (ArrayList<Ruta>) request.getAttribute("listaRutas");

  if (servicios == null || rutas == null) {
    response.sendRedirect(servlet);
    return;
  }

  Servicio seleccionado =
    (Servicio) request.getAttribute("servicioSeleccionado");

  ArrayList<Segmento> segmentosServicio =
    (ArrayList<Segmento>) request.getAttribute("segmentosServicio");

  String filtro = (String) request.getAttribute("filtroEstado");
  if (filtro == null) {
    filtro = "";
  }

  int pagina = (Integer) request.getAttribute("paginaActual");
  int cantidad = (Integer) request.getAttribute("totalRegistros");
  String urlPagina = servlet + "?estado=" + filtro + "&pagina=";
  String urlLista = urlPagina + pagina;

  String[] estados = {"Pendiente", "Activo", "Suspendido", "Cancelado"};
%>

<!doctype html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Servicios | OceanLink</title>
  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/supervisor/servicios.css">
  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/barras.css">
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
            <a href="${pageContext.request.contextPath}/ServicioServletSuper" class="subopcion activo">Servicios</a>
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
        <a href="${pageContext.request.contextPath}/LogoutServlet"
           class="cerrar-sesion">Cerrar sesión</a>
      </nav>
    </div>
  </aside>

  <main class="contenido-principal pagina-servicios">
    <section class="encabezado-pagina">
      <div class="encabezado-panel">
        <h2>Supervisor</h2>
        <h1>Servicios</h1>
      </div>
    </section>

    <section class="barra-herramientas">
      <form method="get" action="<%= servlet %>"
            class="formulario-filtro">
        <label for="estado">Estado:</label>
        <select id="estado" name="estado">
          <option value="">Todos</option>
          <% for (String estado : estados) { %>
          <option value="<%= estado %>"
            <%= estado.equals(filtro) ? "selected" : "" %>>
            <%= estado %>
          </option>
          <% } %>
        </select>
        <button class="boton secundario" type="submit">Filtrar</button>
      </form>
      <span><%= cantidad %> <%= cantidad == 1 ? "servicio" : "servicios" %></span>
    </section>

    <section class="contenedor-tabla">
      <table>
        <thead>
        <tr>
          <th>ID</th>
          <th>Cliente</th>
          <th>Origen</th>
          <th>Destino</th>
          <th>Capacidad</th>
          <th>Ruta</th>
          <th>Estado</th>
        </tr>
        </thead>
        <tbody>
        <% for (Servicio servicio : servicios) {
          Ruta ruta = buscarRuta(rutas, servicio.getIdRuta());
        %>
        <tr>
          <td>
            <a class="enlace-servicio"
               href="<%= urlLista %>&servicio=<%= servicio.getIdServicio() %>">
              SER-<%= servicio.getIdServicio() %>
            </a>
          </td>
          <td><%= texto(servicio.getNombreCliente()) %></td>
          <td>
            <%= ruta != null
              ? texto(ruta.getNombreOrigen()) : "—" %>
          </td>
          <td>
            <%= ruta != null
              ? texto(ruta.getNombreDestino()) : "—" %>
          </td>
          <td><%= servicio.getCapacidadAsignada() %> Gbps</td>
          <td><%= texto(servicio.getNombreRuta()) %></td>
          <td>
                            <span class="estado <%= texto(servicio.getEstado()).toLowerCase(java.util.Locale.ROOT) %>">
                                <%= texto(servicio.getEstado()) %>
                            </span>
          </td>
        </tr>
        <% } %>

        <% if (servicios.isEmpty()) { %>
        <tr>
          <td colspan="7" class="sin-registros">No hay servicios con este estado.</td>
        </tr>
        <% } %>
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

    <% if (seleccionado != null) {
      Ruta rutaDetalle = buscarRuta(rutas, seleccionado.getIdRuta());
    %>
    <section class="panel-detalle">
      <div class="encabezado-detalle">
        <h2>Detalle de SER-<%= seleccionado.getIdServicio() %></h2>
        <a href="<%= urlLista %>" aria-label="Cerrar detalle">×</a>
      </div>

      <div class="datos-detalle">
        <div>
          <span>Solicitud asociada</span>
          <strong>
            <a class="enlace-detalle-relacionado"
               href="${pageContext.request.contextPath}/SolicitudesServletSuper?id=<%= seleccionado.getIdSolicitud() %>#detalle-solicitud">
              SOL-<%= seleccionado.getIdSolicitud() %>
            </a>
          </strong>
        </div>
        <div>
          <span>Cliente</span>
          <strong><%= texto(seleccionado.getNombreCliente()) %></strong>
        </div>
        <div>
          <span>Ruta asignada</span>
          <strong>
            <a class="enlace-detalle-relacionado"
               href="${pageContext.request.contextPath}/RutaServletSuper?detalle=<%= seleccionado.getIdRuta() %>">
              <%= texto(seleccionado.getNombreRuta()) %>
            </a>
          </strong>
        </div>
        <div>
          <span>Capacidad asignada</span>
          <strong><%= seleccionado.getCapacidadAsignada() %> Gbps</strong>
        </div>
        <div>
          <span>Fecha de activación</span>
          <strong>
            <%= seleccionado.getFechaActivacion() == null
              ? "Sin activar"
              : seleccionado.getFechaActivacion().toString() %>
          </strong>
        </div>
        <div>
          <span>Estado del servicio</span>
          <strong><%= texto(seleccionado.getEstado()) %></strong>
        </div>
        <div>
          <span>Origen</span>
          <strong>
            <%= rutaDetalle != null
              ? texto(rutaDetalle.getNombreOrigen()) : "—" %>
          </strong>
        </div>
        <div>
          <span>Destino</span>
          <strong>
            <%= rutaDetalle != null
              ? texto(rutaDetalle.getNombreDestino()) : "—" %>
          </strong>
        </div>
        <div>
          <span>Estado de la solicitud</span>
          <strong><%= texto(seleccionado.getEstadoSolicitud()) %></strong>
        </div>
      </div>

      <% if (segmentosServicio != null && !segmentosServicio.isEmpty()) {
        int orden = 1;
      %>
      <h3>Segmentos de la ruta</h3>
      <div class="contenedor-tabla">
        <table>
          <thead>
          <tr>
            <th>Orden</th>
            <th>Segmento</th>
            <th>Reservada total</th>
            <th>Ocupada total</th>
            <th>Estado</th>
          </tr>
          </thead>
          <tbody>
          <% for (Segmento segmento : segmentosServicio) { %>
          <tr>
            <td><%= orden++ %></td>
            <td><%= texto(segmento.getCodigo()) %></td>
            <td><%= segmento.getCapacidadReservada() %> Gbps</td>
            <td><%= segmento.getCapacidadOcupada() %> Gbps</td>
            <td><%= texto(segmento.getEstado()) %></td>
          </tr>
          <% } %>
          </tbody>
        </table>
      </div>
      <p class="ayuda">
        Las capacidades de cada segmento incluyen todos
        los servicios que lo utilizan.
      </p>
      <% } %>
    </section>
    <% } %>
  </main>
</div>
</body>
</html>
