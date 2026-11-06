<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.capacityplanner.Servicio" %>
<%@ page import="beans.capacityplanner.Solicitud" %>
<%@ page import="beans.capacityplanner.Ruta" %>
<%@ page import="beans.capacityplanner.Segmento" %>
<%!
  private String texto(String valor) {
    return valor == null ? "" : valor.replace("&", "&amp;")
      .replace("<", "&lt;").replace(">", "&gt;")
      .replace("\"", "&quot;").replace("'", "&#39;");
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

  ArrayList<Solicitud> solicitudes =
    (ArrayList<Solicitud>) request.getAttribute("listaSolicitudes");

  ArrayList<Ruta> rutas =
    (ArrayList<Ruta>) request.getAttribute("listaRutas");

  if (servicios == null || solicitudes == null || rutas == null) {
    response.sendRedirect(servlet);
    return;
  }

  Servicio seleccionado =
    (Servicio) request.getAttribute("servicioSeleccionado");

  ArrayList<Segmento> segmentosServicio =
    (ArrayList<Segmento>) request.getAttribute("segmentosServicio");

  Servicio formulario =
    (Servicio) request.getAttribute("servicioFormulario");

  int idSolicitudActual = formulario != null
    ? formulario.getIdSolicitud() : -1;

  int idRutaActual = formulario != null
    ? formulario.getIdRuta() : -1;

  String error = (String) request.getAttribute("error");
  if (error == null) {
    error = "";
  }

  String filtro = (String) request.getAttribute("filtroEstado");
  if (filtro == null) {
    filtro = "";
  }

  String[] estados = {"Pendiente", "Activo", "Suspendido", "Cancelado"};

  boolean nuevo = "nuevo".equals(request.getParameter("ventana"))
    || Boolean.TRUE.equals(request.getAttribute("mostrarFormulario"));

  int rutasActivas = 0;
  for (Ruta ruta : rutas) {
    if ("activa".equals(ruta.getEstado())) {
      rutasActivas++;
    }
  }

  boolean puedeCrear = !solicitudes.isEmpty() && rutasActivas > 0;
%>

<!-- Contenido JSP -->
<!doctype html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>OceanLink | Dashboard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/capacity_planner/servicios.css?v=2">
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
               class="subopcion activo">
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
  <main class="contenido-principal pagina-servicios">
    <section class="encabezado-pagina">
      <div class="encabezado-panel">
        <h2>Supervisor</h2>
        <h1>Servicios</h1>
      </div>
    </section>

    <% if ("1".equals(request.getParameter("guardado"))) { %>
    <p role="status" style="margin-bottom: 16px; color: #237b51;">
      Servicio creado como Pendiente. La capacidad quedó reservada.
    </p>
    <% } %>

    <% if ("1".equals(request.getParameter("activado"))) { %>
    <p role="status" style="margin-bottom: 16px; color: #237b51;">
      Servicio activado. La capacidad reservada pasó a ocupada.
    </p>
    <% } %>

    <% if ("1".equals(request.getParameter("cancelado"))) { %>
    <p role="status" style="margin-bottom: 16px; color: #237b51;">
      Servicio cancelado. Su capacidad fue liberada.
    </p>
    <% } %>

    <% if (!error.isEmpty() && !nuevo) { %>
    <p class="mensaje-error" role="alert"><%= texto(error) %></p>
    <% } %>

    <% if ("1".equals(request.getParameter("suspendido"))) { %>
    <p role="status" style="margin-bottom: 16px; color: #237b51;">
      Servicio suspendido. Su capacidad permanece asignada.
    </p>
    <% } %>

    <% if ("1".equals(request.getParameter("reactivado"))) { %>
    <p role="status" style="margin-bottom: 16px; color: #237b51;">
      Servicio reactivado. Conserva su capacidad asignada.
    </p>
    <% } %>

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
      <span><%= servicios.size() %> servicios</span>
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
               href="<%= servlet %>?servicio=<%= servicio.getIdServicio() %>">
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
          <td colspan="7">No hay servicios con este estado.</td>
        </tr>
        <% } %>
        </tbody>
      </table>
    </section>

    <% if (seleccionado != null) {
      Ruta rutaDetalle = buscarRuta(rutas, seleccionado.getIdRuta());
    %>
    <section class="panel-detalle">
      <div class="encabezado-detalle">
        <h2>Detalle de SER-<%= seleccionado.getIdServicio() %></h2>
        <a href="<%= servlet %>" aria-label="Cerrar detalle">&times;</a>
      </div>

      <div class="datos-detalle">
        <div>
          <span>Solicitud asociada</span>
          <strong>
            <a href="${pageContext.request.contextPath}/SolicitudesServletSuper?id=<%= seleccionado.getIdSolicitud() %>">
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
            <a href="${pageContext.request.contextPath}/RutaServletSuper?detalle=<%= seleccionado.getIdRuta() %>">
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
