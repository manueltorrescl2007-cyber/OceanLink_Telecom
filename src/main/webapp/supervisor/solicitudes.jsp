<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.capacityplanner.Solicitud" %>
<%!
  private String texto(String valor) {
    if (valor == null) return "";
    return valor.replace("&", "&amp;").replace("<", "&lt;")
      .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
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
  String[] estados = {"Registrada", "En evaluacion", "Aprobada", "Provisionada",
    "Activa", "Rechazada", "Pendiente por capacidad"};

  String mensaje = request.getParameter("mensaje");
  String error = null;
  if ("cambioNoPermitido".equals(mensaje)) error = "Ese cambio de estado no está permitido.";
  if ("eliminacionNoPermitida".equals(mensaje)) error = "No se puede eliminar: revisa el estado y los servicios asociados.";
%>

<!-- Contenido JSP -->
<!doctype html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>OceanLink | Dashboard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/capacity_planner/solicitudes.css">
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
              class="subopcion activo">
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
  <!-- 6. ENCABEZADO Y FILTRO -->
  <section class="encabezado-panel" id="encabezadoSolicitudes">
    <div><h2>Supervisor</h2><h1>Solicitudes</h1></div>
  </section>
  <% if (error != null) { %><p class="mensaje-error" role="alert"><%= texto(error) %></p><% } %>
  <% if ("guardado".equals(mensaje) || "estadoActualizado".equals(mensaje) || "eliminado".equals(mensaje)) { %>
  <p role="status">Operación realizada correctamente.</p>
  <% } %>
  <section class="barra-filtros">
    <form method="get" action="<%= servlet %>" class="formulario-filtro">
      <label for="filtroEstado">Estado:</label>
      <select id="filtroEstado" name="estado">
        <option value="">Todos</option>
        <% for (String estado : estados) { %>
        <option value="<%= estado %>" <%= estado.equals(filtro) ? "selected" : "" %>><%= estado %></option>
        <% } %>
      </select>
      <button class="boton secundario" type="submit">Filtrar</button>
    </form>
    <span class="cantidad-solicitudes"><%= solicitudes.size() %> solicitudes</span>
  </section>
  <!-- 7. TABLA: el ID abre el detalle sin JavaScript. -->
  <section class="tabla-contenedor">
    <table class="tabla-solicitudes">
      <thead><tr><th>ID</th><th>Cliente</th><th>Origen</th><th>Destino</th><th>Capacidad</th><th>Estado</th></tr></thead>
      <tbody>
      <% for (Solicitud s : solicitudes) { %>
      <tr class="fila-solicitud <%= seleccionada != null && seleccionada.getIdSolicitud() == s.getIdSolicitud() ? "fila-seleccionada" : "" %>">
        <td><a class="id-solicitud" href="<%= servlet %>?id=<%= s.getIdSolicitud() %>&amp;estado=<%= java.net.URLEncoder.encode(filtro, "UTF-8") %>">SOL-<%= s.getIdSolicitud() %></a></td>
        <td><%= texto(s.getNombreCliente()) %></td>
        <td><%= texto(s.getNombreOrigen()) %></td>
        <td><%= texto(s.getNombreDestino()) %></td>
        <td><%= s.getCapacidadSolicitada() %> Gbps</td>
        <td><span class="etiqueta-estado <%= color(s.getEstado()) %>"><%= s.getEstado() %></span></td>
      </tr>
      <% } %>
      <% if (solicitudes.isEmpty()) { %><tr><td colspan="6" class="sin-resultados">No hay solicitudes con este estado.</td></tr><% } %>
      </tbody>
    </table>
  </section>
  <!-- 8. DETALLE: datos, estado y edición de la solicitud seleccionada. -->
  <% if (seleccionada != null) {
    Solicitud s = seleccionada;
    String estadoActual = s.getEstado();
    boolean editable = "Registrada".equals(estadoActual)
      || "En evaluacion".equals(estadoActual)
      || "Pendiente por capacidad".equals(estadoActual);
  %>
  <section class="panel-detalle">
    <div class="encabezado-detalle">
      <div><span>Detalle de solicitud</span><h2>SOL-<%= s.getIdSolicitud() %></h2></div>
      <a href="<%= servlet %>" class="cerrar-detalle" aria-label="Cerrar detalle">&times;</a>
    </div>
    <div class="cuadricula-detalle">
      <div><span>Cliente</span><strong><%= texto(s.getNombreCliente()) %></strong></div>
      <div><span>Fecha de registro</span><strong><%= s.getFechaRegistro() %></strong></div>
      <div><span>Registrada por</span><strong>Usuario ID <%= s.getIdUsuario() %></strong></div>
      <div><span>Origen</span><strong><%= texto(s.getNombreOrigen()) %></strong></div>
      <div><span>Destino</span><strong><%= texto(s.getNombreDestino()) %></strong></div>
      <div><span>Capacidad solicitada</span><strong><%= s.getCapacidadSolicitada() %> Gbps</strong></div>
    </div>
    <div class="justificacion-detalle"><span>Justificación</span><p><%= texto(s.getJustificacion()) %></p></div>
    <!-- Estado actual: siempre visible, aunque lo gestione Servicios. -->
    <p class="cambio-estado">Estado actual: <strong><%= s.getEstado() %></strong></p>
    <% if (editable) { %>
    <form method="post" action="<%= servlet %>"
          class="formulario-filtro cambio-estado"
          onsubmit="if (this.elements['estado'].value === 'Aprobada') {
                      return confirm('¿Confirmas que deseas aprobar esta solicitud? Una vez aprobada, podrá utilizarse para crear un servicio.');
                  }">
      <input type="hidden" name="action" value="cambiarEstado">
      <input type="hidden" name="id_solicitud" value="<%= s.getIdSolicitud() %>">
      <label for="estadoSolicitud">Evaluación:</label>
      <select id="estadoSolicitud" name="estado" required>
        <option value="">Seleccione un estado</option>
        <% if ("En evaluacion".equals(estadoActual)) { %>
        <option value="Aprobada">Aprobada</option>
        <option value="Rechazada">Rechazada</option>
        <option value="Pendiente por capacidad">Pendiente por capacidad</option>
        <% } else { %>
        <option value="En evaluacion">En evaluación</option>
        <% } %>
      </select>
      <button class="boton secundario" type="submit">Guardar estado</button>
    </form>
    <% } %>
    <% if ("Provisionada".equals(estadoActual) || "Activa".equals(estadoActual)) { %>
    <p class="cambio-estado"><a class="id-solicitud" href="${pageContext.request.contextPath}/supervisor/servicios.jsp">Ver servicio</a></p>
    <% } %>

  </section>

  <% } %>
  </main>

</div>
</body>
</html>
