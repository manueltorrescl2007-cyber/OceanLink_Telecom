<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Dashboard | OceanLink</title>

    <link
        rel="stylesheet"
        href="${pageContext.request.contextPath}/css/capacity_planner/capacity_planner.css"
    >
</head>

<body>

<!-- Barra superior -->
<header class="barra-superior">

    <a
        href="${pageContext.request.contextPath}/"
        class="logo"
    >
        OceanLink
    </a>

    <div class="usuario">
        <div class="foto-usuario">CP</div>

        <div>
            <p class="nombre-usuario">
                <c:out value="${empty usuarioNombre ? 'Username' : usuarioNombre}"/>
            </p>

            <p class="rol-usuario">Capacity Planner</p>
        </div>
    </div>

</header>

<div class="contenedor">

    <!-- Menú lateral -->
    <aside class="menu-lateral">

        <div>
            <h2>Menú</h2>

            <nav>
                <a
                    href="${pageContext.request.contextPath}/capacity-planner"
                    class="activo"
                >
                    Dashboard
                </a>

                <a href="${pageContext.request.contextPath}/clientes">
                    Clientes
                </a>

                <a href="${pageContext.request.contextPath}/solicitudes">
                    Solicitudes
                </a>

                <a href="${pageContext.request.contextPath}/rutas">
                    Rutas
                </a>

                <a href="${pageContext.request.contextPath}/servicios">
                    Servicios
                </a>
            </nav>
        </div>

        <div class="configuracion">
            <h3>Configuración</h3>

            <a href="${pageContext.request.contextPath}/perfil">
                Perfil
            </a>

            <a href="${pageContext.request.contextPath}/cerrar-sesion">
                Cerrar sesión
            </a>
        </div>

    </aside>

    <!-- Contenido principal -->
    <main class="contenido-principal">

        <section class="encabezado-panel">
            <h2>Capacity Planner</h2>
            <h1>Dashboard</h1>
        </section>

        <!-- Mensajes enviados por el Servlet -->
        <c:if test="${not empty mensajeExito}">
            <div class="mensaje mensaje-exito">
                <c:out value="${mensajeExito}"/>
            </div>
        </c:if>

        <c:if test="${not empty mensajeError}">
            <div class="mensaje mensaje-error">
                <c:out value="${mensajeError}"/>
            </div>
        </c:if>

        <!-- Tarjetas -->
        <section class="tarjetas">

            <!-- Resumen -->
            <article class="tarjeta">
                <h3>Resumen</h3>

                <div class="fila">
                    <span>Solicitudes registradas</span>
                    <strong>
                        <c:out value="${empty totalSolicitudes ? 0 : totalSolicitudes}"/>
                    </strong>
                </div>

                <div class="fila">
                    <span>Pendientes de evaluación</span>
                    <strong>
                        <c:out value="${empty totalPendientes ? 0 : totalPendientes}"/>
                    </strong>
                </div>

                <div class="fila">
                    <span>Solicitudes aprobadas</span>
                    <strong>
                        <c:out value="${empty totalAprobadas ? 0 : totalAprobadas}"/>
                    </strong>
                </div>

                <div class="fila">
                    <span>Servicios activos</span>
                    <strong>
                        <c:out value="${empty totalServiciosActivos ? 0 : totalServiciosActivos}"/>
                    </strong>
                </div>
            </article>

            <!-- Estado de rutas -->
            <article class="tarjeta">
                <h3>Estado de rutas por capacidad</h3>

                <div class="fila">
                    <span>
                        <c:out value="${empty totalDisponibles ? 0 : totalDisponibles}"/>
                        disponibles
                    </span>

                    <span class="estado disponible"></span>
                </div>

                <div class="fila">
                    <span>
                        <c:out value="${empty totalLimitadas ? 0 : totalLimitadas}"/>
                        limitadas
                    </span>

                    <span class="estado limitada"></span>
                </div>

                <div class="fila">
                    <span>
                        <c:out value="${empty totalInsuficientes ? 0 : totalInsuficientes}"/>
                        insuficientes
                    </span>

                    <span class="estado insuficiente"></span>
                </div>
            </article>

            <!-- Acciones pendientes -->
            <article class="tarjeta acciones">

                <div class="encabezado-acciones">
                    <h3>Acciones pendientes</h3>

                    <span class="cantidad-acciones">
                        <c:out value="${empty cantidadAcciones ? 0 : cantidadAcciones}"/>
                    </span>
                </div>

                <ul class="lista-acciones">

                    <c:choose>

                        <c:when test="${not empty accionesPendientes}">

                            <c:forEach
                                var="accion"
                                items="${accionesPendientes}"
                            >
                                <li class="item-accion">

                                    <div class="informacion-accion">
                                        <strong>
                                            <c:out value="${accion.codigo}"/>
                                        </strong>

                                        <span>
                                            <c:out value="${accion.descripcion}"/>
                                        </span>
                                    </div>

                                    <span class="prioridad prioridad-${accion.prioridad}">
                                        <c:out value="${accion.prioridad}"/>
                                    </span>

                                </li>
                            </c:forEach>

                        </c:when>

                        <c:otherwise>
                            <li class="sin-acciones">
                                No hay acciones pendientes.
                            </li>
                        </c:otherwise>

                    </c:choose>

                </ul>

                <!-- Abre el formulario sin JavaScript -->
                <button
                    class="boton-nuevo"
                    type="button"
                    popovertarget="modalAccion"
                >
                    + Nuevo
                </button>

            </article>

        </section>

    </main>

</div>

<!-- Ventana para registrar una nueva acción -->
<div
    id="modalAccion"
    class="modal"
    popover
>

    <div class="contenido-modal">

        <div class="encabezado-modal">
            <h2>Nueva acción pendiente</h2>

            <button
                class="cerrar-modal"
                type="button"
                popovertarget="modalAccion"
                popovertargetaction="hide"
                aria-label="Cerrar"
            >
                &times;
            </button>
        </div>

        <form
            method="post"
            action="${pageContext.request.contextPath}/capacity-planner/acciones"
        >

            <div class="grupo-formulario">
                <label for="descripcionAccion">
                    Descripción de la acción
                </label>

                <input
                    type="text"
                    id="descripcionAccion"
                    name="descripcion"
                    placeholder="Ejemplo: Revisar disponibilidad de la ruta"
                    maxlength="80"
                    required
                >
            </div>

            <div class="grupo-formulario">
                <label for="prioridadAccion">
                    Prioridad
                </label>

                <select
                    id="prioridadAccion"
                    name="prioridad"
                    required
                >
                    <option value="">Seleccione una prioridad</option>
                    <option value="critica">Crítica</option>
                    <option value="alta">Alta</option>
                    <option value="media">Media</option>
                </select>
            </div>

            <div class="botones-modal">

                <button
                    class="boton-cancelar"
                    type="button"
                    popovertarget="modalAccion"
                    popovertargetaction="hide"
                >
                    Cancelar
                </button>

                <button
                    class="boton-guardar"
                    type="submit"
                >
                    Guardar acción
                </button>

            </div>

        </form>

    </div>

</div>

</body>
</html>
