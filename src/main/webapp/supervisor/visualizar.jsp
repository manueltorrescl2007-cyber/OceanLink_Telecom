<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.networkoperator.Incidencia" %>
<%@ page import="beans.networkoperator.Segmento" %>

<%
  ArrayList<Incidencia> listaIncidencias = (ArrayList<Incidencia>) request.getAttribute("listaIncidencias");
  ArrayList<Segmento> listaSegmentos = (ArrayList<Segmento>) request.getAttribute("listaSegmentos");
  String filtroSeveridad = (String) request.getAttribute("filtroSeveridad");
  Integer filtroIdSegmento = (Integer) request.getAttribute("filtroIdSegmento");
  if (listaIncidencias == null) { listaIncidencias = new ArrayList<>(); }
  if (listaSegmentos == null) { listaSegmentos = new ArrayList<>(); }
  if (filtroSeveridad == null) { filtroSeveridad = ""; }
  if (filtroIdSegmento == null) { filtroIdSegmento = -1; }
  boolean hayFiltro = !filtroSeveridad.isEmpty() || filtroIdSegmento > 0;

  String[] severidades = {"Critica", "Alta", "Media", "Leve"};
  String servlet = request.getContextPath() + "/IncidenciaServletSuper";
%>

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
               class="subopcion activo">
                Visualizar
            </a>

            <a href="${pageContext.request.contextPath}/IncidenciaServletSuper?action=historial"
               class="subopcion" class="activo">
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
      <h1>Incidencias activas</h1>
    </section>

    <section class="card">

      <form class="filtros" method="GET" action="<%= servlet %>">
        <input type="hidden" name="action" value="lista">
        <select name="severidad" aria-label="Filtrar por severidad">
          <option value="">Todas las severidades</option>
          <% for (String sev : severidades) { %>
          <option value="<%= sev %>" <%= sev.equals(filtroSeveridad) ? "selected" : "" %>>
            <%= "Critica".equals(sev) ? "Crítica" : sev %>
          </option>
          <% } %>
        </select>
        <select name="idSegmento" aria-label="Filtrar por segmento">
          <option value="">Todos los segmentos</option>
          <% for (Segmento s : listaSegmentos) { %>
          <option value="<%= s.getIdSegmento() %>" <%= s.getIdSegmento() == filtroIdSegmento ? "selected" : "" %>>
            <%= s.getCodigo() %>
          </option>
          <% } %>
        </select>
        <button type="submit" class="btn-primary btn-chico">Filtrar</button>
        <% if (hayFiltro) { %>
        <a class="btn-secundario" href="<%= servlet %>">Limpiar</a>
        <% } %>
      </form>

      <div class="table-wrapper">
        <table class="data-table">
          <thead>
              <tr>
                  <th>ID</th>
                  <th>Segmento</th>
                  <th>Severidad</th>
                  <th>Estado</th>
              </tr>
          </thead>
          <tbody>
          <% if (listaIncidencias.isEmpty()) { %>
          <tr>
            <td colspan="4" class="vacio"><%= hayFiltro ? "No hay incidencias activas con ese filtro." : "No hay incidencias activas." %></td>
          </tr>
          <% } else {
            for (Incidencia inc : listaIncidencias) { %>
          <tr>
            <td><a href="<%= servlet %>?action=detalle&id=<%= inc.getIdIncidencia() %>"><%= inc.getCodigo() %></a></td>
            <td><%= inc.getCodigosSegmentos() %></td>
            <td class="<%= inc.getClaseSeveridad() %>"><%= inc.getSeveridadTexto() %></td>
            <td><%= inc.getEstadoTexto() %></td>
          </tr>
          <%     }
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
