<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OceanLink - INC-014</title>
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
            <h1>Detalle de incidencia</h1>
        </section>

        <section class="card">
            <p class="migas">Incidencias / Visualizar / INC-014</p>

            <div class="titulo-incidencia">
                <h3>INC-014</h3>
                <span class="badge severidad-alta">Alta</span>
            </div>

            <!-- Stepper: flujo de la incidencia -->
            <div class="stepper">
                <div class="paso completado">
                    <div class="circulo">&#10003;</div>
                    <p>Detectada</p>
                </div>
                <div class="paso actual">
                    <div class="circulo">2</div>
                    <p>En análisis</p>
                </div>
                <div class="paso">
                    <div class="circulo">3</div>
                    <p>Rep. prog.</p>
                </div>
                <div class="paso">
                    <div class="circulo">4</div>
                    <p>En rep.</p>
                </div>
                <div class="paso">
                    <div class="circulo">5</div>
                    <p>Restaurado</p>
                </div>
                <div class="paso">
                    <div class="circulo">6</div>
                    <p>Cerrada</p>
                </div>
            </div>

            <!-- Dos columnas: servicios afectados / bitácora -->
            <div class="dos-columnas">
                <div class="columna">
                    <h4>Servicios y clientes afectados</h4>
                    <div class="tarjeta">
                        <span>SRV-118</span>
                        <span>Cliente XXYY</span>
                    </div>
                    <div class="tarjeta">
                        <span>SRV-121</span>
                        <span>Cliente ZZUU</span>
                    </div>
                </div>

                <div class="columna">
                    <h4>Bitácora</h4>
                    <div class="registro">
                        <strong>10:32 - J. Ramos</strong>
                        <p>Caída de fibra óptica detectada.</p>
                    </div>
                    <input type="text" class="bitacora-input" placeholder="Agregar observación...">
                </div>
            </div>
        </section>

    </main>

</div>

</body>
</html>
