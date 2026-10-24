<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.networkoperator.Incidencia" %>
<%
    ArrayList<Incidencia> listaIncidencias = (ArrayList<Incidencia>) request.getAttribute("listaIncidencias");
    String filtroSeveridad = (String) request.getAttribute("filtroSeveridad");
    if (listaIncidencias == null) { listaIncidencias = new ArrayList<>(); }
    if (filtroSeveridad == null) { filtroSeveridad = ""; }
    boolean hayFiltro = !filtroSeveridad.isEmpty();

    String[] severidades = {"Critica", "Alta", "Media", "Leve"};
    String servlet = request.getContextPath() + "/IncidenciaServlet";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OceanLink - Historial de Incidencias</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/barras.css">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/network_operator/network_operator.css?v=5">
</head>
<body>

<jsp:include page="header.jsp" />

<div class="contenedor">

    <jsp:include page="sidebar.jsp">
        <jsp:param name="activePage" value="historial" />
    </jsp:include>

    <main class="contenido-principal">

        <section class="encabezado-panel">
            <h2>Incidencias</h2>
            <h1>Historial de incidencias</h1>
        </section>

        <section class="card">
            <h2 class="card-title">Filtrar</h2>

            <form class="filtros" method="GET" action="<%= servlet %>">
                <input type="hidden" name="action" value="historial">
                <select name="severidad" aria-label="Filtrar por severidad">
                    <option value="">Todas las severidades</option>
                    <% for (String sev : severidades) { %>
                        <option value="<%= sev %>" <%= sev.equals(filtroSeveridad) ? "selected" : "" %>>
                            <%= "Critica".equals(sev) ? "Crítica" : sev %>
                        </option>
                    <% } %>
                </select>
                <button type="submit" class="btn-primary btn-chico">Filtrar</button>
                <% if (hayFiltro) { %>
                    <a class="btn-secundario" href="<%= servlet %>?action=historial">Limpiar</a>
                <% } %>
            </form>

            <div class="table-wrapper">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Segmento</th>
                            <th>Severidad</th>
                            <th>Cerrada el</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% if (listaIncidencias.isEmpty()) { %>
                        <tr>
                            <td colspan="4" class="vacio"><%= hayFiltro ? "No hay incidencias cerradas con ese filtro." : "Todavía no hay incidencias cerradas." %></td>
                        </tr>
                    <% } else {
                           for (Incidencia inc : listaIncidencias) { %>
                        <tr>
                            <td><a href="<%= servlet %>?action=detalle&id=<%= inc.getIdIncidencia() %>"><%= inc.getCodigo() %></a></td>
                            <td><%= inc.getCodigosSegmentos() %></td>
                            <td class="<%= inc.getClaseSeveridad() %>"><%= inc.getSeveridadTexto() %></td>
                            <td><%= inc.getFechaCierre() %></td>
                        </tr>
                    <%     }
                       } %>
                    </tbody>
                </table>
            </div>

            <p class="ayuda">Haz clic en el ID para ver el detalle de la incidencia.</p>
        </section>

    </main>

</div>

</body>
</html>
