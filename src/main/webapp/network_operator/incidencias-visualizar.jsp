<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.networkoperator.Incidencia" %>
<%@ page import="beans.networkoperator.Segmento" %>
<%
    ArrayList<Incidencia> listaIncidencias = (ArrayList<Incidencia>) request.getAttribute("listaIncidencias");
    ArrayList<Segmento> listaSegmentos = (ArrayList<Segmento>) request.getAttribute("listaSegmentos");
    String filtroSeveridad = (String) request.getAttribute("filtroSeveridad");
    Integer filtroIdSegmento = (Integer) request.getAttribute("filtroIdSegmento");
    if (listaIncidencias == null) { listaIncidencias = new ArrayList<>(); }
    if (listaSegmentos == null) { listaSegmentos = new ArrayList<>(); }
    if (filtroSeveridad == null) { filtroSeveridad = ""; }
    if (filtroIdSegmento == null) { filtroIdSegmento = -1; }
    boolean hayFiltro = !filtroSeveridad.isEmpty() || filtroIdSegmento > 0;

    String[] severidades = {"Critica", "Alta", "Media", "Leve"};
    String servlet = request.getContextPath() + "/IncidenciaServlet";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OceanLink - Visualizar Incidencias</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/barras.css">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/network_operator/network_operator.css?v=5">
</head>
<body>

<jsp:include page="header.jsp" />

<div class="contenedor">

    <jsp:include page="sidebar.jsp">
        <jsp:param name="activePage" value="visualizar" />
    </jsp:include>

    <main class="contenido-principal">

        <section class="encabezado-panel">
            <h2>Incidencias</h2>
            <h1>Incidencias activas</h1>
        </section>

        <section class="card">

            <form class="filtros" method="GET" action="<%= servlet %>">
                <input type="hidden" name="action" value="lista">
                <select name="severidad" aria-label="Filtrar por severidad">
                    <option value="">Todas las severidades</option>
                    <% for (String sev : severidades) { %>
                        <option value="<%= sev %>" <%= sev.equals(filtroSeveridad) ? "selected" : "" %>>
                            <%= "Critica".equals(sev) ? "Crítica" : sev %>
                        </option>
                    <% } %>
                </select>
                <select name="idSegmento" aria-label="Filtrar por segmento">
                    <option value="">Todos los segmentos</option>
                    <% for (Segmento s : listaSegmentos) { %>
                        <option value="<%= s.getIdSegmento() %>" <%= s.getIdSegmento() == filtroIdSegmento ? "selected" : "" %>>
                            <%= s.getCodigo() %>
                        </option>
                    <% } %>
                </select>
                <button type="submit" class="btn-primary btn-chico">Filtrar</button>
                <% if (hayFiltro) { %>
                    <a class="btn-secundario" href="<%= servlet %>">Limpiar</a>
                <% } %>
            </form>

            <div class="table-wrapper">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Segmento</th>
                            <th>Severidad</th>
                            <th>Estado</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% if (listaIncidencias.isEmpty()) { %>
                        <tr>
                            <td colspan="4" class="vacio"><%= hayFiltro ? "No hay incidencias activas con ese filtro." : "No hay incidencias activas." %></td>
                        </tr>
                    <% } else {
                           for (Incidencia inc : listaIncidencias) { %>
                        <tr>

                            <td><a href="<%= servlet %>?action=detalle&id=<%= inc.getIdIncidencia() %>"><%= inc.getCodigo() %></a></td>
                            <td><%= inc.getCodigosSegmentos() %></td>
                            <td class="<%= inc.getClaseSeveridad() %>"><%= inc.getSeveridadTexto() %></td>
                            <td><%= inc.getEstadoTexto() %></td>
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
