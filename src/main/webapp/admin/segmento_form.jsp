<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="beans.capacityplanner.LandingStation" %>
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
  String filtro = (String) request.getAttribute("filtroEstado");
  if (filtro == null) filtro = "";
  Integer pagina = (Integer) request.getAttribute("paginaActual");
  if (pagina == null) {
    response.sendRedirect(servlet + "?action=formCrear");
    return;
  }

  String urlLista = servlet + "?estado=" + URLEncoder.encode(filtro, StandardCharsets.UTF_8) + "&pagina=" + pagina;
  ArrayList<LandingStation> estaciones =
    (ArrayList<LandingStation>) request.getAttribute("listaEstaciones");
  String error = (String) request.getAttribute("error");

  Segmento segmento = (Segmento) request.getAttribute("segmento");
  boolean esEdicion = (segmento != null && segmento.getIdSegmento() > 0);

  String idSegmento = esEdicion ? String.valueOf(segmento.getIdSegmento()) : "";
  int idInicial = segmento != null ? segmento.getIdLandingInicial() : -1;
  int idFinal   = segmento != null ? segmento.getIdLandingFinal() : -1;
  long total    = (segmento != null && segmento.getCapacidadTotal() > 0) ? segmento.getCapacidadTotal() : 100;
  String estadoActual = (segmento != null && segmento.getEstado() != null && !segmento.getEstado().isEmpty())
    ? segmento.getEstado() : "Operativo";

  String[] estados = {"Operativo", "Degradado", "En mantenimiento", "Fuera de servicio"};
%>
<%
  String nombreUsuarioSesion = (String) session.getAttribute("nombreUsuario");
  if (nombreUsuarioSesion == null || nombreUsuarioSesion.isBlank()) {
    nombreUsuarioSesion = "Administrador";
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
  <title><%= esEdicion ? "Editar segmento" : "Nuevo segmento" %> | OceanLink</title>
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
        <h2>Segmentos</h2>
        <h1><%= esEdicion ? "Editar segmento" : "Nuevo segmento" %></h1>
      </div>
    </section>

    <section class="panel-detalle formulario-segmento" aria-label="<%= esEdicion ? "Editar segmento" : "Nuevo segmento" %>">
      <% if (error != null && !error.isEmpty()) { %>
      <p class="mensaje-error" role="alert"><%= texto(error) %></p>
      <% } %>
      <form action="<%= servlet %>" method="post">
        <input type="hidden" name="action" value="guardar">
        <input type="hidden" name="idSegmento" value="<%= idSegmento %>">
        <input type="hidden" name="estado" value="<%= texto(filtro) %>">
        <input type="hidden" name="pagina" value="<%= pagina %>">

        <% if (esEdicion && segmento.getCodigo() != null) { %>
        <div class="grupo-formulario">
          <label for="codigoActual">Código actual</label>
          <input id="codigoActual" type="text" value="<%= texto(segmento.getCodigo()) %>" readonly>
        </div>

        <div class="grupo-formulario">
          <label for="capacidadComprometida">Ocupada + Reservada</label>
          <input id="capacidadComprometida" type="text"
                 value="<%= segmento.getCapacidadOcupada() + segmento.getCapacidadReservada() %> Gbps" readonly>
        </div>
        <% } %>

        <div class="grupo-formulario">
          <label for="idLandingInicial">Estación inicial</label>
          <select id="idLandingInicial" name="idLandingInicial" required>
            <option value="" disabled <%= idInicial <= 0 ? "selected" : "" %>>Selecciona una estación</option>
            <% if (estaciones != null) {
              for (LandingStation estacion : estaciones) { %>
            <option value="<%= estacion.getIdLanding() %>" <%= estacion.getIdLanding() == idInicial ? "selected" : "" %>>
              <%= texto(estacion.getNombre()) %> (<%= texto(estacion.getPais()) %>)
            </option>
            <%  }
            } %>
          </select>
        </div>

        <div class="grupo-formulario">
          <label for="idLandingFinal">Estación final</label>
          <select id="idLandingFinal" name="idLandingFinal" required>
            <option value="" disabled <%= idFinal <= 0 ? "selected" : "" %>>Selecciona una estación</option>
            <% if (estaciones != null) {
              for (LandingStation estacion : estaciones) { %>
            <option value="<%= estacion.getIdLanding() %>" <%= estacion.getIdLanding() == idFinal ? "selected" : "" %>>
              <%= texto(estacion.getNombre()) %> (<%= texto(estacion.getPais()) %>)
            </option>
            <%  }
            } %>
          </select>
        </div>

        <div class="grupo-formulario">
          <label for="capacidadTotal">Capacidad total (Gbps)</label>
          <input id="capacidadTotal" name="capacidadTotal" type="number"
                 min="1" max="4294967295" step="1"
                 value="<%= total %>" required>
        </div>

        <div class="grupo-formulario">
          <label for="estadoSegmento">Estado</label>
          <select id="estadoSegmento" name="estadoSegmento" required>
            <% for (String estado : estados) { %>
            <option value="<%= estado %>" <%= estado.equals(estadoActual) ? "selected" : "" %>><%= estado %></option>
            <% } %>
          </select>
        </div>

        <p class="ayuda">El código se genera o actualiza automáticamente al guardar según las dos estaciones elegidas.</p>

        <div class="acciones">
          <a href="<%= urlLista %>" class="boton secundario">Cancelar</a>
          <button type="submit" class="boton primario">
            <%= esEdicion ? "Guardar cambios" : "Guardar" %>
          </button>
        </div>
      </form>
    </section>
  </main>
</div>

</body>
</html>
