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
          href="${pageContext.request.contextPath}/css/admin/programacion.css?v=2">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/barras.css">
</head>

<body>

<jsp:include page="header.jsp" />

<div class="contenedor">

  <jsp:include page="sidebar.jsp">
      <jsp:param name="activePage" value="usuarios" />
  </jsp:include>
  <!-- Contenido principal -->
  <main class="contenido-principal">
    <section class="encabezado-panel">
          <h2>Administrador</h2>
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
