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
  // Recuperamos los datos enviados por el Servlet.
  ArrayList<Mantenimiento> historial =
    (ArrayList<Mantenimiento>)
      request.getAttribute("historialMantenimientos");

  Map<Integer, String> segmentos =
    (Map<Integer, String>)
      request.getAttribute("segmentos");

  // Evitamos acceder directamente a la JSP sin pasar por el Servlet.
  if (historial == null || segmentos == null) {
    response.sendRedirect(
      request.getContextPath()
        + "/MantenimientoServlet?accion=historial"
    );
    return;
  }

  DateTimeFormatter formatoFecha =
    DateTimeFormatter.ofPattern(
      "dd/MM/yyyy", Locale.forLanguageTag("es-PE")
    );

  int totalFilas = Math.max(5, historial.size());
%>

<!DOCTYPE html>
<html lang="es">

<head>
  <meta charset="UTF-8">
  <meta name="viewport"
        content="width=device-width, initial-scale=1.0">

  <title>OceanLink - Historial</title>

  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/barras.css">

  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/styles_MC.css">
</head>

<body>

<jsp:include page="header.jsp">
  <jsp:param name="pageTitle"
             value="Registro y actualización de actividades de mantenimiento"/>
</jsp:include>

<div class="contenedor">

  <jsp:include page="sidebar.jsp">
    <jsp:param name="activePage" value="historial"/>
  </jsp:include>

  <main class="contenido-principal">

    <div class="content-container">

      <div class="card">

        <h2 class="card-title">
          Historial de mantenimientos
        </h2>

        <!-- BARRA SUPERIOR -->
        <div class="table-toolbar">

          <div class="table-toolbar-left">
            <span>&#9638;</span>
            Vista de Tabla
          </div>

        </div>

        <!-- TABLA DE HISTORIAL -->
        <div class="data-table-wrapper">

          <table class="data-table">

            <thead>
            <tr>
              <th>ID</th>
              <th>Segmento</th>
              <th>Tipo</th>
              <th>Fecha de fin</th>
              <th>Estado</th>
            </tr>
            </thead>

            <tbody>

            <%
              for (int i = 0; i < totalFilas; i++) {

                if (i < historial.size()) {

                  Mantenimiento m = historial.get(i);

                  String codigoSegmento =
                    segmentos.getOrDefault(
                      m.getIdSegmento(),
                      "Segmento #" + m.getIdSegmento()
                    );

                  String fechaFin =
                    m.getFechaFin() == null
                      ? "—"
                      : m.getFechaFin().format(formatoFecha);

                  String estado = m.getEstado();

                  String badgeClass =
                    "Finalizado".equals(estado)
                      ? "badge-finalizado"
                      : "badge-cancelado";
            %>

            <tr>

              <!-- ID CON ENLACE A ESTADO.JSP -->
              <td>
                <a
                  href="${pageContext.request.contextPath}/MantenimientoServlet?accion=estado&idMantenimiento=<%= m.getIdMantenimiento() %>">

                  <%= m.getIdMantenimiento() %>

                </a>
              </td>

              <!-- SEGMENTO -->
              <td>
                                <span class="badge badge-segmento">
                                    <%= escaparHtml(codigoSegmento) %>
                                </span>
              </td>

              <!-- TIPO -->
              <td>
                <%= escaparHtml(m.getTipo()) %>
              </td>

              <!-- FECHA FIN -->
              <td>
                <%= fechaFin %>
              </td>

              <!-- ESTADO -->
              <td>
                  <span
                    class="badge <%= badgeClass %>"
                    style="<%= "Cancelado".equals(estado)
                          ? "display:inline-block; background-color:#FCE8E6; color:#B42318; padding:4px 12px; border-radius:20px; font-size:13px; font-weight:600;"
                          : "" %>">

                      <%= escaparHtml(estado) %>

                  </span>
              </td>

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
