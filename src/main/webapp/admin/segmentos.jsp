<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="beans.capacityplanner.Segmento" %>
<%!
  private String texto(String valor) {
    if (valor == null) return "";

    return valor.replace("&", "&amp;")
      .replace("<", "&lt;")
      .replace(">", "&gt;")
      .replace("\"", "&quot;")
      .replace("'", "&#39;");
  }
%>
<%
  String servlet = request.getContextPath() + "/SegmentoAdminServlet";

  ArrayList<Segmento> segmentos =
    (ArrayList<Segmento>) request.getAttribute("listaSegmentos");

  if (segmentos == null) {
    response.sendRedirect(servlet);
    return;
  }

  String[] estados = {"Operativo", "Degradado", "En mantenimiento", "Fuera de servicio"};

  String filtro = (String) request.getAttribute("filtroEstado");
  if (filtro == null) filtro = "";
  boolean hayFiltro = !filtro.isEmpty();

  int paginaActual = request.getAttribute("paginaActual") != null
    ? (Integer) request.getAttribute("paginaActual") : 1;
  int totalPaginas = request.getAttribute("totalPaginas") != null
    ? (Integer) request.getAttribute("totalPaginas") : 1;
  int totalRegistros = request.getAttribute("totalRegistros") != null
    ? (Integer) request.getAttribute("totalRegistros") : segmentos.size();
  int registroInicio = request.getAttribute("registroInicio") != null
    ? (Integer) request.getAttribute("registroInicio") : (segmentos.isEmpty() ? 0 : 1);
  int registroFin = request.getAttribute("registroFin") != null
    ? (Integer) request.getAttribute("registroFin") : segmentos.size();

  String filtroUrl = URLEncoder.encode(filtro, StandardCharsets.UTF_8);
  String urlBase = servlet + "?estado=" + filtroUrl;
  String urlLista = urlBase + "&pagina=" + paginaActual;
  String msg = request.getParameter("msg");
%>
<%
  String nombreUsuarioSesion = (String) session.getAttribute("nombreUsuario");
  if (nombreUsuarioSesion == null || nombreUsuarioSesion.isBlank()) {
    nombreUsuarioSesion = "<%= nombreUsuarioSesion %>";
  }
  String iniciales = nombreUsuarioSesion.length() >= 2
    ? nombreUsuarioSesion.substring(0, 2).toUpperCase()
    : "AD";
%>
<!doctype html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Segmentos | OceanLink</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/barras.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin/segmentos.css">
</head>
<body>

<jsp:include page="header.jsp" />

<div class="contenedor">

  <jsp:include page="sidebar.jsp">
    <jsp:param name="activePage" value="segmentos" />
  </jsp:include>

  <main class="contenido-principal pagina-segmentos">
    <section class="encabezado-pagina">
      <div class="encabezado-panel">
        <h2>Administrador</h2>
        <h1>Segmentos</h1>
      </div>
      <a href="<%= servlet %>?action=formCrear&estado=<%= filtroUrl %>&pagina=<%= paginaActual %>" class="boton primario">
        + Nuevo segmento
      </a>
    </section>

    <% if ("guardado".equals(msg)) { %>
    <p class="mensaje-exito" role="status">Segmento guardado correctamente.</p>
    <% } else if ("eliminado".equals(msg)) { %>
    <p class="mensaje-exito" role="status">Segmento eliminado correctamente.</p>
    <% } else if ("asociado".equals(msg)) { %>
    <p class="mensaje-error" role="alert">El segmento está asociado a rutas, incidencias o mantenimientos y no se puede eliminar.</p>
    <% } else if ("noDisponible".equals(msg)) { %>
    <p class="mensaje-error" role="alert">El segmento ya no existe o tiene capacidad ocupada o reservada.</p>
    <% } %>

    <div class="barra-herramientas">
      <form action="<%= servlet %>" method="get" class="formulario-filtro">
        <label for="filtroEstado">Estado:</label>
        <select id="filtroEstado" name="estado">
          <option value="">Todos</option>
          <% for (String estado : estados) { %>
          <option value="<%= estado %>" <%= estado.equals(filtro) ? "selected" : "" %>><%= estado %></option>
          <% } %>
        </select>
        <button class="boton secundario" type="submit">Filtrar</button>
        <% if (hayFiltro) { %>
        <a href="<%= servlet %>" class="boton secundario">Limpiar</a>
        <% } %>
      </form>
      <span><%= totalRegistros %> segmentos</span>
    </div>

    <section class="contenedor-tabla">
      <table>
        <thead>
        <tr>
          <th>Código</th>
          <th>Inicio</th>
          <th>Final</th>
          <th>Total</th>
          <th>Ocupada</th>
          <th>Reservada</th>
          <th>Disponible</th>
          <th>Estado</th>
          <th>Acciones</th>
        </tr>
        </thead>
        <tbody>
        <% for (Segmento segmento : segmentos) {
          long total = segmento.getCapacidadTotal();
          long ocupada = segmento.getCapacidadOcupada();
          boolean critica = total > 0 && ocupada * 100 > total * 95;
          boolean alta = total > 0 && ocupada * 100 >= total * 80;

          String clase = "fuera";
          if ("Operativo".equals(segmento.getEstado())) {
            clase = "operativo";
          } else if ("Degradado".equals(segmento.getEstado())) {
            clase = "degradado";
          } else if ("En mantenimiento".equals(segmento.getEstado())) {
            clase = "mantenimiento";
          }
        %>
        <tr>
          <td>
            <a class="enlace-segmento"
               href="<%= urlLista %>&detalle=<%= segmento.getIdSegmento() %>#detalle">
              <%= texto(segmento.getCodigo()) %>
            </a>
          </td>
          <td><%= texto(segmento.getNombreInicial()) %></td>
          <td><%= texto(segmento.getNombreFinal()) %></td>
          <td><%= segmento.getCapacidadTotal() %> Gbps</td>
          <td>
            <%= ocupada %> Gbps
            <% if (alta) { %>
            <span class="estado <%= critica ? "fuera" : "degradado" %>">
                                        <%= critica ? "Utilización crítica" : "Alta utilización" %>
                                    </span>
            <% } %>
          </td>
          <td><%= segmento.getCapacidadReservada() %> Gbps</td>
          <td><strong><%= segmento.getCapacidadDisponible() %> Gbps</strong></td>
          <td>
                                <span class="estado <%= clase %>">
                                    <%= texto(segmento.getEstado()) %>
                                </span>
          </td>
          <td>
            <div class="acciones-tabla">
              <a href="<%= servlet %>?action=editar&id=<%= segmento.getIdSegmento() %>&estado=<%= filtroUrl %>&pagina=<%= paginaActual %>">
                Editar
              </a>
              <a href="<%= servlet %>?action=eliminar&id=<%= segmento.getIdSegmento() %>&estado=<%= filtroUrl %>&pagina=<%= paginaActual %>"
                 class="accion-peligro"
                 onclick="return confirm('¿Eliminar este segmento de forma permanente?');">
                Eliminar
              </a>
            </div>
          </td>
        </tr>
        <% } %>

        <% if (segmentos.isEmpty()) { %>
        <tr>
          <td colspan="9" class="celda-vacia">
            <%= hayFiltro ? "No hay segmentos con este estado." : "No hay segmentos registrados." %>
          </td>
        </tr>
        <% } %>
        </tbody>
      </table>
    </section>

    <% if (totalRegistros > 0) { %>
    <nav class="pagination-bar" aria-label="Paginación de segmentos">
            <span class="pagination-info">
                Mostrando <%= registroInicio %>–<%= registroFin %> de <%= totalRegistros %> registros (Página <%= paginaActual %> de <%= totalPaginas %>)
            </span>

      <% if (totalPaginas > 1) { %>
      <div class="pagination-links">
        <% if (paginaActual > 1) { %>
        <a href="<%= urlBase %>&pagina=<%= paginaActual - 1 %>" class="boton secundario">Anterior</a>
        <% } %>

        <% for (int p = 1; p <= totalPaginas; p++) {
          boolean esActual = (p == paginaActual); %>
        <a href="<%= urlBase %>&pagina=<%= p %>"
           class="boton <%= esActual ? "primario" : "secundario" %>">
          <%= p %>
        </a>
        <% } %>

        <% if (paginaActual < totalPaginas) { %>
        <a href="<%= urlBase %>&pagina=<%= paginaActual + 1 %>" class="boton secundario">Siguiente</a>
        <% } %>
      </div>
      <% } %>
    </nav>
    <% } %>

    <% Segmento segmento = (Segmento) request.getAttribute("segmentoDetalle");
      if (segmento != null) { %>
    <section class="panel-detalle" id="detalle">
      <div class="encabezado-detalle">
        <h2><%= texto(segmento.getCodigo()) %></h2>
        <a href="<%= urlLista %>" aria-label="Cerrar detalle">×</a>
      </div>

      <div class="datos-detalle">
        <div>
          <span>ID del segmento</span>
          <strong><%= segmento.getIdSegmento() %></strong>
        </div>
        <div>
          <span>Estación inicial</span>
          <strong><%= texto(segmento.getNombreInicial()) %></strong>
        </div>
        <div>
          <span>Estación final</span>
          <strong><%= texto(segmento.getNombreFinal()) %></strong>
        </div>
        <div>
          <span>Estado</span>
          <strong><%= texto(segmento.getEstado()) %></strong>
        </div>
        <div>
          <span>Total</span>
          <strong><%= segmento.getCapacidadTotal() %> Gbps</strong>
        </div>
        <div>
          <span>Ocupada</span>
          <strong><%= segmento.getCapacidadOcupada() %> Gbps</strong>
        </div>
        <div>
          <span>Reservada</span>
          <strong><%= segmento.getCapacidadReservada() %> Gbps</strong>
        </div>
        <div>
          <span>Disponible</span>
          <strong><%= segmento.getCapacidadDisponible() %> Gbps</strong>
        </div>
      </div>

      <p class="ayuda">
        Disponible = total − ocupada − reservada.
        El estado operativo es un dato diferente de la capacidad.
      </p>

      <div class="acciones">
        <a href="<%= servlet %>?action=editar&id=<%= segmento.getIdSegmento() %>&estado=<%= filtroUrl %>&pagina=<%= paginaActual %>"
           class="boton primario">
          Editar segmento
        </a>
      </div>
    </section>
    <% } %>
  </main>
</div>

</body>
</html>
