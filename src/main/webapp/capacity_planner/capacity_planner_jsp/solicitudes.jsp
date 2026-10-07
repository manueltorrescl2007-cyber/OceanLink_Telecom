<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList,java.time.LocalDateTime,java.time.format.DateTimeFormatter" %>
<%!
    // Evita que los textos del formulario se interpreten como HTML.
    private String texto(String valor) {
        if (valor == null) return "";
        return valor.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
    // Busca el nombre que corresponde a un ID del SQL.
    private String nombre(String[][] opciones, String id) {
        for (String[] opcion : opciones) {
            if (opcion[0].equals(id)) return opcion[1];
        }
        return "";
    }
    // Busca una solicitud por su ID; -1 significa que no existe.
    private int buscar(ArrayList<String[]> lista, String id) {
        for (int i = 0; i < lista.size(); i++) {
            if (lista.get(i)[0].equals(id)) return i;
        }
        return -1;
    }
    // Agrupa los estados solamente para mostrar sus colores.
    private String color(String estado) {
        if (estado.equals("Rechazada")) return "rechazada";
        if (estado.equals("Aprobada") || estado.equals("Provisionada") || estado.equals("Activa")) return "aprobada";
        return "pendiente";
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    // 1. CATÁLOGOS DE PRUEBA: IDs del SQL; las estaciones muestran solo el lugar.
    String[][] clientes = {{"1", "Claro"}, {"2", "Movistar"}, {"3", "Pacifico"}};
    String[][] estaciones = {{"1", "Vancouver"}, {"2", "Seattle"}, {"3", "San Francisco"}, {"4", "Los Ángeles"}, {"5", "San Diego"}, {"6", "Tijuana"}, {"7", "Manzanillo"}, {"8", "Puerto Chiapas"}, {"9", "Puerto Quetzal"}, {"10", "Acajutla"}, {"11", "Puntarenas"}, {"12", "Balboa"}, {"13", "Buenaventura"}, {"14", "Manta"}, {"15", "Guayaquil"}, {"16", "Paita"}, {"17", "Lurín"}, {"18", "Arica"}, {"19", "Valparaíso"}, {"20", "Concepción"}};
    String[] estados = {"Registrada", "En evaluacion", "Aprobada", "Provisionada",
            "Activa", "Rechazada", "Pendiente por capacidad"};

    // El filtro conserva TODOS los estados del enum del SQL.
    // Estos cuatro estados los gestiona el Capacity Planner desde Solicitudes.
    String[] estadosPlanner = {"En evaluacion", "Aprobada", "Rechazada", "Pendiente por capacidad"};

    // 2. DATOS TEMPORALES: solo se guardan en esta sesión, no en MySQL.
    // Orden: id_solicitud, id_cliente, id_usuario, id_landing_origen,
    // id_landing_destino, capacidad_solicitada, estado, justificacion, fecha_registro.
    ArrayList<String[]> solicitudes = (ArrayList<String[]>) session.getAttribute("solicitudesPruebaSQL");
    if (solicitudes == null) {
        solicitudes = new ArrayList<String[]>();
        solicitudes.add(new String[]{"1", "3", "4", "4", "17", "50", "Aprobada", "Ampliación de conectividad internacional.", "2026-10-06 08:00:00"});
        solicitudes.add(new String[]{"2", "1", "4", "17", "19", "20", "En evaluacion", "Evaluar capacidad para nuevos servicios.", "2026-10-06 09:00:00"});
        solicitudes.add(new String[]{"3", "2", "4", "15", "17", "30", "Registrada", "Conectar las operaciones de Ecuador y Perú.", "2026-10-06 10:00:00"});
        session.setAttribute("solicitudesPruebaSQL", solicitudes);
        session.setAttribute("siguienteSolicitudPrueba", 4);
    }
    String error = "";
    // 3. ACCIONES DE PRUEBA: más adelante este bloque pasa al Servlet.
    // Los cambios se reciben por POST; los enlaces GET solo muestran información.
    if ("POST".equals(request.getMethod())) {
        String accion = request.getParameter("accion");
        int indice = buscar(solicitudes, request.getParameter("id_solicitud"));
        if ("crear".equals(accion) || "editar".equals(accion)) {
            String cliente = request.getParameter("id_cliente");
            String origen = request.getParameter("id_landing_origen");
            String destino = request.getParameter("id_landing_destino");
            String motivo = request.getParameter("justificacion");
            int capacidad = 0;
            try { capacidad = Integer.parseInt(request.getParameter("capacidad_solicitada")); }
            catch (NumberFormatException e) { capacidad = 0; }
            if (nombre(clientes, cliente).isEmpty() || nombre(estaciones, origen).isEmpty()
                    || nombre(estaciones, destino).isEmpty() || origen.equals(destino)
                    || capacidad <= 0 || motivo == null || motivo.trim().isEmpty()) {
                error = "Seleccione un cliente, estaciones diferentes, capacidad positiva y justificación.";
            } else if ("crear".equals(accion)) {
                int id = (Integer) session.getAttribute("siguienteSolicitudPrueba");
                String fecha = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
                // Usuario 4 existe en el SQL. Al conectar, se obtiene del usuario autenticado.
                solicitudes.add(new String[]{String.valueOf(id), cliente, "4", origen, destino,
                        String.valueOf(capacidad), "Registrada", motivo.trim(), fecha});
                session.setAttribute("siguienteSolicitudPrueba", id + 1);
            } else if (indice >= 0) {
                String[] s = solicitudes.get(indice);
                s[1] = cliente; s[3] = origen; s[4] = destino;
                s[5] = String.valueOf(capacidad); s[7] = motivo.trim();
            } else { error = "No se encontró la solicitud."; }
        } else if ("cambiarEstado".equals(accion) && indice >= 0) {
            // Registrada se asigna al crear; Provisionada y Activa se gestionan en Servicios.
            String estado = request.getParameter("estado");
            String actual = solicitudes.get(indice)[6];
            boolean valido = false;
            for (String opcion : estadosPlanner) {
                if (opcion.equals(estado)) valido = true;
            }
            if (actual.equals("Provisionada") || actual.equals("Activa")) {
                error = "Esta solicitud se gestiona desde Servicios.";
            } else if (valido) {
                solicitudes.get(indice)[6] = estado;
            } else { error = "Seleccione un estado de evaluación válido."; }
        } else if ("eliminar".equals(accion) && indice >= 0) {
            // Solo borra la prueba local. MySQL deberá respetar los servicios asociados.
            solicitudes.remove(indice);
        } else { error = "Acción no válida."; }
        if (error.isEmpty()) {
            response.sendRedirect("solicitudes.jsp");
            return;
        }
    }
    // 4. FILTRO Y DETALLE: se controlan mediante parámetros de la URL.
    String filtro = request.getParameter("filtro");
    boolean filtroValido = false;
    for (String estado : estados) {
        if (estado.equals(filtro)) filtroValido = true;
    }
    if (!filtroValido) filtro = "Todos";
    int detalle = buscar(solicitudes, request.getParameter("detalle"));
    int cantidad = 0;
    for (String[] s : solicitudes) {
        if (filtro.equals("Todos") || filtro.equals(s[6])) cantidad++;
    }
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Solicitudes | OceanLink</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/capacity_planner/solicitudes.css">
    <!-- Las barras comunes se cargan al final. -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/barras.css">
</head>
<body>
<!-- 5. BARRAS COMUNES: misma estructura que Clientes. -->
<input type="checkbox" id="controlMenu" class="control-menu" >
<header class="barra-superior">
    <div class="zona-logo">
        <label for="controlMenu" class="boton-menu" title="Ocultar o mostrar menú">☰</label>
        <a href="${pageContext.request.contextPath}/capacity_planner/capacity_planner_jsp/capacity_planner.jsp" class="logo">OceanLink</a>
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
                <a href="${pageContext.request.contextPath}/capacity_planner/capacity_planner_jsp/capacity_planner.jsp">Dashboard</a>
                <a href="${pageContext.request.contextPath}/capacity_planner/capacity_planner_jsp/clientes.jsp">Clientes</a>
                <a href="${pageContext.request.contextPath}/capacity_planner/capacity_planner_jsp/solicitudes.jsp" class="activo">Solicitudes</a>
                <!-- Checkbox y label abren Infraestructura sin JavaScript -->
                <div class="grupo-menu">
                    <input type="checkbox" id="control-infraestructura" class="control-submenu">
                    <label for="control-infraestructura" class="titulo-grupo">
                        <span>Infraestructura</span>
                        <span class="flecha-submenu"></span>
                    </label>
                    <div class="contenido-submenu">
                        <a href="${pageContext.request.contextPath}/capacity_planner/capacity_planner_jsp/rutas.jsp" class="subopcion">Rutas</a>
                        <a href="${pageContext.request.contextPath}/capacity_planner/capacity_planner_jsp/segmentos.jsp" class="subopcion">Segmentos</a>
                        <a href="${pageContext.request.contextPath}/capacity_planner/capacity_planner_jsp/landing_stations.jsp" class="subopcion">Landing stations</a>
                    </div>
                </div>
                <a href="${pageContext.request.contextPath}/capacity_planner/capacity_planner_jsp/servicios.jsp">Servicios</a>
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
    <!-- CONTENIDO DE SOLICITUDES -->
    <main class="contenido-principal">
        <!-- 6. ENCABEZADO Y FILTRO -->
        <section class="encabezado-panel">
            <div><h2>Capacity Planner</h2><h1>Solicitudes</h1></div>
            <button class="boton primario" type="button" popovertarget="modalNuevaSolicitud">+ Nueva solicitud</button>
        </section>
        <% if (!error.isEmpty()) { %><p class="mensaje-error" role="alert"><%= texto(error) %></p><% } %>
        <section class="barra-filtros">
            <form method="get" action="solicitudes.jsp" class="formulario-filtro">
                <label for="filtroEstado">Estado:</label>
                <select id="filtroEstado" name="filtro">
                    <option value="Todos">Todos</option>
                    <% for (String estado : estados) { %>
                    <option value="<%= estado %>" <%= estado.equals(filtro) ? "selected" : "" %>><%= estado %></option>
                    <% } %>
                </select>
                <button class="boton secundario" type="submit">Filtrar</button>
            </form>
            <span class="cantidad-solicitudes"><%= cantidad %> solicitudes</span>
        </section>
        <!-- 7. TABLA: el ID abre el detalle sin JavaScript. -->
        <section class="tabla-contenedor">
            <table class="tabla-solicitudes">
                <thead><tr><th>ID</th><th>Cliente</th><th>Origen</th><th>Destino</th><th>Capacidad</th><th>Estado</th></tr></thead>
                <tbody>
                <% for (int i = 0; i < solicitudes.size(); i++) {
                    String[] s = solicitudes.get(i);
                    if (!filtro.equals("Todos") && !filtro.equals(s[6])) continue;
                %>
                <tr class="fila-solicitud <%= i == detalle ? "fila-seleccionada" : "" %>">
                    <td><a class="id-solicitud" href="solicitudes.jsp?detalle=<%= s[0] %>&amp;filtro=<%= java.net.URLEncoder.encode(filtro, "UTF-8") %>" >SOL-<%= s[0] %></a></td>
                    <td><%= nombre(clientes, s[1]) %></td>
                    <td><%= nombre(estaciones, s[3]) %></td>
                    <td><%= nombre(estaciones, s[4]) %></td>
                    <td><%= s[5] %> Gbps</td>
                    <td><span class="etiqueta-estado <%= color(s[6]) %>"><%= s[6] %></span></td>
                </tr>
                <% } %>
                <% if (cantidad == 0) { %><tr><td colspan="6" class="sin-resultados">No hay solicitudes con este estado.</td></tr><% } %>
                </tbody>
            </table>
        </section>
        <!-- 8. DETALLE: datos, estado y edición de la solicitud seleccionada. -->
        <% if (detalle >= 0) { String[] s = solicitudes.get(detalle); %>
        <section class="panel-detalle">
            <div class="encabezado-detalle">
                <div><span>Detalle de solicitud</span><h2>SOL-<%= s[0] %></h2></div>
                <a href="solicitudes.jsp" class="cerrar-detalle" aria-label="Cerrar detalle">&times;</a>
            </div>
            <div class="cuadricula-detalle">
                <div><span>Cliente</span><strong><%= nombre(clientes, s[1]) %></strong></div>
                <div><span>Fecha de registro</span><strong><%= s[8] %></strong></div>
                <div><span>Registrada por</span><strong>Guillian Flores (prueba)</strong></div>
                <div><span>Origen</span><strong><%= nombre(estaciones, s[3]) %></strong></div>
                <div><span>Destino</span><strong><%= nombre(estaciones, s[4]) %></strong></div>
                <div><span>Capacidad solicitada</span><strong><%= s[5] %> Gbps</strong></div>
            </div>
            <div class="justificacion-detalle"><span>Justificación</span><p><%= texto(s[7]) %></p></div>
            <!-- Estado actual: siempre visible, aunque lo gestione Servicios. -->
            <p class="cambio-estado">Estado actual: <strong><%= s[6] %></strong></p>
            <% if (!s[6].equals("Provisionada") && !s[6].equals("Activa")) { %>
            <!-- El Planner solo cambia los estados relacionados con la evaluación. -->
            <form method="post" action="solicitudes.jsp" class="formulario-filtro cambio-estado">
                <input type="hidden" name="accion" value="cambiarEstado">
                <input type="hidden" name="id_solicitud" value="<%= s[0] %>">
                <label for="estadoSolicitud">Evaluación:</label>
                <select id="estadoSolicitud" name="estado" required>
                    <option value="">Seleccione un estado</option>
                    <% for (String estado : estadosPlanner) { %>
                    <option value="<%= estado %>" <%= estado.equals(s[6]) ? "selected" : "" %>><%= estado %></option>
                    <% } %>
                </select>
                <button class="boton secundario" type="submit">Guardar estado</button>
            </form>
            <% } else { %>
            <p class="cambio-estado"><a class="id-solicitud" href="servicios.jsp">Ver servicio</a></p>
            <% } %>
            <div class="acciones-detalle">
                <details class="editar-solicitud">
                    <summary>Editar solicitud</summary>
                    <form method="post" action="solicitudes.jsp" class="formulario-solicitud">
                        <input type="hidden" name="accion" value="editar">
                        <input type="hidden" name="id_solicitud" value="<%= s[0] %>">
                        <label>Cliente<select name="id_cliente" required>
                            <% for (String[] opcion : clientes) { %>
                            <option value="<%= opcion[0] %>" <%= opcion[0].equals(s[1]) ? "selected" : "" %>><%= opcion[1] %></option>
                            <% } %>
                        </select></label>
                        <label>Estación de origen<select name="id_landing_origen" required>
                            <% for (String[] opcion : estaciones) { %>
                            <option value="<%= opcion[0] %>" <%= opcion[0].equals(s[3]) ? "selected" : "" %>><%= opcion[1] %></option>
                            <% } %>
                        </select></label>
                        <label>Estación de destino<select name="id_landing_destino" required>
                            <% for (String[] opcion : estaciones) { %>
                            <option value="<%= opcion[0] %>" <%= opcion[0].equals(s[4]) ? "selected" : "" %>><%= opcion[1] %></option>
                            <% } %>
                        </select></label>
                        <label>Capacidad solicitada (Gbps)<input type="number" name="capacidad_solicitada" min="1" max="2147483647" step="1" value="<%= texto(s[5]) %>" required></label>
                        <!-- El ID, usuario y fecha se asignan automáticamente al registrar. -->
                        <label class="ancho-completo">Justificación<textarea name="justificacion" required><%= texto(s[7]) %></textarea></label>
                        <div class="botones-formulario ancho-completo">
                            <button class="boton primario" type="submit">Guardar cambios</button>
                        </div>
                    </form>
                </details>
                <button class="boton-eliminar-solicitud" type="button" popovertarget="confirmarEliminar">Eliminar solicitud</button>
            </div>
        </section>
        <!-- Confirmación de borrado sin JavaScript. -->
        <div id="confirmarEliminar" class="modal" popover>
            <h2>Eliminar SOL-<%= s[0] %></h2>
            <p class="aviso-prueba">¿Deseas eliminar esta solicitud de prueba?</p>
            <form method="post" action="solicitudes.jsp" class="botones-formulario">
                <input type="hidden" name="accion" value="eliminar">
                <input type="hidden" name="id_solicitud" value="<%= s[0] %>">
                <button class="boton secundario" type="button" popovertarget="confirmarEliminar" popovertargetaction="hide">Cancelar</button>
                <button class="boton-eliminar-solicitud" type="submit">Eliminar</button>
            </form>
        </div>
        <% } %>
    </main>
</div>
<!-- 9. NUEVA SOLICITUD: campos con los nombres de tu tabla SQL. -->
<div id="modalNuevaSolicitud" class="modal" popover>
    <div class="encabezado-modal">
        <h2>Nueva solicitud</h2>
        <button class="cerrar-modal" type="button" popovertarget="modalNuevaSolicitud" popovertargetaction="hide" aria-label="Cerrar">&times;</button>
    </div>
    <form method="post" action="solicitudes.jsp" class="formulario-solicitud">
        <input type="hidden" name="accion" value="crear">
        <label>Cliente<select name="id_cliente" required>
            <option value="">Seleccione una opción</option>
            <% for (String[] opcion : clientes) { %>
            <option value="<%= opcion[0] %>"><%= opcion[1] %></option>
            <% } %>
        </select></label>
        <label>Estación de origen<select name="id_landing_origen" required>
            <option value="">Seleccione una opción</option>
            <% for (String[] opcion : estaciones) { %>
            <option value="<%= opcion[0] %>"><%= opcion[1] %></option>
            <% } %>
        </select></label>
        <label>Estación de destino<select name="id_landing_destino" required>
            <option value="">Seleccione una opción</option>
            <% for (String[] opcion : estaciones) { %>
            <option value="<%= opcion[0] %>"><%= opcion[1] %></option>
            <% } %>
        </select></label>
        <label>Capacidad solicitada (Gbps)<input type="number" name="capacidad_solicitada" min="1" max="2147483647" step="1" value="" required></label>
        <!-- El ID, usuario y fecha se asignan automáticamente al registrar. -->
        <label class="ancho-completo">Justificación<textarea name="justificacion" required></textarea></label>
        <div class="botones-formulario ancho-completo">
            <button class="boton secundario" type="button" popovertarget="modalNuevaSolicitud" popovertargetaction="hide">Cancelar</button>
            <button class="boton primario" type="submit">Guardar solicitud</button>
        </div>
    </form>
</div>
</body>
</html>

