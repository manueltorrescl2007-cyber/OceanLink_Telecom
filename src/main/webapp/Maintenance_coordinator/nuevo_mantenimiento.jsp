<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Oceanlink - Nuevo mantenimiento</title>
    <link rel="stylesheet" href="../css/styles_MC.css">
</head>
<body>

<div class="app-layout">

    <jsp:include page="sidebar.jsp">
        <jsp:param name="activePage" value="nuevo" />
    </jsp:include>

    <div class="main-content">

        <jsp:include page="header.jsp">
            <jsp:param name="pageTitle" value="Registro y actualizaci&oacute;n de actividades de mantenimiento" />
        </jsp:include>

        <div class="content-container">
            <div class="card">
                <h2 class="card-title">Programar un nuevo mantenimiento</h2>

                <form action="ProgramarMantenimientoServlet" method="post" class="form-grid">

                    <div class="form-field">
                        <label for="segmento">Segmento <span class="required">*</span></label>
                        <select id="segmento" name="segmento" required>
                            <option value="" selected disabled>Seleccione un segmento</option>
                            <option value="LIM-VLP-01">LIM-VLP-01</option>
                            <option value="LIM-VLP-02">LIM-VLP-02</option>
                            <option value="LIM-VLP-03">LIM-VLP-03</option>
                        </select>
                    </div>

                    <div class="form-field">
                        <label for="tipoMantenimiento">Tipo de mantenimiento <span class="required">*</span></label>
                        <select id="tipoMantenimiento" name="tipoMantenimiento" required>
                            <option value="" selected disabled>Seleccione un tipo</option>
                            <option value="Preventivo">Preventivo</option>
                            <option value="Correctivo">Correctivo</option>
                            <option value="Predictivo">Predictivo</option>
                        </select>
                    </div>

                    <div class="form-field">
                        <label for="fechaInicio">Fecha de inicio <span class="required">*</span></label>
                        <input type="date" id="fechaInicio" name="fechaInicio" required>
                    </div>

                    <div class="form-field">
                        <label for="fechaFin">Fecha de fin estimada <span class="required">*</span></label>
                        <input type="date" id="fechaFin" name="fechaFin" required>
                    </div>

                    <div class="form-field">
                        <label for="prioridad">Prioridad <span class="required">*</span></label>
                        <select id="prioridad" name="prioridad" required>
                            <option value="" selected disabled>Seleccione una prioridad</option>
                            <option value="Leve">Leve</option>
                            <option value="Media">Media</option>
                            <option value="Alta">Alta</option>
                            <option value="Critica">Crítica</option>
                        </select>
                    </div>

                    <div class="form-field">
                        <!-- Campo vacío para mantener alineada la grilla de 2 columnas -->
                    </div>

                    <div class="form-field full-width">
                        <label for="notas">Notas / Descripción</label>
                        <textarea id="notas" name="notas" placeholder="Ingrese detalles adicionales..."></textarea>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">Programar</button>
                    </div>

                </form>
            </div>
        </div>

    </div>
</div>

</body>
</html>
