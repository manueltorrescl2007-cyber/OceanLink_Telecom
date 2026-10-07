<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>OceanLink - INC-014</title>
  <link rel="stylesheet" href="../css/style.css">
</head>
<body>

<div class="contenedor">

<!-- Estructura de la barra lateral -->
  <jsp:include page="slidebar_netoperator.jsp" />

  <!-- ===== CONTENIDO PRINCIPAL ===== -->
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
