<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OceanLink - Visualizar Incidencias</title>
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
        <jsp:param name="activePage" value="visualizar" />
    </jsp:include>

    <%-- Pieza 3: contenido de la página --%>
    <main class="contenido-principal">

        <section class="encabezado-panel">
            <h2>Incidencias</h2>
            <h1>Incidencias activas</h1>
        </section>

        <section class="card">

            <div class="filtros">
                <select>
                    <option>Todas las severidades</option>
                    <option>Alta</option>
                    <option>Crítica</option>
                    <option>Media</option>
                </select>
                <select>
                    <option>Todos los segmentos</option>
                    <option>LIM-VLP-01</option>
                    <option>LIM-VLP-02</option>
                    <option>LIM-GYE-01</option>
                </select>
            </div>

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
                        <tr>
                            <td><a href="incidencias-detalle.jsp?id=INC-014">INC-014</a></td>
                            <td>LIM-VLP-02</td>
                            <td class="severidad-alta">Alta</td>
                            <td>En análisis</td>
                        </tr>
                        <tr>
                            <td><a href="incidencias-detalle.jsp?id=INC-013">INC-013</a></td>
                            <td>LIM-VLP-02</td>
                            <td class="severidad-critica">Crítica</td>
                            <td>En reparación</td>
                        </tr>
                        <tr>
                            <td><a href="incidencias-detalle.jsp?id=INC-011">INC-011</a></td>
                            <td>LIM-GYE-01</td>
                            <td class="severidad-media">Media</td>
                            <td>Reparación programada</td>
                        </tr>
                        <tr>
                            <td><a href="incidencias-detalle.jsp?id=INC-010">INC-010</a></td>
                            <td>LIM-GYE-04</td>
                            <td class="severidad-alta">Alta</td>
                            <td>Restaurado</td>
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
