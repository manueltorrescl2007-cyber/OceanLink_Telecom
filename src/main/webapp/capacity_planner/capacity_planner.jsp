<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.Solicitud" %>
<%
    String servlet = request.getContextPath() + "/CapacityPlannerServlet";

    if (request.getAttribute("totalSolicitudes") == null) {
        response.sendRedirect(servlet);
        return;
    }

    int totalSolicitudes =
            (Integer) request.getAttribute("totalSolicitudes");

    int pendientesEvaluacion =
            (Integer) request.getAttribute("pendientesEvaluacion");

    int solicitudesAprobadas =
            (Integer) request.getAttribute("solicitudesAprobadas");

    int pendientesCapacidad =
            (Integer) request.getAttribute("pendientesCapacidad");

    int serviciosActivos =
            (Integer) request.getAttribute("serviciosActivos");

    int segmentosEstables =
            (Integer) request.getAttribute("segmentosEstables");

    int segmentosLimitados =
            (Integer) request.getAttribute("segmentosLimitados");

    int segmentosCriticos =
            (Integer) request.getAttribute("segmentosCriticos");

    ArrayList<Solicitud> acciones =
            (ArrayList<Solicitud>) request.getAttribute("accionesPendientes");
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Dashboard | OceanLink</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/capacity_planner/capacity_planner.css?v=2">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/barras.css">
</head>
<body>

<input type="checkbox"
       id="controlMenu"
       class="control-menu"
       aria-label="Ocultar menú lateral">

<header class="barra-superior">
    <div class="zona-logo">
        <label for="controlMenu"
               class="boton-menu"
               title="Ocultar o mostrar menú">☰</label>

        <a href="<%= servlet %>" class="logo">OceanLink</a>
    </div>

    <div class="usuario">
        <div class="foto-usuario">CP</div>
        <div>
            <p class="nombre-usuario">Username</p>
            <p class="rol-usuario">Capacity Planner</p>
        </div>
    </div>
</header>

<div class="contenedor">
    <aside class="menu-lateral">
        <div class="contenido-menu">
            <h2>Menú</h2>

            <nav class="navegacion-lateral" aria-label="Menú principal">
                <a href="<%= servlet %>" class="activo">
                    Dashboard
                </a>

                <a href="${pageContext.request.contextPath}/ClienteServlet">
                    Clientes
                </a>

                <a href="${pageContext.request.contextPath}/SolicitudesServlet">
                    Solicitudes
                </a>

                <div class="grupo-menu">
                    <input type="checkbox"
                           id="control-infraestructura"
                           class="control-submenu">

                    <label for="control-infraestructura" class="titulo-grupo">
                        <span>Infraestructura</span>
                        <span class="flecha-submenu"></span>
                    </label>

                    <div class="contenido-submenu">
                        <a href="${pageContext.request.contextPath}/RutaServlet"
                           class="subopcion">
                            Rutas
                        </a>

                        <a href="${pageContext.request.contextPath}/SegmentoServlet"
                           class="subopcion">
                            Segmentos
                        </a>

                        <a href="${pageContext.request.contextPath}/LandingStationServlet"
                           class="subopcion">
                            Landing stations
                        </a>
                    </div>
                </div>

                <a href="${pageContext.request.contextPath}/ServicioServlet">
                    Servicios
                </a>
            </nav>
        </div>

        <div class="configuracion">
            <nav aria-label="Opciones del usuario">
                <a href="#">Perfil</a>

                <a href="${pageContext.request.contextPath}/login.jsp"
                   class="cerrar-sesion">
                    Cerrar sesión
                </a>
            </nav>
        </div>
    </aside>

    <main class="contenido-principal">
        <section class="encabezado-panel">
            <h2>Capacity Planner</h2>
            <h1>Dashboard</h1>
        </section>

        <section class="tarjetas">

            <!-- Resumen consultado desde MySQL -->
            <article class="tarjeta tarjeta-resumen">
                <h3>Resumen</h3>

                <div class="fila">
                    <span>Total de solicitudes</span>
                    <strong><%= totalSolicitudes %></strong>
                </div>

                <div class="fila">
                    <span>Pendientes de evaluación</span>
                    <strong><%= pendientesEvaluacion %></strong>
                </div>

                <div class="fila">
                    <span>Solicitudes aprobadas</span>
                    <strong><%= solicitudesAprobadas %></strong>
                </div>

                <div class="fila">
                    <span>Pendientes por capacidad</span>
                    <strong><%= pendientesCapacidad %></strong>
                </div>

                <div class="fila">
                    <span>Servicios activos</span>
                    <strong><%= serviciosActivos %></strong>
                </div>
            </article>

            <!-- Utilización: ocupada + reservada -->
            <article class="tarjeta tarjeta-segmentos">
                <h3>Estado de segmentos</h3>

                <div class="fila">
                    <span><%= segmentosEstables %> estables</span>
                    <span class="estado disponible"
                          aria-label="Normal"></span>
                </div>

                <div class="fila">
                    <span><%= segmentosLimitados %> limitados</span>
                    <span class="estado limitada"
                          aria-label="Alta utilización"></span>
                </div>

                <div class="fila">
                    <span><%= segmentosCriticos %> críticos</span>
                    <span class="estado insuficiente"
                          aria-label="Utilización crítica"></span>
                </div>

                <div class="fila enlace-segmentos">
                    <a href="${pageContext.request.contextPath}/SegmentoServlet">
                        Ver segmentos →
                    </a>
                </div>
            </article>

            <!-- Acciones según el estado de las solicitudes -->
            <article class="tarjeta acciones">
                <div class="encabezado-acciones">
                    <h3>Acciones pendientes</h3>
                    <span class="cantidad-acciones">
                        <%= acciones.size() %>
                    </span>
                </div>

                <% if (acciones.isEmpty()) { %>
                    <p>No hay solicitudes pendientes de atención.</p>
                <% } %>

                <ul class="lista-acciones">
                    <% for (Solicitud solicitud : acciones) {
                        String accion = "";

                        switch (solicitud.getEstado()) {
                            case "Registrada":
                                accion = "Evaluar solicitud";
                                break;
                            case "En evaluacion":
                                accion = "Revisar capacidad de segmentos";
                                break;
                            case "Pendiente por capacidad":
                                accion = "Revisar alternativas de capacidad";
                                break;
                            case "Aprobada":
                                accion = "Gestionar reserva de capacidad";
                                break;
                        }
                    %>
                        <li>
                            <div class="informacion-accion">
                                <a href="${pageContext.request.contextPath}/SolicitudesServlet?id=<%= solicitud.getIdSolicitud() %>">
                                    <strong>
                                        SOL-<%= solicitud.getIdSolicitud() %>
                                    </strong>
                                </a>
                                <span><%= accion %></span>
                            </div>
                        </li>
                    <% } %>
                </ul>

                <a href="${pageContext.request.contextPath}/SolicitudesServlet"
                   class="boton-nuevo">
                    Ver solicitudes
                </a>
            </article>

        </section>
    </main>
</div>

</body>
</html>
