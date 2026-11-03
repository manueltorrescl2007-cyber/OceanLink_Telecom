<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.networkoperator.Segmento" %>
<%@ page import="beans.networkoperator.UtilizacionDiaria" %>
<%
  ArrayList<Segmento> listaSegmentos = (ArrayList<Segmento>) request.getAttribute("listaSegmentos");
  String filtroEstado = (String) request.getAttribute("filtroEstado");
  UtilizacionDiaria fotoHoy = (UtilizacionDiaria) request.getAttribute("fotoHoy");
  UtilizacionDiaria[] semana = (UtilizacionDiaria[]) request.getAttribute("semana");
  String[] fechasSemana = (String[]) request.getAttribute("fechasSemana");
  Integer indiceHoy = (Integer) request.getAttribute("indiceHoy");
  Integer cantSegmentos = (Integer) request.getAttribute("cantSegmentos");
  Integer cantNormal = (Integer) request.getAttribute("cantNormal");
  Integer cantAlta = (Integer) request.getAttribute("cantAlta");
  Integer cantCritica = (Integer) request.getAttribute("cantCritica");

  if (listaSegmentos == null) { listaSegmentos = new ArrayList<>(); }
  if (filtroEstado == null) { filtroEstado = ""; }
  if (fotoHoy == null) { fotoHoy = new UtilizacionDiaria(); }
  if (semana == null) { semana = new UtilizacionDiaria[7]; }
  if (fechasSemana == null) { fechasSemana = new String[]{"", "", "", "", "", "", ""}; }
  if (indiceHoy == null) { indiceHoy = 0; }
  if (cantSegmentos == null) { cantSegmentos = 0; cantNormal = 0; cantAlta = 0; cantCritica = 0; }

  String[] dias = {"Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"};
  String etiquetasJs = "[", ocupadaJs = "[", reservadaJs = "[", disponibleJs = "[";
  String ocupadaGbpsJs = "[", reservadaGbpsJs = "[", disponibleGbpsJs = "[";
  for (int i = 0; i < 7; i++) {
    String coma = (i == 0) ? "" : ", ";
    UtilizacionDiaria d = semana[i];
    etiquetasJs      += coma + "'" + dias[i] + " " + fechasSemana[i] + "'";
    ocupadaJs        += coma + (d == null ? "null" : String.valueOf(d.getPorcentajeOcupada()));
    reservadaJs      += coma + (d == null ? "null" : String.valueOf(d.getPorcentajeReservada()));
    disponibleJs     += coma + (d == null ? "null" : String.valueOf(d.getPorcentajeDisponible()));
    ocupadaGbpsJs    += coma + (d == null ? "null" : String.valueOf(d.getCapacidadOcupada()));
    reservadaGbpsJs  += coma + (d == null ? "null" : String.valueOf(d.getCapacidadReservada()));
    disponibleGbpsJs += coma + (d == null ? "null" : String.valueOf(d.getCapacidadDisponible()));
  }
  etiquetasJs += "]"; ocupadaJs += "]"; reservadaJs += "]"; disponibleJs += "]";
  ocupadaGbpsJs += "]"; reservadaGbpsJs += "]"; disponibleGbpsJs += "]";

  String[] estados = {"Operativo", "Degradado", "En mantenimiento", "Fuera de servicio"};
  String servletEstadoRed = request.getContextPath() + "/EstadoRedServletSuper";
%>

<%@ page import="beans.capacityplanner.Solicitud" %>
<%
  String servletTarjetas = request.getContextPath() + "/TarjetasServletSuper";

  if (request.getAttribute("totalSolicitudes") == null) {
    response.sendRedirect(servletTarjetas);
    return;
  }

  int totalSolicitudes =
    (Integer) request.getAttribute("totalSolicitudes");

  int pendientesEvaluacion =
    (Integer) request.getAttribute("pendientesEvaluacion");

  int solicitudesAprobadas =
    (Integer) request.getAttribute("solicitudesAprobadas");

  int pendientesCapacidad =
    (Integer) request.getAttribute("pendientesCapacidad");

  int serviciosActivos =
    (Integer) request.getAttribute("serviciosActivos");

  int segmentosEstables =
    (Integer) request.getAttribute("segmentosEstables");

  int segmentosLimitados =
    (Integer) request.getAttribute("segmentosLimitados");

  int segmentosCriticos =
    (Integer) request.getAttribute("segmentosCriticos");

  ArrayList<Solicitud> acciones =
    (ArrayList<Solicitud>) request.getAttribute("accionesPendientes");
%>

<!-- Contenido visual -->
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>OceanLink | Dashboard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/capacity_planner/capacity_planner.css">
    <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/network_operator/network_operator.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/barras.css">
</head>

<body>

<!-- Control para abrir/cerrar el menú -->
<input
  type="checkbox"
  id="controlMenu"
  class="control-menu"
  aria-label="Ocultar menú lateral">

<!-- Barra superior -->
<header class="barra-superior">

  <div class="zona-logo">

    <label
            for="controlMenu"
            class="boton-menu"
            title="Ocultar o mostrar menú">☰</label>

    <a href="${pageContext.request.contextPath}/supervisor/supervisor.jsp"
       class="logo">
        OceanLink
    </a>
  </div>

  <div class="usuario">
    <div class="foto-usuario">SU</div>
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

      <nav class="navegacion-lateral"
           aria-label="Menú principal">

        <!-- Dashboard -->
        <a href="${pageContext.request.contextPath}/supervisor/supervisor.jsp">
            Dashboard general
        </a>

        <!-- Incidencias -->
        <div class="grupo-menu">
          <!-- Controla la apertura del submenú -->
          <input
            type="checkbox"
            id="control-incidencias"
            class="control-submenu"
          >
           <!-- Al hacer clic, marca o desmarca el checkbox -->
          <label for="control-incidencias"
                 class="titulo-grupo">
            <span>Incidencias</span>
            <span class="flecha-submenu"></span>
          </label>
          <!-- Opciones que aparecen al desplegar -->
          <div class="contenido-submenu">
            <a href="${pageContext.request.contextPath}/IncidenciaServletSuper"
               class="subopcion">
                Visualizar
            </a>

            <a href="${pageContext.request.contextPath}/IncidenciaServletSuper"
               class="subopcion">
                Historial de incidencias
            </a>
          </div>
        </div>

        <!-- Estado de la red -->
        <div class="grupo-menu">
          <!-- Controla la apertura del submenú -->
          <input
            type="checkbox"
            id="controlEstadoRed"
            class="control-submenu">

          <!-- Al hacer clic, marca o desmarca el checkbox -->
          <label for="controlEstadoRed"
                 class="titulo-grupo">
            <span class="texto-grupo">
                Estado de la red
            </span>
            <span class="flecha-submenu"></span>
          </label>

          <!-- Opciones que aparecen al desplegar -->
          <div class="contenido-submenu">
            <a href="${pageContext.request.contextPath}/TarjetasServletSuper" class="subopcion activo">Capacidad</a>
            <a href="${pageContext.request.contextPath}/RutaServletSuper"
               class="subopcion">
                Rutas
            </a>
            <a href="${pageContext.request.contextPath}/SegmentoServletSuper"
               class="subopcion">
                Segmentos
            </a>
            <a href="${pageContext.request.contextPath}/LandingStationServletSuper"
               class="subopcion">
                Landing stations
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

          <label for="control-servicios-clientes"
                  class="titulo-grupo">
            <span class="texto-grupo">
                Servicios y clientes
            </span>
            <span class="flecha-submenu"></span>
          </label>
          <div class="contenido-submenu">

            <a href="${pageContext.request.contextPath}/supervisor/clientes.jsp"
               class="subopcion">
                Clientes
            </a>

            <a href="${pageContext.request.contextPath}/supervisor/servicios.jsp"
               class="subopcion">
                Servicios
            </a>
            <a
                    href="${pageContext.request.contextPath}/supervisor/solicitudes.jsp"
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
                    href="${pageContext.request.contextPath}/supervisor/programacion.jsp"
                    class="subopcion">
                Programación
            </a>

            <a
                    href="${pageContext.request.contextPath}/supervisor/historial_programados.jsp"
                    class="subopcion">
                Historial de programados
            </a>
          </div>
        </div>
        <!-- Reportes -->
        <a href="${pageContext.request.contextPath}/supervisor/reportes.jsp">
            Reportes
        </a>
        <!-- Históricos -->
        <a href="${pageContext.request.contextPath}/supervisor/historicos.jsp">
            Históricos
        </a>
      </nav>
    </div>
    <!-- parte baja -->
    <div class="configuracion">
      <nav aria-label="Opciones del usuario">
          <a href="#">Perfil</a>
          <a href="${pageContext.request.contextPath}/login.jsp"
             class="cerrar-sesion">
              Cerrar sesión
          </a>
      </nav>
    </div>
  </aside>

  <!-- Contenido principal -->
  <main class="contenido-principal">
    <div class="encabezado-panel">
      <h2>Supervisor</h2>
      <h1>Utilización de la red</h1>
    </div>
    <section class="card">
      <div class="chart-header">
        <h2 class="card-title">Utilización de la red (<%= fotoHoy.getPorcentajeOcupada() %>%)</h2>
        <p class="ayuda">Semana del <%= fechasSemana[0] %> al <%= fechasSemana[6] %> · <%= cantSegmentos %> segmento(s)</p>
      </div>

      <div class="grafico-semana">
        <canvas id="graficoSemana" aria-label="Utilización de la red de lunes a domingo"></canvas>
      </div>
      <noscript><p class="ayuda">Activa JavaScript para ver la gráfica.</p></noscript>

      <ul class="leyenda">
        <li><span class="punto tramo-ocupada"></span>Ocupada hoy: <strong><%= fotoHoy.getCapacidadOcupada() %> Gbps</strong> (<%= fotoHoy.getPorcentajeOcupada() %>%)</li>
        <li><span class="punto tramo-reservada"></span>Reservada: <strong><%= fotoHoy.getCapacidadReservada() %> Gbps</strong> (<%= fotoHoy.getPorcentajeReservada() %>%)</li>
        <li><span class="punto tramo-disponible"></span>Disponible: <strong><%= fotoHoy.getCapacidadDisponible() %> Gbps</strong> (<%= fotoHoy.getPorcentajeDisponible() %>%)</li>
        <li>Capacidad total: <strong><%= fotoHoy.getCapacidadTotal() %> Gbps</strong></li>
      </ul>

      <div class="resumen-niveles">
        <div class="nivel-caja nivel-normal"><strong><%= cantNormal %></strong><span>Normal (&lt; 80%)</span></div>
        <div class="nivel-caja nivel-alta"><strong><%= cantAlta %></strong><span>Alta (80% - 95%)</span></div>
        <div class="nivel-caja nivel-critica"><strong><%= cantCritica %></strong><span>Crítica (&gt; 95%)</span></div>
      </div>
    </section>

    <div class="encabezado-panel">
      <h1>Detalles generales</h1>
    </div>
    <!-- Las tres tarjetas conservan el diseño existente -->
    <section class="tarjetas">

      <!-- Resumen consultado desde MySQL -->
      <article class="tarjeta tarjeta-resumen">
        <h3>Resumen</h3>

        <div class="fila">
          <span>Total de solicitudes</span>
          <strong><%= totalSolicitudes %></strong>
        </div>

        <div class="fila">
          <span>Pendientes de evaluación</span>
          <strong><%= pendientesEvaluacion %></strong>
        </div>

        <div class="fila">
          <span>Solicitudes aprobadas</span>
          <strong><%= solicitudesAprobadas %></strong>
        </div>

        <div class="fila">
          <span>Pendientes por capacidad</span>
          <strong><%= pendientesCapacidad %></strong>
        </div>

        <div class="fila">
          <span>Servicios activos</span>
          <strong><%= serviciosActivos %></strong>
        </div>
      </article>

      <!-- Utilización: ocupada + reservada -->
      <article class="tarjeta tarjeta-segmentos">
        <h3>Estado de segmentos</h3>

        <div class="fila">
          <span><%= segmentosEstables %> estables</span>
          <span class="estado disponible"
                aria-label="Normal"></span>
        </div>

        <div class="fila">
          <span><%= segmentosLimitados %> limitados</span>
          <span class="estado limitada"
                aria-label="Alta utilización"></span>
        </div>

        <div class="fila">
          <span><%= segmentosCriticos %> críticos</span>
          <span class="estado insuficiente"
                aria-label="Utilización crítica"></span>
        </div>

        <div class="fila enlace-segmentos">
          <a href="${pageContext.request.contextPath}/SegmentoServletSuper">
            Ver segmentos →
          </a>
        </div>
      </article>

      <!-- Acciones según el estado de las solicitudes -->
      <article class="tarjeta acciones">
        <div class="encabezado-acciones">
          <h3>Acciones pendientes</h3>
          <span class="cantidad-acciones">
                        <%= acciones.size() %>
                    </span>
        </div>

        <% if (acciones.isEmpty()) { %>
        <p>No hay solicitudes pendientes de atención.</p>
        <% } %>

        <ul class="lista-acciones">
          <% for (Solicitud solicitud : acciones) {
            String accion = "";

            switch (solicitud.getEstado()) {
              case "Registrada":
                accion = "Evaluar solicitud";
                break;
              case "En evaluacion":
                accion = "Revisar capacidad de segmentos";
                break;
              case "Pendiente por capacidad":
                accion = "Revisar alternativas de capacidad";
                break;
              case "Aprobada":
                accion = "Gestionar reserva de capacidad";
                break;
            }
          %>
          <li>
            <div class="informacion-accion">
              <a href="${pageContext.request.contextPath}/SolicitudesServletSuper?id=<%= solicitud.getIdSolicitud() %>">
                <strong>
                  SOL-<%= solicitud.getIdSolicitud() %>
                </strong>
              </a>
              <span><%= accion %></span>
            </div>
          </li>
          <% } %>
        </ul>

        <a href="${pageContext.request.contextPath}/SolicitudesServletSuper"
           class="boton-nuevo">
          Ver solicitudes
        </a>
      </article>

    </section>

  </main>
</div>

<script>
  const etiquetas      = <%= etiquetasJs %>;
  const ocupada        = <%= ocupadaJs %>;
  const reservada      = <%= reservadaJs %>;
  const disponible     = <%= disponibleJs %>;
  const ocupadaGbps    = <%= ocupadaGbpsJs %>;
  const reservadaGbps  = <%= reservadaGbpsJs %>;
  const disponibleGbps = <%= disponibleGbpsJs %>;
  const indiceHoy      = <%= indiceHoy %>;

  const css = getComputedStyle(document.documentElement);
  const colorOcupada   = css.getPropertyValue('--color-primario').trim() || '#0b3d5c';
  const colorReservada = css.getPropertyValue('--color-media').trim()    || '#ecb84a';
  const colorDisponible = '#1c8c9c';

  const radioPuntos = etiquetas.map((e, i) => i === indiceHoy ? 7 : 4);

  function linea(nombre, datos, gbps, color) {
    return {
      label: nombre,
      data: datos,
      gbps: gbps,
      borderColor: color,
      backgroundColor: color,
      pointRadius: radioPuntos,
      tension: 0.3,
      spanGaps: true
    };
  }

  new Chart(document.getElementById('graficoSemana'), {
    type: 'line',
    data: {
      labels: etiquetas,
      datasets: [
        linea('Ocupada', ocupada, ocupadaGbps, colorOcupada),
        linea('Reservada', reservada, reservadaGbps, colorReservada),
        linea('Disponible', disponible, disponibleGbps, colorDisponible)
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      interaction: { mode: 'index', intersect: false },
      scales: {
        y: { min: 0, max: 100, ticks: { callback: valor => valor + '%' } }
      },
      plugins: {
        legend: { position: 'bottom' },
        tooltip: {
          callbacks: {

            label: ctx => ctx.dataset.label + ': ' + ctx.parsed.y + '% ('
              + ctx.dataset.gbps[ctx.dataIndex] + ' Gbps)'
          }
        }
      }
    }
  });
</script>
</body>
</html>
