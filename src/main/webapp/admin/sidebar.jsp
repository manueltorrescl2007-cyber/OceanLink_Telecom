<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  String activePage = request.getParameter("activePage");
  if (activePage == null) {
    activePage = "dashboard";
  }

  boolean grupoUsuariosAbierto = "usuarios".equals(activePage) || "nuevo".equals(activePage);
  boolean grupoInfraAbierto = "landing_stations".equals(activePage) || "segmentos".equals(activePage);
%>
<aside class="menu-lateral">

  <div class="contenido-menu">

    <h2>Menú</h2>

    <nav class="navegacion-lateral" aria-label="Menú principal">

      <!-- Dashboard general -->
      <a href="${pageContext.request.contextPath}/DashboardServletAdmin"
         class="<%= "dashboard".equals(activePage) ? "activo" : "" %>">
        Dashboard general
      </a>

      <!-- Usuarios y roles -->
      <div class="grupo-menu">
        <input
          type="checkbox"
          id="control-usuarios"
          class="control-submenu"
          <%= grupoUsuariosAbierto ? "checked" : "" %>>

        <label for="control-usuarios" class="titulo-grupo">
          <span class="texto-grupo">Usuarios y roles</span>
          <span class="flecha-submenu"></span>
        </label>

        <div class="contenido-submenu">
          <a href="${pageContext.request.contextPath}/UsuarioServlet"
             class="subopcion <%= "usuarios".equals(activePage) ? "activo" : "" %>">
            Gestión de usuarios
          </a>

          <a href="${pageContext.request.contextPath}/UsuarioServlet?action=formCrear"
             class="subopcion <%= "nuevo".equals(activePage) ? "activo" : "" %>">
            Nuevo usuario
          </a>
        </div>
      </div>

      <!-- Infraestructura de red -->
      <div class="grupo-menu">
        <input
          type="checkbox"
          id="control-infraestructura"
          class="control-submenu"
          <%= grupoInfraAbierto ? "checked" : "" %>>

        <label for="control-infraestructura" class="titulo-grupo">
          <span class="texto-grupo">Infraestructura de red</span>
          <span class="flecha-submenu"></span>
        </label>

        <div class="contenido-submenu">
          <a href="${pageContext.request.contextPath}/LandingStationAdminServlet"
             class="subopcion <%= "landing_stations".equals(activePage) ? "activo" : "" %>">
            Landing stations
          </a>

          <a href="${pageContext.request.contextPath}/SegmentoAdminServlet"
             class="subopcion <%= "segmentos".equals(activePage) ? "activo" : "" %>">
            Segmentos
          </a>
        </div>
      </div>

    </nav>
  </div>

  <!-- Parte baja -->
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
