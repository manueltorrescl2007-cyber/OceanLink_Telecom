<%@ page contentType="text/html;charset=UTF-8" language="java" %>

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
    <link
        rel="stylesheet"
        href="../../css/capacity_planner/comun.css"
    >
</head>

<body>

<!-- Barra superior -->
<header class="barra-superior">

    <div class="zona-logo">

        <!-- Control para ocultar o mostrar el menú -->
        <label
            for="controlMenu"
            class="boton-menu"
            title="Ocultar o mostrar menú"
        >
            ☰
        </label>

        <a
            href="${pageContext.request.contextPath}/capacity_planner/capacity_planner_jsp/capacity_planner.jsp"
            class="logo"
        >
            OceanLink
        </a>

    </div>

    <div class="usuario">

        <div class="foto-usuario">
            CP
        </div>

        <div>
            <p class="nombre-usuario">Username</p>
            <p class="rol-usuario">Capacity Planner</p>
        </div>

    </div>

</header>

<!-- Checkbox invisible para controlar el menú sin JavaScript -->
<input
    type="checkbox"
    id="controlMenu"
    class="control-menu"
>

<div class="contenedor">

    <!-- Menú lateral -->
    <aside class="menu-lateral">

        <div class="contenido-menu">

            <h2>Menú</h2>

            <nav>

                <a
                    href="${pageContext.request.contextPath}/capacity_planner/capacity_planner_jsp/capacity_planner.jsp"
                    class="activo"
                >
                    Dashboard
                </a>

                <a
                    href="${pageContext.request.contextPath}/capacity_planner/capacity_planner_jsp/clientes.jsp"
                >
                    Clientes
                </a>

                <a
                    href="${pageContext.request.contextPath}/capacity_planner/capacity_planner_jsp/solicitudes.jsp"
                >
                    Solicitudes
                </a>

                <a
                    href="${pageContext.request.contextPath}/capacity_planner/capacity_planner_jsp/rutas.jsp"
                >
                    Rutas
                </a>

                <a
                    href="${pageContext.request.contextPath}/capacity_planner/capacity_planner_jsp/servicios.jsp"
                >
                    Servicios
                </a>

            </nav>

        </div>

        <div class="configuracion">

            <h3>Configuración</h3>

            <a href="#">
                Perfil
            </a>

            <a href="${pageContext.request.contextPath}/index.html">
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

        <!-- Tarjetas del dashboard -->
        <section class="tarjetas">

            <!-- Resumen -->
            <article class="tarjeta">

                <h3>Resumen</h3>

                <!-- Datos de prueba -->
                <div class="fila">
                    <span>Solicitudes registradas</span>
                    <strong>12</strong>
                </div>

                <div class="fila">
                    <span>Pendientes de evaluación</span>
                    <strong>4</strong>
                </div>

                <div class="fila">
                    <span>Solicitudes aprobadas</span>
                    <strong>6</strong>
                </div>

                <div class="fila">
                    <span>Servicios activos</span>
                    <strong>2</strong>
                </div>

            </article>

            <!-- Estado de las rutas -->
            <article class="tarjeta">

                <h3>Estado de rutas por capacidad</h3>

                <!-- Caso de prueba: ruta disponible -->
                <div class="fila">
                    <span>8 disponibles</span>
                    <span
                        class="estado disponible"
                        title="Disponible"
                    ></span>
                </div>

                <!-- Caso de prueba: ruta limitada -->
                <div class="fila">
                    <span>3 limitadas</span>
                    <span
                        class="estado limitada"
                        title="Limitada"
                    ></span>
                </div>

                <!-- Caso de prueba: ruta insuficiente -->
                <div class="fila">
                    <span>2 insuficientes</span>
                    <span
                        class="estado insuficiente"
                        title="Insuficiente"
                    ></span>
                </div>

            </article>

            <!-- Acciones pendientes -->
            <article class="tarjeta acciones">

                <div class="encabezado-acciones">

                    <h3>Acciones pendientes</h3>

                    <span class="cantidad-acciones">
                        4
                    </span>

                </div>

                <ul class="lista-acciones">

                    <!-- Caso de prueba 1 -->
                    <li class="item-accion">

                        <div class="informacion-accion">
                            <strong>SOL-014</strong>
                            <span>Verificar capacidad</span>
                        </div>

                        <span class="prioridad prioridad-critica">
                            Crítica
                        </span>

                    </li>

                    <!-- Caso de prueba 2 -->
                    <li class="item-accion">

                        <div class="informacion-accion">
                            <strong>SOL-018</strong>
                            <span>Seleccionar ruta</span>
                        </div>

                        <span class="prioridad prioridad-alta">
                            Alta
                        </span>

                    </li>

                    <!-- Caso de prueba 3 -->
                    <li class="item-accion">

                        <div class="informacion-accion">
                            <strong>SOL-021</strong>
                            <span>Confirmar reserva</span>
                        </div>

                        <span class="prioridad prioridad-media">
                            Media
                        </span>

                    </li>

                    <!-- Caso de prueba 4 -->
                    <li class="item-accion">

                        <div class="informacion-accion">
                            <strong>SOL-022</strong>
                            <span>Revisar disponibilidad</span>
                        </div>

                        <span class="prioridad prioridad-alta">
                            Alta
                        </span>

                    </li>

                </ul>

                <!-- Abre la ventana sin JavaScript -->
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
                aria-label="Cerrar ventana"
            >
                &times;
            </button>

        </div>

        <!--
            Este formulario es visual.
            Posteriormente se conectará con un Servlet.
        -->
        <form action="#" method="post">

            <div class="grupo-formulario">

                <label for="codigoAccion">
                    Código
                </label>

                <input
                    type="text"
                    id="codigoAccion"
                    name="codigo"
                    placeholder="Ejemplo: SOL-023"
                    maxlength="15"
                    required
                >

            </div>

            <div class="grupo-formulario">

                <label for="descripcionAccion">
                    Descripción de la acción
                </label>

                <input
                    type="text"
                    id="descripcionAccion"
                    name="descripcion"
                    placeholder="Ejemplo: Revisar disponibilidad de ruta"
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
                    <option value="">
                        Seleccione una prioridad
                    </option>

                    <option value="critica">
                        Crítica
                    </option>

                    <option value="alta">
                        Alta
                    </option>

                    <option value="media">
                        Media
                    </option>
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
