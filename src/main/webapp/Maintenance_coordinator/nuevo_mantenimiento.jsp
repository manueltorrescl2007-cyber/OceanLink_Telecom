<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
  Map<Integer, String> segmentos =
    (Map<Integer, String>) request.getAttribute("segmentos");

  if (segmentos == null) {
    response.sendRedirect(
      request.getContextPath()
        + "/MantenimientoServlet?accion=nuevo"
    );
    return;
  }

  String error = (String) request.getAttribute("error");
  Mantenimiento previo = (Mantenimiento) request.getAttribute("mantenimiento");
  // Formato que usa el input datetime-local: 2026-11-25T10:05
  java.time.format.DateTimeFormatter formatoInput = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
  String ahora = java.time.LocalDateTime.now().format(formatoInput);

  int segPrevio = previo != null ? previo.getIdSegmento() : 0;
  String tipoPrevio = previo != null && previo.getTipo() != null ? previo.getTipo() : "";
  String prioPrevia = previo != null && previo.getPrioridad() != null ? previo.getPrioridad() : "";
  String inicioPrevio = (previo != null && previo.getFechaInicio() != null)
    ? previo.getFechaInicio().format(formatoInput) : "";
  String finPrevio = (previo != null && previo.getFechaFin() != null)
    ? previo.getFechaFin().format(formatoInput) : "";
  String descPrevia = (previo != null && previo.getDescripcionGeneral() != null)
    ? previo.getDescripcionGeneral() : "";
%>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>OceanLink - Nuevo mantenimiento</title>
  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/barras.css">

  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/styles_MC.css">
</head>
<body>

<jsp:include page="header.jsp">
  <jsp:param name="pageTitle" value="Registro y actualización de actividades de mantenimiento" />
</jsp:include>

<div class="contenedor">

  <jsp:include page="sidebar.jsp">
    <jsp:param name="activePage" value="nuevo" />
  </jsp:include>

  <main class="contenido-principal">

    <div class="content-container">
      <div class="card">
        <h2 class="card-title">Programar un nuevo mantenimiento</h2>

        <% if (error != null && !error.isBlank()) { %>
        <div class="alert-error">
          <%= escaparHtml(error) %>
        </div>
        <% } %>

        <form action="${pageContext.request.contextPath}/MantenimientoServlet"
              method="post"
              class="form-grid">

          <!-- Indica al servlet que debe crear un mantenimiento -->
          <input type="hidden" name="accion" value="crear">

          <div class="form-field">
            <label for="segmento">
              Segmento <span class="required">*</span>
            </label>

            <select id="segmento" name="idSegmento" required>
              <option value="" <%= segPrevio == 0 ? "selected" : "" %> disabled>
                Seleccione un segmento
              </option>

              <%
                for (Map.Entry<Integer, String> segmento : segmentos.entrySet()) {
                  boolean seleccionado = segmento.getKey() == segPrevio;
              %>
              <option value="<%= segmento.getKey() %>" <%= seleccionado ? "selected" : "" %>>
                <%= escaparHtml(segmento.getValue()) %>
              </option>
              <%
                }
              %>
            </select>
          </div>

          <div class="form-field">
            <label for="tipoMantenimiento">Tipo de mantenimiento <span class="required">*</span></label>

            <select id="tipoMantenimiento" name="tipo" required>
              <option value="" <%= tipoPrevio.isEmpty() ? "selected" : "" %> disabled>Seleccione un tipo</option>
              <option value="Preventivo" <%= "Preventivo".equals(tipoPrevio) ? "selected" : "" %>>Preventivo</option>
              <option value="Correctivo" <%= "Correctivo".equals(tipoPrevio) ? "selected" : "" %>>Correctivo</option>
            </select>
          </div>

          <div class="form-field">
            <label for="fechaInicio">Fecha y hora de inicio <span class="required">*</span></label>
            <input type="datetime-local" id="fechaInicio" name="fechaInicio" min="<%= ahora %>" value="<%= inicioPrevio %>" required>
          </div>

          <div class="form-field">
            <label for="fechaFin">Fecha y hora de fin estimada <span class="required">*</span></label>
            <input type="datetime-local" id="fechaFin" name="fechaFin" min="<%= ahora %>" value="<%= finPrevio %>" required>
          </div>

          <div class="form-field">
            <label for="prioridad">Prioridad <span class="required">*</span></label>

            <select id="prioridad" name="prioridad" required>
              <option value="" <%= prioPrevia.isEmpty() ? "selected" : "" %> disabled>Seleccione una prioridad</option>
              <option value="Leve" <%= "Leve".equals(prioPrevia) ? "selected" : "" %>>Leve</option>
              <option value="Media" <%= "Media".equals(prioPrevia) ? "selected" : "" %>>Media</option>
              <option value="Alta" <%= "Alta".equals(prioPrevia) ? "selected" : "" %>>Alta</option>
              <option value="Crítica" <%= "Crítica".equals(prioPrevia) ? "selected" : "" %>>Crítica</option>
            </select>
          </div>

          <div class="form-field">
            <!-- Espacio para mantener la grilla de dos columnas -->
          </div>

          <div class="form-field full-width">
            <label for="notas">Notas / Descripción</label>
            <textarea id="notas"
                      name="descripcionGeneral"
                      placeholder="Ingrese detalles adicionales..."><%= escaparHtml(descPrevia) %></textarea>
          </div>

          <div class="form-actions">
            <button type="submit" class="btn btn-primary">Programar</button>
          </div>

        </form>
      </div>
    </div>

  </main>
</div>

</body>
</html>
