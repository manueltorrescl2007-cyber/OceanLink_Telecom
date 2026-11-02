
<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ page import="beans.maintenance.Mantenimiento" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%!
  private String escaparHtml(String valor) {
    if (valor == null) return "";

    return valor.replace("&", "&amp;")
      .replace("<", "&lt;")
      .replace(">", "&gt;")
      .replace("\"", "&quot;")
      .replace("'", "&#39;");
  }
%>

<%
  ArrayList<Mantenimiento> mantenimientos =
    (ArrayList<Mantenimiento>)
      request.getAttribute("mantenimientos");

  Map<Integer, String> segmentos =
    (Map<Integer, String>)
      request.getAttribute("segmentos");

  // Esta vista debe recibir los datos del Servlet.
  if (mantenimientos == null || segmentos == null) {
    response.sendRedirect(
      request.getContextPath()
        + "/MantenimientoServlet?accion=listar"
    );
    return;
  }

  DateTimeFormatter formatoFecha =
    DateTimeFormatter.ofPattern(
      "dd/MM/yyyy",
      Locale.forLanguageTag("es-PE")
    );

  // Mantener al menos 10 filas.
  int totalFilas = Math.max(10, mantenimientos.size());

  String resultado = request.getParameter("resultado");
%>

<!DOCTYPE html>
<html lang="es">

<head>
  <meta charset="UTF-8">

  <meta name="viewport"
        content="width=device-width, initial-scale=1.0">

  <title>OceanLink - Fechas y duración</title>

  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/barras.css">

  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/styles_MC.css">
</head>

<body>

<jsp:include page="header.jsp">
  <jsp:param name="pageTitle"
             value="Registro y actualizaci&oacute;n de actividades de mantenimiento"/>
</jsp:include>

<div class="contenedor">

  <jsp:include page="sidebar.jsp">
    <jsp:param name="activePage" value="fechas"/>
  </jsp:include>

  <main class="contenido-principal">

    <div class="content-container">

      <div class="card">

        <h2 class="card-title">
          Fechas y duración de mantenimientos
        </h2>

        <!-- MENSAJES DE RESULTADO -->

        <% if ("actualizado".equals(resultado)) { %>

        <p style="color: green; font-weight: bold;">
          El mantenimiento se actualizó correctamente.
        </p>

        <% } else if ("creado".equals(resultado)) { %>

        <p style="color: green; font-weight: bold;">
          El mantenimiento se registró correctamente.
        </p>

        <% } else if ("cancelado".equals(resultado)) { %>

        <p style="color: green; font-weight: bold;">
          El mantenimiento se canceló correctamente.
        </p>

        <% } %>


        <!-- BARRA SUPERIOR -->

        <div class="table-toolbar">

          <div class="table-toolbar-left">
            <span>&#9638;</span>
            Vista de Tabla
          </div>

        </div>


        <!-- TABLA DE MANTENIMIENTOS -->

        <div class="data-table-wrapper">

          <table class="data-table">

            <thead>
            <tr>
              <th>ID</th>
              <th>Segmento</th>
              <th>Tipo de mantenimiento</th>
              <th>Fecha de inicio</th>
              <th>Fecha de fin</th>
              <th>Prioridad</th>
              <th>Estado</th>
              <th>Notas / Descripción</th>
              <th>Acciones</th>
            </tr>
            </thead>

            <tbody>

            <%
              for (int i = 0; i < totalFilas; i++) {

                if (i < mantenimientos.size()) {

                  Mantenimiento m =
                    mantenimientos.get(i);

                  // PRIORIDAD
                  String prioridad = m.getPrioridad();

                  String badgeClass = "badge-leve";

                  if ("Media".equals(prioridad)) {
                    badgeClass = "badge-media";

                  } else if ("Alta".equals(prioridad)) {
                    badgeClass = "badge-alta";

                  } else if ("Crítica".equals(prioridad)) {
                    badgeClass = "badge-critica";
                  }

                  // SEGMENTO
                  String codigoSegmento =
                    segmentos.getOrDefault(
                      m.getIdSegmento(),
                      "Segmento #" + m.getIdSegmento()
                    );

                  // FECHAS
                  String fechaInicio =
                    m.getFechaInicio() == null
                      ? "—"
                      : m.getFechaInicio()
                      .format(formatoFecha);

                  String fechaFin =
                    m.getFechaFin() == null
                      ? "—"
                      : m.getFechaFin()
                      .format(formatoFecha);

                  // ESTADO CALCULADO POR EL DAO
                  String estado = m.getEstado();

                  String estadoVisible =
                    "En ejecucion".equals(estado)
                      ? "En ejecución"
                      : estado;

                  String badgeEstado = "badge-programado";

                  if ("En ejecucion".equals(estado)) {
                    badgeEstado = "badge-en-progreso";

                  } else if ("Finalizado".equals(estado)) {
                    badgeEstado = "badge-finalizado";
                  }

                  boolean puedeEditar =
                    "Programado".equals(estado);

                  boolean puedeCancelar =
                    "Programado".equals(estado)
                      || "En ejecucion".equals(estado);
            %>

            <tr>

              <!-- ID: ENLACE A ESTADO -->
              <td>
                <a
                  href="${pageContext.request.contextPath}/MantenimientoServlet?accion=estado&idMantenimiento=<%= m.getIdMantenimiento() %>"
                  title="Ver estado del mantenimiento"
                  style="font-weight: bold; text-decoration: underline;">

                  <%= m.getIdMantenimiento() %>

                </a>
              </td>

              <!-- SEGMENTO -->
              <td>
                <%= escaparHtml(codigoSegmento) %>
              </td>

              <!-- TIPO -->
              <td>
                <%= escaparHtml(m.getTipo()) %>
              </td>

              <!-- FECHA INICIO -->
              <td>
                <%= fechaInicio %>
              </td>

              <!-- FECHA FIN -->
              <td>
                <%= fechaFin %>
              </td>

              <!-- PRIORIDAD -->
              <td>
                                <span class="badge <%= badgeClass %>">
                                    <%= escaparHtml(prioridad) %>
                                </span>
              </td>

              <!-- ESTADO -->
              <td>
                                <span class="badge <%= badgeEstado %>">
                                    <%= escaparHtml(estadoVisible) %>
                                </span>
              </td>

              <!-- DESCRIPCIÓN -->
              <td>
                <%= escaparHtml(
                  m.getDescripcionGeneral()
                ) %>
              </td>

              <!-- ACCIONES -->
              <td>
                <div style="display: flex;
                flex-direction: column;
                align-items: flex-start;
                gap: 6px;">

                  <% if (puedeEditar) { %>

                  <a
                    href="${pageContext.request.contextPath}/MantenimientoServlet?accion=editar&idMantenimiento=<%= m.getIdMantenimiento() %>"
                    class="btn btn-primary"
                    style="padding: 8px 20px;
                   font-size: 14px;
                   min-width: 90px;
                   text-align: center;
                   box-sizing: border-box;">

                    Editar

                  </a>

                  <% } %>

                  <% if (puedeCancelar) { %>

                  <form
                    action="${pageContext.request.contextPath}/MantenimientoServlet"
                    method="POST"
                    style="margin: 0;"
                    onsubmit="return confirm('¿Estás seguro de que deseas cancelar el mantenimiento #<%= m.getIdMantenimiento() %>? Esta acción no se puede deshacer.');">

                    <input
                      type="hidden"
                      name="accion"
                      value="cancelar">

                    <input
                      type="hidden"
                      name="idMantenimiento"
                      value="<%= m.getIdMantenimiento() %>">

                    <button
                      type="submit"
                      class="btn btn-primary"
                      style="padding: 8px 20px;
                       font-size: 14px;
                       min-width: 90px;
                       text-align: center;
                       box-sizing: border-box;
                       background-color: #b42318;
                       border-color: #b42318;">

                      Cancelar

                    </button>

                  </form>

                  <% } %>

                </div>
              </td>

            <!-- FILAS VACÍAS DEL DISEÑO ORIGINAL -->
            <tr class="row-empty">
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
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

  </main>

</div>

</body>
</html>
