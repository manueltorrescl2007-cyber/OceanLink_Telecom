<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="beans.capacityplanner.Ruta" %>
<%@ page import="beans.capacityplanner.Segmento" %>
<%@ page import="beans.capacityplanner.LandingStation" %>
<%!
    private int paginaValida(String valor) {
        try { return Integer.parseInt(valor); }
        catch (NumberFormatException e) { return 1; }
    }

    private String texto(String valor) {
        return valor == null ? "" : valor.replace("&", "&amp;")
                .replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    String servlet = request.getContextPath() + "/RutaServlet";

    boolean formulario = Boolean.TRUE.equals(request.getAttribute("vistaFormulario"));
    if (!formulario && request.getAttribute("listaRutas") == null) {
        response.sendRedirect(servlet);
        return;
    }
    String error = (String) request.getAttribute("error");
    if (error == null) error = "";
    String filtro = request.getParameter("filtro");
    if (!"activa".equals(filtro) && !"inactiva".equals(filtro)) filtro = "Todas";
    int pagina = formulario ? Math.max(1, paginaValida(request.getParameter("pagina")))
                            : (Integer) request.getAttribute("paginaActual");
    String urlLista = servlet + "?filtro=" + filtro + "&amp;pagina=" + pagina;
    String titulo = formulario
        ? (request.getAttribute("rutaFormulario") == null
            || ((Ruta) request.getAttribute("rutaFormulario")).getIdRuta() == 0 ? "Nueva ruta" : "Editar ruta")
        : "Rutas";
%>

<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= titulo %> | OceanLink</title>
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/capacity_planner/rutas.css?v=4">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/barras.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/capacity_planner/rutas_formulario.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/capacity_planner/paginacion.css">
</head>
<body class="vista-rutas">

<jsp:include page="header.jsp" />

<div class="contenedor">
    <aside class="menu-lateral">
        <div class="contenido-menu">
            <h2>Menú</h2>
            <nav class="navegacion-lateral" aria-label="Menú principal">
                <a href="${pageContext.request.contextPath}/CapacityPlannerServlet">
                    Dashboard
                </a>
                <a href="${pageContext.request.contextPath}/ClienteServlet">
                    Clientes
                </a>
                <a href="${pageContext.request.contextPath}/SolicitudesServlet">
                    Solicitudes
                </a>

                <div class="grupo-menu">
                    <input type="checkbox" id="control-infraestructura"
                           class="control-submenu" checked>
                    <label for="control-infraestructura" class="titulo-grupo">
                        <span>Infraestructura</span>
                        <span class="flecha-submenu"></span>
                    </label>
                    <div class="contenido-submenu">
                        <a href="<%= servlet %>" class="subopcion activo">
                            Rutas
                        </a>
                        <a href="${pageContext.request.contextPath}/SegmentoServlet"
                           class="subopcion">Segmentos</a>
                        <a href="${pageContext.request.contextPath}/LandingStationServlet"
                           class="subopcion">Landing stations</a>
                    </div>
                </div>

                <a href="${pageContext.request.contextPath}/capacity_planner/servicios.jsp">
                    Servicios
                </a>
            </nav>
        </div>

        <div class="configuracion">
            <nav aria-label="Opciones del usuario">
                <a href="${pageContext.request.contextPath}/PerfilServlet">Perfil</a>
                <a href="${pageContext.request.contextPath}/LogoutServlet"
                   class="cerrar-sesion">Cerrar sesión</a>
            </nav>
        </div>
    </aside>

    <main class="contenido-principal pagina-rutas">
        <section class="encabezado-pagina">
            <div class="encabezado-panel">
                <h2>Capacity Planner</h2>
                <h1><%= titulo %></h1>
            </div>
            <% if (formulario) { %>
                <a class="boton secundario" href="<%= urlLista %>">Volver a rutas</a>
            <% } else { %>
                <a class="boton primario" href="<%= urlLista %>&amp;ventana=nuevo">+ Nueva ruta</a>
            <% } %>
        </section>

        <%
            List<Ruta> rutas = (List<Ruta>) request.getAttribute("listaRutas");
            Ruta rutaDetalle = (Ruta) request.getAttribute("rutaDetalle");
            int cantidad = (Integer) request.getAttribute("totalRegistros");
            String urlPagina = servlet + "?filtro=" + filtro + "&amp;pagina=";
        %>
        <% if ("1".equals(request.getParameter("guardado"))) { %>
            <p class="mensaje-exito">Ruta guardada.</p>
        <% } %>

        <% if ("1".equals(request.getParameter("eliminado"))) { %>
            <p class="mensaje-exito">Ruta eliminada.</p>
        <% } %>

        <% if (!error.isEmpty() && !formulario) { %>
            <p class="mensaje-error" role="alert"><%= texto(error) %></p>
        <% } %>

        <section class="barra-herramientas">
            <form method="get" action="<%= servlet %>" class="formulario-filtro">
                <label for="filtro">Estado:</label>
                <select id="filtro" name="filtro">
                    <option value="Todas"
                            <%= "Todas".equals(filtro) ? "selected" : "" %>>
                        Todas
                    </option>
                    <option value="activa"
                            <%= "activa".equals(filtro) ? "selected" : "" %>>
                        Activa
                    </option>
                    <option value="inactiva"
                            <%= "inactiva".equals(filtro) ? "selected" : "" %>>
                        Inactiva
                    </option>
                </select>
                <button class="boton secundario" type="submit">Filtrar</button>
            </form>
            <span><%= cantidad %> rutas</span>
        </section>

        <section class="contenedor-tabla">
            <table>
                <thead>
                <tr>
                    <th>ID</th>
                    <th>Nombre</th>
                    <th>Origen</th>
                    <th>Destino</th>
                    <th>Segmentos</th>
                    <th>Capacidad disponible</th>
                    <th>Estado</th>
                </tr>
                </thead>
                <tbody>
                <% for (Ruta ruta : rutas) { %>
                    <tr>
                        <td>
                            <a class="enlace-ruta"
                               href="<%= urlLista %>&amp;detalle=<%= ruta.getIdRuta() %>#detalle-ruta">
                                RUT-<%= ruta.getIdRuta() %>
                            </a>
                        </td>
                        <td><%= texto(ruta.getNombre()) %></td>
                        <td><%= texto(ruta.getNombreOrigen()) %></td>
                        <td><%= texto(ruta.getNombreDestino()) %></td>
                        <td><%= ruta.getSegmentos().size() %></td>
                        <td><%= ruta.getCapacidadDisponible() %> Gbps</td>
                        <td>
                            <span class="estado <%= texto(ruta.getEstado()) %>">
                                <%= "activa".equals(ruta.getEstado())
                                        ? "Activa" : "Inactiva" %>
                            </span>
                        </td>
                    </tr>
                <% } %>

                <% if (cantidad == 0) { %>
                    <tr>
                        <td colspan="7">No hay rutas con este estado.</td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </section>

        <%
            int totalPaginado = (Integer) request.getAttribute("totalRegistros");
            int paginaPaginada = (Integer) request.getAttribute("paginaActual");
            int paginasPaginadas = (Integer) request.getAttribute("totalPaginas");
            if (totalPaginado > 0) {
        %>
        <nav class="pagination-bar" aria-label="Paginación de resultados">
            <span class="pagination-info">
                Mostrando <%= request.getAttribute("registroInicio") %>–<%= request.getAttribute("registroFin") %>
                de <%= totalPaginado %> registros (Página <%= paginaPaginada %> de <%= paginasPaginadas %>)
            </span>
            <% if (paginasPaginadas > 1) { %>
                <div class="pagination-links">
                    <% if (paginaPaginada > 1) { %>
                        <a class="boton secundario" href="<%= urlPagina %><%= paginaPaginada - 1 %>">Anterior</a>
                    <% } %>
                    <% for (int numero = 1; numero <= paginasPaginadas; numero++) { %>
                        <% if (numero == paginaPaginada) { %>
                            <span class="boton primario" aria-current="page"><%= numero %></span>
                        <% } else { %>
                            <a class="boton secundario" href="<%= urlPagina %><%= numero %>"
                               aria-label="Página <%= numero %>"><%= numero %></a>
                        <% } %>
                    <% } %>
                    <% if (paginaPaginada < paginasPaginadas) { %>
                        <a class="boton secundario" href="<%= urlPagina %><%= paginaPaginada + 1 %>">Siguiente</a>
                    <% } %>
                </div>
            <% } %>
        </nav>
        <% } %>

        <% if (rutaDetalle != null) {
            int orden = 1;
        %>
        <section id="detalle-ruta" class="panel-detalle">
            <div class="encabezado-detalle">
                <h2><%= texto(rutaDetalle.getNombre()) %></h2>
                <a href="<%= urlLista %>" aria-label="Cerrar detalle">&times;</a>
            </div>

            <p class="resumen-ruta">
                <%= texto(rutaDetalle.getNombreOrigen()) %>
                →
                <%= texto(rutaDetalle.getNombreDestino()) %>
            </p>

            <h3>Segmentos de la ruta</h3>

            <div class="contenedor-tabla">
                <table>
                    <thead>
                    <tr>
                        <th>Orden</th>
                        <th>Segmento</th>
                        <th>Total</th>
                        <th>Ocupada</th>
                        <th>Reservada</th>
                        <th>Estado</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (Segmento segmento : rutaDetalle.getSegmentos()) { %>
                        <tr>
                            <td><%= orden++ %></td>
                            <td><%= texto(segmento.getCodigo()) %></td>
                            <td><%= segmento.getCapacidadTotal() %> Gbps</td>
                            <td><%= segmento.getCapacidadOcupada() %> Gbps</td>
                            <td><%= segmento.getCapacidadReservada() %> Gbps</td>
                            <td><%= texto(segmento.getEstado()) %></td>
                        </tr>
                    <% } %>

                    <% if (rutaDetalle.getSegmentos().isEmpty()) { %>
                        <tr>
                            <td colspan="6">Esta ruta no tiene segmentos.</td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>

            <p class="ayuda">
                Disponible = menor valor de (total − ocupada − reservada)
                entre los segmentos.
            </p>

            <div class="acciones">
                <a class="boton secundario"
                   href="<%= urlLista %>&amp;editar=<%= rutaDetalle.getIdRuta() %>">
                    Editar ruta
                </a>
                <button class="boton peligro" type="button"
                        popovertarget="confirmar-eliminar">
                    Eliminar ruta
                </button>
            </div>

            <div id="confirmar-eliminar" class="confirmacion" popover>
                <h2>Eliminar ruta</h2>
                <p>¿Deseas eliminar <%= texto(rutaDetalle.getNombre()) %>?</p>

                <form method="post" action="<%= servlet %>" class="acciones">
                    <input type="hidden" name="filtro" value="<%= filtro %>">
                    <input type="hidden" name="pagina" value="<%= pagina %>">
                    <input type="hidden" name="id_ruta"
                           value="<%= rutaDetalle.getIdRuta() %>">
                    <button class="boton secundario" type="button"
                            popovertarget="confirmar-eliminar"
                            popovertargetaction="hide">
                        Volver
                    </button>
                    <button class="boton peligro" name="accion"
                            value="eliminar" type="submit">
                        Eliminar
                    </button>
                </form>
            </div>
        </section>
        <% } %>
    </main>
</div>

</body>
</html>
