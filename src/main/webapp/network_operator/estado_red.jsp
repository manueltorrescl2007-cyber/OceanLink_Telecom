<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OceanLink - Estado de la Red</title>

    <%-- Estilos de tu contenido (temporal, en el paso 4 lo unificamos) --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/network_operator/network_operator.css">    <%-- Estilos comunes de barra y menú: SIEMPRE al final para que ganen --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/barras.css">
</head>
<body>

<%-- Pieza 1: barra superior --%>
<jsp:include page="header.jsp" />

<div class="contenedor">

    <%-- Pieza 2: menú lateral, indicando qué opción resaltar --%>
    <jsp:include page="sidebar.jsp">
        <jsp:param name="activePage" value="estado" />
    </jsp:include>

    <%-- Pieza 3: tu contenido --%>
    <main class="contenido-principal">

        <div class="encabezado-panel">
            <h1>Utilización de la red y Visualizador de segmentos</h1>
        </div>

        <section class="card chart-section">
            <div class="chart-header">
                <h2 class="card-title">Utilización de la Red (50%)</h2>
                <p class="stat-trend stat-trend-positive">↗ +4.2% los últimos 7 días</p>
            </div>

            <figure class="chart-figure">
                <img class="chart-image"
                     src="${pageContext.request.contextPath}/img/grafico_utilizacion.svg"
                     alt="Gráfico de utilización de la red en los últimos 7 días: sube de 45.8% a 50%">
            </figure>
        </section>

        <section class="card segments-section">
            <h2 class="card-title">Segmentos</h2>

            <div class="table-wrapper">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th scope="col">Segmento</th>
                            <th scope="col">Uso</th>
                            <th scope="col">Estado</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>LIM-VLP-02</td>
                            <td>91%</td>
                            <td><span class="badge badge-limitada">Limitada</span></td>
                        </tr>
                        <tr>
                            <td>LIM-VLP-01</td>
                            <td>65%</td>
                            <td><span class="badge badge-disponible">Disponible</span></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </section>

    </main>

</div>

</body>
</html>
