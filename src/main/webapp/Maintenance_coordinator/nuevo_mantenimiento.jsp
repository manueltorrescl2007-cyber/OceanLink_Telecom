<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Oceanlink - Nuevo mantenimiento</title>
    <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/barras.css">

    <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/styles_MC.css">
</head>
<body>

<jsp:include page="header.jsp">
  <jsp:param name="pageTitle" value="Registro y actualizaci&oacute;n de actividades de mantenimiento" />
</jsp:include>

<div class="contenedor">

    <jsp:include page="sidebar.jsp">
        <jsp:param name="activePage" value="nuevo" />
    </jsp:include>

    <main class="contenido-principal">



      <div class="content-container">
        <div class="card">
          <h2 class="card-title">Programar un nuevo mantenimiento</h2>

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
                <option value="" selected disabled>
                  Seleccione un segmento
                </option>

                <c:forEach var="segmento" items="${segmentos}">
                  <option value="${segmento.key}">
                      ${segmento.value}
                  </option>
                </c:forEach>
              </select>
            </div>

            <div class="form-field">
              <label for="tipoMantenimiento">Tipo de mantenimiento <span class="required">*</span></label>

              <select id="tipoMantenimiento" name="tipo" required>
                <option value="" selected disabled>Seleccione un tipo</option>
                <option value="Preventivo">Preventivo</option>
                <option value="Correctivo">Correctivo</option>
              </select>
            </div>

            <div class="form-field">
              <label for="fechaInicio">Fecha de inicio <span class="required">*</span></label>
              <input type="date" id="fechaInicio" name="fechaInicio" required>
            </div>

            <div class="form-field">
              <label for="fechaFin">Fecha de fin estimada <span class="required">*</span></label>
              <input type="date" id="fechaFin" name="fechaFin" required>
            </div>

            <div class="form-field">
              <label for="prioridad">Prioridad <span class="required">*</span></label>

              <select id="prioridad" name="prioridad" required>
                <option value="" selected disabled>Seleccione una prioridad</option>
                <option value="Leve">Leve</option>
                <option value="Media">Media</option>
                <option value="Alta">Alta</option>
                <option value="Critica">Crítica</option>
              </select>
            </div>

            <div class="form-field">
              <!-- Espacio para mantener la grilla de dos columnas -->
            </div>

            <div class="form-field full-width">
              <label for="notas">Notas / Descripción</label>
              <textarea id="notas"
                        name="descripcionGeneral"
                        placeholder="Ingrese detalles adicionales..."></textarea>
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
