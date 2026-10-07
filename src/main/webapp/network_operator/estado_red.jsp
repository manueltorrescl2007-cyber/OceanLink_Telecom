<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Oceanlink | Estado de la Red</title>
    <link rel="stylesheet" href="../css/estado_red.css">
</head>
<body class="app-page">

    <!-- 1. Configuramos la clave de la página activa -->
    <% request.setAttribute("activePage", "estado_red"); %>

    <!-- 2. Reemplazamos la barra lateral por la inclusión dinámica -->
    <jsp:include page="slidebar_netoperator.jsp" />

    <div class="content-wrapper">

        <header class="header">
            <h1 class="header-title">Utilización de la red y Visualizador de segmentos</h1>

            <div class="user-info">
                <span class="user-avatar" aria-hidden="true"></span>
                <div class="user-text">
                    <p class="user-name">Username</p>
                    <p class="user-role">Network Operator</p>
                </div>
            </div>
        </header>

        <main class="main-content">

            <section class="card chart-section">
                <div class="chart-header">
                    <h2 class="card-title">Utilización de la Red (50%)</h2>
                    <p class="stat-trend stat-trend-positive">↗ +4.2% los últimos 7 días</p>
                </div>

                <figure class="chart-figure">
                    <img class="chart-image" src="assets/network-usage-chart.png" alt="Gráfico de utilización de la red durante los últimos días">
                    <figcaption class="visually-hidden">Tendencia de utilización de la red</figcaption>
                </figure>
            </section>

            <section class="card segments-section">
                <h2 class="card-title">Segmentos</h2>

                <div class="table-wrapper">
                    <table class="data-table">
                        <caption class="visually-hidden">Utilización por segmento de red</caption>
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
