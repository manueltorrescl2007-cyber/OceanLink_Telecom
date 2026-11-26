<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="daos.capacityplanner.HistorialSegmentoDao.Evento" %>
<%@ page import="daos.capacityplanner.HistorialSegmentoDao.Pagina" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.capacityplanner.Segmento" %>

<%!
    private String texto(String valor) {
        if (valor == null) return "";

        return valor.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String nivelUtilizacion(Segmento segmento) {
        return servlets.capacityplanner.SegmentoServlet.nivelUtilizacion(segmento);
    }

    private String claseUtilizacion(String nivel) {
        switch (nivel) {
            case "Crítica": return "fuera";
            case "Alta": return "degradado";
            case "Normal": return "operativo";
            default: return "";
        }
    }

    private double porcentajeUtilizacion(Segmento segmento) {
        long total = segmento.getCapacidadTotal();
        // Uso = ocupada + reservada (igual que el nivel de utilización)
        return total > 0 ? (segmento.getCapacidadOcupada() + segmento.getCapacidadReservada()) * 100.0 / total : 0;
    }
%>

<%
    String servlet = request.getContextPath() + "/SegmentoServlet";

    ArrayList<Segmento> segmentos =
            (ArrayList<Segmento>) request.getAttribute("listaSegmentos");

    if (segmentos == null) {
        response.sendRedirect(servlet);
        return;
    }

    String[] estados = {
            "Normal",
            "Alta",
            "Crítica"
    };

    String filtro = (String) request.getAttribute("filtroEstado");
    int pagina = (Integer) request.getAttribute("paginaActual");
    int cantidad = (Integer) request.getAttribute("totalRegistros");
    String filtroUrl = java.net.URLEncoder.encode(filtro, "UTF-8");
    String urlPagina = servlet + "?estado=" + filtroUrl + "&amp;pagina=";
    String urlLista = urlPagina + pagina;
%>

<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Segmentos | OceanLink</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/capacity_planner/segmentos.css?v=3">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/barras.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/capacity_planner/paginacion.css">
</head>
<body class="vista-segmentos">
<jsp:include page="/comun/header.jsp" />
<div class="contenedor">
    <aside class="menu-lateral">
        <div class="contenido-menu">
            <h2>Menú</h2>
            <nav class="navegacion-lateral" aria-label="Menú principal">
                <a href="${pageContext.request.contextPath}/CapacityPlannerServlet">Dashboard</a>
                <a href="${pageContext.request.contextPath}/ClienteServlet">Clientes</a>
                <a href="${pageContext.request.contextPath}/SolicitudesServlet">Solicitudes</a>
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
        <div class="configuracion">
            <nav aria-label="Opciones del usuario">
                <a href="${pageContext.request.contextPath}/PerfilServlet">Perfil</a>
                <a href="${pageContext.request.contextPath}/LogoutServlet" class="cerrar-sesion">Cerrar sesión</a>
            </nav>
        </div>
    </aside>

    <main class="contenido-principal pagina-segmentos">
        <% if (request.getAttribute("historialSegmento") != null) { %>
            <%
                Segmento segmentoHistorial = (Segmento) request.getAttribute("segmentoDetalle");
                Pagina historial = (Pagina) request.getAttribute("historialSegmento");
                List<Evento> eventos = historial.eventos();
                String urlHistorial = urlLista + "&amp;detalle=" + segmentoHistorial.getIdSegmento()
                        + "&amp;accion=historial&amp;paginaHistorial=";
                DateTimeFormatter formatoFecha = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
            %>
            <section class="historial-segmento">
                <div class="encabezado-pagina">
                    <div class="encabezado-panel">
                        <h2>Capacity Planner</h2>
                        <h1>Historial del segmento · <%= texto(segmentoHistorial.getCodigo()) %></h1>
                    </div>
                    <a class="boton secundario"
                       href="<%= urlLista %>&amp;detalle=<%= segmentoHistorial.getIdSegmento() %>#detalle">
                        Volver al detalle
                    </a>
                </div>

                <div class="panel-detalle datos-detalle">
                    <div>
                        <span>Estación inicial</span>
                        <strong><%= texto(segmentoHistorial.getNombreInicial()) %></strong>
                    </div>
                    <div>
                        <span>Estación final</span>
                        <strong><%= texto(segmentoHistorial.getNombreFinal()) %></strong>
                    </div>
                    <div>
                        <span>Capacidad total</span>
                        <strong><%= segmentoHistorial.getCapacidadTotal() %> Gbps</strong>
                    </div>
                    <div>
                        <span>Utilización actual</span>
                        <strong>
                            <% if (segmentoHistorial.getCapacidadTotal() > 0) { %>
                                <%= String.format(java.util.Locale.forLanguageTag("es-PE"), "%.2f",
                                                  porcentajeUtilizacion(segmentoHistorial)) %> % ·
                            <% } %>
                            <%= nivelUtilizacion(segmentoHistorial) %>
                        </strong>
                    </div>
                </div>

                <section class="contenedor-tabla">
                    <table aria-label="Eventos del segmento">
                        <thead>
                            <tr>
                                <th>Fecha y hora</th>
                                <th>Evento</th>
                                <th>Referencia</th>
                                <th>Cambio en el segmento</th>
                                <th>Reservada después</th>
                                <th>Ocupación después</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Evento evento : eventos) { %>
                                <tr>
                                    <td><%= evento.fecha().format(formatoFecha) %></td>
                                    <td><%= texto(evento.nombre()) %></td>
                                    <td><%= texto(evento.referencia()) %></td>
                                    <td>
                                        <% if (evento.cambioOcupada() != 0) { %>
                                            <%= String.format("%+d", evento.cambioOcupada()) %> Gbps ocupados
                                        <% } %>
                                        <% if (evento.cambioReservada() != 0) { %>
                                            <%= String.format("%+d", evento.cambioReservada()) %> Gbps reservados
                                        <% } %>
                                        <% if (evento.cambioOcupada() == 0 && evento.cambioReservada() == 0) { %>
                                            Sin cambio de capacidad
                                        <% } %>
                                    </td>
                                    <td><%= evento.reservada() %> Gbps</td>
                                    <td>
                                        <%= evento.ocupada() %> de <%= evento.total() %> Gbps
                                        <% if (evento.total() > 0) { %>
                                            · <%= String.format(java.util.Locale.forLanguageTag("es-PE"), "%.2f",
                                                evento.ocupada() * 100.0 / evento.total()) %> %
                                        <% } %>
                                    </td>
                                </tr>
                            <% } %>
                            <% if (eventos.isEmpty()) { %>
                                <tr><td colspan="6">Todavía no hay eventos registrados para este segmento.</td></tr>
                            <% } %>
                        </tbody>
                    </table>
                </section>

                <% if (!eventos.isEmpty()) { %>
                    <nav class="pagination-bar" aria-label="Paginación del historial">
                        <span class="pagination-info">
                            Mostrando <%= historial.desde() + 1 %>–<%= historial.desde() + eventos.size() %>
                            de <%= historial.total() %> eventos
                            (Página <%= historial.numero() %> de <%= historial.totalPaginas() %>)
                        </span>
                        <% if (historial.totalPaginas() > 1) { %>
                            <div class="pagination-links">
                                <% if (historial.numero() > 1) { %>
                                    <a class="boton secundario" href="<%= urlHistorial %><%= historial.numero() - 1 %>">Anterior</a>
                                <% } %>
                                <% for (int numero = Math.max(1, historial.numero() - 2);
                                        numero <= Math.min(historial.totalPaginas(), historial.numero() + 2); numero++) { %>
                                    <% if (numero == historial.numero()) { %>
                                        <span class="boton primario" aria-current="page"><%= numero %></span>
                                    <% } else { %>
                                        <a class="boton secundario" href="<%= urlHistorial %><%= numero %>"
                                           aria-label="Página <%= numero %>"><%= numero %></a>
                                    <% } %>
                                <% } %>
                                <% if (historial.numero() < historial.totalPaginas()) { %>
                                    <a class="boton secundario" href="<%= urlHistorial %><%= historial.numero() + 1 %>">Siguiente</a>
                                <% } %>
                            </div>
                        <% } %>
                    </nav>
                <% } %>
            </section>
        <% } else { %>
        <section class="encabezado-pagina">
            <div class="encabezado-panel">
                <h2>Capacity Planner</h2>
                <h1>Segmentos</h1>
            </div>
        </section>

        <div class="barra-herramientas">
            <form action="<%= servlet %>" method="get" class="formulario-filtro">
                <label for="filtroEstado">Nivel de utilización:</label>
                <select id="filtroEstado" name="estado">
                    <option value="">Todos</option>
                    <% for (String estado : estados) { %>
                        <option value="<%= estado %>" <%= estado.equals(filtro) ? "selected" : "" %>>
                            <%= estado %>
                        </option>
                    <% } %>
                </select>
                <button class="boton secundario" type="submit">Filtrar</button>
            </form>
            <span><%= cantidad %> segmentos</span>
        </div>

        <section class="contenedor-tabla">
            <table>
                <thead>
                    <tr>
                        <th>Código</th>
                        <th>Inicio</th>
                        <th>Final</th>
                        <th>Total</th>
                        <th>Ocupada</th>
                        <th>Reservada</th>
                        <th>Disponible</th>
                        <th>Nivel de utilización</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Segmento segmento : segmentos) {
                        String nivel = nivelUtilizacion(segmento);
                    %>
                        <tr>
                            <td>
                                <a class="enlace-segmento"
                                   href="<%= urlLista %>&amp;detalle=<%= segmento.getIdSegmento() %>#detalle">
                                    <%= texto(segmento.getCodigo()) %>
                                </a>
                            </td>
                            <td><%= texto(segmento.getNombreInicial()) %></td>
                            <td><%= texto(segmento.getNombreFinal()) %></td>
                            <td><%= segmento.getCapacidadTotal() %> Gbps</td>
                            <td><%= segmento.getCapacidadOcupada() %> Gbps</td>
                            <td><%= segmento.getCapacidadReservada() %> Gbps</td>
                            <td><strong><%= segmento.getCapacidadDisponible() %> Gbps</strong></td>
                            <td><span class="estado <%= claseUtilizacion(nivel) %>"><%= nivel %></span></td>
                        </tr>
                    <% } %>

                    <% if (cantidad == 0) { %>
                        <tr>
                            <td colspan="8">No hay segmentos con este estado.</td>
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

        <% Segmento segmento = (Segmento) request.getAttribute("segmentoDetalle");
           if (segmento != null) {
               String nivel = nivelUtilizacion(segmento);
               String clase = claseUtilizacion(nivel);
               double porcentaje = porcentajeUtilizacion(segmento);
        %>
            <section class="panel-detalle" id="detalle">
                <div class="encabezado-detalle">
                    <h2><%= texto(segmento.getCodigo()) %></h2>
                    <a href="<%= urlLista %>" aria-label="Cerrar detalle">×</a>
                </div>

                <div class="datos-detalle">
                    <div>
                        <span>ID del segmento</span>
                        <strong><%= segmento.getIdSegmento() %></strong>
                    </div>
                    <div>
                        <span>Estación inicial</span>
                        <strong><%= texto(segmento.getNombreInicial()) %></strong>
                    </div>
                    <div>
                        <span>Estación final</span>
                        <strong><%= texto(segmento.getNombreFinal()) %></strong>
                    </div>
                    <div>
                        <span>Total</span>
                        <strong><%= segmento.getCapacidadTotal() %> Gbps</strong>
                    </div>
                    <div>
                        <span>Ocupada</span>
                        <strong><%= segmento.getCapacidadOcupada() %> Gbps</strong>
                    </div>
                    <div>
                        <span>Reservada</span>
                        <strong><%= segmento.getCapacidadReservada() %> Gbps</strong>
                    </div>
                    <div>
                        <span>Disponible</span>
                        <strong><%= segmento.getCapacidadDisponible() %> Gbps</strong>
                    </div>
                </div>

                <p class="ayuda">Disponible = total − ocupada − reservada.</p>

                <div class="pie-detalle-segmento">
                    <div class="utilizacion-detalle">
                        <strong>Nivel de utilización</strong>
                        <div class="utilizacion-indicador">
                            <% if (segmento.getCapacidadTotal() > 0) { %>
                                <progress class="<%= clase %>" max="100"
                                          value="<%= Math.max(0, Math.min(100, porcentaje)) %>"
                                          aria-label="Utilización del segmento">
                                </progress>
                                <strong><%= String.format(java.util.Locale.forLanguageTag("es-PE"), "%.2f", porcentaje) %> %</strong>
                            <% } %>
                            <span class="estado <%= clase %>"><%= nivel %></span>
                        </div>
                    </div>
                    <a class="boton primario"
                       href="<%= urlLista %>&amp;detalle=<%= segmento.getIdSegmento() %>&amp;accion=historial">
                        Historial del segmento
                    </a>
                </div>
            </section>
        <% } %>
        <% } %>
    </main>
</div>
</body>
</html>
