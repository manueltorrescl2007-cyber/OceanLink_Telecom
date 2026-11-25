<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
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
%>
<%
  String servlet = request.getContextPath() + "/RutaServletSuper";

  List<Ruta> rutas = (List<Ruta>) request.getAttribute("listaRutas");
  if (rutas == null) {
    response.sendRedirect(servlet);
    return;
  }

  String filtro = (String) request.getAttribute("filtroEstado");
  if (!"activa".equals(filtro) && !"inactiva".equals(filtro)) {
    filtro = "Todas";
  }

  int pagina = request.getAttribute("paginaActual") != null
    ? (Integer) request.getAttribute("paginaActual") : 1;
  int totalPaginas = request.getAttribute("totalPaginas") != null
    ? (Integer) request.getAttribute("totalPaginas") : 1;
  int cantidad = request.getAttribute("totalRegistros") != null
    ? (Integer) request.getAttribute("totalRegistros") : rutas.size();
  int registroInicio = request.getAttribute("registroInicio") != null
    ? (Integer) request.getAttribute("registroInicio") : (rutas.isEmpty() ? 0 : 1);
  int registroFin = request.getAttribute("registroFin") != null
    ? (Integer) request.getAttribute("registroFin") : rutas.size();

  String urlPagina = servlet + "?filtro=" + filtro + "&pagina=";
  String urlLista = urlPagina + pagina;
  Ruta rutaDetalle = (Ruta) request.getAttribute("rutaDetalle");
%>
<!doctype html>
<html lang="es">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <title>OceanLink | Rutas</title>

  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/barras.css">
  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/supervisor/rutas.css">
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
               class="subopcion activo">
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
  <main class="contenido-principal pagina-rutas">
    <section class="encabezado-pagina">
      <div class="encabezado-panel">
        <h2>Supervisor</h2>
        <h1>Rutas</h1>
      </div>
    </section>

    <section class="barra-herramientas">
      <form method="get" action="<%= servlet %>" class="formulario-filtro">
        <label for="filtro">Estado:</label>
        <select id="filtro" name="filtro">
          <option value="Todas" <%= "Todas".equals(filtro) ? "selected" : "" %>>Todas</option>
          <option value="activa" <%= "activa".equals(filtro) ? "selected" : "" %>>Activa</option>
          <option value="inactiva" <%= "inactiva".equals(filtro) ? "selected" : "" %>>Inactiva</option>
        </select>
        <button class="boton secundario" type="submit">Filtrar</button>
        <% if (!"Todas".equals(filtro)) { %>
        <a href="<%= servlet %>" class="boton secundario">Limpiar</a>
        <% } %>
      </form>
      <span><%= cantidad %> rutas</span>
    </section>

    <section class="contenedor-tabla">
      <table>
        <thead>
        <tr>
          <th>ID</th>
          <th>Nombre</th>
          <th>Origen</th>
          <th>Destino</th>
          <th>Segmentos</th>
          <th>Capacidad disponible</th>
          <th>Estado</th>
        </tr>
        </thead>
        <tbody>
        <% for (Ruta ruta : rutas) {
          boolean esSeleccionada = rutaDetalle != null
            && rutaDetalle.getIdRuta() == ruta.getIdRuta();
        %>
        <tr class="<%= esSeleccionada ? "fila-seleccionada" : "" %>">
          <td>
            <a class="enlace-ruta"
               href="<%= urlLista %>&detalle=<%= ruta.getIdRuta() %>#detalle-ruta">
              RUT-<%= ruta.getIdRuta() %>
            </a>
          </td>
          <td><%= texto(ruta.getNombre()) %></td>
          <td><%= texto(ruta.getNombreOrigen()) %></td>
          <td><%= texto(ruta.getNombreDestino()) %></td>
          <td><%= ruta.getSegmentos().size() %></td>
          <td class="disponible-destacado"><%= ruta.getCapacidadDisponible() %> Gbps</td>
          <td>
              <span class="estado <%= texto(ruta.getEstado()) %>">
                <%= "activa".equals(ruta.getEstado()) ? "Activa" : "Inactiva" %>
              </span>
          </td>
        </tr>
        <% } %>

        <% if (rutas.isEmpty()) { %>
        <tr>
          <td colspan="7" class="celda-vacia">No hay rutas con este estado.</td>
        </tr>
        <% } %>
        </tbody>
      </table>
    </section>

    <div class="pie-tabla">
      <span>
        <% if (cantidad > 0) { %>
          Mostrando <%= registroInicio %>–<%= registroFin %> de <%= cantidad %> registros (Página <%= pagina %> de <%= totalPaginas %>) · Haz clic en el ID para ver los segmentos de la ruta.
        <% } else { %>
          Haz clic en el ID para ver los segmentos de la ruta.
        <% } %>
      </span>

      <% if (totalPaginas > 1) { %>
      <div class="controles-paginacion">
        <% if (pagina > 1) { %>
        <a class="boton secundario" href="<%= urlPagina %><%= pagina - 1 %>">Anterior</a>
        <% } else { %>
        <span class="pagina-deshabilitada">Anterior</span>
        <% } %>

        <% for (int numero = 1; numero <= totalPaginas; numero++) { %>
        <% if (numero == pagina) { %>
        <span class="boton primario" aria-current="page"><%= numero %></span>
        <% } else { %>
        <a class="boton secundario" href="<%= urlPagina %><%= numero %>"><%= numero %></a>
        <% } %>
        <% } %>

        <% if (pagina < totalPaginas) { %>
        <a class="boton secundario" href="<%= urlPagina %><%= pagina + 1 %>">Siguiente</a>
        <% } else { %>
        <span class="pagina-deshabilitada">Siguiente</span>
        <% } %>
      </div>
      <% } %>
    </div>

    <% if (rutaDetalle != null) {
      int orden = 1;
    %>
    <section id="detalle-ruta" class="panel-detalle">
      <div class="encabezado-detalle">
        <h2><%= texto(rutaDetalle.getNombre()) %></h2>
        <a href="<%= urlLista %>" aria-label="Cerrar detalle">×</a>
      </div>

      <p class="resumen-ruta">
        <%= texto(rutaDetalle.getNombreOrigen()) %> → <%= texto(rutaDetalle.getNombreDestino()) %>
      </p>

      <h3>Segmentos de la ruta</h3>

      <div class="contenedor-tabla">
        <table>
          <thead>
          <tr>
            <th>Orden</th>
            <th>Segmento</th>
            <th>Total</th>
            <th>Ocupada</th>
            <th>Reservada</th>
            <th>Estado</th>
          </tr>
          </thead>
          <tbody>
          <% for (Segmento segmento : rutaDetalle.getSegmentos()) { %>
          <tr>
            <td><%= orden++ %></td>
            <td><%= texto(segmento.getCodigo()) %></td>
            <td><%= segmento.getCapacidadTotal() %> Gbps</td>
            <td><%= segmento.getCapacidadOcupada() %> Gbps</td>
            <td><%= segmento.getCapacidadReservada() %> Gbps</td>
            <td><%= texto(segmento.getEstado()) %></td>
          </tr>
          <% } %>

          <% if (rutaDetalle.getSegmentos().isEmpty()) { %>
          <tr>
            <td colspan="6" class="celda-vacia">Esta ruta no tiene segmentos.</td>
          </tr>
          <% } %>
          </tbody>
        </table>
      </div>

      <p class="ayuda">
        Disponible = menor valor de (total − ocupada − reservada) entre los segmentos.
      </p>
    </section>
    <% } %>
  </main>
</div>
</body>
</html>
