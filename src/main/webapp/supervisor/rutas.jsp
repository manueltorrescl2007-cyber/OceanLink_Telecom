<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.capacityplanner.Ruta" %>
<%@ page import="beans.capacityplanner.Segmento" %>
<%@ page import="beans.capacityplanner.LandingStation" %>
<%!
  private String texto(String valor) {
    return valor == null ? "" : valor.replace("&", "&amp;")
      .replace("<", "&lt;").replace(">", "&gt;")
      .replace("\"", "&quot;").replace("'", "&#39;");
  }
%>
<%
  String servlet = request.getContextPath() + "/RutaServletSuper";

  ArrayList<Ruta> rutas =
    (ArrayList<Ruta>) request.getAttribute("listaRutas");

  ArrayList<LandingStation> estaciones =
    (ArrayList<LandingStation>) request.getAttribute("listaEstaciones");

  ArrayList<Segmento> segmentos =
    (ArrayList<Segmento>) request.getAttribute("listaSegmentos");

  // Si se abre el JSP directamente, pasar primero por el servlet
  if (rutas == null || estaciones == null || segmentos == null) {
    response.sendRedirect(servlet);
    return;
  }

  String error = (String) request.getAttribute("error");
  if (error == null) {
    error = "";
  }

  String filtro = request.getParameter("filtro");
  if (!"activa".equals(filtro) && !"inactiva".equals(filtro)) {
    filtro = "Todas";
  }

  int cantidad = 0;
  Ruta rutaDetalle = null;
  Ruta rutaFormulario = null;

  boolean formulario = "nuevo".equals(request.getParameter("ventana"));

  for (Ruta ruta : rutas) {
    if ("Todas".equals(filtro) || filtro.equals(ruta.getEstado())) {
      cantidad++;
    }

    String idRuta = String.valueOf(ruta.getIdRuta());

    if (idRuta.equals(request.getParameter("detalle"))) {
      rutaDetalle = ruta;
    }

    if (idRuta.equals(request.getParameter("editar"))) {
      rutaFormulario = ruta;
      formulario = true;
    }
  }

  // Recuperar los datos enviados si hubo un error al guardar
  Ruta datosEnviados =
    (Ruta) request.getAttribute("rutaFormulario");

  if (datosEnviados != null) {
    rutaFormulario = datosEnviados;
    formulario = true;
  }

  boolean esEdicion =
    rutaFormulario != null && rutaFormulario.getIdRuta() > 0;

  // ID, nombre, origen, destino, estado y códigos de segmentos
  String[] valor = {"", "", "", "", "activa", ""};

  if (rutaFormulario != null) {
    valor[0] = esEdicion
      ? String.valueOf(rutaFormulario.getIdRuta()) : "";
    valor[1] = rutaFormulario.getNombre();
    valor[2] = String.valueOf(rutaFormulario.getIdLandingOrigen());
    valor[3] = String.valueOf(rutaFormulario.getIdLandingDestino());
    valor[4] = rutaFormulario.getEstado();

    for (Segmento segmento : rutaFormulario.getSegmentos()) {
      if (!valor[5].isEmpty()) {
        valor[5] += ", ";
      }
      valor[5] += segmento.getCodigo();
    }
  }

  String codigosEnviados =
    (String) request.getAttribute("segmentosFormulario");

  if (codigosEnviados != null) {
    valor[5] = codigosEnviados;
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
          href="${pageContext.request.contextPath}/css/capacity_planner/rutas.css">
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
            <a href="${pageContext.request.contextPath}/supervisor/visualizar.jsp"
               class="subopcion">
                Visualizar
            </a>

            <a href="${pageContext.request.contextPath}/supervisor/historial_incidencias.jsp"
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
            <a href="${pageContext.request.contextPath}/supervisor/capacidad.jsp"
               class="subopcion">
                Capacidad
            </a>
            <a href="rutas.jsp" class="subopcion activo">Rutas</a>
            <a href="${pageContext.request.contextPath}/supervisor/segmentos.jsp"
               class="subopcion">
                Segmentos
            </a>
            <a href="${pageContext.request.contextPath}/supervisor/landing_stations.jsp"
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

            <a href="${pageContext.request.contextPath}/supervisor/clientes.jsp"
               class="subopcion">
                Clientes
            </a>

            <a href="${pageContext.request.contextPath}/supervisor/servicios.jsp"
               class="subopcion">
                Servicios
            </a>
            <a
                    href="${pageContext.request.contextPath}/supervisor/solicitudes.jsp"
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
                    href="${pageContext.request.contextPath}/supervisor/programacion.jsp"
                    class="subopcion">
                Programación
            </a>

            <a
                    href="${pageContext.request.contextPath}/supervisor/historial_programados.jsp"
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
  <main class="contenido-principal pagina-rutas">
    <section class="encabezado-pagina">
      <div class="encabezado-panel">
        <h2>Capacity Planner</h2>
        <h1>Rutas</h1>
      </div>
    </section>

    <% if ("1".equals(request.getParameter("guardado"))) { %>
    <p class="mensaje-exito">Ruta guardada.</p>
    <% } %>

    <% if ("1".equals(request.getParameter("eliminado"))) { %>
    <p class="mensaje-exito">Ruta eliminada.</p>
    <% } %>

    <% if (!error.isEmpty() && !formulario) { %>
    <p class="mensaje-error" role="alert"><%= texto(error) %></p>
    <% } %>

    <section class="barra-herramientas">
      <form method="get" action="<%= servlet %>" class="formulario-filtro">
        <label for="filtro">Estado:</label>
        <select id="filtro" name="filtro">
          <option value="Todas"
            <%= "Todas".equals(filtro) ? "selected" : "" %>>
            Todas
          </option>
          <option value="activa"
            <%= "activa".equals(filtro) ? "selected" : "" %>>
            Activa
          </option>
          <option value="inactiva"
            <%= "inactiva".equals(filtro) ? "selected" : "" %>>
            Inactiva
          </option>
        </select>
        <button class="boton secundario" type="submit">Filtrar</button>
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
          if ("Todas".equals(filtro)
            || filtro.equals(ruta.getEstado())) { %>
        <tr>
          <td>
            <a class="enlace-ruta"
               href="<%= servlet %>?detalle=<%= ruta.getIdRuta() %>">
              RUT-<%= ruta.getIdRuta() %>
            </a>
          </td>
          <td><%= texto(ruta.getNombre()) %></td>
          <td><%= texto(ruta.getNombreOrigen()) %></td>
          <td><%= texto(ruta.getNombreDestino()) %></td>
          <td><%= ruta.getSegmentos().size() %></td>
          <td><%= ruta.getCapacidadDisponible() %> Gbps</td>
          <td>
                            <span class="estado <%= texto(ruta.getEstado()) %>">
                                <%= "activa".equals(ruta.getEstado())
                                  ? "Activa" : "Inactiva" %>
                            </span>
          </td>
        </tr>
        <%  }
        } %>

        <% if (cantidad == 0) { %>
        <tr>
          <td colspan="7">No hay rutas con este estado.</td>
        </tr>
        <% } %>
        </tbody>
      </table>
    </section>

    <% if (rutaDetalle != null) {
      int orden = 1;
    %>
    <section class="panel-detalle">
      <div class="encabezado-detalle">
        <h2><%= texto(rutaDetalle.getNombre()) %></h2>
        <a href="<%= servlet %>" aria-label="Cerrar detalle">&times;</a>
      </div>

      <p class="resumen-ruta">
        <%= texto(rutaDetalle.getNombreOrigen()) %>
        →
        <%= texto(rutaDetalle.getNombreDestino()) %>
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
            <td colspan="6">Esta ruta no tiene segmentos.</td>
          </tr>
          <% } %>
          </tbody>
        </table>
      </div>

      <p class="ayuda">
        Disponible = menor valor de (total − ocupada − reservada)
        entre los segmentos.
      </p>

    </section>
    <% } %>
  </main>
</div>
</body>
</html>
