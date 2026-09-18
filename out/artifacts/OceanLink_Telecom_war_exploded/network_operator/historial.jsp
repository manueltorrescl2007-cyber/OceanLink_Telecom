<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>OceanLink - Historial de Incidencias</title>
  <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<% request.setAttribute("activePage", "historial"); %>
<div class="contenedor">

  <jsp:include page="slidebar_netoperator.jsp" />

  <!-- ===== CONTENIDO PRINCIPAL ===== -->
  <main class="contenido">

    <header class="topbar">
      <h2>Historial de incidencias</h2>
      <div class="usuario">
        <div class="avatar"></div>
        <div>
          <strong>Username</strong><br>
          <small>Network Operator</small>
        </div>
      </div>
    </header>

    <section>
      <h3>Filtrar</h3>

      <div class="filtros">
        <input type="date">
        <input type="date">
        <select>
          <option>Severidad</option>
          <option>Alta</option>
          <option>Crítica</option>
          <option>Media</option>
        </select>
        <select>
          <option>Segmento</option>
          <option>LIM-VLP-01</option>
          <option>LIM-VLP-02</option>
          <option>LIM-GYE-01</option>
          <option>LIM-GYE-04</option>
        </select>
      </div>

      <table>
        <thead>
        <tr>
          <th>ID</th>
          <th>Segmento</th>
          <th>Severidad</th>
          <th>Cerrada el</th>
        </tr>
        </thead>
        <tbody>
        <tr>
          <td><a href="incidencias-detalle.html">INC-009</a></td>
          <td>LIM-VLP-01</td>
          <td class="severidad-media">Media</td>
          <td>18 ago 2026</td>
        </tr>
        <tr>
          <td><a href="incidencias-detalle.html">INC-013</a></td>
          <td>LIM-VLP-02</td>
          <td class="severidad-critica">Crítica</td>
          <td>13 jul 2026</td>
        </tr>
        <tr>
          <td><a href="incidencias-detalle.html">INC-011</a></td>
          <td>LIM-GYE-01</td>
          <td class="severidad-media">Media</td>
          <td>25 ago 2025</td>
        </tr>
        <tr>
          <td><a href="incidencias-detalle.html">INC-010</a></td>
          <td>LIM-GYE-04</td>
          <td class="severidad-alta">Alto</td>
          <td>5 jul 2025</td>
        </tr>
        </tbody>
      </table>

      <p class="ayuda">Click en una fila para ver el detalle de la incidencia.</p>
    </section>

  </main>

</div>

</body>
</html>
