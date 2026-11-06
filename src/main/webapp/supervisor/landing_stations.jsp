<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.capacityplanner.LandingStation" %>
<%
  ArrayList<LandingStation> estaciones = (ArrayList<LandingStation>) request.getAttribute("listaEstaciones");
  if (estaciones == null) { response.sendRedirect(request.getContextPath() + "/LandingStationServletSuper"); return; }
%>
<!-- Contenido JSP -->
<!doctype html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>OceanLink | Dashboard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/capacity_planner/landing_stations.css">
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

    <a href="${pageContext.request.contextPath}/supervisor/supervisor.jsp"
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
        <a href="${pageContext.request.contextPath}/supervisor/supervisor.jsp">
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
  <main class="contenido-principal pagina-landings">
    <section class="encabezado-pagina"><div class="encabezado-panel"><h2>Supervisor</h2><h1>Landing stations</h1></div></section>
    <section class="contenedor-tabla"><table><thead><tr><th>Nombre</th><th>País</th><th>Ciudad</th><th>Estado</th></tr></thead><tbody>
    <% for (LandingStation e : estaciones) { %>
    <tr><td><%= e.getNombre() %></td><td><%= e.getPais() %></td><td><%= e.getCiudad() %></td><td><span class="estado <%= "Activa".equals(e.getEstado()) ? "activa" : "inactiva" %>"><%= e.getEstado() %></span></td></tr>
    <% } %>
    <% if (estaciones.isEmpty()) { %><tr><td colspan="4">No se encontraron estaciones.</td></tr><% } %>
    </tbody></table></section>
  </main>
</div>
</body>
</html>
