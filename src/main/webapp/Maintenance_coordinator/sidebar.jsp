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
<aside class="menu-lateral">
  <div class="contenido-menu">
      <h2>Menú</h2>
    <nav class="navegacion-lateral">


        <a href="nuevo_mantenimiento.jsp"
           class="<%= "nuevo".equals(activePage) ? "activo" : "" %>">
            Nuevo mantenimiento
        </a>


      <!-- Grupo de mantenimientos -->
      <div class="grupo-menu">

        <!-- Control del submenu -->
        <input
          type="checkbox"
          id="control-mantenimientos"
          class="control-submenu"
        >

        <!-- titulo del grupo -->
        <label
          for="control-mantenimientos"
          class="titulo-grupo"
        >
          <span>Mantenimientos</span>

          <span class="flecha-submenu"></span>
        </label>

        <!-- opciones del menu lateral -->
        <div class="contenido-submenu">

          <a
            href="fechas_duracion.jsp"
            class="subopcion <%= "fechas".equals(activePage) ? "activo" : "" %>"
          >
            Fechas y duración
          </a>

          <a
            href="estado.jsp"
            class="subopcion <%= "estado".equals(activePage) ? "activo" : "" %>"
          >
            Estado
          </a>

          <a
            href="historial.jsp"
            class="subopcion <%= "historial".equals(activePage) ? "activo" : "" %>"
          >
            Historial
          </a>

        </div>

      </div>

    </nav>
  </div>

  <!-- Configuración -->
  <div class="configuracion">

    <nav>

      <a href="#">
        Perfil
      </a>

      <a
        href="${pageContext.request.contextPath}/login.jsp"
        class="cerrar-sesion"
      >
        Cerrar sesión
      </a>

    </nav>

  </div>

</aside>
