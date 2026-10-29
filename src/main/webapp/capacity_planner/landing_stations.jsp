<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.LandingStation" %>
<%!
    // Protege los textos del formulario al mostrarlos en HTML.
    public String texto(String valor) {
        if (valor == null) return "";
        return valor.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                    .replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    String servlet = request.getContextPath() + "/LandingStationServlet";

    ArrayList<LandingStation> estaciones =
            (ArrayList<LandingStation>) request.getAttribute("listaEstaciones");

    if (estaciones == null) {
        response.sendRedirect(servlet);
        return;
    }

    String[] estados = {"Activa", "Inactiva"};

    String filtro = request.getParameter("estado");
    String editar = request.getParameter("editar");
    String detalle = request.getParameter("detalle");

    if (filtro == null) filtro = "";

    String error = (String) request.getAttribute("error");
    if (error == null) error = "";

    boolean mostrarFormulario =
            "nuevo".equals(request.getParameter("ventana"))
                    || editar != null;

    String[] formulario = {"", "", "", "", "Activa"};

    // Cargar los datos de la estación que se quiere editar.
    for (LandingStation estacion : estaciones) {
        if (String.valueOf(estacion.getIdLanding()).equals(editar)) {
            formulario = new String[]{
                    String.valueOf(estacion.getIdLanding()),
                    estacion.getNombre(),
                    estacion.getPais(),
                    estacion.getCiudad(),
                    estacion.getEstado()
            };
        }
    }

    // Recuperar lo escrito si el servlet devuelve un error.
    LandingStation datos =
            (LandingStation) request.getAttribute("estacionFormulario");

    if (datos != null) {
        mostrarFormulario = true;

        formulario = new String[]{
                datos.getIdLanding() > 0
                        ? String.valueOf(datos.getIdLanding()) : "",
                datos.getNombre(),
                datos.getPais(),
                datos.getCiudad(),
                datos.getEstado()
        };
    }

    int cantidad = 0;

    for (LandingStation estacion : estaciones) {
        if (filtro.isEmpty() || estacion.getEstado().equals(filtro)) {
            cantidad++;
        }
    }
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
<div class="contenedor">
    <!-- MENÚ LATERAL: Landing stations es la opción activa de esta página -->
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

                        <a href="${pageContext.request.contextPath}/capacity_planner/segmentos.jsp" class="subopcion">Segmentos</a>

                        <a href="<%= servlet %>" class="subopcion activo">Landing stations</a>
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

    <!-- 4. ENCABEZADO Y FILTRO POR ESTADO. -->
    <main class="contenido-principal pagina-landings">
        <section class="encabezado-pagina">
            <div class="encabezado-panel">
                <h2>Capacity Planner</h2>
                <h1>Landing stations</h1>
            </div>
            <a href="<%= servlet %>?ventana=nuevo" class="boton primario">
                + Nueva estación
            </a>
        </section>
        <% if ("1".equals(request.getParameter("guardado"))) { %>
            <p class="mensaje-exito">Estación guardada correctamente.</p>
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
                <button type="submit" class="boton secundario">Filtrar</button>
            </form>
            <span><%= cantidad %> estaciones</span>
        </div>

        <!-- 5. TABLA: muestra los cinco campos que existen en el SQL. -->
        <section class="contenedor-tabla">
            <table>
                <thead><tr><th>ID</th><th>Nombre</th><th>País</th><th>Ciudad</th><th>Estado</th></tr></thead>
                <tbody>
                    <% for (LandingStation estacion : estaciones) {
                        if (!filtro.isEmpty()
                                && !estacion.getEstado().equals(filtro)) {
                            continue;
                        }
                    %>
                        <tr>
                            <td><%= estacion.getIdLanding() %></td>

                            <td>
                                <a href="<%= servlet %>?detalle=<%= estacion.getIdLanding() %>#detalle"
                                   class="enlace-estacion">
                                    <%= texto(estacion.getNombre()) %>
                                </a>
                            </td>

                            <td><%= texto(estacion.getPais()) %></td>

                            <td><%= texto(estacion.getCiudad()) %></td>

                            <td>
                                <span class="estado <%= "Activa".equals(estacion.getEstado()) ? "activa" : "inactiva" %>">
                                    <%= texto(estacion.getEstado()) %>
                                </span>
                            </td>
                        </tr>
                    <% } %>

                    <% if (cantidad == 0) { %>
                        <tr>
                            <td colspan="5">No hay estaciones con este estado.</td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </section>


        <<!-- 6. DETALLE de la estación seleccionada. -->
         <% for (LandingStation estacion : estaciones) {
             if (!String.valueOf(estacion.getIdLanding()).equals(detalle)) {
                 continue;
             }
         %>
             <section class="panel-detalle" id="detalle">
                 <div class="encabezado-detalle">
                     <h2><%= texto(estacion.getNombre()) %></h2>
                     <a href="<%= servlet %>" aria-label="Cerrar detalle">×</a>
                 </div>

                 <div class="datos-detalle">
                     <div>
                         <span>ID de la estación</span>
                         <strong><%= estacion.getIdLanding() %></strong>
                     </div>

                     <div>
                         <span>País</span>
                         <strong><%= texto(estacion.getPais()) %></strong>
                     </div>

                     <div>
                         <span>Ciudad</span>
                         <strong><%= texto(estacion.getCiudad()) %></strong>
                     </div>

                     <div>
                         <span>Estado</span>
                         <strong><%= texto(estacion.getEstado()) %></strong>
                     </div>
                 </div>

                 <div class="acciones">
                     <a href="<%= servlet %>?editar=<%= estacion.getIdLanding() %>"
                        class="boton primario">
                         Editar estación
                     </a>
                 </div>
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
            <a href="<%= servlet %>" aria-label="Cerrar formulario">×</a>
        </div>
        <% if (!error.isEmpty()) { %><p class="mensaje-error"><%= error %></p><% } %>
        <form action="<%= servlet %>" method="post">
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
                <a href="<%= servlet %>" class="boton secundario">Cancelar</a>
                <button type="submit" class="boton primario">Guardar</button>
            </div>
        </form>
    </section>
</div>
<% } %>
</body>
</html>
