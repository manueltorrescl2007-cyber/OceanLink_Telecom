<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.capacityplanner.LandingStation" %>
<%!

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

    String filtro = (String) request.getAttribute("filtroEstado");
    int pagina = (Integer) request.getAttribute("paginaActual");
    int totalPaginas = (Integer) request.getAttribute("totalPaginas");
    int cantidad = (Integer) request.getAttribute("totalEstaciones");
    String urlPagina = servlet + "?estado=" + filtro + "&amp;pagina=";
    String urlLista = urlPagina + pagina;
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
    <style>
        .vista-landings .paginacion-estaciones {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 8px;
        }

        .paginacion-estaciones .paginacion-controles {
            display: flex;
            gap: 8px;
            margin-inline-start: auto;
        }

        .paginacion-estaciones .boton.paginacion-boton {
            background: #fff;
            border: 1px solid var(--color-borde, #d9e1e8);
        }

        .paginacion-estaciones .paginacion-indicador {
            color: var(--color-texto-claro, #64748b);
            font-size: .875rem;
        }
    </style>
</head>
<body class="vista-landings">
<jsp:include page="header.jsp" />
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
                <a href="${pageContext.request.contextPath}/PerfilServlet">Perfil</a>
                <!-- Navega al login; el cierre real de sesión se conectará después -->
                <a href="${pageContext.request.contextPath}/LogoutServlet" class="cerrar-sesion">Cerrar sesión</a>
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
        </section>
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
                    <% for (LandingStation estacion : estaciones) { %>
                        <tr>
                            <td><%= estacion.getIdLanding() %></td>

                            <td>
                                <a href="<%= urlLista %>&amp;detalle=<%= estacion.getIdLanding() %>#detalle"
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


        <% if (totalPaginas > 1) { %>
        <nav class="paginacion-estaciones" aria-label="Paginación de estaciones">
            <span class="paginacion-indicador" aria-current="page">Página <%= pagina %> de <%= totalPaginas %></span>
            <div class="paginacion-controles">
                <% if (pagina > 1) { %>
                    <a class="boton secundario paginacion-boton" href="<%= urlPagina %><%= pagina - 1 %>">Anterior</a>
                <% } %>
                <% if (pagina < totalPaginas) { %>
                    <a class="boton secundario paginacion-boton" href="<%= urlPagina %><%= pagina + 1 %>">Siguiente</a>
                <% } %>
            </div>
        </nav>
        <% } %>

        <% LandingStation estacion = (LandingStation) request.getAttribute("estacionDetalle");
           if (estacion != null) { %>
             <section class="panel-detalle" id="detalle">
                 <div class="encabezado-detalle">
                     <h2><%= texto(estacion.getNombre()) %></h2>
                     <a href="<%= urlLista %>" aria-label="Cerrar detalle">×</a>
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

             </section>
         <% } %>
    </main>
</div>
</body>
</html>
