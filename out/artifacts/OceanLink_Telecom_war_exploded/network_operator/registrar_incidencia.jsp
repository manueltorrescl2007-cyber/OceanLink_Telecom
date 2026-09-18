<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Oceanlink | Registrar Incidencia</title>
    <link rel="stylesheet" href="../css/registrar_incidencia.css">
</head>
<% request.setAttribute("activePage", "registrar_incidencia"); %>
<body class="app-page">
<jsp:include page="slidebar_netoperator.jsp" />

    <div class="content-wrapper">

        <header class="header">
            <h1 class="header-title">Registrar Incidencia</h1>

            <div class="user-info">
                <span class="user-avatar" aria-hidden="true"></span>
                <div class="user-text">
                    <p class="user-name">Username</p>
                    <p class="user-role">Network Operator</p>
                </div>
            </div>
        </header>

        <main class="main-content">

            <section class="card">
                <h2 class="card-title">Registrar una nueva incidencia</h2>
                <p class="segment-context">Segmento: LIM-VLP-02</p>

                <form class="incident-form" action="#" method="POST">

                    <div class="form-row">
                        <div class="form-group">
                            <label for="segmentos">Segmento(s) *</label>
                            <select id="segmentos" name="segmentos" multiple required>
                                <option value="LIM-VLP-02" selected>LIM-VLP-02</option>
                                <option value="LIM-VLP-01">LIM-VLP-01</option>
                                <option value="LIM-GYE-01">LIM-GYE-01</option>
                                <option value="LIM-GYE-04">LIM-GYE-04</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="tipo-mantenimiento">Tipo de mantenimiento *</label>
                            <select id="tipo-mantenimiento" name="tipo-mantenimiento" required>
                                <option value="" selected disabled>Seleccionar</option>
                                <option value="preventivo">Preventivo</option>
                                <option value="correctivo">Correctivo</option>
                                <option value="predictivo">Predictivo</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="fecha-inicio">Fecha de inicio *</label>
                            <input type="date" id="fecha-inicio" name="fecha-inicio" required>
                        </div>

                        <div class="form-group">
                            <label for="fecha-fin">Fecha de fin estimada *</label>
                            <input type="date" id="fecha-fin" name="fecha-fin" required>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="severidad">Severidad *</label>
                            <select id="severidad" name="severidad" required>
                                <option value="" selected disabled>Seleccionar</option>
                                <option value="leve">Leve</option>
                                <option value="media">Media</option>
                                <option value="alta">Alta</option>
                                <option value="critica">Crítica</option>
                            </select>
                        </div>
                    </div>

                    <fieldset class="form-group form-group-full affected-services">
                        <legend>Servicios y clientes potencialmente afectados</legend>
                        <ul class="affected-services-list">
                            <li class="affected-service-item">
                                <span class="service-id">SRV-118</span>
                                <span class="client-name">Cliente XXYY</span>
                            </li>
                            <li class="affected-service-item">
                                <span class="service-id">SRV-121</span>
                                <span class="client-name">Cliente ZZUU</span>
                            </li>
                        </ul>
                    </fieldset>

                    <div class="form-group form-group-full">
                        <label for="notas">Notas / Descripción</label>
                        <textarea id="notas" name="notas" rows="5"></textarea>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn-primary">Registrar</button>
                    </div>

                </form>
            </section>

        </main>

    </div>

</body>
</html>
