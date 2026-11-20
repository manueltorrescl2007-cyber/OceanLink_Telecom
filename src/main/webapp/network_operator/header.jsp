<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    String nombreUsuario = (String) session.getAttribute("nombreUsuario");
    if (nombreUsuario == null || nombreUsuario.trim().isEmpty()) {
        nombreUsuario = "Usuario";
    }

    String iniciales = "";
    for (String parte : nombreUsuario.trim().split("\\s+")) {
        if (iniciales.length() < 2) {
            iniciales += Character.toUpperCase(parte.charAt(0));
        }
    }
%>

<input
  type="checkbox"
  id="controlMenu"
  class="control-menu"
>

<header class="barra-superior">

  <div class="zona-logo">

    <label
      for="controlMenu"
      class="boton-menu"
    >
      ☰
    </label>

    <a
      href="${pageContext.request.contextPath}/EstadoRedServlet"
      class="logo"
    >
      OceanLink
    </a>

  </div>

  <div class="usuario">

    <div class="foto-usuario">
      <%= iniciales %>
    </div>

    <div>
      <p class="nombre-usuario">
        <%= nombreUsuario %>
      </p>

      <p class="rol-usuario">
        Network Operator
      </p>

    </div>

  </div>

</header>
