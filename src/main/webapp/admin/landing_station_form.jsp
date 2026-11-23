<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="beans.capacityplanner.LandingStation" %>
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
  String servlet = request.getContextPath() + "/LandingStationAdminServlet";
  String filtro = (String) request.getAttribute("filtroEstado");
  if (filtro == null) filtro = "";
  int pagina = request.getAttribute("paginaActual") != null
    ? (Integer) request.getAttribute("paginaActual") : 1;

  String urlLista = servlet + "?estado=" + URLEncoder.encode(filtro, StandardCharsets.UTF_8) + "&pagina=" + pagina;
  String error = (String) request.getAttribute("error");
  String[] estados = {"Activa", "Inactiva"};

  LandingStation datos = (LandingStation) request.getAttribute("estacion");
  boolean esEdicion = (datos != null && datos.getIdLanding() > 0);

  String idLanding = esEdicion ? String.valueOf(datos.getIdLanding()) : "";
  String nombre    = datos != null ? datos.getNombre() : "";
  String pais      = datos != null ? datos.getPais() : "";
  String ciudad    = datos != null ? datos.getCiudad() : "";
  String estadoAct = (datos != null && datos.getEstado() != null && !datos.getEstado().isEmpty())
    ? datos.getEstado() : "Activa";
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
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= esEdicion ? "Editar estación" : "Nueva estación" %> | OceanLink</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/barras.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin/landing_stations.css">
</head>
<body>

<jsp:include page="header.jsp" />

<div class="contenedor">

  <jsp:include page="sidebar.jsp">
    <jsp:param name="activePage" value="landing_stations" />
  </jsp:include>

  <main class="contenido-principal pagina-landings">
    <section class="encabezado-pagina">
      <div class="encabezado-panel">
        <h2>Landing stations</h2>
        <h1><%= esEdicion ? "Editar estación" : "Nueva estación" %></h1>
      </div>
    </section>

    <section class="panel-detalle formulario-estacion" aria-label="<%= esEdicion ? "Editar estación" : "Nueva estación" %>">
      <% if (error != null && !error.isEmpty()) { %>
      <p class="mensaje-error" role="alert"><%= texto(error) %></p>
      <% } %>
      <form action="<%= servlet %>" method="post">
        <input type="hidden" name="action" value="guardar">
        <input type="hidden" name="idLanding" value="<%= idLanding %>">
        <input type="hidden" name="estado" value="<%= texto(filtro) %>">
        <input type="hidden" name="pagina" value="<%= pagina %>">

        <div class="grupo-formulario">
          <label for="nombre">Nombre</label>
          <input type="text" id="nombre" name="nombre" maxlength="100"
                 placeholder="Ejemplo: Callao Landing"
                 value="<%= texto(nombre) %>" required>
        </div>

        <div class="grupo-formulario">
          <label for="pais">País</label>
          <input type="text" id="pais" name="pais" maxlength="45"
                 placeholder="Ejemplo: Perú"
                 value="<%= texto(pais) %>" required>
        </div>

        <div class="grupo-formulario">
          <label for="ciudad">Ciudad</label>
          <input type="text" id="ciudad" name="ciudad" maxlength="45"
                 placeholder="Ejemplo: Callao"
                 value="<%= texto(ciudad) %>" required>
        </div>

        <div class="grupo-formulario">
          <label for="estadoEstacion">Estado</label>
          <select id="estadoEstacion" name="estadoEstacion" required>
            <% for (String est : estados) { %>
            <option value="<%= est %>" <%= est.equals(estadoAct) ? "selected" : "" %>><%= est %></option>
            <% } %>
          </select>
        </div>

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
