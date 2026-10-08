<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OceanLink - Historial de Incidencias</title>
    <%-- 1. Estilos comunes (barra superior y menú lateral) --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/barras.css">
    <%-- 2. Estilos del contenido del Network Operator --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/network_operator/network_operator.css">
</head>
<body>

<%-- Pieza 1: barra superior --%>
<jsp:include page="header.jsp" />

<div class="contenedor">

    <%-- Pieza 2: menú lateral (resalta la opción actual) --%>
    <jsp:include page="sidebar.jsp">
        <jsp:param name="activePage" value="historial" />
    </jsp:include>

    <%-- Pieza 3: contenido de la página --%>
    <main class="contenido-principal">

        <section class="encabezado-panel">
            <h2>Incidencias</h2>
            <h1>Historial de incidencias</h1>
        </section>

        <section class="card">
            <h2 class="card-title">Filtrar</h2>

            <div class="filtros">
                <input type="date">
                <input type="date">
                <select>
                    <option>Severidad</option>
                    <option>Alta</option>
                    <option>Crítica</option>
                    <option>Media</option>
                </select>
                <select>
                    <option>Segmento</option>
                    <option>LIM-VLP-01</option>
                    <option>LIM-VLP-02</option>
                    <option>LIM-GYE-01</option>
                    <option>LIM-GYE-04</option>
                </select>
            </div>

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
                        <tr>
                            <td><a href="incidencias-detalle.jsp?id=INC-009">INC-009</a></td>
                            <td>LIM-VLP-01</td>
                            <td class="severidad-media">Media</td>
                            <td>18 ago 2026</td>
                        </tr>
                        <tr>
                            <td><a href="incidencias-detalle.jsp?id=INC-008">INC-008</a></td>
                            <td>LIM-VLP-02</td>
                            <td class="severidad-critica">Crítica</td>
                            <td>13 jul 2026</td>
                        </tr>
                        <tr>
                            <td><a href="incidencias-detalle.jsp?id=INC-007">INC-007</a></td>
                            <td>LIM-GYE-01</td>
                            <td class="severidad-media">Media</td>
                            <td>25 ago 2025</td>
                        </tr>
                        <tr>
                            <td><a href="incidencias-detalle.jsp?id=INC-006">INC-006</a></td>
                            <td>LIM-GYE-04</td>
                            <td class="severidad-alta">Alta</td>
                            <td>5 jul 2025</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <p class="ayuda">Haz clic en el ID para ver el detalle de la incidencia.</p>
        </section>

    </main>

</div>

</body>
</html>
