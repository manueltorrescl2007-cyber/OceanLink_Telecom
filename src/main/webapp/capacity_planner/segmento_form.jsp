<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.capacityplanner.LandingStation" %>

<%!
    public String texto(String valor) {
        if (valor == null) return "";

        return valor.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<%
    String servlet = request.getContextPath() + "/SegmentoServlet";
    String filtro = (String) request.getAttribute("filtroEstado");
    Integer pagina = (Integer) request.getAttribute("paginaActual");
    if (pagina == null) {
        response.sendRedirect(servlet + "?accion=nuevo");
        return;
    }
    String urlLista = servlet + "?estado=" + java.net.URLEncoder.encode(filtro, "UTF-8") + "&amp;pagina=" + pagina;
    ArrayList<LandingStation> estaciones =
            (ArrayList<LandingStation>) request.getAttribute("listaEstaciones");
    String error = (String) request.getAttribute("error");
    String total = request.getParameter("total");
    String estadoActual = request.getParameter("estadoSegmento");
    String[] estados = {"Operativo", "Degradado", "En mantenimiento", "Fuera de servicio"};
%>

<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nuevo segmento | OceanLink</title>
    <!-- CSS propio primero; barras comunes después. -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/capacity_planner/segmentos.css?v=1">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/barras.css">
    <style>
        .pagina-segmentos .formulario-segmento { max-width: 860px; margin-inline: auto; }
        .formulario-segmento form { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 20px; }
        .formulario-segmento .grupo-formulario { margin: 0; }
        .formulario-segmento label { color: #0b3d5c; font-weight: 600; }
        .formulario-segmento input:not([type="hidden"]), .formulario-segmento select {
            box-sizing: border-box; min-height: 46px; padding: 10px 12px;
            border: 1px solid #d9e1e8; border-radius: 8px; background: white; color: #1e293b; font: inherit;
        }
        .formulario-segmento .ayuda, .formulario-segmento .acciones { grid-column: 1 / -1; margin: 0; }
        @media (max-width: 760px) {
            .formulario-segmento form { grid-template-columns: minmax(0, 1fr); }
        }
    </style>
</head>
<body class="vista-segmentos">
<jsp:include page="header.jsp" />
<div class="contenedor">
    <!-- MENÚ LATERAL: Segmentos es la opción activa de esta página -->
    <aside class="menu-lateral">
        <div class="contenido-menu">
            <h2>Menú</h2>
            <nav class="navegacion-lateral" aria-label="Menú principal">
                <a href="${pageContext.request.contextPath}/CapacityPlannerServlet">Dashboard</a>

                <a href="${pageContext.request.contextPath}/ClienteServlet">Clientes</a>

                <a href="${pageContext.request.contextPath}/SolicitudesServlet">Solicitudes</a>
                <!-- Checkbox y label abren Infraestructura sin JavaScript -->
                <div class="grupo-menu">
                    <input type="checkbox" id="control-infraestructura" class="control-submenu" checked>
                    <label for="control-infraestructura" class="titulo-grupo">
                        <span>Infraestructura</span>
                        <span class="flecha-submenu"></span>
                    </label>
                    <div class="contenido-submenu">
                        <a href="${pageContext.request.contextPath}/capacity_planner/rutas.jsp" class="subopcion">Rutas</a>

                        <a href="<%= servlet %>" class="subopcion activo">Segmentos</a>

                        <a href="${pageContext.request.contextPath}/LandingStationServlet" class="subopcion">Landing stations</a>
                    </div>
                </div>
                <a href="${pageContext.request.contextPath}/capacity_planner/servicios.jsp">Servicios</a>
            </nav>
        </div>
        <!-- OPCIONES DEL USUARIO: barras.css las coloca abajo -->
        <div class="configuracion">
            <nav aria-label="Opciones del usuario">
                <!-- Pendiente: colocar la dirección real de Perfil -->
                <a href="${pageContext.request.contextPath}/PerfilServlet">Perfil</a>
                <!-- Navega al login; el cierre real de sesión se conectará después -->
                <a href="${pageContext.request.contextPath}/login.jsp" class="cerrar-sesion">Cerrar sesión</a>
            </nav>
        </div>
    </aside>

    <main class="contenido-principal pagina-segmentos">
        <section class="encabezado-pagina">
            <div class="encabezado-panel"><h2>Segmentos</h2><h1>Nuevo segmento</h1></div>
        </section>
        <section class="panel-detalle formulario-segmento" aria-label="Nuevo segmento">
            <% if (error != null) { %><p class="mensaje-error" role="alert"><%= texto(error) %></p><% } %>
            <form action="<%= servlet %>" method="post">
                <input type="hidden" name="accion" value="guardar">
                <input type="hidden" name="estado" value="<%= filtro %>">
                <input type="hidden" name="pagina" value="<%= pagina %>">
                <div class="grupo-formulario">
                    <label for="nombreInicial">Estación inicial</label>
                    <input id="nombreInicial" name="nombreInicial" list="estaciones" placeholder="Escribe el nombre" value="<%= texto(request.getParameter("nombreInicial")) %>" required>
                </div>
                <div class="grupo-formulario">
                    <label for="nombreFinal">Estación final</label>
                    <input id="nombreFinal" name="nombreFinal" list="estaciones" placeholder="Escribe el nombre" value="<%= texto(request.getParameter("nombreFinal")) %>" required>
                </div>
                <datalist id="estaciones">
                    <% for (LandingStation estacion : estaciones) { %>
                        <option value="<%= texto(estacion.getNombre()) %>"></option>
                    <% } %>
                </datalist>
                <div class="grupo-formulario">
                    <label for="total">Capacidad total (Gbps)</label>
                    <input id="total" name="total" type="number" min="1" max="4294967295" step="1" value="<%= texto(total == null ? "100" : total) %>" required>
                </div>
                <div class="grupo-formulario">
                    <label for="estadoSegmento">Estado</label>
                    <select id="estadoSegmento" name="estadoSegmento" required>
                        <% for (String estado : estados) { %>
                            <option value="<%= estado %>" <%= estado.equals(estadoActual) ? "selected" : "" %>><%= estado %></option>
                        <% } %>
                    </select>
                </div>
                <p class="ayuda">El código se genera al guardar con las dos estaciones elegidas.</p>
                <div class="acciones">
                    <a href="<%= urlLista %>" class="boton secundario">Cancelar</a>
                    <button type="submit" class="boton primario">Guardar</button>
                </div>
            </form>
        </section>
    </main>
</div>
</body>
</html>
