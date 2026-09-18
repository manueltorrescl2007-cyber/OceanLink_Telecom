<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<html lang="es">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <title>OceanLink | Dashboard</title>

  <link rel="stylesheet" href="../css/supervisor/supervisor.css">
</head>

<body>

  <!-- Barra superior -->
  <header class="barra-superior">

    <a href="#" class="logo">OceanLink</a>

    <div class="usuario">
      <div class="foto-usuario">CP</div>

      <div>
        <p class="nombre-usuario">Username</p>
        <p class="rol-usuario">Capacity Planner</p>
      </div>
    </div>

  </header>

  <div class="contenedor">

    <!-- Menú lateral -->
    <aside class="menu-lateral">

      <div>
        <h2>Menú</h2>

        <nav>
          <a href="supervisor.html" class="activo">Dashboard general</a>
          <a href="incidencias.html">Incidencias</a>
          <a href="estado_red_s.html">Estado de la red</a>
          <a href="servicios_clientes.html">Servicios y clientes</a>
          <a href="mantenimientos.html">Mantenimientos</a>
          <a href="reportes.html">Reportes</a>
          <a href="historicos.html">Históricos</a>
        </nav>
      </div>

      <div class="configuracion">
        <nav>
          <h4><a href="#">Perfil</a></h4>
          <h4><a href="#">Cerrar sesión</a></h4>
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
          <img src="../img/mapa.png" alt="Mapa interactivo">
        </div>
      </section>

      <!-- Incidencias -->




    </main>
  </div>
</body>

</html>

