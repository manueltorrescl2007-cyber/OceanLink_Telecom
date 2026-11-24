<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Locale" %>
<%@ page import="beans.Rol" %>
<%@ page import="beans.Usuario" %>
<%@ page import="beans.admin.DashboardItem" %>
<%
  String servlet = request.getContextPath() + "/DashboardServletAdmin";
  Map<String, Object> resumen = (Map<String, Object>) request.getAttribute("resumen");

  if (resumen == null) {
    response.sendRedirect(servlet);
    return;
  }

  ArrayList<Rol> listaRoles = (ArrayList<Rol>) request.getAttribute("listaRoles");
  ArrayList<Usuario> listaUsuarios = (ArrayList<Usuario>) request.getAttribute("listaUsuarios");
  ArrayList<DashboardItem> topSegmentos = (ArrayList<DashboardItem>) request.getAttribute("topSegmentos");
  ArrayList<DashboardItem> ultimosUsuarios = (ArrayList<DashboardItem>) request.getAttribute("ultimosUsuarios");
  ArrayList<DashboardItem> ultimaInfraestructura = (ArrayList<DashboardItem>) request.getAttribute("ultimaInfraestructura");

  int totalUsuarios = (Integer) resumen.get("totalUsuarios");
  int usuariosActivos = (Integer) resumen.get("usuariosActivos");
  int usuariosInactivos = (Integer) resumen.get("usuariosInactivos");
  int totalRoles = (Integer) resumen.get("totalRoles");

  int totalLandings = (Integer) resumen.get("totalLandings");
  int landingsActivas = (Integer) resumen.get("landingsActivas");
  int landingsInactivas = (Integer) resumen.get("landingsInactivas");

  int totalSegmentos = (Integer) resumen.get("totalSegmentos");
  int segmentosOperativos = (Integer) resumen.get("segmentosOperativos");
  int segmentosNoOperativos = (Integer) resumen.get("segmentosNoOperativos");
  double porcentajeOperativo = (Double) resumen.get("porcentajeOperativo");

  long capacidadTotal = (Long) resumen.get("capacidadTotal");
  long capacidadOcupada = (Long) resumen.get("capacidadOcupada");
  long capacidadReservada = (Long) resumen.get("capacidadReservada");
  long capacidadUsada = capacidadOcupada + capacidadReservada;
  double porcentajeUso = (Double) resumen.get("porcentajeUso");

  String porcentajeUsoTexto = String.format(Locale.US, "%.1f%%", porcentajeUso);
  String porcentajeOpTexto = String.format(Locale.US, "%.1f%%", porcentajeOperativo);
  String claseUtilizacion = porcentajeUso > 95.0 ? "kpi-alerta-critica" : (porcentajeUso >= 80.0 ? "kpi-alerta-alta" : "kpi-alerta-normal");
  boolean redOperativa = segmentosNoOperativos == 0;
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>OceanLink - Dashboard Administrador</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/barras.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin/admin_dashboard.css">
</head>
<body>

<jsp:include page="header.jsp" />

<div class="contenedor">

  <jsp:include page="sidebar.jsp">
    <jsp:param name="activePage" value="dashboard" />
  </jsp:include>

  <main class="contenido-principal">

    <section class="encabezado-panel">
      <h2>Administrador</h2>
      <h1>Dashboard general</h1>
    </section>

    <!-- FILA 1: 5 TARJETAS KPI -->
    <section class="kpi-grid-cinco" aria-label="Indicadores generales de la plataforma">

      <%
        String estadoRed = (String) resumen.get("estadoRed");
        String claseEstadoRed = (String) resumen.get("claseEstadoRed");
      %>
      <article class="kpi-card">
        <span class="kpi-label">Estado de la red</span>
        <strong class="kpi-value kpi-value-estado <%= claseEstadoRed %>">
          <%= estadoRed %>
        </strong>
        <span class="kpi-detail">Segmentos operativos: <%= porcentajeOpTexto %></span>
      </article>

      <article class="kpi-card">
        <span class="kpi-label">Usuarios del sistema</span>
        <strong class="kpi-value"><%= totalUsuarios %></strong>
        <span class="kpi-detail"><%= usuariosActivos %> activos · <%= usuariosInactivos %> inactivos</span>
        <a class="kpi-link" href="${pageContext.request.contextPath}/UsuarioServlet">Gestionar usuarios →</a>
      </article>

      <article class="kpi-card">
        <span class="kpi-label">Landing stations</span>
        <strong class="kpi-value"><%= totalLandings %></strong>
        <span class="kpi-detail"><%= landingsActivas %> activas · <%= landingsInactivas %> inactivas</span>
        <a class="kpi-link" href="${pageContext.request.contextPath}/LandingStationAdminServlet">Ver estaciones →</a>
      </article>

      <article class="kpi-card">
        <span class="kpi-label">Segmentos de fibra</span>
        <strong class="kpi-value"><%= totalSegmentos %></strong>
        <span class="kpi-detail"><%= segmentosOperativos %> operativos · <%= segmentosNoOperativos %> no operativos</span>
        <a class="kpi-link" href="${pageContext.request.contextPath}/SegmentoAdminServlet">Ver segmentos →</a>
      </article>

      <article class="kpi-card">
        <span class="kpi-label">Utilización de la red</span>
        <strong class="kpi-value <%= claseUtilizacion %>"><%= porcentajeUsoTexto %></strong>
        <span class="kpi-detail">Capacidad global plataforma</span>
        <span class="kpi-detail"><%= capacidadUsada %> / <%= capacidadTotal %> Gbps</span>
      </article>

    </section>

    <!-- FILA 2: TOP 5 SEGMENTOS | MAPA TOPOLOGÍA | DISTRIBUCIÓN POR ROL + RESUMEN -->
    <section class="dashboard-grid-tres">

      <!-- Columna izquierda: Estado y capacidad de segmentos (Top 5) -->
      <article class="card">
        <div class="card-header">
          <h2 class="card-title">Estado y capacidad de segmentos (Top 5)</h2>
          <a class="btn-secundario" href="${pageContext.request.contextPath}/SegmentoAdminServlet">Ver detalle</a>
        </div>

        <div class="lista-top-segmentos">
          <% if (topSegmentos == null || topSegmentos.isEmpty()) { %>
          <p class="vacio">No hay segmentos registrados.</p>
          <% } else {
            for (DashboardItem seg : topSegmentos) {
              long capTot = seg.getCapacidadTotal();
              long capEnUso = seg.getCapacidadOcupada() + seg.getCapacidadReservada();
              double pct = capTot > 0 ? (capEnUso * 100.0) / capTot : 0.0;
              long pctRedondeado = Math.round(pct);
              String claseBarra = pct > 95 ? "barra-segmento-critica" : (pct >= 80 ? "barra-segmento-alta" : "");
          %>
          <div class="segmento-top-item">
            <div class="segmento-top-fila">
              <span class="segmento-top-codigo"><%= seg.getCodigo() %></span>
              <span class="segmento-top-cap"><%= capTot %> Gbps</span>
            </div>
            <progress class="barra-segmento <%= claseBarra %>" value="<%= pctRedondeado %>" max="100">
              <%= pctRedondeado %>%
            </progress>
            <div class="segmento-top-subfila">
              <span><%= seg.getTramo() %></span>
              <span><%= pctRedondeado %>%</span>
            </div>
          </div>
          <%   }
          } %>
        </div>
      </article>

      <!-- Columna central: Topología de red submarina -->
      <article class="card">
        <div class="card-header">
          <div class="card-header-texto">
            <h2 class="card-title">Topología de red submarina</h2>
            <p class="card-subtitle">Red de cable submarino en el Pacífico</p>
          </div>
        </div>

        <div class="mapa-contenedor">
          <img src="${pageContext.request.contextPath}/img/mapa_red.svg"
               alt="Mapa de topología de red submarina OceanLink"
               class="mapa-topologia-img">
        </div>
      </article>

      <!-- Columna derecha: Distribución de usuarios por rol + Resumen -->
      <article class="card">
        <div class="card-header">
          <h2 class="card-title">Distribución de usuarios por rol</h2>
          <a class="btn-secundario" href="${pageContext.request.contextPath}/UsuarioServlet">Ver todos</a>
        </div>

        <div class="table-wrapper">
          <table class="data-table data-table-compacta">
            <thead>
            <tr>
              <th>Rol</th>
              <th>Activos</th>
              <th>Inactivos</th>
              <th>Total</th>
            </tr>
            </thead>
            <tbody>
            <% if (listaRoles == null || listaRoles.isEmpty()) { %>
            <tr>
              <td colspan="4" class="vacio">No hay roles registrados.</td>
            </tr>
            <% } else {
              for (Rol rol : listaRoles) {
                int activosRol = 0;
                int inactivosRol = 0;
                if (listaUsuarios != null) {
                  for (Usuario u : listaUsuarios) {
                    if (u.getRol() != null && u.getRol().getIdRol() == rol.getIdRol()) {
                      if ("activo".equalsIgnoreCase(u.getEstado())) {
                        activosRol++;
                      } else {
                        inactivosRol++;
                      }
                    }
                  }
                }
            %>
            <tr>
              <td><%= rol.getNombre() %></td>
              <td><span class="badge badge-activo"><%= activosRol %></span></td>
              <td><span class="badge badge-inactivo"><%= inactivosRol %></span></td>
              <td><strong><%= activosRol + inactivosRol %></strong></td>
            </tr>
            <%     }
            } %>
            </tbody>
          </table>
        </div>

        <div class="resumen-plataforma-lista">
          <h3 class="resumen-plataforma-titulo">Resumen de plataforma</h3>
          <div class="resumen-plataforma-fila">
            <span>Usuarios totales</span>
            <strong><%= totalUsuarios %></strong>
          </div>
          <div class="resumen-plataforma-fila">
            <span>Roles activos</span>
            <strong><%= totalRoles %></strong>
          </div>
          <div class="resumen-plataforma-fila">
            <span>Landing Stations</span>
            <strong><%= totalLandings %></strong>
          </div>
          <div class="resumen-plataforma-fila">
            <span>Segmentos de fibra</span>
            <strong><%= totalSegmentos %></strong>
          </div>
        </div>
      </article>

    </section>

    <!-- FILA 3: ÚLTIMOS USUARIOS REGISTRADOS | INFRAESTRUCTURA - ÚLTIMOS CAMBIOS -->
    <section class="dashboard-grid-dos">

      <article class="card">
        <div class="card-header">
          <h2 class="card-title">Últimos usuarios registrados</h2>
          <a class="btn-secundario" href="${pageContext.request.contextPath}/UsuarioServlet">Ver todos</a>
        </div>

        <div class="table-wrapper">
          <table class="data-table">
            <thead>
            <tr>
              <th>ID</th>
              <th>Nombre</th>
              <th>Correo</th>
              <th>Rol</th>
              <th>Estado</th>
            </tr>
            </thead>
            <tbody>
            <% if (ultimosUsuarios == null || ultimosUsuarios.isEmpty()) { %>
            <tr>
              <td colspan="5" class="vacio">No hay usuarios recientes.</td>
            </tr>
            <% } else {
              for (DashboardItem u : ultimosUsuarios) {
                boolean activo = "activo".equalsIgnoreCase(u.getEstado());
            %>
            <tr>
              <td><%= u.getIdUsuario() %></td>
              <td><strong><%= u.getNombre() %></strong></td>
              <td><%= u.getCorreo() %></td>
              <td><%= u.getRol() %></td>
              <td>
                <span class="badge <%= activo ? "badge-activo" : "badge-inactivo" %>">
                  <%= activo ? "Activo" : "Inactivo" %>
                </span>
              </td>
            </tr>
            <%   }
            } %>
            </tbody>
          </table>
        </div>
      </article>

      <article class="card">
        <div class="card-header">
          <h2 class="card-title">Infraestructura - Últimos cambios</h2>
          <a class="btn-secundario" href="${pageContext.request.contextPath}/LandingStationAdminServlet">Ver todos</a>
        </div>

        <div class="table-wrapper">
          <table class="data-table">
            <thead>
            <tr>
              <th>Estructura</th>
              <th>Tipo</th>
              <th>Detalle</th>
              <th>Estado</th>
            </tr>
            </thead>
            <tbody>
            <% if (ultimaInfraestructura == null || ultimaInfraestructura.isEmpty()) { %>
            <tr>
              <td colspan="4" class="vacio">No hay registros recientes.</td>
            </tr>
            <% } else {
              for (DashboardItem inf : ultimaInfraestructura) {
                boolean ok = "Operativo".equalsIgnoreCase(inf.getEstado()) || "Activa".equalsIgnoreCase(inf.getEstado());
            %>
            <tr>
              <td><strong><%= inf.getEstructura() %></strong></td>
              <td><%= inf.getTipo() %></td>
              <td><%= inf.getDetalle() %></td>
              <td>
                <span class="badge <%= ok ? "badge-operativo" : "badge-alerta" %>">
                  <%= inf.getEstado() %>
                </span>
              </td>
            </tr>
            <%   }
            } %>
            </tbody>
          </table>
        </div>
      </article>

    </section>

  </main>
</div>

</body>
</html>
