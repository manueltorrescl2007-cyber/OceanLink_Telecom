<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    /*
        En una implementación real esta lista vendría filtrada desde un
        Servlet/DAO según los parámetros "fechaFin", "estado" y
        "nombreClave" enviados por el formulario de filtros (GET).
        Aquí se simula un único registro de ejemplo, igual que en el
        wireframe, y se completan filas vacías hasta 5.
    */
    List<Map<String, String>> historial = new ArrayList<Map<String, String>>();
    Map<String, String> ejemplo = new HashMap<String, String>();
    ejemplo.put("id", "REV-0405");
    ejemplo.put("segmento", "LIM-VLP-01");
    ejemplo.put("tipo", "Preventivo");
    ejemplo.put("fechaCierre", "2 de sep. de 2026");
    ejemplo.put("estado", "Finalizado");
    historial.add(ejemplo);

    int totalFilas = 5;
%>
<!doctype html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>OceanLink | Dashboard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/supervisor/programacion.css?v=2">
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
                    class="subopcion activo">
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
    <section class="encabezado-panel" id="encabezadoSolicitudes">
      <div>
        <h2>Supervisor</h2>
        <h1>Historial de mantenimientos</h1>
      </div>
    </section>
    <div class="content-container">
      <div class="card">
        <form action="historial.jsp" method="get" class="filters-bar">
          <div class="form-field">
              <select name="fechaFin">
                  <option value="" selected>Fecha fin</option>
                  <option value="7d">Últimos 7 días</option>
                  <option value="30d">Últimos 30 días</option>
                  <option value="custom">Rango personalizado</option>
              </select>
          </div>
          <div class="form-field">
              <select name="estado">
                  <option value="" selected>Estado</option>
                  <option value="Programado">Programado</option>
                  <option value="En progreso">En progreso</option>
                  <option value="Testing">Testing</option>
                  <option value="Finalizado">Finalizado</option>
              </select>
          </div>
          <div class="form-field">
              <select name="nombreClave">
                  <option value="" selected>Nombre en clave</option>
                  <option value="LIM-VLP-01">LIM-VLP-01</option>
                  <option value="LIM-VLP-02">LIM-VLP-02</option>
                  <option value="LIM-VLP-03">LIM-VLP-03</option>
              </select>
          </div>
        </form>

        <div class="table-toolbar">
          <div class="table-toolbar-left">
              <span>&#9638;</span> Vista de Tabla
          </div>
          <div class="table-toolbar-icons">
              <span title="Expandir">&#8599;</span>
              <span title="Más opciones">&#8942;</span>
          </div>
        </div>

        <div class="table-icons-row">
          <span title="Actualizar">&#8635;</span>
          <span title="Vistas">&#9638;</span>
          <span title="Agrupar">&#9776;</span>
          <span title="Filtrar">&#9660;</span>
          <span title="Ordenar">&#8645;</span>
          <span title="Lista de campos">&#9776;</span>
          <span title="Compartir">&#8646;</span>
          <span title="Ver como cuadrícula">&#9638;</span>
          <span title="Buscar">&#128269;</span>
        </div>

        <div class="data-table-wrapper">
          <table class="data-table">
              <thead>
                  <tr>
                      <th>ID</th>
                      <th>Segmento</th>
                      <th>Tipo</th>
                      <th>Fecha de cierre</th>
                      <th>Estado</th>
                  </tr>
              </thead>
              <tbody>
                  <%
                      for (int i = 0; i < totalFilas; i++) {
                          if (i < historial.size()) {
                              Map<String, String> h = historial.get(i);
                              String estado = h.get("estado");
                              String badgeClass = "badge-programado";
                              if ("En progreso".equalsIgnoreCase(estado)) badgeClass = "badge-en-progreso";
                              else if ("Testing".equalsIgnoreCase(estado)) badgeClass = "badge-testing";
                              else if ("Finalizado".equalsIgnoreCase(estado)) badgeClass = "badge-finalizado";
                  %>
                      <tr>
                          <td><%= h.get("id") %></td>
                          <td><span class="badge badge-segmento"><%= h.get("segmento") %></span></td>
                          <td><%= h.get("tipo") %></td>
                          <td><%= h.get("fechaCierre") %></td>
                          <td><span class="badge <%= badgeClass %>"><%= estado %></span></td>
                      </tr>
                  <%
                          } else {
                  %>
                      <tr class="row-empty">
                          <td>&nbsp;</td>
                          <td>&nbsp;</td>
                          <td>&nbsp;</td>
                          <td>&nbsp;</td>
                          <td>&nbsp;</td>
                      </tr>
                  <%
                          }
                      }
                  %>
              </tbody>
          </table>
        </div>
      </div>
    </div>
  </main>
</div>
</body>
</html>
