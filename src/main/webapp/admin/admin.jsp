<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>OceanLink | Dashboard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/admin/admin_dashboard.css?v=2">
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
        <h1>Dashboard general</h1>
      </section>

      <!-- Tarjetas del dashboard -->
      <section class="tarjetas">

        <!-- Estado de la red -->
        <article class="tarjeta">
          <div class="information">
            <p>Estado de la red</p>
          </div>
          <div class="information">
            <strong>OPERATIVA</strong>
          </div>
          <div class = "information">
            <p>Disponiblidad: <b>99.2%</b></p>
          </div>
        </article>

        <!-- Incidencias activas -->
        <article class="tarjeta">
          <div class="information">
            <p>Incidencias activas</p>
          </div>
          <div class="information">
            <strong>5</strong>
          </div>
          <div class = "information">
            <p>Críticas: <b>2</b> Medias: <b>3</b></p>
          </div>
        </article>

        <!-- Clientes afectados -->
        <article class="tarjeta">
          <div class="information">
            <p>Clientes afectados</p>
          </div>
          <div class="information">
            <strong>32</strong>
          </div>
          <div class = "information">
            <p>Servicios afectados: <b>3</b></p>
          </div>
        </article>

        <!-- Mantenimientos programados -->
        <article class="tarjeta">
          <div class="information">
            <p>Mantenimientos programados</p>
          </div>
          <div class="information">
            <strong>2</strong>
          </div>
          <div class = "information">
            <p>Próximos 7 días</p>
          </div>
        </article>

        <!-- Utilización promedio -->
        <article class="tarjeta">
          <div class="information">
            <p>Utilización promedio</p>
          </div>
          <div class="information">
            <strong>68%</strong>
          </div>
          <div class = "information">
            <p>Capacidad de la red</p>
          </div>
        </article>
      </section>

      <!-- Mapa interactivo (con fe) -->
      <section class="mapa-interactivo">
          <div>
              <img src="${pageContext.request.contextPath}/img/mapa_red.svg"
                   alt="Mapa de la red OceanLink: landing stations y segmentos en la costa del Pacífico"
                   style="display:block; max-width:100%; max-height:620px; height:auto; margin:0 auto;">
          </div>
      </section>
      <section class="encabezado-panel">
        <h1>Incidencias activas</h1>
      </section>
      <section class="card">

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

        <div class="table-wrapper">
            <table class="data-table">
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
                        <td><a href="incidencias-detalle.jsp?id=INC-014">INC-014</a></td>
                        <td>LIM-VLP-02</td>
                        <td class="severidad-alta">Alta</td>
                        <td>En análisis</td>
                    </tr>
                    <tr>
                        <td><a href="incidencias-detalle.jsp?id=INC-013">INC-013</a></td>
                        <td>LIM-VLP-02</td>
                        <td class="severidad-critica">Crítica</td>
                        <td>En reparación</td>
                    </tr>
                    <tr>
                        <td><a href="incidencias-detalle.jsp?id=INC-011">INC-011</a></td>
                        <td>LIM-GYE-01</td>
                        <td class="severidad-media">Media</td>
                        <td>Reparación programada</td>
                    </tr>
                    <tr>
                        <td><a href="incidencias-detalle.jsp?id=INC-010">INC-010</a></td>
                        <td>LIM-GYE-04</td>
                        <td class="severidad-alta">Alta</td>
                        <td>Restaurado</td>
                    </tr>
                </tbody>
            </table>
        </div>
        <p class="ayuda">Haz clic en el ID para ver el detalle de la incidencia.</p>
      </section>
    </main>
  </div>
</body>

</html>
