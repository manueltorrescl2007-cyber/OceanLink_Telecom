<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>OceanLink | Dashboard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/supervisor/incidencias.css">
</head>

<body>

<!-- Control para abrir/cerrar el menú -->
<input
  type="checkbox"
  id="controlMenu"
  class="control-menu"
>

<!-- Barra superior -->
<header class="barra-superior">

  <div class="zona-logo">

    <label
            for="controlMenu"
            class="boton-menu">
        ☰
    </label>

    <a href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/supervisor.jsp"
       class="logo">
        OceanLink
    </a>
  </div>

  <div class="usuario">

    <div class="foto-usuario">
        SU
    </div>

    <div>
        <p class="nombre-usuario">Username</p>
        <p class="rol-usuario">Supervisor</p>
    </div>
  </div>
</header>

<div class="contenedor">

  <!-- Barra lateral -->
  <aside class="menu-lateral">

    <div class="contenido-menu">

      <h2>Menú</h2>

      <nav class="navegacion-lateral">

        <!-- Dashboard -->
        <a href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/supervisor.jsp"
           class="activo">
            Dashboard general
        </a>

        <!-- Incidencias -->
        <div class="grupo-menu">

          <input
            type="checkbox"
            id="control-incidencias"
            class="control-submenu"
          >

          <label
                  for="control-incidencias"
                  class="titulo-grupo">

            <span class="texto-grupo">
                Incidencias
            </span>

            <span class="flecha-submenu"></span>

          </label>


          <div class="contenido-submenu">

            <a
                    href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/visualizar.jsp"
                    class="subopcion">
                Visualizar
            </a>

            <a
                    href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/historial_incidencias.jsp"
                    class="subopcion">
                Historial de incidencias
            </a>
          </div>
        </div>

        <!-- Estado de la red -->
        <div class="grupo-menu">

          <input
            type="checkbox"
            id="controlEstadoRed"
            class="control-submenu"
          >

          <label
                  for="controlEstadoRed"
                  class="titulo-grupo">

            <span class="texto-grupo">
                Estado de la red
            </span>

            <span class="flecha-submenu"></span>

          </label>


          <div class="contenido-submenu">

            <a
                    href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/capacidad.jsp"
                    class="subopcion">
                Capacidad
            </a>

            <a
                    href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/segmentos.jsp"
                    class="subopcion">
                Segmentos
            </a>
          </div>
        </div>

        <!-- Servicios y clientes -->
        <div class="grupo-menu">

          <input
            type="checkbox"
            id="control-servicios-clientes"
            class="control-submenu"
          >

          <label
                  for="control-servicios-clientes"
                  class="titulo-grupo">

            <span class="texto-grupo">
                Servicios y clientes
            </span>

            <span class="flecha-submenu"></span>

          </label>


          <div class="contenido-submenu">

            <a
                    href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/clientes.jsp"
                    class="subopcion">
                Clientes
            </a>

            <a
                    href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/servicios.jsp"
                    class="subopcion">
                Servicios
            </a>
            <a
                    href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/solicitudes.jsp"
                    class="subopcion">
                Solicitudes
            </a>
          </div>
        </div>

        <!-- Mantenimientos -->
        <div class="grupo-menu">

          <input
            type="checkbox"
            id="control-mantenimientos"
            class="control-submenu"
          >

          <label
                  for="control-mantenimientos"
                  class="titulo-grupo">

            <span class="texto-grupo">
                Mantenimientos
            </span>

            <span class="flecha-submenu"></span>

          </label>

          <div class="contenido-submenu">

            <a
                    href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/programacion.jsp"
                    class="subopcion">
                Programación
            </a>

            <a
                    href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/historial_programados.jsp"
                    class="subopcion">
                Historial de programados
            </a>
          </div>
        </div>

        <!-- Reportes -->
        <a href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/reportes.jsp">
            Reportes
        </a>

        <!-- Históricos -->
        <a href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/historicos.jsp">
            Históricos
        </a>

      </nav>

    </div>


    <!-- parte baja -->
    <div class="configuracion">
      <nav>
        <h4>
          <a href="#">
              Perfil
          </a>
        </h4>

        <h4>
          <a href="../../login.jsp">
              Cerrar sesión
          </a>
        </h4>
      </nav>
    </div>
  </aside>



    <!-- Contenido principal -->
    <main class="contenido-principal">
      <section class="encabezado-panel">
              <h2>Incidencias</h2>
              <h1>Incidencias activas</h1>
            </section>
      <section>
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
            <td><a href="incidencia-detalle.jsp">INC-014</a></td>
            <td>LIM-VLP-02</td>
            <td class="severidad-alta">Alta</td>
            <td>En análisis</td>
          </tr>
          <tr>
            <td><a href="incidencia-detalle.jsp">INC-013</a></td>
            <td>LIM-VLP-02</td>
            <td class="severidad-critica">Crítica</td>
            <td>En reparación</td>
          </tr>
          <tr>
            <td><a href="incidencia-detalle.jsp">INC-011</a></td>
            <td>LIM-GYE-01</td>
            <td class="severidad-media">Media</td>
            <td>Reparación programada</td>
          </tr>
          <tr>
            <td><a href="incidencia-detalle.jsp">INC-010</a></td>
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
