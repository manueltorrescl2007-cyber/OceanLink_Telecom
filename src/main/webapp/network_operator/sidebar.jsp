<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String activePage = request.getParameter("activePage");
    if (activePage == null) {
        activePage = "";
    }

    String ctx = request.getContextPath();
%>
<aside class="menu-lateral">
  <div class="contenido-menu">
    <h2>Menú</h2>
    <nav class="navegacion-lateral">

      <a href="<%= ctx %>/EstadoRedServlet"
         class="<%= "estado".equals(activePage) ? "activo" : "" %>">
        Estado de la red
      </a>

      <div class="grupo-menu">

        <input
          type="checkbox"
          id="control-incidencias"
          class="control-submenu"
          checked
        >

        <label for="control-incidencias" class="titulo-grupo">
          <span>Incidencias</span>
          <span class="flecha-submenu"></span>
        </label>

        <div class="contenido-submenu">
          <a href="<%= ctx %>/IncidenciaServlet?action=formCrear"
             class="subopcion <%= "registrar".equals(activePage) ? "activo" : "" %>">
            Registrar
          </a>
          <a href="<%= ctx %>/IncidenciaServlet?action=lista"
             class="subopcion <%= "visualizar".equals(activePage) ? "activo" : "" %>">
            Visualizar
          </a>
          <a href="<%= ctx %>/IncidenciaServlet?action=historial"
             class="subopcion <%= "historial".equals(activePage) ? "activo" : "" %>">
            Historial
          </a>
        </div>

      </div>

    </nav>
  </div>

  <div class="configuracion">
    <nav>
      <a href="#">Perfil</a>
      <a href="${pageContext.request.contextPath}/login.jsp" class="cerrar-sesion">
        Cerrar sesión
      </a>
    </nav>
  </div>

</aside>
