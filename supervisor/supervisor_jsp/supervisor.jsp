<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>OceanLink | Dashboard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/supervisor/supervisor.css?v=2">
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
        <a href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/incidencias.jsp">
            Incidencias
        </a>

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
        <a href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/servicios_clientes.jsp">
            Servicios y clientes
        </a>

        <!-- Mantenimientos -->
        <a href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/mantenimientos.jsp">
            Mantenimientos
        </a>

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


      <!-- Conservamos tu configuración -->
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
        <h2>Supervisor</h2>
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
              <img src="${pageContext.request.contextPath}/img/mapa.png"
                   alt="Mapa interactivo">
          </div>
      </section>

      <!-- Incidencias -->

    </main>
  </div>
</body>

</html>
