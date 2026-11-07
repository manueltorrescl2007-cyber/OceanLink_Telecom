<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="beans.networkoperator.Incidencia" %>
<%@ page import="java.util.List" %>
<%!
  private String escapar(String valor) {
    if (valor == null) return "";
    return valor.replace("&", "&amp;").replace("<", "&lt;")
      .replace(">", "&gt;").replace("\"", "&quot;")
      .replace("'", "&#39;");
  }
%>
<%
  // El Servlet trae todos los datos desde MySQL.
  Incidencia inc = (Incidencia) request.getAttribute("incidencia");
  List<?> servicios = (List<?>) request.getAttribute("listaServicios");
  List<?> observaciones = (List<?>) request.getAttribute("listaObservaciones");

  boolean cerrada = inc != null && "Cerrada".equals(inc.getEstado());
  String origen = cerrada ? "Historial" : "Visualizar";
  String paginaOrigen = request.getContextPath() + "/IncidenciaServletSuper" + (cerrada ? "?action=historial" : "");

  String[] estados = {"Detectada", "En analisis", "Reparacion programada", "En reparacion", "Servicio restaurado", "Cerrada"};
  String[] pasos = {"Detectada", "En análisis", "Rep. prog.", "En rep.", "Restaurado", "Cerrada"};
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

<!-- Contenido JSP -->
<!doctype html>
<html lang="es">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <title>OceanLink | Dashboard</title>

  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/network_operator/network_operator.css">
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
            class="control-submenu" checked
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
               class="subopcion <%= !cerrada ? "activo" : "" %>">
              Visualizar
            </a>

            <a href="${pageContext.request.contextPath}/IncidenciaServletSuper?action=historial"
               class="subopcion <%= cerrada ? "activo" : "" %>">
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
              href="${pageContext.request.contextPath}/programacion.jsp"
              class="subopcion">
              Programación
            </a>

            <a
              href="${pageContext.request.contextPath}/historial_programados.jsp"
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
        Segmento(s): <strong><%= escapar(inc.getCodigosSegmentos()) %></strong>
        <% if (inc.getFechaRegistro() != null) { %> · Detectada el <%= escapar(inc.getFechaRegistro()) %><% } %>
        <% if (cerrada && inc.getFechaCierre() != null) { %> · Cerrada el <%= escapar(inc.getFechaCierre()) %><% } %>
      </p>

      <h4 style="margin-bottom: 8px;">Descripción</h4>
      <p style="margin-bottom: 26px; line-height: 1.5; white-space: pre-wrap;"><%= escapar(inc.getDescripcion()) %></p>

      <!-- Estado actual de la incidencia: solo consulta para Supervisor -->
      <div class="stepper">
        <% for (int i = 1; i <= pasos.length; i++) {
          String clase = i < pasoActual ? "completado" : (i == pasoActual ? "actual" : "");
        %>
        <div class="paso <%= clase %>">
          <div class="circulo"><%= i < pasoActual ? "&#10003;" : String.valueOf(i) %></div>
          <p><%= pasos[i - 1] %></p>
        </div>
        <% } %>
      </div>

      <div class="dos-columnas">
        <div class="columna">
          <h4>Servicios y clientes afectados</h4>
          <% if (servicios == null || servicios.isEmpty()) { %>
          <p class="ayuda">No hay servicios activos afectados registrados.</p>
          <% } else {
            for (Object servicio : servicios) {
              request.setAttribute("servicioFila", servicio);
          %>
          <div class="tarjeta">
            <span>SRV-${servicioFila.idServicio}</span>
            <span>${servicioFila.solicitud.cliente.nombre}</span>
          </div>
          <%   }
          } %>
        </div>

        <div class="columna">
          <h4>Bitácora</h4>
          <% if (observaciones == null || observaciones.isEmpty()) { %>
          <p class="ayuda">Todavía no hay observaciones registradas.</p>
          <% } else {
            for (Object observacion : observaciones) {
              request.setAttribute("observacionFila", observacion);
          %>
          <div class="registro">
            <strong>${observacionFila.usuario.nombre}</strong>
            <p>${observacionFila.mensaje}</p>
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
