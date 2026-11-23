<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ page import="beans.maintenance.ServicioAfectado" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>


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
  List<ServicioAfectado> servicios =
    (List<ServicioAfectado>) request.getAttribute("serviciosAfectados");

  Map<Integer, String> segmentos =
    (Map<Integer, String>) request.getAttribute("segmentos");

  Integer idServicioSeleccionado =
    (Integer) request.getAttribute("idServicioSeleccionado");

  Integer idSegmentoSeleccionado =
    (Integer) request.getAttribute("idSegmentoSeleccionado");

  Map<Integer, String> clientes =
    (Map<Integer, String>) request.getAttribute("clientes");

  Integer idClienteSeleccionado =
    (Integer) request.getAttribute("idClienteSeleccionado");


  if (servicios == null || segmentos == null || clientes == null) {
    response.sendRedirect(
      request.getContextPath() + "/ServiciosAfectadosServlet"
    );
    return;
  }
%>

<!DOCTYPE html>
<html lang="es">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <title>OceanLink - Servicios afectados</title>

  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/barras.css">

  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/styles_MC.css">
</head>

<body>

<jsp:include page="header.jsp">
  <jsp:param name="pageTitle" value="Registro y actualización de actividades de mantenimiento"/>
</jsp:include>

<div class="contenedor">

  <jsp:include page="sidebar.jsp">
    <jsp:param name="activePage" value="serviciosAfectados"/>
  </jsp:include>

  <main class="contenido-principal">

    <div class="content-container">

      <div class="card">

        <h2 class="card-title">
          Servicios afectados por mantenimientos
        </h2>

        <!-- FILTROS DE SERVICIOS AFECTADOS -->
        <form action="${pageContext.request.contextPath}/ServiciosAfectadosServlet"
              method="GET"
              class="filters-bar">

          <!-- FILTRO POR CLIENTE -->
          <div class="form-field">
            <label for="filtroCliente">Cliente</label>

            <select id="filtroCliente" name="idCliente">

              <option value="">Todos los clientes</option>

              <%
                for (Map.Entry<Integer, String> entry : clientes.entrySet()) {

                  boolean seleccionado =
                    idClienteSeleccionado != null
                      && idClienteSeleccionado.equals(entry.getKey());
              %>

              <option
                value="<%= entry.getKey() %>"
                <%= seleccionado ? "selected" : "" %>
              >
                <%= escaparHtml(entry.getValue()) %>
              </option>

              <%
                }
              %>

            </select>
          </div>

          <!-- FILTRO POR SEGMENTO -->
          <div class="form-field">
            <label for="filtroSegmento">Segmento</label>

            <select id="filtroSegmento" name="idSegmento">

              <option value="">Todos los segmentos</option>

              <%
                for (Map.Entry<Integer, String> entry : segmentos.entrySet()) {

                  boolean seleccionado =
                    idSegmentoSeleccionado != null
                      && idSegmentoSeleccionado.equals(entry.getKey());
              %>

              <option
                value="<%= entry.getKey() %>"
                <%= seleccionado ? "selected" : "" %>
              >
                <%= escaparHtml(entry.getValue()) %>
              </option>

              <%
                }
              %>

            </select>
          </div>

          <!-- BOTONES -->
          <div class="filters-actions">

            <button type="submit" class="btn btn-primary">
              Filtrar
            </button>

            <a
              href="${pageContext.request.contextPath}/ServiciosAfectadosServlet"
              class="btn btn-secondary"
            >
              Limpiar
            </a>

          </div>

        </form>

        <!-- TABLA DE SERVICIOS AFECTADOS -->
        <div class="data-table-wrapper">

          <table class="data-table">

            <thead>
            <tr>
              <th>Servicio</th>
              <th>Cliente</th>
              <th>Ruta</th>
              <th>Segmentos en mantenimiento</th>
              <th>Usuario encargado</th>
            </tr>
            </thead>

            <tbody>

            <% if (servicios.isEmpty()) { %>

            <tr>
              <td colspan="5" class="table-empty-cell">
                No se encontraron resultados para esta búsqueda.
              </td>
            </tr>

            <% } else {
              for (ServicioAfectado servicio : servicios) {
            %>

            <tr>
              <td>
                #<%= servicio.getIdServicio() %>
              </td>

              <td>
                <%= escaparHtml(servicio.getCliente()) %>
              </td>

              <td>
                <%= escaparHtml(servicio.getRuta()) %>
              </td>

              <td>
                <%= escaparHtml(servicio.getSegmentosEnMantenimiento()) %>
              </td>

              <td>
                <%= escaparHtml(servicio.getUsuariosEncargados()) %>
              </td>
            </tr>

            <%  }
            } %>

            </tbody>

          </table>

        </div>

      </div>

    </div>

  </main>

</div>

</body>
</html>
