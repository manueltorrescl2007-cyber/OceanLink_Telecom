<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.networkoperator.Incidencia" %>
<%
  ArrayList<Incidencia> listaIncidencias = (ArrayList<Incidencia>) request.getAttribute("listaIncidencias");
  String filtroSeveridad = (String) request.getAttribute("filtroSeveridad");
  if (listaIncidencias == null) { listaIncidencias = new ArrayList<>(); }
  if (filtroSeveridad == null) { filtroSeveridad = ""; }
  boolean hayFiltro = !filtroSeveridad.isEmpty();

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
            <a href="${pageContext.request.contextPath}/supervisor/visualizar.jsp"
               class="subopcion">
                Visualizar
            </a>

            <a href="${pageContext.request.contextPath}/supervisor/historial_incidencias.jsp"
               class="subopcion activo">
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
            <a href="${pageContext.request.contextPath}/supervisor/rutas.jsp"
               class="subopcion">
                Rutas
            </a>
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
  <main class="contenido-principal">
    <section class="encabezado-panel">
      <h2>Incidencias</h2>
      <h1>Historial de incidencias</h1>
    </section>
    <section class="card">
      <h2 class="card-title">Filtrar</h2>

      <form class="filtros" method="GET" action="<%= servlet %>">
        <input type="hidden" name="action" value="historial">
        <select name="severidad" aria-label="Filtrar por severidad">
          <option value="">Todas las severidades</option>
          <% for (String sev : severidades) { %>
          <option value="<%= sev %>" <%= sev.equals(filtroSeveridad) ? "selected" : "" %>>
            <%= "Critica".equals(sev) ? "Crítica" : sev %>
          </option>
          <% } %>
        </select>
        <button type="submit" class="btn-primary btn-chico">Filtrar</button>
        <% if (hayFiltro) { %>
        <a class="btn-secundario" href="<%= servlet %>?action=historial">Limpiar</a>
        <% } %>
      </form>

      <div class="table-wrapper">
        <table class="data-table">
          <thead>
          <tr>
            <th>ID</th>
            <th>Segmento</th>
            <th>Severidad</th>
            <th>Cerrada el</th>
          </tr>
          </thead>
          <tbody>
          <% if (listaIncidencias.isEmpty()) { %>
          <tr>
            <td colspan="4" class="vacio"><%= hayFiltro ? "No hay incidencias cerradas con ese filtro." : "Todavía no hay incidencias cerradas." %></td>
          </tr>
          <% } else {
            for (Incidencia inc : listaIncidencias) { %>
          <tr>
            <td><a href="<%= servlet %>?action=detalle&id=<%= inc.getIdIncidencia() %>"><%= inc.getCodigo() %></a></td>
            <td><%= inc.getCodigosSegmentos() %></td>
            <td class="<%= inc.getClaseSeveridad() %>"><%= inc.getSeveridadTexto() %></td>
            <td><%= inc.getFechaCierre() %></td>
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
