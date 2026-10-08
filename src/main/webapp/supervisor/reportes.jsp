<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.UUID" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%
    request.setCharacterEncoding("UTF-8");

    ArrayList<Map<String, String>> reportes =
            (ArrayList<Map<String, String>>)
                    session.getAttribute("reportesSupervisor");

    if (reportes == null) {
        reportes = new ArrayList<>();
        session.setAttribute("reportesSupervisor", reportes);
    }

    String accion = request.getParameter("accion");

    if ("generar".equals(accion)) {

        String tipo = request.getParameter("tipo");
        String desde = request.getParameter("desde");
        String hasta = request.getParameter("hasta");
        String segmento = request.getParameter("segmento");
        String severidad = request.getParameter("severidad");

        if (tipo != null
                && desde != null
                && hasta != null
                && segmento != null
                && severidad != null
                && !tipo.isBlank()
                && !desde.isBlank()
                && !hasta.isBlank()) {

            Map<String, String> reporte = new LinkedHashMap<>();

            String id = UUID.randomUUID().toString();

            String fechaGeneracion =
                    LocalDateTime.now().format(
                            DateTimeFormatter.ofPattern(
                                    "dd/MM/yyyy HH:mm"
                            )
                    );

            String nombreLimpio = tipo
                    .replace("á", "a")
                    .replace("é", "e")
                    .replace("í", "i")
                    .replace("ó", "o")
                    .replace("ú", "u")
                    .replace(" ", "_");

            String nombreArchivo =
                    nombreLimpio + "_"
                    + hasta.replace("-", "_")
                    + ".pdf";

            reporte.put("id", id);
            reporte.put("nombre", nombreArchivo);
            reporte.put("tipo", tipo);
            reporte.put("desde", desde);
            reporte.put("hasta", hasta);
            reporte.put("segmento", segmento);
            reporte.put("severidad", severidad);
            reporte.put("fecha", fechaGeneracion);

            reportes.add(0, reporte);

            session.setAttribute(
                    "reportesSupervisor",
                    reportes
            );

            response.sendRedirect(
                    "reportes.jsp?generado=si"
            );

            return;
        }
    }
%>
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

            <h2>Supervisor</h2>
            <h1>Generar reportes</h1>

        </section>

        <section class="cuadricula-reportes">

            <article class="panel panel-generador">

                <div class="titulo-panel">

                    <div>
                        <h2>Nuevo reporte</h2>

                        <p>
                            Selecciona la información del reporte.
                        </p>
                    </div>

                </div>

                <form
                        method="post"
                        action="reportes.jsp"
                >

                    <input
                            type="hidden"
                            name="accion"
                            value="generar"
                    >

                    <div class="grupo-formulario">

                        <label for="tipo">
                            Tipo de reporte
                        </label>

                        <select
                                id="tipo"
                                name="tipo"
                                required
                        >

                            <option value="Utilización del estado de la red">
                                Utilización del estado de la red
                            </option>

                            <option value="Capacidad de rutas">
                                Capacidad de rutas
                            </option>

                            <option value="Estado de segmentos">
                                Estado de segmentos
                            </option>

                            <option value="Incidencias registradas">
                                Incidencias registradas
                            </option>

                            <option value="Servicios y clientes">
                                Servicios y clientes
                            </option>

                        </select>

                    </div>

                    <p class="titulo-campo">
                        Periodo
                    </p>

                    <div class="fila-formulario">

                        <div class="grupo-formulario">

                            <label for="desde">
                                Desde
                            </label>

                            <input
                                    type="date"
                                    id="desde"
                                    name="desde"
                                    required
                            >

                        </div>

                        <div class="grupo-formulario">

                            <label for="hasta">
                                Hasta
                            </label>

                            <input
                                    type="date"
                                    id="hasta"
                                    name="hasta"
                                    required
                            >

                        </div>

                    </div>

                    <fieldset class="grupo-opciones">

                        <legend>Segmentos</legend>

                        <div class="lista-opciones">

                            <label class="opcion">
                                <input
                                        type="radio"
                                        name="segmento"
                                        value="Todos"
                                        checked
                                >
                                <span>Todos</span>
                            </label>

                            <label class="opcion">
                                <input
                                        type="radio"
                                        name="segmento"
                                        value="Lima"
                                >
                                <span>Lima</span>
                            </label>

                            <label class="opcion">
                                <input
                                        type="radio"
                                        name="segmento"
                                        value="Callao"
                                >
                                <span>Callao</span>
                            </label>

                            <label class="opcion">
                                <input
                                        type="radio"
                                        name="segmento"
                                        value="Valparaíso"
                                >
                                <span>Valparaíso</span>
                            </label>

                            <label class="opcion">
                                <input
                                        type="radio"
                                        name="segmento"
                                        value="Barcelona"
                                >
                                <span>Barcelona</span>
                            </label>

                            <label class="opcion">
                                <input
                                        type="radio"
                                        name="segmento"
                                        value="Miami"
                                >
                                <span>Miami</span>
                            </label>

                        </div>

                    </fieldset>

                    <fieldset class="grupo-opciones">

                        <legend>Severidad</legend>

                        <div class="lista-opciones severidades">

                            <label class="opcion">
                                <input
                                        type="radio"
                                        name="severidad"
                                        value="Todas"
                                        checked
                                >
                                <span>Todas</span>
                            </label>

                            <label class="opcion">
                                <input
                                        type="radio"
                                        name="severidad"
                                        value="Crítica"
                                >
                                <span>Crítica</span>
                            </label>

                            <label class="opcion">
                                <input
                                        type="radio"
                                        name="severidad"
                                        value="Alta"
                                >
                                <span>Alta</span>
                            </label>

                            <label class="opcion">
                                <input
                                        type="radio"
                                        name="severidad"
                                        value="Media"
                                >
                                <span>Media</span>
                            </label>

                        </div>

                    </fieldset>

                    <% if ("si".equals(request.getParameter("generado"))) { %>

                    <p class="mensaje-formulario correcto">
                        El reporte fue generado correctamente.
                    </p>

                    <% } %>

                    <button
                            type="submit"
                            class="boton-generar"
                    >
                        Generar reporte
                    </button>

                </form>

            </article>

            <article class="panel panel-generados">

                <div class="titulo-panel">

                    <div>
                        <h2>Reportes generados</h2>

                        <p>
                            Consulta o descarga los reportes creados.
                        </p>
                    </div>

                    <span class="cantidad-reportes">
                        <%= reportes.size() %>
                    </span>

                </div>

                <% if (reportes.isEmpty()) { %>

                <div class="sin-reportes">

                    <div class="icono-vacio">
                        PDF
                    </div>

                    <p>
                        Todavía no se generaron reportes.
                    </p>

                </div>

                <% } else { %>

                <div class="lista-reportes">

                    <%
                        for (Map<String, String> reporte : reportes) {
                    %>

                    <article class="reporte">

                        <div class="icono-pdf">
                            PDF
                        </div>

                        <div class="informacion-reporte">

                            <p class="nombre-reporte">
                                <%= reporte.get("nombre") %>
                            </p>

                            <p class="fecha-reporte">
                                <%= reporte.get("fecha") %>
                            </p>

                        </div>

                        <div class="acciones-reporte">

                            <a
                                    class="boton-accion"
                                    href="reporte_pdf.jsp?id=<%= reporte.get("id") %>"
                                    target="_blank"
                            >
                                Vista previa
                            </a>

                            <a
                                    class="boton-accion"
                                    href="reporte_pdf.jsp?id=<%= reporte.get("id") %>"
                            >
                                Descargar
                            </a>

                        </div>

                    </article>

                    <% } %>

                </div>

                <% } %>

            </article>

        </section>

    </main>

</div>

</body>
</html>
