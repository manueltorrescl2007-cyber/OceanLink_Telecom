<%--
    sidebar.jsp
    Componente reutilizable de menú lateral.
    Recibe el parámetro "activePage" para resaltar la sección activa.
    Valores esperados: nuevo | fechas | estado | historial
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String activePage = request.getParameter("activePage");
    if (activePage == null) {
        activePage = "";
    }
%>
<aside class="sidebar">
    <div class="sidebar-logo">Oceanlink</div>

    <nav class="sidebar-nav">
        <span class="nav-label">Menú</span>

        <a href="nuevo_mantenimiento.jsp"
           class="nav-item <%= "nuevo".equals(activePage) ? "active" : "" %>">
            Nuevo mantenimiento
        </a>

        <span class="nav-group-label">Mantenimientos</span>
        <ul class="nav-sublist">
            <li>
                <a href="fechas_duracion.jsp"
                   class="nav-subitem <%= "fechas".equals(activePage) ? "active" : "" %>">
                    Fechas y duración
                </a>
            </li>
            <li>
                <a href="estado.jsp"
                   class="nav-subitem <%= "estado".equals(activePage) ? "active" : "" %>">
                    Estado
                </a>
            </li>
            <li>
                <a href="historial.jsp"
                   class="nav-subitem <%= "historial".equals(activePage) ? "active" : "" %>">
                    Historial
                </a>
            </li>
        </ul>
    </nav>

    <div class="sidebar-footer">
        <span class="nav-group-label">Configuración</span>
        <ul class="nav-sublist">
            <li><a href="perfil.jsp" class="nav-subitem">Perfil</a></li>
            <li><a href="../login.jsp" class="nav-subitem">Cerrar sesión</a></li>
        </ul>
    </div>
</aside>
