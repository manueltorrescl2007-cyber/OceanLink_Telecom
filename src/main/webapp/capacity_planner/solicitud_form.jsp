<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.Cliente" %>
<%@ page import="beans.Solicitud" %>
<%!
    private String texto(String valor) {
        if (valor == null) return "";
        return valor.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
    private String color(String estado) {
        if ("Rechazada".equals(estado)) return "rechazada";
        if ("Aprobada".equals(estado) || "Provisionada".equals(estado)
                || "Activa".equals(estado)) return "aprobada";
        return "pendiente";
    }
%>
<%
    String servlet = request.getContextPath() + "/SolicitudesServlet";
    Solicitud solicitud = (Solicitud) request.getAttribute("solicitud");
    ArrayList<Cliente> clientes = (ArrayList<Cliente>) request.getAttribute("listaClientes");
    ArrayList<String[]> estaciones = (ArrayList<String[]>) request.getAttribute("listaEstaciones");
    if (clientes == null || estaciones == null) {
        response.sendRedirect(servlet + "?action=formCrear");
        return;
    }
    boolean esEdicion = solicitud != null && solicitud.getIdSolicitud() > 0;
    String id = esEdicion ? String.valueOf(solicitud.getIdSolicitud()) : "";
    int idCliente = solicitud != null ? solicitud.getIdCliente() : -1;
    String origen = solicitud != null ? String.valueOf(solicitud.getIdLandingOrigen()) : "";
    String destino = solicitud != null ? String.valueOf(solicitud.getIdLandingDestino()) : "";
    String capacidad = solicitud != null ? String.valueOf(solicitud.getCapacidadSolicitada()) : "";
    String motivo = solicitud != null ? solicitud.getJustificacion() : "";
    String error = (String) request.getAttribute("error");
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= esEdicion ? "Editar solicitud" : "Nueva solicitud" %> | OceanLink</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/capacity_planner/solicitudes.css?v=2">
    <!-- Las barras comunes se cargan al final. -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/barras.css">
</head>
<body>
<!-- 5. BARRAS COMUNES: misma estructura que Clientes. -->
<input type="checkbox" id="controlMenu" class="control-menu" >
<header class="barra-superior">
    <div class="zona-logo">
        <label for="controlMenu" class="boton-menu" title="Ocultar o mostrar menú">☰</label>
        <a href="${pageContext.request.contextPath}/capacity_planner/capacity_planner.jsp" class="logo">OceanLink</a>
    </div>
    <div class="usuario">
        <div class="foto-usuario">
            CP
        </div>
        <div>
            <p class="nombre-usuario">Username</p>
            <p class="rol-usuario">Capacity Planner</p>
        </div>
    </div>
</header>
<div class="contenedor">
    <!-- MENÚ LATERAL: Solicitudes es la opción activa de esta página -->
    <aside class="menu-lateral">
        <div class="contenido-menu">
            <h2>Menú</h2>
            <nav class="navegacion-lateral" aria-label="Menú principal">
                <a href="${pageContext.request.contextPath}/capacity_planner/capacity_planner.jsp">Dashboard</a>
                <a href="${pageContext.request.contextPath}/ClienteServlet">Clientes</a>
                <a href="<%= servlet %>" class="activo">Solicitudes</a>
                <!-- Checkbox y label abren Infraestructura sin JavaScript -->
                <div class="grupo-menu">
                    <input type="checkbox" id="control-infraestructura" class="control-submenu">
                    <label for="control-infraestructura" class="titulo-grupo">
                        <span>Infraestructura</span>
                        <span class="flecha-submenu"></span>
                    </label>
                    <div class="contenido-submenu">
                        <a href="${pageContext.request.contextPath}/capacity_planner/rutas.jsp" class="subopcion">Rutas</a>
                        <a href="${pageContext.request.contextPath}/capacity_planner/segmentos.jsp" class="subopcion">Segmentos</a>
                        <a href="${pageContext.request.contextPath}/capacity_planner/landing_stations.jsp" class="subopcion">Landing stations</a>
                    </div>
                </div>
                <a href="${pageContext.request.contextPath}/capacity_planner/servicios.jsp">Servicios</a>
            </nav>
        </div>
        <!-- OPCIONES DEL USUARIO: barras.css las coloca abajo -->
        <div class="configuracion">
            <nav aria-label="Opciones del usuario">
                <!-- Pendiente: colocar la dirección real de Perfil -->
                <a href="#">Perfil</a>
                <!-- Navega al login; el cierre real de sesión se conectará después -->
                <a href="${pageContext.request.contextPath}/login.jsp" class="cerrar-sesion">Cerrar sesión</a>
            </nav>
        </div>
    </aside>
    <main class="contenido-principal">
        <section class="encabezado-panel">
            <div><h2>Solicitudes</h2><h1><%= esEdicion ? "Editar solicitud" : "Nueva solicitud" %></h1></div>
        </section>
        <section class="panel-detalle">
            <% if (error != null) { %><p class="mensaje-error" role="alert"><%= texto(error) %></p><% } %>
            <% if (clientes.isEmpty() || estaciones.size() < 2) { %>
                <p class="mensaje-error">Necesitas al menos un cliente activo y dos estaciones activas.</p>
            <% } %>
            <form method="post" action="<%= servlet %>?action=guardar" class="formulario-solicitud">
                <input type="hidden" name="id_solicitud" value="<%= id %>">
                <label>Cliente
                    <select name="id_cliente" required>
                        <option value="">Seleccione un cliente activo</option>
                        <% for (Cliente c : clientes) { %>
                        <option value="<%= c.getIdCliente() %>" <%= c.getIdCliente() == idCliente ? "selected" : "" %>><%= texto(c.getNombre()) %></option>
                        <% } %>
                    </select>
                </label>
                <label>Estación de origen
                    <select name="id_landing_origen" required>
                        <option value="">Seleccione una estación activa</option>
                        <% for (String[] estacion : estaciones) { %>
                        <option value="<%= texto(estacion[0]) %>" <%= estacion[0].equals(origen) ? "selected" : "" %>><%= texto(estacion[1]) %></option>
                        <% } %>
                    </select>
                </label>
                <label>Estación de destino
                    <select name="id_landing_destino" required>
                        <option value="">Seleccione una estación activa</option>
                        <% for (String[] estacion : estaciones) { %>
                        <option value="<%= texto(estacion[0]) %>" <%= estacion[0].equals(destino) ? "selected" : "" %>><%= texto(estacion[1]) %></option>
                        <% } %>
                    </select>
                </label>
                <label>Capacidad solicitada (Gbps)
                    <input type="number" name="capacidad_solicitada" min="1" max="4294967295" step="1" value="<%= capacidad %>" required>
                </label>
                <label class="ancho-completo">Justificación
                    <textarea name="justificacion" rows="4" required><%= texto(motivo) %></textarea>
                </label>
                <div class="botones-formulario ancho-completo">
                    <a class="boton secundario" href="<%= servlet %>">Cancelar</a>
                    <button class="boton primario" type="submit" <%= clientes.isEmpty() || estaciones.size() < 2 ? "disabled" : "" %>><%= esEdicion ? "Guardar cambios" : "Crear solicitud" %></button>
                </div>
            </form>
        </section>
    </main>
</div>
</body>
</html>

