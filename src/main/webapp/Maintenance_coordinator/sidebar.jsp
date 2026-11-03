
<%--
    sidebar.jsp
    Componente reutilizable de menú lateral.
    Recibe el parámetro "activePage" para resaltar la sección activa.
    Valores esperados: fechas | nuevo | historial

    La página "Estado" no aparece en el menú lateral.
    Se accederá a ella desde los detalles de un mantenimiento.
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

      <!-- Fechas y duración -->
      <a
        href="${pageContext.request.contextPath}/MantenimientoServlet?accion=listar"
        class="<%= "fechas".equals(activePage) ? "activo" : "" %>"
      >
        Fechas y duración
      </a>

      <!-- Nuevo mantenimiento -->
      <a
        href="${pageContext.request.contextPath}/MantenimientoServlet?accion=nuevo"
        class="<%= "nuevo".equals(activePage) ? "activo" : "" %>"
      >
        Nuevo mantenimiento
      </a>

      <!-- Historial -->
      <a
        href="${pageContext.request.contextPath}/MantenimientoServlet?accion=historial"
        class="<%= "historial".equals(activePage) ? "activo" : "" %>"
      >
        Historial
      </a>

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
