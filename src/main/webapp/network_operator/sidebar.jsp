<%--
    sidebar.jsp - Menú lateral del Network Operator
    Recibe el parámetro "activePage" para resaltar la opción actual.
    Valores esperados: estado | registrar | visualizar | historial
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String activePage = request.getParameter("activePage");
    if (activePage == null) {
        activePage = "";
    }
    String ctx = request.getContextPath() + "/network_operator/";
%>
<aside class="menu-lateral">
  <div class="contenido-menu">
    <h2>Menú</h2>
    <nav class="navegacion-lateral">

      <a href="<%= ctx %>estado_red.jsp"
         class="<%= "estado".equals(activePage) ? "activo" : "" %>">
        Estado de la red
      </a>

      <!-- Grupo Incidencias -->
      <div class="grupo-menu">

        <!-- Control del submenú (abierto por defecto) -->
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
          <a href="<%= ctx %>registrar_incidencia.jsp"
             class="subopcion <%= "registrar".equals(activePage) ? "activo" : "" %>">
            Registrar
          </a>
          <a href="<%= ctx %>incidencias-visualizar.jsp"
             class="subopcion <%= "visualizar".equals(activePage) ? "activo" : "" %>">
            Visualizar
          </a>
          <a href="<%= ctx %>historial.jsp"
             class="subopcion <%= "historial".equals(activePage) ? "activo" : "" %>">
            Historial
          </a>
        </div>

      </div>

    </nav>
  </div>

  <!-- Configuración -->
  <div class="configuracion">
    <nav>
      <a href="#">Perfil</a>
      <a href="${pageContext.request.contextPath}/login.jsp" class="cerrar-sesion">
        Cerrar sesión
      </a>
    </nav>
  </div>

</aside>
