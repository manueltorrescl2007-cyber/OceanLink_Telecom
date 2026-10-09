<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    /*
        Lista consolidada de registros de prueba tomados de historial_incidencias.jsp
        y historial_programados.jsp, ordenados del más reciente al más antiguo.
    */
    List<Map<String, String>> historicoConsolidado = new ArrayList<Map<String, String>>();

    // 1. Mantenimiento REV-0405 (2 sep 2026)
    Map<String, String> m1 = new HashMap<String, String>();
    m1.put("id", "REV-0405");
    m1.put("tipoRegistro", "Mantenimiento");
    m1.put("segmento", "LIM-VLP-01");
    m1.put("detalleTipo", "Preventivo");
    m1.put("fecha", "02 sep 2026");
    m1.put("estadoSeveridad", "Finalizado");
    m1.put("claseBadge", "badge-finalizado");
    historicoConsolidado.add(m1);

    // 2. Incidencia INC-009 (18 ago 2026)
    Map<String, String> i1 = new HashMap<String, String>();
    i1.put("id", "INC-009");
    i1.put("tipoRegistro", "Incidencia");
    i1.put("segmento", "LIM-VLP-01");
    i1.put("detalleTipo", "Incidencia de red");
    i1.put("fecha", "18 ago 2026");
    i1.put("estadoSeveridad", "Media");
    i1.put("claseBadge", "severidad-media");
    historicoConsolidado.add(i1);

    // 3. Incidencia INC-008 (13 jul 2026)
    Map<String, String> i2 = new HashMap<String, String>();
    i2.put("id", "INC-008");
    i2.put("tipoRegistro", "Incidencia");
    i2.put("segmento", "LIM-VLP-02");
    i2.put("detalleTipo", "Incidencia de red");
    i2.put("fecha", "13 jul 2026");
    i2.put("estadoSeveridad", "Crítica");
    i2.put("claseBadge", "severidad-critica");
    historicoConsolidado.add(i2);

    // 4. Incidencia INC-007 (25 ago 2025)
    Map<String, String> i3 = new HashMap<String, String>();
    i3.put("id", "INC-007");
    i3.put("tipoRegistro", "Incidencia");
    i3.put("segmento", "LIM-GYE-01");
    i3.put("detalleTipo", "Incidencia de red");
    i3.put("fecha", "25 ago 2025");
    i3.put("estadoSeveridad", "Media");
    i3.put("claseBadge", "severidad-media");
    historicoConsolidado.add(i3);

    // 5. Incidencia INC-006 (5 jul 2025)
    Map<String, String> i4 = new HashMap<String, String>();
    i4.put("id", "INC-006");
    i4.put("tipoRegistro", "Incidencia");
    i4.put("segmento", "LIM-GYE-04");
    i4.put("detalleTipo", "Incidencia de red");
    i4.put("fecha", "05 jul 2025");
    i4.put("estadoSeveridad", "Alta");
    i4.put("claseBadge", "severidad-alta");
    historicoConsolidado.add(i4);
%>
<!doctype html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>OceanLink | Históricos</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/barras.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/admin/historicos.css">
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
      <h1>Histórico general</h1>
    </section>

    <section class="card">
      <h2 class="card-title">Filtrar</h2>

      <div class="filtros">
          <input type="date">
          <input type="date">
          <select>
            <option value="">Origen / Registro</option>
            <option value="Incidencia">Incidencia</option>
            <option value="Mantenimiento">Mantenimiento</option>
          </select>
          <select>
            <option value="">Segmento</option>
            <option value="LIM-VLP-01">LIM-VLP-01</option>
            <option value="LIM-VLP-02">LIM-VLP-02</option>
            <option value="LIM-GYE-01">LIM-GYE-01</option>
            <option value="LIM-GYE-04">LIM-GYE-04</option>
          </select>
      </div>

      <div class="table-wrapper">
        <table class="data-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Registro</th>
              <th>Segmento</th>
              <th>Tipo</th>
              <th>Fecha de cierre</th>
              <th>Estado / Severidad</th>
            </tr>
          </thead>
          <tbody>
            <%
              for (Map<String, String> reg : historicoConsolidado) {
                  String id = reg.get("id");
                  String tipoReg = reg.get("tipoRegistro");
                  String estadoSeveridad = reg.get("estadoSeveridad");
                  String claseBadge = reg.get("claseBadge");
            %>
            <tr>
              <td>
                <% if ("Incidencia".equals(tipoReg)) { %>
                  <a href="incidencias-detalle.jsp?id=<%= id %>"><%= id %></a>
                <% } else { %>
                  <strong><%= id %></strong>
                <% } %>
              </td>
              <td><span class="badge badge-registro"><%= tipoReg %></span></td>
              <td><span class="badge badge-segmento"><%= reg.get("segmento") %></span></td>
              <td><%= reg.get("detalleTipo") %></td>
              <td><%= reg.get("fecha") %></td>
              <td>
                <% if ("Mantenimiento".equals(tipoReg)) { %>
                  <span class="badge <%= claseBadge %>"><%= estadoSeveridad %></span>
                <% } else { %>
                  <span class="<%= claseBadge %>"><%= estadoSeveridad %></span>
                <% } %>
              </td>
            </tr>
            <%
              }
            %>
          </tbody>
        </table>
      </div>

      <p class="ayuda">Haz clic en el ID de la incidencia para ver su detalle.</p>
    </section>
  </main>

</div>
</body>
</html>
