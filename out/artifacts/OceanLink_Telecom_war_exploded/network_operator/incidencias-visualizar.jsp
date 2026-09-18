<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>OceanLink - Visualizar Incidencia</title>
  <link rel="stylesheet" href="../css/style.css">
</head>
<body>

<% request.setAttribute("activePage", "incidencias-visualizar"); %>

<div class="contenedor">

  <!-- ===== SIDEBAR: se repite igual en las 3 páginas ===== -->
  <jsp:include page="slidebar_netoperator.jsp" />

  <!-- ===== CONTENIDO PRINCIPA Y OJO NO TOCAR EL MAIN BASENSE EN ESTE===== -->
  <main class="contenido">

    <header class="topbar">
      <h2>Visualizar Incidencia</h2>
      <div class="usuario">
        <div class="avatar"></div>
        <div>
          <strong>Username</strong><br>
          <small>Network Operator</small>
        </div>
      </div>
    </header>

    <section>
      <h3>Incidencias activas</h3>

      <div class="filtros">
        <select>
          <option>Todas las severidades</option>
          <option>Alta</option>
          <option>Crítica</option>
          <option>Media</option>
        </select>
        <select>
          <option>Todos los segmentos</option>
          <option>LIM-VLP-01</option>
          <option>LIM-VLP-02</option>
          <option>LIM-GYE-01</option>
        </select>
      </div>

      <table>
        <thead>
        <tr>
          <th>ID</th>
          <th>Segmento</th>
          <th>Severidad</th>
          <th>Estado</th>
        </tr>
        </thead>
        <tbody>
        <tr>
          <td><a href="incidencias-detalle.jsp">INC-014</a></td>
          <td>LIM-VLP-02</td>
          <td class="severidad-alta">Alta</td>
          <td>En análisis</td>
        </tr>
        <tr>
          <td><a href="incidencias-detalle.jsp">INC-013</a></td>
          <td>LIM-VLP-02</td>
          <td class="severidad-critica">Crítica</td>
          <td>En reparación</td>
        </tr>
        <tr>
          <td><a href="incidencias-detalle.jsp">INC-011</a></td>
          <td>LIM-GYE-01</td>
          <td class="severidad-media">Media</td>
          <td>Reparación programada</td>
        </tr>
        <tr>
          <td><a href="incidencias-detalle.jsp">INC-010</a></td>
          <td>LIM-GYE-04</td>
          <td class="severidad-alta">Alta</td>
          <td>Restaurado</td>
        </tr>
        </tbody>
      </table>

      <p class="ayuda">Click en una fila para ver el detalle de la incidencia.</p>
    </section>

  </main>

</div>

</body>
</html>
