<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="beans.Cliente" %>
<%!
    // Mostrar texto de la base de datos sin interpretarlo como HTML.
    private String texto(String valor) {
        if (valor == null) return "";
        return valor.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>
<%
    // Un solo formulario sirve para crear y editar.
    Cliente cliente = (Cliente) request.getAttribute("clienteFormulario");
    if (cliente == null) {
        cliente = (Cliente) request.getAttribute("clienteSeleccionado");
    }
    if ("formulario".equals(request.getParameter("vista")) && cliente == null) {
        response.sendError(404, "El cliente no existe");
        return;
    }
    boolean esEdicion = cliente != null && cliente.getIdCliente() > 0;

    String idCliente = esEdicion ? String.valueOf(cliente.getIdCliente()) : "";
    String nombre = cliente != null ? cliente.getNombre() : "";
    String razonSocial = cliente != null ? cliente.getRazonSocial() : "";
    String ruc = cliente != null ? cliente.getRuc() : "";
    String correo = cliente != null ? cliente.getCorreo() : "";
    String telefono = cliente != null ? cliente.getTelefono() : "";
    String estado = cliente != null ? cliente.getEstado() : "activo";

    String error = (String) request.getAttribute("error");
    String servlet = request.getContextPath() + "/ClienteServlet";
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0" >
    <title><%= esEdicion ? "Editar cliente" : "Nuevo cliente" %> | OceanLink</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/capacity_planner/clientes.css" >
    <!-- CSS compartido: colores, animaciones y tamaño de las barras -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/barras.css">
</head>
<body>
<!-- Barra superior -->
<header class="barra-superior">
    <div class="zona-logo">
        <label for="controlMenu" class="boton-menu" title="Ocultar o mostrar menú">☰</label>
        <a href="${pageContext.request.contextPath}/CapacityPlannerServlet" class="logo">OceanLink</a>
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
<!-- Control del menú lateral -->
<input type="checkbox" id="controlMenu" class="control-menu" >
<div class="contenedor">
    <!-- MENÚ LATERAL: Clientes es la opción activa de esta página -->
    <aside class="menu-lateral">
        <div class="contenido-menu">
            <h2>Menú</h2>
            <nav class="navegacion-lateral" aria-label="Menú principal">
                <a href="${pageContext.request.contextPath}/CapacityPlannerServlet">Dashboard</a>
                <a href="<%= servlet %>" class="activo">Clientes</a>
                <a href="${pageContext.request.contextPath}/capacity_planner/solicitudes.jsp">Solicitudes</a>
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
            <h2>Clientes</h2>
            <h1><%= esEdicion ? "Editar cliente" : "Nuevo cliente" %></h1>
        </section>
        <section class="panel-detalle">
            <% if (error != null) { %>
                <p role="alert"><%= texto(error) %></p>
            <% } %>
            <form method="post" action="<%= servlet %>?action=guardar">
                <!-- Vacío: crear. Con un identificador: actualizar. -->
                <input type="hidden" name="id_cliente" value="<%= idCliente %>">
                <div class="grupo-formulario">
                    <label for="nombre">Nombre</label>
                    <input id="nombre" name="nombre" type="text" value="<%= texto(nombre) %>" maxlength="100" required>
                </div>
                <div class="grupo-formulario">
                    <label for="razon_social">Razón social</label>
                    <input id="razon_social" name="razon_social" type="text" value="<%= texto(razonSocial) %>" maxlength="150" required>
                </div>
                <div class="grupo-formulario">
                    <label for="RUC">RUC</label>
                    <input id="RUC" name="RUC" type="text" value="<%= texto(ruc) %>" minlength="11" maxlength="11" pattern="[0-9]{11}" inputmode="numeric" required>
                </div>
                <div class="grupo-formulario">
                    <label for="correo">Correo electrónico</label>
                    <input id="correo" name="correo" type="email" value="<%= texto(correo) %>" maxlength="100" required>
                </div>
                <div class="grupo-formulario">
                    <label for="telefono">Teléfono (opcional)</label>
                    <input id="telefono" name="telefono" type="tel" value="<%= texto(telefono) %>" maxlength="15">
                </div>
                <div class="grupo-formulario">
                    <label for="estado">Estado</label>
                    <select id="estado" name="estado" required>
                        <option value="activo" <%= "activo".equals(estado) ? "selected" : "" %>>Activo</option>
                        <option value="inactivo" <%= "inactivo".equals(estado) ? "selected" : "" %>>Inactivo</option>
                    </select>
                </div>
                <div class="botones-modal">
                    <a class="boton secundario" href="<%= servlet %>">Cancelar</a>
                    <button class="boton-guardar" type="submit"><%= esEdicion ? "Guardar cambios" : "Crear cliente" %></button>
                </div>
            </form>
        </section>
    </main>
</div>
</body>
</html>
