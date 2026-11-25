<%@ page contentType="text/html;charset=UTF-8"
         pageEncoding="UTF-8"
         language="java" %>

<%@ page import="beans.maintenance.Mantenimiento" %>
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
  Mantenimiento mantenimiento =
    (Mantenimiento) request.getAttribute("mantenimiento");

  Map<Integer, String> segmentos =
    (Map<Integer, String>) request.getAttribute("segmentos");

  // El formulario debe abrirse desde MantenimientoServlet.
  if (mantenimiento == null || segmentos == null) {
    response.sendRedirect(
      request.getContextPath()
        + "/MantenimientoServlet?accion=listar"
    );
    return;
  }

  String error = (String) request.getAttribute("error");
  // Formato que usa el input datetime-local: 2026-11-25T10:05
  java.time.format.DateTimeFormatter formatoInput = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
  String ahora = java.time.LocalDateTime.now().format(formatoInput);

  String fechaInicio = mantenimiento.getFechaInicio() == null
    ? ""
    : mantenimiento.getFechaInicio().format(formatoInput);

  String fechaFin = mantenimiento.getFechaFin() == null
    ? ""
    : mantenimiento.getFechaFin().format(formatoInput);
%>

<!DOCTYPE html>
<html lang="es">

<head>
  <meta charset="UTF-8">

  <meta name="viewport"
        content="width=device-width, initial-scale=1.0">

  <title>OceanLink - Editar mantenimiento</title>

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
    <jsp:param name="activePage" value="fechas"/>
  </jsp:include>

  <main class="contenido-principal">

    <div class="content-container">

      <div class="card">

        <h2 class="card-title">
          Editar mantenimiento
        </h2>

        <% if (error != null && !error.isBlank()) { %>
        <div class="alert-error">
          <%= escaparHtml(error) %>
        </div>
        <% } %>

        <form
          action="${pageContext.request.contextPath}/MantenimientoServlet"
          method="post"
          class="form-grid">

          <!-- Acción que procesará el Servlet -->
          <input type="hidden"
                 name="accion"
                 value="actualizar">

          <!-- Identificador del registro que se editará -->
          <input type="hidden"
                 name="idMantenimiento"
                 value="<%= mantenimiento.getIdMantenimiento() %>">


          <!-- SEGMENTO -->
          <div class="form-field">

            <label for="idSegmento">
              Segmento
              <span class="required">*</span>
            </label>

            <select id="idSegmento"
                    name="idSegmento"
                    required>

              <option value="" disabled>
                Seleccione un segmento
              </option>

              <% for (Map.Entry<Integer, String> segmento
                : segmentos.entrySet()) {

                int idSegmento = segmento.getKey();

                boolean seleccionado =
                  idSegmento == mantenimiento.getIdSegmento();
              %>

              <option
                value="<%= idSegmento %>"
                <%= seleccionado ? "selected" : "" %>>

                <%= escaparHtml(segmento.getValue()) %>

              </option>

              <% } %>

            </select>
          </div>


          <!-- TIPO -->
          <div class="form-field">

            <label for="tipo">
              Tipo de mantenimiento
              <span class="required">*</span>
            </label>

            <select id="tipo"
                    name="tipo"
                    required>

              <option value="Preventivo"
                <%= "Preventivo".equals(
                  mantenimiento.getTipo())
                  ? "selected" : "" %>>

                Preventivo

              </option>

              <option value="Correctivo"
                <%= "Correctivo".equals(
                  mantenimiento.getTipo())
                  ? "selected" : "" %>>

                Correctivo

              </option>

            </select>
          </div>


          <!-- FECHA INICIO -->
          <div class="form-field">

            <label for="fechaInicio">
              Fecha y hora de inicio
              <span class="required">*</span>
            </label>

            <input
              type="datetime-local"
              id="fechaInicio"
              name="fechaInicio"
              min="<%= ahora %>"
              value="<%= fechaInicio %>"
              required>

          </div>


          <!-- FECHA FIN -->
          <div class="form-field">

            <label for="fechaFin">
              Fecha y hora de fin
              <span class="required">*</span>
            </label>

            <input
              type="datetime-local"
              id="fechaFin"
              name="fechaFin"
              min="<%= ahora %>"
              value="<%= fechaFin %>"
              required>

          </div>


          <!-- PRIORIDAD -->
          <div class="form-field">

            <label for="prioridad">
              Prioridad
              <span class="required">*</span>
            </label>

            <select id="prioridad"
                    name="prioridad"
                    required>

              <option value="Leve"
                <%= "Leve".equals(
                  mantenimiento.getPrioridad())
                  ? "selected" : "" %>>

                Leve

              </option>

              <option value="Media"
                <%= "Media".equals(
                  mantenimiento.getPrioridad())
                  ? "selected" : "" %>>

                Media

              </option>

              <option value="Alta"
                <%= "Alta".equals(
                  mantenimiento.getPrioridad())
                  ? "selected" : "" %>>

                Alta

              </option>

              <option value="Crítica"
                <%= "Crítica".equals(
                  mantenimiento.getPrioridad())
                  ? "selected" : "" %>>

                Crítica

              </option>

            </select>
          </div>


          <!-- Espacio vacío para conservar la grilla -->
          <div class="form-field">
          </div>


          <!-- DESCRIPCIÓN -->
          <div class="form-field full-width">

            <label for="descripcionGeneral">
              Notas / Descripción
            </label>

            <textarea
              id="descripcionGeneral"
              name="descripcionGeneral"
              placeholder="Ingrese detalles adicionales..."><%= escaparHtml(mantenimiento.getDescripcionGeneral()) %></textarea>

          </div>


          <!-- BOTONES -->
          <div class="form-actions">

            <a
              href="${pageContext.request.contextPath}/MantenimientoServlet?accion=listar"
              class="btn btn-secondary btn-cancel-link">

              Cancelar

            </a>

            <button
              type="submit"
              class="btn btn-primary">

              Guardar cambios

            </button>

          </div>

        </form>

      </div>

    </div>

  </main>

</div>

</body>
</html>
