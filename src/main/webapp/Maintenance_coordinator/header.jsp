<%--
    header.jsp
    Barra superior reutilizable del área de contenido principal.
    Recibe el parámetro "pageTitle" con el título a mostrar.
    (El nombre de usuario y rol son estáticos por ahora; en producción
    deberían leerse de la sesión, p. ej. session.getAttribute("username")).
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
      href="nuevo_mantenimiento.jsp"
      class="logo"
    >
      OceanLink
    </a>

  </div>

  <!-- Información del usuario -->
  <div class="usuario">

    <div class="foto-usuario">
      MC
    </div>

    <div>
      <p class="nombre-usuario">
        Username
      </p>

      <p class="rol-usuario">
        Maintenance Coordinator
      </p>

    </div>

  </div>

</header>
