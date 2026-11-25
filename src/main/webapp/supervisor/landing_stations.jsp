<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="beans.capacityplanner.LandingStation" %>
<%!
  private String texto(String valor) {
    if (valor == null) return "";

    return valor.replace("&", "&amp;")
      .replace("<", "&lt;")
      .replace(">", "&gt;")
      .replace("\"", "&quot;")
      .replace("'", "&#39;");
  }
%>
<%
  String servlet = request.getContextPath() + "/LandingStationServletSuper";

  List<LandingStation> estaciones =
    (List<LandingStation>) request.getAttribute("listaEstaciones");

  if (estaciones == null) {
    response.sendRedirect(servlet);
    return;
  }

  String[] estados = {"Activa", "Inactiva"};

  String filtro = (String) request.getAttribute("filtroEstado");
  if (filtro == null) filtro = "";

  int pagina = request.getAttribute("paginaActual") != null
    ? (Integer) request.getAttribute("paginaActual") : 1;
  int totalPaginas = request.getAttribute("totalPaginas") != null
    ? (Integer) request.getAttribute("totalPaginas") : 1;
  int cantidad = request.getAttribute("totalRegistros") != null
    ? (Integer) request.getAttribute("totalRegistros") : estaciones.size();
  int registroInicio = request.getAttribute("registroInicio") != null
    ? (Integer) request.getAttribute("registroInicio") : (estaciones.isEmpty() ? 0 : 1);
  int registroFin = request.getAttribute("registroFin") != null
    ? (Integer) request.getAttribute("registroFin") : estaciones.size();

  String queryFiltro = filtro.isEmpty()
    ? "" : "&estado=" + URLEncoder.encode(filtro, StandardCharsets.UTF_8);
  String urlPagina = servlet + "?pagina=";
  String urlLista = servlet + "?pagina=" + pagina + queryFiltro;

  LandingStation estacionDetalle = (LandingStation) request.getAttribute("estacionDetalle");
%>
<!doctype html>
<html lang="es">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <title>OceanLink | Landing stations</title>

  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/barras.css">
  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/supervisor/landing_stations.css">
</head>

<body>
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
               class="subopcion">
              Segmentos
            </a>
            <a href="${pageContext.request.contextPath}/LandingStationServletSuper"
               class="subopcion activo">
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
  <main class="contenido-principal pagina-landings">
    <section class="encabezado-pagina">
      <div class="encabezado-panel">
        <h2>Supervisor</h2>
        <h1>Landing stations</h1>
      </div>
    </section>

    <div class="barra-herramientas">
      <form action="<%= servlet %>" method="get" class="formulario-filtro">
        <label for="filtroEstado">Estado:</label>
        <select id="filtroEstado" name="estado">
          <option value="">Todos</option>
          <% for (String estado : estados) { %>
          <option value="<%= estado %>" <%= estado.equals(filtro) ? "selected" : "" %>><%= estado %></option>
          <% } %>
        </select>
        <button type="submit" class="boton secundario">Filtrar</button>
        <% if (!filtro.isEmpty()) { %>
        <a href="<%= servlet %>" class="boton secundario">Limpiar</a>
        <% } %>
      </form>
      <span><%= cantidad %> estaciones</span>
    </div>

    <section class="contenedor-tabla">
      <table>
        <thead>
        <tr>
          <th>ID</th>
          <th>Nombre</th>
          <th>País</th>
          <th>Ciudad</th>
          <th>Estado</th>
        </tr>
        </thead>
        <tbody>
        <% for (LandingStation estacion : estaciones) {
          boolean esSeleccionada = estacionDetalle != null
            && estacionDetalle.getIdLanding() == estacion.getIdLanding();
        %>
        <tr class="<%= esSeleccionada ? "fila-seleccionada" : "" %>">
          <td><%= estacion.getIdLanding() %></td>
          <td>
            <a href="<%= urlLista %>&detalle=<%= estacion.getIdLanding() %>#detalle"
               class="enlace-estacion">
              <%= texto(estacion.getNombre()) %>
            </a>
          </td>
          <td><%= texto(estacion.getPais()) %></td>
          <td><%= texto(estacion.getCiudad()) %></td>
          <td>
              <span class="estado <%= "Activa".equals(estacion.getEstado()) ? "activa" : "inactiva" %>">
                <%= texto(estacion.getEstado()) %>
              </span>
          </td>
        </tr>
        <% } %>

        <% if (estaciones.isEmpty()) { %>
        <tr>
          <td colspan="5" class="celda-vacia">No hay estaciones con este estado.</td>
        </tr>
        <% } %>
        </tbody>
      </table>
    </section>

    <div class="pie-tabla">
      <span>
        <% if (cantidad > 0) { %>
          Mostrando <%= registroInicio %>–<%= registroFin %> de <%= cantidad %> registros (Página <%= pagina %> de <%= totalPaginas %>) · Haz clic en una estación para ver su detalle.
        <% } else { %>
          Haz clic en una estación para ver su detalle.
        <% } %>
      </span>

      <% if (totalPaginas > 1) { %>
      <div class="controles-paginacion">
        <% if (pagina > 1) { %>
        <a class="boton secundario" href="<%= urlPagina %><%= pagina - 1 %><%= queryFiltro %>">Anterior</a>
        <% } else { %>
        <span class="pagina-deshabilitada">Anterior</span>
        <% } %>

        <% for (int numero = 1; numero <= totalPaginas; numero++) { %>
        <% if (numero == pagina) { %>
        <span class="boton primario" aria-current="page"><%= numero %></span>
        <% } else { %>
        <a class="boton secundario" href="<%= urlPagina %><%= numero %><%= queryFiltro %>"><%= numero %></a>
        <% } %>
        <% } %>

        <% if (pagina < totalPaginas) { %>
        <a class="boton secundario" href="<%= urlPagina %><%= pagina + 1 %><%= queryFiltro %>">Siguiente</a>
        <% } else { %>
        <span class="pagina-deshabilitada">Siguiente</span>
        <% } %>
      </div>
      <% } %>
    </div>

    <% if (estacionDetalle != null) { %>
    <section class="panel-detalle" id="detalle">
      <div class="encabezado-detalle">
        <h2><%= texto(estacionDetalle.getNombre()) %></h2>
        <a href="<%= urlLista %>" aria-label="Cerrar detalle">×</a>
      </div>

      <div class="datos-detalle">
        <div>
          <span>ID de la estación</span>
          <strong><%= estacionDetalle.getIdLanding() %></strong>
        </div>
        <div>
          <span>País</span>
          <strong><%= texto(estacionDetalle.getPais()) %></strong>
        </div>
        <div>
          <span>Ciudad</span>
          <strong><%= texto(estacionDetalle.getCiudad()) %></strong>
        </div>
        <div>
          <span>Estado</span>
          <strong><%= texto(estacionDetalle.getEstado()) %></strong>
        </div>
      </div>
    </section>
    <% } %>
  </main>
</div>
</body>
</html>
