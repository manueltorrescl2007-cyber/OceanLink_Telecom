<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.networkoperator.Incidencia" %>
<%@ page import="beans.networkoperator.Segmento" %>
<%!
  private String html(String s) {
    if (s == null) return "";
    return s.replace("&", "&amp;").replace("<", "&lt;")
      .replace(">", "&gt;").replace("\"", "&quot;")
      .replace("'", "&#39;");
  }
%>
<%
  if (request.getAttribute("totalIncidencias") == null) {
    response.sendRedirect(request.getContextPath() + "/DashboardServletSuper");
    return;
  }
  ArrayList<Incidencia> listaIncidencias = (ArrayList<Incidencia>) request.getAttribute("listaIncidencias");
  ArrayList<Segmento> listaSegmentos = (ArrayList<Segmento>) request.getAttribute("listaSegmentos");
  String filtroSeveridad = (String) request.getAttribute("filtroSeveridad");
  int filtroIdSegmento = (Integer) request.getAttribute("filtroIdSegmento");
%>


<!doctype html>
<html lang="es">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <title>OceanLink | Dashboard</title>

  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/supervisor/supervisor.css?v=2">
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
        <a href="${pageContext.request.contextPath}/DashboardServletSuper"
           class="activo">
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
  <main class="contenido-principal">

    <section class="encabezado-panel">
      <h2>Supervisor</h2>
      <h1>Dashboard general</h1>
    </section>

    <!-- Indicadores reales calculados por DashboardServletSuper -->
    <section class="tarjetas">
      <article class="tarjeta">
        <div class="information"><p>Estado de la red</p></div>
        <div class="information"><strong><%= html((String) request.getAttribute("estadoRed")) %></strong></div>
        <div class="information"><p>Segmentos operativos: <b><%= request.getAttribute("disponibilidad") %>%</b></p></div>
      </article>
      <article class="tarjeta">
        <div class="information"><p>Incidencias activas</p></div>
        <div class="information"><strong><%= request.getAttribute("totalIncidencias") %></strong></div>
        <div class="information"><p>Críticas: <b><%= request.getAttribute("incidenciasCriticas") %></b> Medias: <b><%= request.getAttribute("incidenciasMedias") %></b></p></div>
      </article>
      <article class="tarjeta">
        <div class="information"><p>Clientes afectados</p></div>
        <div class="information"><strong><%= request.getAttribute("clientesAfectados") %></strong></div>
        <div class="information"><p>Servicios afectados: <b><%= request.getAttribute("serviciosAfectados") %></b></p></div>
      </article>
      <article class="tarjeta">
        <div class="information"><p>Mantenimientos programados</p></div>
        <div class="information"><strong><%= request.getAttribute("mantenimientosProgramados") == null ? "—" : request.getAttribute("mantenimientosProgramados") %></strong></div>
        <div class="information"><p><%= request.getAttribute("mantenimientosProgramados") == null ? "Consulta no disponible" : "Próximos 7 días" %></p></div>
      </article>
      <article class="tarjeta">
        <div class="information"><p>Utilización de la red</p></div>
        <div class="information"><strong><%= request.getAttribute("utilizacion") %>%</strong></div>
        <div class="information"><p>Capacidad ocupada / total</p></div>
      </article>
    </section>

    <!-- Mapa interactivo (con fe) -->
    <section class="mapa-interactivo">
      <div>
        <img src="${pageContext.request.contextPath}/img/mapa_red.svg"
             alt="Mapa de la red OceanLink: landing stations y segmentos en la costa del Pacífico"
             style="display:block; max-width:100%; max-height:620px; height:auto; margin:0 auto;">
      </div>
    </section>

    <section class="encabezado-panel">
      <h1>Incidencias activas</h1>
    </section>
    <section class="card">

      <form class="filtros" action="${pageContext.request.contextPath}/DashboardServletSuper" method="get">
        <select name="severidad" aria-label="Filtrar por severidad">
          <option value="">Todas las severidades</option>
          <% for (String sev : new String[]{"Critica", "Alta", "Media", "Leve"}) { %>
          <option value="<%= sev %>" <%= sev.equals(filtroSeveridad) ? "selected" : "" %>><%= "Critica".equals(sev) ? "Crítica" : sev %></option>
          <% } %>
        </select>
        <select name="idSegmento" aria-label="Filtrar por segmento">
          <option value="">Todos los segmentos</option>
          <% for (Segmento segmento : listaSegmentos) { %>
          <option value="<%= segmento.getIdSegmento() %>" <%= segmento.getIdSegmento() == filtroIdSegmento ? "selected" : "" %>><%= html(segmento.getCodigo()) %></option>
          <% } %>
        </select>
        <button type="submit" class="boton-filtrar-dashboard">Filtrar</button>
        <a class="limpiar-filtro-dashboard" href="${pageContext.request.contextPath}/DashboardServletSuper">Limpiar</a>
      </form>

      <div class="table-wrapper">
        <table class="data-table">
          <thead>
          <tr><th>ID</th><th>Segmento</th><th>Severidad</th><th>Estado</th></tr>
          </thead>
          <tbody>
          <% if (listaIncidencias.isEmpty()) { %>
          <tr><td colspan="4" style="text-align:center">No hay incidencias para mostrar.</td></tr>
          <% } else {
            for (Incidencia inc : listaIncidencias) { %>
          <tr>
            <td><a href="${pageContext.request.contextPath}/IncidenciaServletSuper?action=detalle&amp;id=<%= inc.getIdIncidencia() %>"><%= html(inc.getCodigo()) %></a></td>
            <td><%= html(inc.getCodigosSegmentos()) %></td>
            <td class="<%= html(inc.getClaseSeveridad()) %>"><%= html(inc.getSeveridadTexto()) %></td>
            <td><%= html(inc.getEstadoTexto()) %></td>
          </tr>
          <%  }
          } %>
          </tbody>
        </table>
      </div>
      <p class="ayuda">Haz clic en el ID para ver el detalle de la incidencia.</p>
    </section>
  </main>
</div>
</body>

</html>
