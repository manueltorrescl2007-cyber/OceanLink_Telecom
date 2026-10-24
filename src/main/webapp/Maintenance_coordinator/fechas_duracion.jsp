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

  // El listado siempre debe recibir los datos del Servlet.
  if (mantenimientos == null || segmentos == null) {
    response.sendRedirect(
      request.getContextPath()
        + "/MantenimientoServlet?accion=listar"
    );
    return;
  }

  DateTimeFormatter formatoFecha =
    DateTimeFormatter.ofPattern(
      "dd/MM/yyyy", Locale.forLanguageTag("es-PE")
    );

  // Conservamos al menos diez filas en la tabla.
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
          Fechas y duración de mantenimientos programados
        </h2>


        <!-- MENSAJE DE RESULTADO -->
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

          <div class="table-toolbar-icons">

            <a
              href="${pageContext.request.contextPath}/MantenimientoServlet?accion=listar"
              title="Actualizar listado"
              aria-label="Actualizar listado">

              &#8635;

            </a>

            <span title="Más opciones">&#8942;</span>

          </div>

        </div>


        <!-- TABLA DE MANTENIMIENTOS -->
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
              <th>Acciones</th>
            </tr>
            </thead>

            <tbody>

            <%
              for (int i = 0; i < totalFilas; i++) {

                if (i < mantenimientos.size()) {

                  Mantenimiento m =
                    mantenimientos.get(i);

                  String prioridad = m.getPrioridad();

                  String badgeClass = "badge-leve";

                  if ("Media".equals(prioridad)) {
                    badgeClass = "badge-media";

                  } else if ("Alta".equals(prioridad)) {
                    badgeClass = "badge-alta";

                  } else if ("Crítica".equals(prioridad)) {
                    badgeClass = "badge-critica";
                  }

                  String codigoSegmento =
                    segmentos.getOrDefault(
                      m.getIdSegmento(),
                      "Segmento #" + m.getIdSegmento()
                    );

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
            %>

            <tr>

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


              <!-- DESCRIPCIÓN -->
              <td>
                <%= escaparHtml(
                  m.getDescripcionGeneral()
                ) %>
              </td>


              <!-- ACCIONES -->
              <td>

                <% if ("Programado".equals(
                  m.getEstado())) { %>

                <a
                  href="${pageContext.request.contextPath}/MantenimientoServlet?accion=editar&idMantenimiento=<%= m.getIdMantenimiento() %>"
                  class="btn btn-primary">

                  Editar

                </a>

                <% } else { %>

                <span>
                                            <%= escaparHtml(m.getEstado()) %>
                                        </span>

                <% } %>

              </td>

            </tr>

            <%
            } else {
            %>

            <!-- FILAS VACÍAS DEL DISEÑO ORIGINAL -->
            <tr class="row-empty">

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
