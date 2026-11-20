<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.networkoperator.Segmento" %>
<%@ page import="beans.networkoperator.Incidencia" %>
<%@ page import="beans.networkoperator.Servicio" %>
<%
    Segmento seg = (Segmento) request.getAttribute("segmento");
    ArrayList<Incidencia> listaIncidencias = (ArrayList<Incidencia>) request.getAttribute("listaIncidencias");
    ArrayList<Servicio> listaServicios = (ArrayList<Servicio>) request.getAttribute("listaServicios");
    if (listaIncidencias == null) { listaIncidencias = new ArrayList<>(); }
    if (listaServicios == null) { listaServicios = new ArrayList<>(); }

    String servletRed = request.getContextPath() + "/EstadoRedServlet";
    String servletInc = request.getContextPath() + "/IncidenciaServlet";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OceanLink - <%= seg != null ? seg.getCodigo() : "Segmento no encontrado" %></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/barras.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/network_operator/network_operator.css?v=6">
</head>
<body>

<jsp:include page="header.jsp" />

<div class="contenedor">

    <jsp:include page="sidebar.jsp">
        <jsp:param name="activePage" value="estado" />
    </jsp:include>

    <main class="contenido-principal">

        <section class="encabezado-panel">
            <h2>Estado de la red</h2>
            <h1>Detalle de segmento</h1>
        </section>

        <% if (seg == null) { %>

        <section class="card">
            <h2 class="card-title">Segmento no encontrado</h2>
            <p class="ayuda"><a href="<%= servletRed %>">Volver al estado de la red</a></p>
        </section>

        <% } else {
               String claseEstado = "badge-" + seg.getEstado().toLowerCase().replace(" ", "-");
        %>

        <section class="card">
            <p class="migas">
                <a href="<%= servletRed %>">Estado de la red</a> / <%= seg.getCodigo() %>
            </p>

            <div class="titulo-incidencia">
                <h3><%= seg.getCodigo() %></h3>
                <span class="badge <%= claseEstado %>"><%= seg.getEstado() %></span>
            </div>

            <p class="segment-context">
                Tramo: <strong><%= seg.getLandingInicial().getNombre() %> &rarr; <%= seg.getLandingFinal().getNombre() %></strong>
            </p>

            <div class="resumen-niveles">
                <div class="nivel-caja"><strong><%= seg.getCapacidadTotal() %></strong><span>Total (Gbps)</span></div>
                <div class="nivel-caja"><strong><%= seg.getCapacidadOcupada() %></strong><span>Ocupada (Gbps)</span></div>
                <div class="nivel-caja"><strong><%= seg.getCapacidadReservada() %></strong><span>Reservada (Gbps)</span></div>
                <div class="nivel-caja"><strong><%= seg.getCapacidadDisponible() %></strong><span>Disponible (Gbps)</span></div>
            </div>

            <p class="segment-context">Uso actual:</p>
            <div class="mini-barra">
                <div class="relleno nivel-<%= seg.getNivelUso() %>" style="width: <%= seg.getPorcentajeUso() %>%"></div>
            </div>
            <span class="texto-uso"><%= seg.getPorcentajeUso() %>%</span>

            <div class="dos-columnas">
                <div class="columna">

                    <h4>Incidencias activas</h4>
                    <% if (listaIncidencias.isEmpty()) { %>
                        <p class="ayuda">Este segmento no tiene incidencias activas.</p>
                    <% } else {
                           for (Incidencia inc : listaIncidencias) { %>
                    <div class="tarjeta">
                        <span><a href="<%= servletInc %>?action=detalle&id=<%= inc.getIdIncidencia() %>"><%= inc.getCodigo() %></a> · <%= inc.getTitulo() %></span>
                        <span class="badge <%= inc.getClaseSeveridad() %>"><%= inc.getSeveridadTexto() %></span>
                    </div>
                    <%     }
                       } %>
                </div>

                <div class="columna">

                    <h4>Servicios y clientes que usan el segmento</h4>
                    <% if (listaServicios.isEmpty()) { %>
                        <p class="ayuda">Ningún servicio activo pasa por este segmento.</p>
                    <% } else {
                           for (Servicio sv : listaServicios) { %>
                    <div class="tarjeta">
                        <span>SRV-<%= sv.getIdServicio() %></span>
                        <span><%= sv.getSolicitud().getCliente().getNombre() %></span>
                    </div>
                    <%     }
                       } %>
                </div>
            </div>
        </section>

        <% } %>

    </main>

</div>

</body>
</html>
