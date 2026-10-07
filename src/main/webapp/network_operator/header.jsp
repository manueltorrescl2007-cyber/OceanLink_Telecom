<%--
    header.jsp - Barra superior del Network Operator
    Componente reutilizable incluido en todas las páginas del rol.
    (El nombre de usuario es estático por ahora; luego vendrá de la sesión,
    p. ej. session.getAttribute("usuario")).
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");
%>
<!-- Control del menú lateral -->
<input
  type="checkbox"
  id="controlMenu"
  class="control-menu"
>

<header class="barra-superior">

  <!-- Logo y botón del menú -->
  <div class="zona-logo">

    <label
      for="controlMenu"
      class="boton-menu"
    >
      ☰
    </label>

    <a
      href="${pageContext.request.contextPath}/network_operator/estado_red.jsp"
      class="logo"
    >
      OceanLink
    </a>

  </div>

  <!-- Información del usuario -->
  <div class="usuario">

    <div class="foto-usuario">
      NO
    </div>

    <div>
      <p class="nombre-usuario">
        Username
      </p>

      <p class="rol-usuario">
        Network Operator
      </p>

    </div>

  </div>

</header>
