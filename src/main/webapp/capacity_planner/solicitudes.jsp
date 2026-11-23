<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="beans.capacityplanner.Solicitud" %>
<%!
    private String texto(String valor) {
        if (valor == null) return "";
        return valor.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
    private static final DateTimeFormatter FORMATO_FECHA =
            DateTimeFormatter.ofPattern("dd/MM/uuuu HH:mm");

    private String mostrarEstado(String estado) {
        return "En evaluacion".equals(estado) ? "En evaluación" : texto(estado);
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
    ArrayList<Solicitud> solicitudes = (ArrayList<Solicitud>) request.getAttribute("listaSolicitudes");
    if (solicitudes == null) {
        response.sendRedirect(servlet);
        return;
    }
    Solicitud seleccionada = (Solicitud) request.getAttribute("solicitudSeleccionada");
    String filtro = (String) request.getAttribute("filtroEstado");
    if (filtro == null) filtro = "";
    String filtroUrl = java.net.URLEncoder.encode(filtro, "UTF-8");
    int paginaActual = (Integer) request.getAttribute("paginaActual");
    int totalPaginas = (Integer) request.getAttribute("totalPaginas");
    String urlPagina = servlet + "?estado=" + filtroUrl + "&amp;pagina=";
    String[] estados = {"Registrada", "En evaluacion", "Aprobada", "Provisionada",
            "Activa", "Rechazada", "Pendiente por capacidad"};

    String mensaje = request.getParameter("mensaje");
    String error = null;
    if ("cambioNoPermitido".equals(mensaje)) error = "Ese cambio de estado no está permitido.";
    if ("eliminacionNoPermitida".equals(mensaje)) error = "No se puede eliminar: revisa el estado y los servicios asociados.";
%>

<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Solicitudes | OceanLink</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/capacity_planner/solicitudes.css?v=2">
    <!-- Las barras comunes se cargan al final. -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/barras.css">
    <style>
        .paginacion-solicitudes {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 8px;
        }

        .paginacion-solicitudes .paginacion-controles {
            display: flex;
            gap: 8px;
            margin-inline-start: auto;
        }

        .paginacion-solicitudes .boton.paginacion-boton {
            background: #fff;
            border: 1px solid var(--color-borde, #d9e1e8);
        }

        .paginacion-solicitudes .paginacion-indicador {
            color: var(--color-texto-claro, #64748b);
            font-size: .875rem;
        }
    </style>
</head>
<body>
<!-- 5. BARRAS COMUNES: misma estructura que Clientes. -->
<jsp:include page="header.jsp" />
<div class="contenedor">
    <!-- MENÚ LATERAL: Solicitudes es la opción activa de esta página -->
    <aside class="menu-lateral">
        <div class="contenido-menu">
            <h2>Menú</h2>
            <nav class="navegacion-lateral" aria-label="Menú principal">
                <a href="${pageContext.request.contextPath}/CapacityPlannerServlet">Dashboard</a>
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
                <a href="${pageContext.request.contextPath}/PerfilServlet">Perfil</a>
                <!-- Navega al login; el cierre real de sesión se conectará después -->
                <a href="${pageContext.request.contextPath}/LogoutServlet" class="cerrar-sesion">Cerrar sesión</a>
            </nav>
        </div>
    </aside>
    <!-- CONTENIDO DE SOLICITUDES -->
    <main class="contenido-principal">
        <!-- 6. ENCABEZADO Y FILTRO -->
        <section class="encabezado-panel" id="encabezadoSolicitudes">
            <div><h2>Capacity Planner</h2><h1>Solicitudes</h1></div>
            <button id="botonNuevaSolicitud" class="boton primario" type="button" onclick="location.href='<%= servlet %>?action=formCrear'">+ Nueva solicitud</button>
        </section>
        <% if (error != null) { %><p class="mensaje-error" role="alert"><%= texto(error) %></p><% } %>
        <% if ("guardado".equals(mensaje) || "estadoActualizado".equals(mensaje) || "eliminado".equals(mensaje)) { %>
            <p role="status">Operación realizada correctamente.</p>
        <% } %>
        <section class="barra-filtros">
            <form method="get" action="<%= servlet %>" class="formulario-filtro">
                <label for="filtroEstado">Estado:</label>
                <select id="filtroEstado" name="estado">
                    <option value="">Todos</option>
                    <% for (String estado : estados) { %>
                    <option value="<%= estado %>" <%= estado.equals(filtro) ? "selected" : "" %>><%= mostrarEstado(estado) %></option>
                    <% } %>
                </select>
                <button class="boton secundario" type="submit">Filtrar</button>
            </form>
            <span class="cantidad-solicitudes">${totalSolicitudes} solicitudes</span>
        </section>
        <!-- 7. TABLA: el ID abre el detalle sin JavaScript. -->
        <section class="tabla-contenedor">
            <table class="tabla-solicitudes">
                <thead><tr><th>ID</th><th>Cliente</th><th>Origen</th><th>Destino</th><th>Capacidad</th><th>Estado</th></tr></thead>
                <tbody>
                <% for (Solicitud s : solicitudes) { %>
                <tr class="fila-solicitud <%= seleccionada != null && seleccionada.getIdSolicitud() == s.getIdSolicitud() ? "fila-seleccionada" : "" %>">
                    <td><a class="id-solicitud" href="<%= urlPagina %><%= paginaActual %>&amp;id=<%= s.getIdSolicitud() %>">SOL-<%= s.getIdSolicitud() %></a></td>
                    <td><%= texto(s.getNombreCliente()) %></td>
                    <td><%= texto(s.getNombreOrigen()) %></td>
                    <td><%= texto(s.getNombreDestino()) %></td>
                    <td><%= s.getCapacidadSolicitada() %> Gbps</td>
                    <td><span class="etiqueta-estado <%= color(s.getEstado()) %>"><%= mostrarEstado(s.getEstado()) %></span></td>
                </tr>
                <% } %>
                <% if (solicitudes.isEmpty()) { %><tr><td colspan="6" class="sin-resultados">No hay solicitudes con este estado.</td></tr><% } %>
                </tbody>
            </table>
        </section>
        <% if (totalPaginas > 1) { %>
        <nav class="paginacion-solicitudes" aria-label="Paginación de solicitudes">
            <span class="paginacion-indicador" aria-current="page">Página <%= paginaActual %> de <%= totalPaginas %></span>
            <div class="paginacion-controles">
                <% if (paginaActual > 1) { %>
                    <a class="boton secundario paginacion-boton" href="<%= urlPagina %><%= paginaActual - 1 %>">Anterior</a>
                <% } %>
                <% if (paginaActual < totalPaginas) { %>
                    <a class="boton secundario paginacion-boton" href="<%= urlPagina %><%= paginaActual + 1 %>">Siguiente</a>
                <% } %>
            </div>
        </nav>
        <% } %>
        <!-- 8. DETALLE: datos, estado y edición de la solicitud seleccionada. -->
        <% if (seleccionada != null) {
            Solicitud s = seleccionada;
            String estadoActual = s.getEstado();
            boolean editable = "Registrada".equals(estadoActual)
                    || "En evaluacion".equals(estadoActual)
                    || "Pendiente por capacidad".equals(estadoActual);
        %>
        <section class="panel-detalle">
            <div class="encabezado-detalle">
                <div><span>Detalle de solicitud</span><h2>SOL-<%= s.getIdSolicitud() %></h2></div>
                <a href="<%= urlPagina %><%= paginaActual %>" class="cerrar-detalle" aria-label="Cerrar detalle">&times;</a>
            </div>
            <div class="cuadricula-detalle">
                <div><span>Cliente</span><strong><%= texto(s.getNombreCliente()) %></strong></div>
                <div><span>Fecha de registro</span><strong><%= s.getFechaRegistro() == null ? "" : s.getFechaRegistro().toLocalDateTime().format(FORMATO_FECHA) %></strong></div>
                <div><span>Registrada por</span><strong><%= s.getNombreUsuario() == null ? "Usuario ID " + s.getIdUsuario() : texto(s.getNombreUsuario()) %></strong></div>
                <div><span>Origen</span><strong><%= texto(s.getNombreOrigen()) %></strong></div>
                <div><span>Destino</span><strong><%= texto(s.getNombreDestino()) %></strong></div>
                <div><span>Capacidad solicitada</span><strong><%= s.getCapacidadSolicitada() %> Gbps</strong></div>
            </div>
            <div class="justificacion-detalle"><span>Justificación</span><p><%= texto(s.getJustificacion()) %></p></div>
            <!-- Estado actual: siempre visible, aunque lo gestione Servicios. -->
            <p class="cambio-estado">Estado actual: <strong><%= mostrarEstado(s.getEstado()) %></strong></p>
            <% if (editable) { %>
            <form method="post" action="<%= servlet %>"
                  class="formulario-filtro cambio-estado"
                  onsubmit="if (this.elements['estado'].value === 'Aprobada') {
                      return confirm('¿Confirmas que deseas aprobar esta solicitud? Una vez aprobada, podrá utilizarse para crear un servicio.');
                  }">
                <input type="hidden" name="action" value="cambiarEstado">
                <input type="hidden" name="id_solicitud" value="<%= s.getIdSolicitud() %>">
                <label for="estadoSolicitud">Evaluación:</label>
                <select id="estadoSolicitud" name="estado" required>
                    <option value="">Seleccione un estado</option>
                    <% if ("En evaluacion".equals(estadoActual)) { %>
                        <option value="Aprobada">Aprobada</option>
                        <option value="Rechazada">Rechazada</option>
                        <option value="Pendiente por capacidad">Pendiente por capacidad</option>
                    <% } else { %>
                        <option value="En evaluacion">En evaluación</option>
                    <% } %>
                </select>
                <button class="boton secundario" type="submit">Guardar estado</button>
            </form>
            <% } %>
            <% if ("Provisionada".equals(estadoActual) || "Activa".equals(estadoActual)) { %>
                <p class="cambio-estado"><a class="id-solicitud" href="${pageContext.request.contextPath}/capacity_planner/servicios.jsp">Ver servicio</a></p>
            <% } %>
            <div class="acciones-detalle">
                <% if (editable) { %>
                    <a class="boton secundario" href="<%= servlet %>?action=editar&amp;id=<%= s.getIdSolicitud() %>">Editar solicitud</a>
                <% } %>
                <% if (editable || "Rechazada".equals(estadoActual)) { %>
                    <button class="boton-eliminar-solicitud" type="button" popovertarget="confirmarEliminar">Eliminar solicitud</button>
                <% } %>
            </div>
        </section>
        <!-- Confirmación de borrado sin JavaScript. -->
        <div id="confirmarEliminar" class="modal" popover>
            <h2>Eliminar SOL-<%= s.getIdSolicitud() %></h2>
            <p class="aviso-prueba">¿Deseas eliminar esta solicitud? Esta acción no se puede deshacer.</p>
            <form method="post" action="<%= servlet %>" class="botones-formulario">
                <input type="hidden" name="action" value="eliminar">
                <input type="hidden" name="id_solicitud" value="<%= s.getIdSolicitud() %>">
                <button class="boton secundario" type="button" popovertarget="confirmarEliminar" popovertargetaction="hide">Cancelar</button>
                <button class="boton-eliminar-solicitud" type="submit">Eliminar</button>
            </form>
        </div>
        <% } %>
    </main>
</div>
</body>
</html>
