<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
    <aside class="menu-lateral">
        <div class="contenido-menu">
            <h2>Menú</h2>

            <nav class="navegacion-lateral" aria-label="Menú principal">
                <a href="${pageContext.request.contextPath}/CapacityPlannerServlet" class="">
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
                <a href="${pageContext.request.contextPath}/PerfilServlet">Perfil</a>

                <a href="${pageContext.request.contextPath}/login.jsp"
                   class="cerrar-sesion">
                    Cerrar sesión
                </a>
            </nav>
        </div>
    </aside>
