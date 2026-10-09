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
    <nav class="navegacion-lateral"
         aria-label="Menú principal">

      <!-- Dashboard -->
      <a href="${pageContext.request.contextPath}/admin/admin.jsp">
          Dashboard general
      </a>

      <!-- Incidencias -->
      <div class="grupo-menu">
        <!-- Controla la apertura del submenú -->
        <input
          type="checkbox"
          id="control-incidencias"
          class="control-submenu"
        >
         <!-- Al hacer clic, marca o desmarca el checkbox -->
        <label for="control-incidencias"
               class="titulo-grupo">
          <span>Incidencias</span>
          <span class="flecha-submenu"></span>
        </label>
        <!-- Opciones que aparecen al desplegar -->
        <div class="contenido-submenu">
          <a href="${pageContext.request.contextPath}/admin/visualizar.jsp"
             class="subopcion">
              Visualizar
          </a>

          <a href="${pageContext.request.contextPath}/admin/historial_incidencias.jsp"
             class="subopcion">
              Historial de incidencias
          </a>
        </div>
      </div>

      <!-- Estado de la red -->
      <div class="grupo-menu">
        <!-- Controla la apertura del submenú -->
        <input
          type="checkbox"
          id="controlEstadoRed"
          class="control-submenu">

        <!-- Al hacer clic, marca o desmarca el checkbox -->
        <label for="controlEstadoRed"
               class="titulo-grupo">
          <span class="texto-grupo">
              Estado de la red
          </span>
          <span class="flecha-submenu"></span>
        </label>

        <!-- Opciones que aparecen al desplegar -->
        <div class="contenido-submenu">
          <a href="${pageContext.request.contextPath}/admin/capacidad.jsp"
             class="subopcion">
              Capacidad
          </a>
          <a href="${pageContext.request.contextPath}/admin/rutas.jsp"
             class="subopcion">
              Rutas
          </a>
          <a href="${pageContext.request.contextPath}/admin/segmentos.jsp"
             class="subopcion">
              Segmentos
          </a>
          <a href="${pageContext.request.contextPath}/admin/landing_stations.jsp"
             class="subopcion">
              Landing stations
          </a>
        </div>
      </div>

      <!-- Servicios y clientes -->
      <div class="grupo-menu">
        <input
          type="checkbox"
          id="control-servicios-clientes"
          class="control-submenu"
        >

        <label for="control-servicios-clientes"
                class="titulo-grupo">
          <span class="texto-grupo">
              Servicios y clientes
          </span>
          <span class="flecha-submenu"></span>
        </label>
        <div class="contenido-submenu">

          <a href="${pageContext.request.contextPath}/admin/clientes.jsp"
             class="subopcion">
              Clientes
          </a>

          <a href="${pageContext.request.contextPath}/admin/servicios.jsp"
             class="subopcion">
              Servicios
          </a>
          <a
                  href="${pageContext.request.contextPath}/admin/solicitudes.jsp"
                  class="subopcion">
              Solicitudes
          </a>
        </div>
      </div>

      <!-- Mantenimientos -->
      <div class="grupo-menu">

        <input
          type="checkbox"
          id="control-mantenimientos"
          class="control-submenu"
        >

        <label
                for="control-mantenimientos"
                class="titulo-grupo">

          <span class="texto-grupo">
              Mantenimientos
          </span>

          <span class="flecha-submenu"></span>

        </label>

        <div class="contenido-submenu">

          <a
                  href="${pageContext.request.contextPath}/admin/programacion.jsp"
                  class="subopcion">
              Programación
          </a>

          <a
                  href="${pageContext.request.contextPath}/admin/historial_programados.jsp"
                  class="subopcion">
              Historial de programados
          </a>
        </div>
      </div>
      <!-- Grupo Usuarios -->
      <div class="grupo-menu">
        <input type="checkbox" id="control-usuarios" class="control-submenu" checked>
        <label for="control-usuarios" class="titulo-grupo">
          <span>Usuarios</span>
          <span class="flecha-submenu"></span>
        </label>
        <div class="contenido-submenu">
          <a href="<%= servlet %>"
             class="subopcion" <%= "usuarios".equals(activePage) ? "activo" : "" %>>
            Lista de usuarios
          </a>
          <a href="<%= servlet %>?action=formCrear"
             class="subopcion" <%= "nuevo".equals(activePage) ? "activo" : "" %>>
            Nuevo usuario
          </a>
        </div>
      </div>
      <!-- Históricos -->
      <a href="${pageContext.request.contextPath}/admin/historicos.jsp">
          Históricos
      </a>
    </nav>
  </div>

  <div class="configuracion">
    <nav>
      <a href="#">Perfil</a>
      <a href="${pageContext.request.contextPath}/login.jsp" class="cerrar-sesion">Cerrar sesión</a>
    </nav>
  </div>
</aside>
