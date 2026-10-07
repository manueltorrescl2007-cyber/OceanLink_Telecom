<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Dashboard | OceanLink</title>

    <!-- Estilos de las tarjetas del dashboard -->
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/capacity_planner/capacity_planner.css?v=2">

    <!-- Estilos comunes de las barras. Se cargan al final. -->
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/barras.css">
</head>

<body>

<!-- Este checkbox permite abrir y cerrar el menú sin JavaScript.
     El botón ☰ lo controla mediante for="controlMenu". -->
<input type="checkbox"
       id="controlMenu"
       class="control-menu"
       aria-label="Ocultar menú lateral">

<!-- ==================================================
     1. BARRA SUPERIOR
     ================================================== -->
<header class="barra-superior">

    <div class="zona-logo">

        <label for="controlMenu"
               class="boton-menu"
               title="Ocultar o mostrar menú">☰</label>

        <!-- contextPath agrega la ruta base de la aplicación -->
        <a href="${pageContext.request.contextPath}/capacity_planner/capacity_planner_jsp/capacity_planner.jsp"
           class="logo">
            OceanLink
        </a>
    </div>

    <!-- Datos de ejemplo. Después vendrán del usuario conectado. -->
    <div class="usuario">

        <div class="foto-usuario">CP</div>

        <div>
            <p class="nombre-usuario">Username</p>
            <p class="rol-usuario">Capacity Planner</p>
        </div>
    </div>

</header>

<!-- Agrupa el menú lateral y el contenido principal -->
<div class="contenedor">

    <!-- ==================================================
         2. MENÚ LATERAL
         ================================================== -->
    <aside class="menu-lateral">

        <div class="contenido-menu">

            <h2>Menú</h2>

            <nav class="navegacion-lateral"
                 aria-label="Menú principal">

                <!-- activo resalta la página que estamos viendo -->
                <a href="${pageContext.request.contextPath}/capacity_planner/capacity_planner_jsp/capacity_planner.jsp"
                   class="activo">
                    Dashboard
                </a>

                <a href="${pageContext.request.contextPath}/capacity_planner/capacity_planner_jsp/clientes.jsp">
                    Clientes
                </a>

                <a href="${pageContext.request.contextPath}/capacity_planner/capacity_planner_jsp/solicitudes.jsp">
                    Solicitudes
                </a>

                <!-- Infraestructura: agrupa las tres pantallas -->
                <div class="grupo-menu">

                    <!-- Controla la apertura del submenú -->
                    <input type="checkbox"
                           id="control-infraestructura"
                           class="control-submenu">

                    <!-- Al hacer clic, marca o desmarca el checkbox -->
                    <label for="control-infraestructura"
                           class="titulo-grupo">

                        <span>Infraestructura</span>
                        <span class="flecha-submenu"></span>

                    </label>

                    <!-- Opciones que aparecen al desplegar -->
                    <div class="contenido-submenu">

                        <a href="${pageContext.request.contextPath}/capacity_planner/capacity_planner_jsp/rutas.jsp"
                           class="subopcion">
                            Rutas
                        </a>

                        <a href="${pageContext.request.contextPath}/capacity_planner/capacity_planner_jsp/segmentos.jsp"
                           class="subopcion">
                            Segmentos
                        </a>

                        <a href="${pageContext.request.contextPath}/capacity_planner/capacity_planner_jsp/landing_stations.jsp"
                           class="subopcion">
                            Landing stations
                        </a>

                    </div>

                </div>

                <a href="${pageContext.request.contextPath}/capacity_planner/capacity_planner_jsp/servicios.jsp">
                    Servicios
                </a>

            </nav>
        </div>

        <!-- Opciones inferiores del usuario -->
        <div class="configuracion">
            <nav aria-label="Opciones del usuario">

                <!-- Pendiente: colocar la ruta real de Perfil -->
                <a href="#">Perfil</a>

                <!-- Por ahora lleva al login.
                     El cierre de sesión real se conectará después. -->
                <a href="${pageContext.request.contextPath}/login.jsp"
                   class="cerrar-sesion">
                    Cerrar sesión
                </a>

            </nav>
        </div>

    </aside>

    <!-- ==================================================
         3. CONTENIDO PRINCIPAL
         ================================================== -->
    <main class="contenido-principal">

        <section class="encabezado-panel">
            <h2>Capacity Planner</h2>
            <h1>Dashboard</h1>
        </section>

        <!-- Las tres tarjetas conservan el diseño existente -->
        <section class="tarjetas">

            <!-- ==========================================
                 4. RESUMEN
                 Los números son ejemplos para el mockup.
                 Después se calcularán consultando MySQL.
                 ========================================== -->
            <article class="tarjeta tarjeta-resumen">

                <h3>Resumen</h3>

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
                    <span>Pendientes por capacidad</span>
                    <strong>2</strong>
                </div>

                <div class="fila">
                    <span>Servicios activos</span>
                    <strong>2</strong>
                </div>

            </article>

            <!-- ==========================================
                 5. UTILIZACIÓN DE SEGMENTOS

                 Propuesta de cálculo:
                 (ocupada + reservada) / total * 100

                 Normal: menor al 80%.
                 Alta: del 80% al 95%, inclusive.
                 Crítica: mayor al 95%.

                 Los conteos siguientes son ejemplos.
                 ========================================== -->
            <article class="tarjeta tarjeta-segmentos">

                <h3>Estado de segmentos</h3>

                <div class="fila">
                    <span>25 estables</span>
                    <span class="estado disponible"
                          aria-label="Normal"></span>
                </div>

                <div class="fila">
                    <span>3 limitados</span>
                    <span class="estado limitada"
                          aria-label="Alta utilización"></span>
                </div>

                <div class="fila">
                    <span>2 críticos</span>
                    <span class="estado insuficiente"
                          aria-label="Utilización crítica"></span>
                </div>

                <div class="fila enlace-segmentos">
                    <a href="${pageContext.request.contextPath}/capacity_planner/capacity_planner_jsp/segmentos.jsp">
                        Ver segmentos →
                    </a>
                </div>

            </article>

            <!-- ==========================================
                 6. ACCIONES PENDIENTES

                 Ya no se registran manualmente.
                 Después se generarán según el estado
                 de cada solicitud consultada en MySQL.

                 Aquí mostramos ejemplos del resultado.
                 ========================================== -->
            <article class="tarjeta acciones">

                <div class="encabezado-acciones">
                    <h3>Acciones pendientes</h3>

                    <!-- Después mostrará el total obtenido
                         de la consulta de solicitudes -->
                    <span class="cantidad-acciones">4</span>
                </div>

                <ul class="lista-acciones">

                    <!-- Solicitud registrada -->
                    <li>
                        <div class="informacion-accion">

                            <!-- Por ahora abre la lista de solicitudes -->
                            <a href="${pageContext.request.contextPath}/capacity_planner/capacity_planner_jsp/solicitudes.jsp">
                                <strong>SOL-014</strong>
                            </a>

                            <span>Evaluar solicitud</span>
                        </div>
                    </li>

                    <!-- Solicitud en evaluación -->
                    <li>
                        <div class="informacion-accion">

                            <a href="${pageContext.request.contextPath}/capacity_planner/capacity_planner_jsp/solicitudes.jsp">
                                <strong>SOL-018</strong>
                            </a>

                            <span>Revisar capacidad de segmentos</span>
                        </div>
                    </li>

                    <!-- Solicitud pendiente por capacidad -->
                    <li>
                        <div class="informacion-accion">

                            <a href="${pageContext.request.contextPath}/capacity_planner/capacity_planner_jsp/solicitudes.jsp">
                                <strong>SOL-021</strong>
                            </a>

                            <span>Revisar alternativas de capacidad</span>
                        </div>
                    </li>

                    <!-- Solicitud aprobada -->
                    <li>
                        <div class="informacion-accion">

                            <a href="${pageContext.request.contextPath}/capacity_planner/capacity_planner_jsp/solicitudes.jsp">
                                <strong>SOL-022</strong>
                            </a>

                            <span>Gestionar reserva de capacidad</span>
                        </div>
                    </li>

                </ul>

                <!-- Reemplaza el botón "+ Nuevo".
                     Conserva su clase para usar el mismo diseño. -->
                <a href="${pageContext.request.contextPath}/capacity_planner/capacity_planner_jsp/solicitudes.jsp"
                   class="boton-nuevo">
                    Ver solicitudes
                </a>

            </article>

        </section>

    </main>

</div>

</body>
</html>
