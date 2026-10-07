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
      <p class="migas">Incidencias / Visualizar / INC-014</p>

      <div class="titulo-incidencia">
        <h3>INC-014</h3>
        <span class="badge severidad-alta">Alta</span>
      </div>

      <!-- Stepper: 6 pasos en fila, gracias a display:flex -->
      <div class="stepper">
        <div class="paso completado">
          <div class="circulo">&#10003;</div>
          <p>Detectada</p>
        </div>
        <div class="paso actual">
          <div class="circulo">2</div>
          <p>En análisis</p>
        </div>
        <div class="paso">
          <div class="circulo">3</div>
          <p>Rep. prog.</p>
        </div>
        <div class="paso">
          <div class="circulo">4</div>
          <p>En rep.</p>
        </div>
        <div class="paso">
          <div class="circulo">5</div>
          <p>Restaurado</p>
        </div>
        <div class="paso">
          <div class="circulo">6</div>
          <p>Cerrada</p>
        </div>
      </div>

      <!-- Dos columnas repartidas al 50% con flex -->
      <div class="dos-columnas">
        <div class="columna">
          <h4>Servicios y clientes afectados</h4>
          <div class="tarjeta">
            <span>SRV-118</span>
            <span>Cliente XXYY</span>
          </div>
          <div class="tarjeta">
            <span>SRV-121</span>
            <span>Cliente ZZUU</span>
          </div>
        </div>

        <div class="columna">
          <h4>Bitácora</h4>
          <div class="registro">
            <strong>10:32 - J. Ramos</strong>
            <p>Caída de fibra óptica detectada.</p>
          </div>
          <input type="text" placeholder="Agregar observación...">
        </div>
      </div>
    </section>
  </main>

</div>

</body>
</html>
