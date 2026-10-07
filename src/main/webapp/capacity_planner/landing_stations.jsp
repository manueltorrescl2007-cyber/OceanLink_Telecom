<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%!
    // Protege los textos del formulario al mostrarlos en HTML.
    public String texto(String valor) {
        if (valor == null) return "";
        return valor.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                    .replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    // 1. DATOS INICIALES: las 20 estaciones de la tabla landingstation del SQL.
    // Cada fila contiene: ID, nombre, país, ciudad y estado.
    String[][] ejemplos = {
        {"1", "Vancouver Landing", "Canadá", "Vancouver", "Activa"},
        {"2", "Seattle Landing", "Estados Unidos", "Seattle", "Activa"},
        {"3", "San Francisco Landing", "Estados Unidos", "San Francisco", "Activa"},
        {"4", "Los Ángeles Landing", "Estados Unidos", "Los Ángeles", "Activa"},
        {"5", "San Diego Landing", "Estados Unidos", "San Diego", "Activa"},
        {"6", "Tijuana Landing", "México", "Tijuana", "Activa"},
        {"7", "Manzanillo Landing", "México", "Manzanillo", "Activa"},
        {"8", "Puerto Chiapas Landing", "México", "Puerto Chiapas", "Activa"},
        {"9", "Puerto Quetzal Landing", "Guatemala", "Puerto Quetzal", "Activa"},
        {"10", "Acajutla Landing", "El Salvador", "Acajutla", "Activa"},
        {"11", "Puntarenas Landing", "Costa Rica", "Puntarenas", "Activa"},
        {"12", "Balboa Landing", "Panamá", "Balboa", "Activa"},
        {"13", "Buenaventura Landing", "Colombia", "Buenaventura", "Activa"},
        {"14", "Manta Landing", "Ecuador", "Manta", "Activa"},
        {"15", "Guayaquil Landing", "Ecuador", "Guayaquil", "Activa"},
        {"16", "Paita Landing", "Perú", "Paita", "Activa"},
        {"17", "Lurín Landing", "Perú", "Lurín", "Activa"},
        {"18", "Arica Landing", "Chile", "Arica", "Activa"},
        {"19", "Valparaíso Landing", "Chile", "Valparaíso", "Activa"},
        {"20", "Concepción Landing", "Chile", "Concepción", "Activa"}
    };
    String[] estados = {"Activa", "Inactiva"};

    // 2. MOCKUP INDEPENDIENTE: almacena los cambios en esta sesión.
    // Cuando conectemos MySQL, el Servlet enviará esta lista a la vista.
    ArrayList<String[]> estaciones = (ArrayList<String[]>) session.getAttribute("landingStationsMockupIndependiente");
    if (estaciones == null) {
        estaciones = new ArrayList<String[]>();
        for (String[] fila : ejemplos) estaciones.add(fila.clone());
        session.setAttribute("landingStationsMockupIndependiente", estaciones);
    }
    String error = "";
    String filtro = request.getParameter("estado");
    String editar = request.getParameter("editar");
    String detalle = request.getParameter("detalle");
    if (filtro == null) filtro = "";
    boolean mostrarFormulario = "nuevo".equals(request.getParameter("ventana")) || editar != null;
    String[] formulario = {"", "", "", "", "Activa"};
    for (String[] fila : estaciones) if (fila[0].equals(editar)) formulario = fila.clone();

    // 3. GUARDAR O EDITAR: valida los campos y evita nombres duplicados.
    if ("POST".equals(request.getMethod()) && "guardar".equals(request.getParameter("accion"))) {
        mostrarFormulario = true;
        String id = request.getParameter("id");
        String nombre = request.getParameter("nombre");
        String pais = request.getParameter("pais");
        String ciudad = request.getParameter("ciudad");
        String estado = request.getParameter("estadoEstacion");
        id = id == null ? "" : id;
        nombre = nombre == null ? "" : nombre.trim();
        pais = pais == null ? "" : pais.trim();
        ciudad = ciudad == null ? "" : ciudad.trim();
        formulario = new String[] {id, nombre, pais, ciudad, estado};
        int posicion = -1;
        int nuevoId = 1;
        for (int i = 0; i < estaciones.size(); i++) {
            String[] fila = estaciones.get(i);
            if (fila[0].equals(id)) posicion = i;
            nuevoId = Math.max(nuevoId, Integer.parseInt(fila[0]) + 1);
        }
        if (!id.isEmpty() && posicion < 0) error = "La estación que quieres editar no existe.";
        else if (nombre.isEmpty() || nombre.length() > 100) error = "Escribe un nombre de hasta 100 caracteres.";
        else if (pais.isEmpty() || pais.length() > 45) error = "Escribe un país de hasta 45 caracteres.";
        else if (ciudad.isEmpty() || ciudad.length() > 45) error = "Escribe una ciudad de hasta 45 caracteres.";
        else if (!"Activa".equals(estado) && !"Inactiva".equals(estado)) error = "Selecciona un estado válido.";
        for (String[] fila : estaciones) {
            if (!fila[0].equals(id) && fila[1].equalsIgnoreCase(nombre)) error = "Ya existe una estación con ese nombre.";
        }
        if (error.isEmpty()) {
            String[] guardado = {posicion >= 0 ? id : String.valueOf(nuevoId), nombre, pais, ciudad, estado};
            if (posicion >= 0) estaciones.set(posicion, guardado);
            else estaciones.add(guardado);
            response.sendRedirect("landing_stations.jsp?guardado=1&detalle=" + guardado[0] + "#detalle");
            return;
        }
    }
    int cantidad = 0;
    for (String[] fila : estaciones) if (filtro.isEmpty() || fila[4].equals(filtro)) cantidad++;
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Landing stations | OceanLink</title>
    <!-- Estilos de la página primero; barras comunes después. -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/capacity_planner/landing_stations.css?v=1">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/barras.css">
</head>
<body class="vista-landings">
<input type="checkbox" id="controlMenu" class="control-menu" >
<header class="barra-superior">
    <div class="zona-logo">
        <label for="controlMenu" class="boton-menu" title="Ocultar o mostrar menú">☰</label>
        <a href="capacity_planner.jsp" class="logo">OceanLink</a>
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
    <!-- MENÚ LATERAL: Landing stations es la opción activa de esta página -->
    <aside class="menu-lateral">
        <div class="contenido-menu">
            <h2>Menú</h2>
            <nav class="navegacion-lateral" aria-label="Menú principal">
                <a href="capacity_planner.jsp">Dashboard</a>
                <a href="clientes.jsp">Clientes</a>
                <a href="solicitudes.jsp">Solicitudes</a>
                <!-- Checkbox y label abren Infraestructura sin JavaScript -->
                <div class="grupo-menu">
                    <input type="checkbox" id="control-infraestructura" class="control-submenu" checked>
                    <label for="control-infraestructura" class="titulo-grupo">
                        <span>Infraestructura</span>
                        <span class="flecha-submenu"></span>
                    </label>
                    <div class="contenido-submenu">
                        <a href="rutas.jsp" class="subopcion">Rutas</a>
                        <a href="segmentos.jsp" class="subopcion">Segmentos</a>
                        <a href="landing_stations.jsp" class="subopcion activo">Landing stations</a>
                    </div>
                </div>
                <a href="servicios.jsp">Servicios</a>
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

    <!-- 4. ENCABEZADO Y FILTRO POR ESTADO. -->
    <main class="contenido-principal pagina-landings">
        <section class="encabezado-pagina">
            <div class="encabezado-panel">
                <h2>Capacity Planner</h2>
                <h1>Landing stations</h1>
            </div>
            <a href="landing_stations.jsp?ventana=nuevo" class="boton primario">+ Nueva estación</a>
        </section>
        <% if ("1".equals(request.getParameter("guardado"))) { %>
            <p class="mensaje-exito">Estación guardada correctamente.</p>
        <% } %>
        <div class="barra-herramientas">
            <form action="landing_stations.jsp" method="get" class="formulario-filtro">
                <label for="filtroEstado">Estado:</label>
                <select id="filtroEstado" name="estado">
                    <option value="">Todos</option>
                    <% for (String estado : estados) { %>
                        <option value="<%= estado %>" <%= estado.equals(filtro) ? "selected" : "" %>><%= estado %></option>
                    <% } %>
                </select>
                <button type="submit" class="boton secundario">Filtrar</button>
            </form>
            <span><%= cantidad %> estaciones</span>
        </div>

        <!-- 5. TABLA: muestra los cinco campos que existen en el SQL. -->
        <section class="contenedor-tabla">
            <table>
                <thead><tr><th>ID</th><th>Nombre</th><th>País</th><th>Ciudad</th><th>Estado</th></tr></thead>
                <tbody>
                <% for (String[] fila : estaciones) {
                    if (!filtro.isEmpty() && !fila[4].equals(filtro)) continue;
                %>
                    <tr>
                        <td><%= fila[0] %></td>
                        <td><a href="landing_stations.jsp?detalle=<%= fila[0] %>#detalle" class="enlace-estacion"><%= texto(fila[1]) %></a></td>
                        <td><%= texto(fila[2]) %></td>
                        <td><%= texto(fila[3]) %></td>
                        <td><span class="estado <%= fila[4].equals("Activa") ? "activa" : "inactiva" %>"><%= fila[4] %></span></td>
                    </tr>
                <% } %>
                <% if (cantidad == 0) { %><tr><td colspan="5">No hay estaciones con este estado.</td></tr><% } %>
                </tbody>
            </table>
        </section>
        <p class="ayuda">Haz clic en el nombre de una estación para ver su detalle.</p>

        <!-- 6. DETALLE: muestra la estación seleccionada y permite editarla. -->
        <% for (String[] fila : estaciones) {
            if (!fila[0].equals(detalle)) continue;
        %>
            <section class="panel-detalle" id="detalle">
                <div class="encabezado-detalle">
                    <h2><%= texto(fila[1]) %></h2>
                    <a href="landing_stations.jsp" aria-label="Cerrar detalle">×</a>
                </div>
                <div class="datos-detalle">
                    <div><span>ID de la estación</span><strong><%= fila[0] %></strong></div>
                    <div><span>País</span><strong><%= texto(fila[2]) %></strong></div>
                    <div><span>Ciudad</span><strong><%= texto(fila[3]) %></strong></div>
                    <div><span>Estado</span><strong><%= fila[4] %></strong></div>
                </div>
                <div class="acciones"><a href="landing_stations.jsp?editar=<%= fila[0] %>" class="boton primario">Editar estación</a></div>
            </section>
        <% } %>
    </main>
</div>

<!-- 7. FORMULARIO: registro y edición sin JavaScript. -->
<% if (mostrarFormulario) { %>
<div class="modal" role="dialog" aria-modal="true" aria-labelledby="tituloFormulario">
    <section class="contenido-modal">
        <div class="encabezado-detalle">
            <h2 id="tituloFormulario"><%= formulario[0].isEmpty() ? "Nueva estación" : "Editar estación" %></h2>
            <a href="landing_stations.jsp" aria-label="Cerrar formulario">×</a>
        </div>
        <% if (!error.isEmpty()) { %><p class="mensaje-error"><%= error %></p><% } %>
        <form action="landing_stations.jsp" method="post">
            <input type="hidden" name="accion" value="guardar">
            <input type="hidden" name="id" value="<%= texto(formulario[0]) %>">
            <div class="grupo-formulario">
                <label for="nombre">Nombre</label>
                <input id="nombre" name="nombre" maxlength="100" placeholder="Ejemplo: Callao Landing" value="<%= texto(formulario[1]) %>" required>
            </div>
            <div class="grupo-formulario">
                <label for="pais">País</label>
                <input id="pais" name="pais" maxlength="45" placeholder="Ejemplo: Perú" value="<%= texto(formulario[2]) %>" required>
            </div>
            <div class="grupo-formulario">
                <label for="ciudad">Ciudad</label>
                <input id="ciudad" name="ciudad" maxlength="45" placeholder="Ejemplo: Callao" value="<%= texto(formulario[3]) %>" required>
            </div>
            <div class="grupo-formulario">
                <label for="estadoEstacion">Estado</label>
                <select id="estadoEstacion" name="estadoEstacion" required>
                    <% for (String estado : estados) { %>
                        <option value="<%= estado %>" <%= estado.equals(formulario[4]) ? "selected" : "" %>><%= estado %></option>
                    <% } %>
                </select>
            </div>
            <div class="acciones">
                <a href="landing_stations.jsp" class="boton secundario">Cancelar</a>
                <button type="submit" class="boton primario">Guardar</button>
            </div>
        </form>
    </section>
</div>
<% } %>
</body>
</html>
