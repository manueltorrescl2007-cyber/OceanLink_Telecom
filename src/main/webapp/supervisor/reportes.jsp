<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="beans.supervisor.ReporteSupervisor" %>

<%
  List<String> listaSegmentos = (List<String>) request.getAttribute("listaSegmentos");
  if (listaSegmentos == null) listaSegmentos = new ArrayList<>();

  List<String> listaClientes = (List<String>) request.getAttribute("listaClientes");
  if (listaClientes == null) listaClientes = new ArrayList<>();

  String[] encabezados = (String[]) request.getAttribute("encabezados");
  if (encabezados == null) {
    encabezados = new String[]{"Código", "Origen -> Destino", "Cap. Total", "Ocupada / Reservada", "Disponible (% Uso)", "Estado"};
  }

  List<ReporteSupervisor> listaReporte = (List<ReporteSupervisor>) request.getAttribute("listaReporte");
  if (listaReporte == null) listaReporte = new ArrayList<>();

  String tipoSeleccionado = (String) request.getAttribute("tipoSeleccionado");
  if (tipoSeleccionado == null || tipoSeleccionado.isEmpty()) tipoSeleccionado = "capacidad";

  String desdeSeleccionado = (String) request.getAttribute("desdeSeleccionado");
  if (desdeSeleccionado == null) desdeSeleccionado = "";

  String hastaSeleccionado = (String) request.getAttribute("hastaSeleccionado");
  if (hastaSeleccionado == null) hastaSeleccionado = "";

  String segmentoSeleccionado = (String) request.getAttribute("segmentoSeleccionado");
  if (segmentoSeleccionado == null || segmentoSeleccionado.isEmpty()) segmentoSeleccionado = "Todos";

  String clienteSeleccionado = (String) request.getAttribute("clienteSeleccionado");
  if (clienteSeleccionado == null || clienteSeleccionado.isEmpty()) clienteSeleccionado = "Todos";

  String severidadSeleccionada = (String) request.getAttribute("severidadSeleccionada");
  if (severidadSeleccionada == null || severidadSeleccionada.isEmpty()) severidadSeleccionada = "Todas";

  String estadoSeleccionado = (String) request.getAttribute("estadoSeleccionado");
  if (estadoSeleccionado == null || estadoSeleccionado.isEmpty()) estadoSeleccionado = "Todos";

  // Construcción de URLs para Vista Previa y Descarga del PDF
  String paramsPdf = "tipo=" + URLEncoder.encode(tipoSeleccionado, StandardCharsets.UTF_8)
    + "&desde=" + URLEncoder.encode(desdeSeleccionado, StandardCharsets.UTF_8)
    + "&hasta=" + URLEncoder.encode(hastaSeleccionado, StandardCharsets.UTF_8)
    + "&segmento=" + URLEncoder.encode(segmentoSeleccionado, StandardCharsets.UTF_8)
    + "&cliente=" + URLEncoder.encode(clienteSeleccionado, StandardCharsets.UTF_8)
    + "&severidad=" + URLEncoder.encode(severidadSeleccionada, StandardCharsets.UTF_8)
    + "&estado=" + URLEncoder.encode(estadoSeleccionado, StandardCharsets.UTF_8);

  String urlPdfVista = request.getContextPath() + "/PdfReporteServletSuper?" + paramsPdf;
  String urlPdfDescarga = request.getContextPath() + "/PdfReporteServletSuper?" + paramsPdf + "&descargar=si";
%>

<!doctype html>
<html lang="es">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <title>OceanLink | Reportes</title>

  <link rel="stylesheet"
        href="<%= request.getContextPath() %>/css/supervisor/reportes.css?v=6">
  <link rel="stylesheet"
        href="<%= request.getContextPath() %>/css/barras.css">
</head>

<body>
<jsp:include page="header.jsp" />

<div class="contenedor">

  <aside class="menu-lateral">
    <div class="contenido-menu">
      <h2>Menú</h2>
      <nav class="navegacion-lateral" aria-label="Menú principal">

        <a href="<%= request.getContextPath() %>/DashboardServletSuper">Dashboard general</a>

        <div class="grupo-menu">
          <input type="checkbox" id="control-incidencias" class="control-submenu">
          <label for="control-incidencias" class="titulo-grupo">
            <span>Incidencias</span>
            <span class="flecha-submenu"></span>
          </label>
          <div class="contenido-submenu">
            <a href="<%= request.getContextPath() %>/IncidenciaServletSuper" class="subopcion">Visualizar</a>
            <a href="<%= request.getContextPath() %>/IncidenciaServletSuper?action=historial" class="subopcion">Historial de incidencias</a>
          </div>
        </div>

        <div class="grupo-menu">
          <input type="checkbox" id="controlEstadoRed" class="control-submenu">
          <label for="controlEstadoRed" class="titulo-grupo">
            <span class="texto-grupo">Estado de la red</span>
            <span class="flecha-submenu"></span>
          </label>
          <div class="contenido-submenu">
            <a href="<%= request.getContextPath() %>/TarjetasServletSuper" class="subopcion">Capacidad</a>
            <a href="<%= request.getContextPath() %>/RutaServletSuper" class="subopcion">Rutas</a>
            <a href="<%= request.getContextPath() %>/SegmentoServletSuper" class="subopcion">Segmentos</a>
            <a href="<%= request.getContextPath() %>/LandingStationServletSuper" class="subopcion">Landing stations</a>
          </div>
        </div>

        <div class="grupo-menu">
          <input type="checkbox" id="control-servicios-clientes" class="control-submenu">
          <label for="control-servicios-clientes" class="titulo-grupo">
            <span class="texto-grupo">Servicios y clientes</span>
            <span class="flecha-submenu"></span>
          </label>
          <div class="contenido-submenu">
            <a href="<%= request.getContextPath() %>/ClienteServletSuper" class="subopcion">Clientes</a>
            <a href="<%= request.getContextPath() %>/ServicioServletSuper" class="subopcion">Servicios</a>
            <a href="<%= request.getContextPath() %>/SolicitudesServletSuper" class="subopcion">Solicitudes</a>
          </div>
        </div>

        <div class="grupo-menu">
          <input type="checkbox" id="control-mantenimientos" class="control-submenu">
          <label for="control-mantenimientos" class="titulo-grupo">
            <span class="texto-grupo">Mantenimientos</span>
            <span class="flecha-submenu"></span>
          </label>
          <div class="contenido-submenu">
            <a href="<%= request.getContextPath() %>/MantenimientoServletSuper?accion=listar" class="subopcion">Programación</a>
            <a href="<%= request.getContextPath() %>/MantenimientoServletSuper?accion=historial" class="subopcion">Historial de mantenimientos</a>
          </div>
        </div>

        <a href="<%= request.getContextPath() %>/ReporteServletSuper" class="activo">Reportes</a>
        <a href="<%= request.getContextPath() %>/HistoricoServletSuper">Históricos</a>
      </nav>
    </div>

    <div class="configuracion">
      <nav aria-label="Opciones del usuario">
        <a href="#">Perfil</a>
        <a href="<%= request.getContextPath() %>/login.jsp" class="cerrar-sesion">Cerrar sesión</a>
      </nav>
    </div>
  </aside>

  <main class="contenido-principal">

    <section class="encabezado-panel">
      <h2>Supervisor</h2>
      <h1>Reportes</h1>
    </section>

    <section class="cuadricula-reportes">

      <!-- Panel izquierdo: Filtros adaptativos -->
      <article class="panel panel-generador">
        <div class="titulo-panel">
          <div>
            <h2>Configurar reporte</h2>
            <p>Los filtros se adaptan automáticamente al reporte elegido.</p>
          </div>
        </div>

        <form id="formReporte" method="get" action="<%= request.getContextPath() %>/ReporteServletSuper">

          <div class="grupo-formulario">
            <label for="tipo">Tipo de reporte</label>
            <select id="tipo" name="tipo" onchange="cambiarTipoReporte()">
              <option value="capacidad" <%= "capacidad".equals(tipoSeleccionado) ? "selected" : "" %>>
                Estado y Capacidad de Segmentos
              </option>
              <option value="incidencias" <%= "incidencias".equals(tipoSeleccionado) ? "selected" : "" %>>
                Incidencias de Red
              </option>
              <option value="mantenimientos" <%= "mantenimientos".equals(tipoSeleccionado) ? "selected" : "" %>>
                Mantenimientos Programados y Ejecutados
              </option>
              <option value="clientes_servicios" <%= "clientes_servicios".equals(tipoSeleccionado) ? "selected" : "" %>>
                Clientes, Solicitudes y Servicios
              </option>
              <option value="consolidado" <%= "consolidado".equals(tipoSeleccionado) ? "selected" : "" %>>
                Resumen Ejecutivo Consolidado
              </option>
            </select>
          </div>

          <!-- Filtro Periodo -->
          <div id="bloquePeriodo">
            <p class="titulo-campo">Periodo (Opcional)</p>
            <div class="fila-formulario">
              <div class="grupo-formulario">
                <label for="desde">Desde</label>
                <input type="date" id="desde" name="desde" value="<%= desdeSeleccionado %>">
              </div>
              <div class="grupo-formulario">
                <label for="hasta">Hasta</label>
                <input type="date" id="hasta" name="hasta" value="<%= hastaSeleccionado %>">
              </div>
            </div>
          </div>

          <!-- Filtro Segmento -->
          <div id="bloqueSegmento" class="grupo-formulario">
            <label for="segmento">Segmento</label>
            <select id="segmento" name="segmento">
              <option value="Todos" <%= "Todos".equals(segmentoSeleccionado) ? "selected" : "" %>>Todos los segmentos</option>
              <%
                for (int i = 0; i < listaSegmentos.size(); i++) {
                  String seg = listaSegmentos.get(i);
              %>
              <option value="<%= seg %>" <%= seg.equals(segmentoSeleccionado) ? "selected" : "" %>><%= seg %></option>
              <%
                }
              %>
            </select>
          </div>

          <!-- Filtro Cliente -->
          <div id="bloqueCliente" class="grupo-formulario">
            <label for="cliente">Cliente empresarial</label>
            <select id="cliente" name="cliente">
              <option value="Todos" <%= "Todos".equals(clienteSeleccionado) ? "selected" : "" %>>Todos los clientes</option>
              <%
                for (int i = 0; i < listaClientes.size(); i++) {
                  String cli = listaClientes.get(i);
              %>
              <option value="<%= cli %>" <%= cli.equals(clienteSeleccionado) ? "selected" : "" %>><%= cli %></option>
              <%
                }
              %>
            </select>
          </div>

          <!-- Filtro Severidad / Prioridad -->
          <fieldset id="bloqueSeveridad" class="grupo-opciones">
            <legend>Severidad / Prioridad</legend>
            <div class="lista-opciones severidades">
              <label class="opcion">
                <input type="radio" name="severidad" value="Todas" <%= "Todas".equals(severidadSeleccionada) ? "checked" : "" %>>
                <span>Todas</span>
              </label>
              <label class="opcion">
                <input type="radio" name="severidad" value="Critica" <%= "Critica".equals(severidadSeleccionada) ? "checked" : "" %>>
                <span>Crítica</span>
              </label>
              <label class="opcion">
                <input type="radio" name="severidad" value="Alta" <%= "Alta".equals(severidadSeleccionada) ? "checked" : "" %>>
                <span>Alta</span>
              </label>
              <label class="opcion">
                <input type="radio" name="severidad" value="Media" <%= "Media".equals(severidadSeleccionada) ? "checked" : "" %>>
                <span>Media</span>
              </label>
              <label class="opcion">
                <input type="radio" name="severidad" value="Leve" <%= "Leve".equals(severidadSeleccionada) ? "checked" : "" %>>
                <span>Leve</span>
              </label>
            </div>
          </fieldset>

          <!-- Filtro Estado -->
          <div id="bloqueEstado" class="grupo-formulario">
            <label for="estado">Estado</label>
            <select id="estado" name="estado" data-valor-actual="<%= estadoSeleccionado %>">
              <option value="Todos">Todos los estados</option>
            </select>
          </div>

          <p id="notaConsolidado" class="nota-consolidado">
            Este reporte consolida en tiempo real los indicadores globales de toda la red OceanLink (sin filtros adicionales).
          </p>

          <button type="submit" class="boton-generar">Filtrar y actualizar vista</button>
        </form>
      </article>

      <!-- Panel derecho: Vista previa en tabla + Exportación PDF -->
      <article class="panel panel-generados">
        <div class="titulo-panel">
          <div>
            <h2>Resultados del reporte</h2>
            <p>Vista previa de los datos filtrados listos para exportar.</p>
          </div>
          <span class="cantidad-reportes"><%= listaReporte.size() %></span>
        </div>

        <div class="acciones-reporte acciones-pdf">
          <a class="boton-accion" href="<%= urlPdfVista %>" target="_blank">Vista previa PDF</a>
          <a class="boton-accion" href="<%= urlPdfDescarga %>">Descargar PDF</a>
        </div>

        <div class="tabla-reporte-wrapper">
          <table class="tabla-reporte">
            <thead>
            <tr>
              <%
                for (int i = 0; i < encabezados.length; i++) {
              %>
              <th><%= encabezados[i] %></th>
              <%
                }
              %>
            </tr>
            </thead>
            <tbody>
            <%
              if (listaReporte.isEmpty()) {
            %>
            <tr>
              <td colspan="6" class="celda-vacia">
                No hay registros para los filtros seleccionados.
              </td>
            </tr>
            <%
            } else {
              for (int i = 0; i < listaReporte.size(); i++) {
                ReporteSupervisor fila = listaReporte.get(i);
            %>
            <tr>
              <td class="celda-destacada"><%= fila.getCol1() %></td>
              <td><%= fila.getCol2() %></td>
              <td><%= fila.getCol3() %></td>
              <td><%= fila.getCol4() %></td>
              <td><%= fila.getCol5() %></td>
              <td><%= fila.getCol6() %></td>
            </tr>
            <%
                }
              }
            %>
            </tbody>
          </table>
        </div>

      </article>

    </section>

  </main>

</div>

<script>
  const ESTADOS_POR_TIPO = {
    capacidad: ["Operativo", "Degradado", "En mantenimiento", "Fuera de servicio"],
    incidencias: ["Detectada", "En analisis", "Reparacion programada", "En reparacion", "Servicio restaurado", "Cerrada"],
    mantenimientos: ["Programado", "En ejecucion", "Finalizado", "Cancelado"],
    clientes_servicios: ["Registrada", "En evaluacion", "Aprobada", "Provisionada", "Activa", "Pendiente por capacidad", "Rechazada"],
    consolidado: []
  };

  function actualizarVisibilidadFiltros(mantenerValores) {
    const tipo = document.getElementById("tipo").value;
    const bloquePeriodo = document.getElementById("bloquePeriodo");
    const bloqueSegmento = document.getElementById("bloqueSegmento");
    const bloqueCliente = document.getElementById("bloqueCliente");
    const bloqueSeveridad = document.getElementById("bloqueSeveridad");
    const bloqueEstado = document.getElementById("bloqueEstado");
    const notaConsolidado = document.getElementById("notaConsolidado");
    const selectEstado = document.getElementById("estado");

    bloquePeriodo.style.display = (tipo === "capacidad" || tipo === "consolidado") ? "none" : "block";
    bloqueSegmento.style.display = (tipo === "capacidad" || tipo === "incidencias" || tipo === "mantenimientos") ? "block" : "none";
    bloqueCliente.style.display = (tipo === "clientes_servicios") ? "block" : "none";
    bloqueSeveridad.style.display = (tipo === "incidencias" || tipo === "mantenimientos") ? "block" : "none";
    bloqueEstado.style.display = (tipo === "consolidado") ? "none" : "block";
    notaConsolidado.style.display = (tipo === "consolidado") ? "block" : "none";

    const valorPrevio = mantenerValores ? selectEstado.getAttribute("data-valor-actual") : "Todos";
    selectEstado.innerHTML = '<option value="Todos">Todos los estados</option>';
    (ESTADOS_POR_TIPO[tipo] || []).forEach(est => {
      const opt = document.createElement("option");
      opt.value = est;
      opt.textContent = est;
      if (est === valorPrevio) opt.selected = true;
      selectEstado.appendChild(opt);
    });
  }

  function cambiarTipoReporte() {
    document.getElementById("desde").value = "";
    document.getElementById("hasta").value = "";
    document.getElementById("segmento").value = "Todos";
    document.getElementById("cliente").value = "Todos";
    const radioTodas = document.querySelector('input[name="severidad"][value="Todas"]');
    if (radioTodas) radioTodas.checked = true;
    actualizarVisibilidadFiltros(false);
    document.getElementById("formReporte").submit();
  }

  document.addEventListener("DOMContentLoaded", function () {
    actualizarVisibilidadFiltros(true);
  });
</script>

</body>
</html>
