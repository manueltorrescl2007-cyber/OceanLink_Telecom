<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>

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
        <a href="${pageContext.request.contextPath}/supervisor/supervisor.jsp"
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
                    class="subopcion activo">
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
      <%
          /*
              En una implementación real, esta lista vendría de un Servlet/DAO
              (p. ej. request.getAttribute("mantenimientos")) que consulta la
              base de datos. Aquí se simula un único registro de ejemplo,
              tal como en el wireframe, y se completan filas vacías hasta 10
              para conservar el aspecto de "Vista de Tabla".
          */
          List<Map<String, String>> mantenimientos = new ArrayList<Map<String, String>>();
          Map<String, String> ejemplo = new HashMap<String, String>();
          ejemplo.put("segmento", "LIM-VLP-02");
          ejemplo.put("tipo", "Preventivo");
          ejemplo.put("fechaInicio", "4 de sep. de 2026");
          ejemplo.put("fechaFin", "30 de sep. de 2026");
          ejemplo.put("prioridad", "Leve");
          ejemplo.put("notas", "Verificar estado de conectores");
          mantenimientos.add(ejemplo);

          int totalFilas = 10;
      %>

      <div class="app-layout">

          <div class="main-content">

              <div class="content-container">
                  <div class="card">
                      <h2 class="card-title">Fechas y duración de mantenimientos programados</h2>

                      <div class="table-toolbar">
                          <div class="table-toolbar-left">
                              <span>&#9638;</span> Vista de Tabla
                          </div>
                          <div class="table-toolbar-icons">
                              <span title="Expandir">&#8599;</span>
                              <span title="Más opciones">&#8942;</span>
                          </div>
                      </div>

                      <div class="data-table-wrapper">
                          <table class="data-table">
                              <thead>
                                  <tr>
                                      <th>Segmento</th>
                                      <th>Tipo de mantenimiento</th>
                                      <th>Fecha de inicio</th>
                                      <th>Fecha de fin</th>
                                      <th>Prioridad</th>
                                      <th>Notas / Descripción</th>
                                  </tr>
                              </thead>
                              <tbody>
                                  <%
                                      for (int i = 0; i < totalFilas; i++) {
                                          if (i < mantenimientos.size()) {
                                              Map<String, String> m = mantenimientos.get(i);
                                              String prioridad = m.get("prioridad");
                                              String badgeClass = "badge-leve";
                                              if ("Media".equalsIgnoreCase(prioridad)) badgeClass = "badge-media";
                                              else if ("Alta".equalsIgnoreCase(prioridad)) badgeClass = "badge-alta";
                                              else if ("Critica".equalsIgnoreCase(prioridad) || "Crítica".equalsIgnoreCase(prioridad)) badgeClass = "badge-critica";
                                  %>
                                      <tr>
                                          <td><%= m.get("segmento") %></td>
                                          <td><%= m.get("tipo") %></td>
                                          <td><%= m.get("fechaInicio") %></td>
                                          <td><%= m.get("fechaFin") %></td>
                                          <td><span class="badge <%= badgeClass %>"><%= prioridad %></span></td>
                                          <td><%= m.get("notas") %></td>
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

          </div>
      </div>
    </main>
  </div>
</body>
</html>
