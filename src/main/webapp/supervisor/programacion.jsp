<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.*" %>
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
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>OceanLink | Dashboard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/styles_MC">
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
            <a href="${pageContext.request.contextPath}/visualizar.jsp"
               class="subopcion">
                Visualizar
            </a>

            <a href="${pageContext.request.contextPath}/historial_incidencias.jsp"
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
            <a href="${pageContext.request.contextPath}/capacidad.jsp"
               class="subopcion">
                Capacidad
            </a>
            <a href="${pageContext.request.contextPath}/rutas.jsp"
               class="subopcion">
                Rutas
            </a>
            <a href="${pageContext.request.contextPath}/segmentos.jsp"
               class="subopcion">
                Segmentos
            </a>
            <a href="${pageContext.request.contextPath}/landing_stations.jsp"
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

            <a href="${pageContext.request.contextPath}/clientes.jsp"
               class="subopcion">
                Clientes
            </a>

            <a href="${pageContext.request.contextPath}/servicios.jsp"
               class="subopcion">
                Servicios
            </a>
            <a
                    href="${pageContext.request.contextPath}/solicitudes.jsp"
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
                    class="subopcion activo">
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
          <h1>Programación de mantenimientos</h1>
    </section>
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
<%
    /*
        En una implementación real "estadoActual" vendría de un Servlet/DAO
        según el ID de mantenimiento seleccionado. Valores posibles:
        "programado" | "en-progreso" | "testing" | "finalizado".
        Aquí se deja fijo en "testing" para reflejar el wireframe.
    */
    String estadoActual = "testing";

    List<String> pasos = Arrays.asList("programado", "en-progreso", "testing", "finalizado");
    List<String> etiquetas = Arrays.asList("Programado", "En progreso", "Testing", "Finalizado");
    int indiceActual = pasos.indexOf(estadoActual);
%>
    <section class="encabezado-panel">
      <h1>Estado</h1>
    </section>
    <div class="content-container">
      <div class="card">
          <div class="inline-field">
              <label for="idMantenimiento">ID</label>
              <select id="idMantenimiento" name="idMantenimiento">
                  <option value="" selected disabled>Seleccione un ID</option>
                  <option value="REV-0405">REV-0405</option>
                  <option value="REV-0406">REV-0406</option>
                  <option value="REV-0407">REV-0407</option>
              </select>
          </div>

          <div class="stepper">
              <%
                  for (int i = 0; i < pasos.size(); i++) {
                      String stepClass = "";
                      if (i < indiceActual) {
                          stepClass = "completed";
                      } else if (i == indiceActual) {
                          stepClass = "active";
                      }
              %>
                  <div class="stepper-step <%= stepClass %>">
                      <div class="stepper-circle"></div>
                      <span class="stepper-label"><%= etiquetas.get(i) %></span>
                  </div>
              <%
                  }
              %>
          </div>

          <div class="bitacora">BITACORA DE INTERVENCIÓN

            14:42 - Técnico llegó al sitio de inserción
            14:46 - Inicio de revisión de conectores ópticos
            15:09 - Detección de degradación leve en fibra secundaria, se procede a reemplazarlo</div>
      </div>
    </div>
  </main>

</div>
</body>
</html>
