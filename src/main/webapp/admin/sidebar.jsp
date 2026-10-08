<%--
    sidebar.jsp - Menú lateral del Administrador
    Parámetro "activePage": usuarios | nuevo
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String activePage = request.getParameter("activePage");
    if (activePage == null) {
        activePage = "";
    }
    String servlet = request.getContextPath() + "/UsuarioServlet";
%>
<aside class="menu-lateral">
  <div class="contenido-menu">
    <h2>Menú</h2>
    <nav class="navegacion-lateral">

      <!-- Grupo Usuarios -->
      <div class="grupo-menu">
        <input type="checkbox" id="control-usuarios" class="control-submenu" checked>
        <label for="control-usuarios" class="titulo-grupo">
          <span>Usuarios</span>
          <span class="flecha-submenu"></span>
        </label>
        <div class="contenido-submenu">
          <a href="<%= servlet %>"
             class="subopcion <%= "usuarios".equals(activePage) ? "activo" : "" %>">
            Lista de usuarios
          </a>
          <a href="<%= servlet %>?action=formCrear"
             class="subopcion <%= "nuevo".equals(activePage) ? "activo" : "" %>">
            Nuevo usuario
          </a>
        </div>
      </div>

    </nav>
  </div>

  <div class="configuracion">
    <nav>
      <a href="#">Perfil</a>
      <a href="${pageContext.request.contextPath}/login.jsp" class="cerrar-sesion">Cerrar sesión</a>
    </nav>
  </div>
</aside>
