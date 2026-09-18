<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
// 1. Capturar los parámetros enviados por el formulario
String user = request.getParameter("username");
String pass = request.getParameter("password");
String errorMsg = null;

// 2. Evaluar si se envió el formulario
if (user != null && pass != null) {

// 3. Lógica estática de roles
if (user.equals("network_operator") && pass.equals("network_operator")) {
response.sendRedirect(request.getContextPath() + "/network_operator/estado_red.jsp");
return; // Termina la ejecución de esta página

} else if (user.equals("maintenance_coordinator") && pass.equals("maintenance_coordinator")) {
response.sendRedirect(request.getContextPath() + "/Maintenance_coordinator/nuevo_mantenimiento.jsp");
return;

} else if (user.equals("capacity_planner") && pass.equals("capacity_planner")) {
  response.sendRedirect(request.getContextPath() + "/capacity_planner/capacity_planner_jsp/capacity_planner.jsp");
  return;


} else if (user.equals("supervisor") && pass.equals("supervisor")) {
  response.sendRedirect(request.getContextPath() + "/supervisor/supervisor_jsp/supervisor.jsp");
  return;

} else if (user.equals("admin") && pass.equals("admin")) {
  response.sendRedirect(request.getContextPath() + "/supervisor/supervisor_jsp/usuarios.jsp");
  return;



} else {
errorMsg = "Usuario o contraseña incorrectos.";
}
}
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Oceanlink | Inicio de Sesión</title>
  <link rel="stylesheet" href="login.css">
</head>
<body class="login-page">

<main class="login-container">

  <section class="brand-section">
    <div class="brand-content">
      <h1 class="brand-name">Oceanlink</h1>
      <img class="brand-icon" src="LOGO.png" alt="Icono Oceanlink">

    </div>
  </section>

  <section class="form-section">
    <div class="form-content">
      <h2 class="welcome-message">Bienvenido, registra tus credenciales para continuar</h2>

      <%-- Mostrar mensaje de error dinámico si las credenciales fallan --%>
      <% if (errorMsg != null) { %>
      <div style="color: #ff0000; margin-bottom: 15px; font-weight: bold; text-align: center;">
        <%= errorMsg %>
      </div>
      <% } %>

      <%-- El action apunta a sí mismo (login.jsp) y usa método POST --%>
      <form class="login-form" action="login.jsp" method="POST">
        <div class="form-group">
          <label for="username" class="visually-hidden">Usuario o correo</label>
          <input type="text" id="username" name="username" class="input-field" placeholder="Usuario o correo" required>
        </div>

        <div class="form-group">
          <label for="password" class="visually-hidden">Contraseña</label>
          <input type="password" id="password" name="password" class="input-field" placeholder="Contraseña" required>
        </div>

        <a href="#" class="forgot-password-link">Olvidé mi contraseña</a>

        <button type="submit" class="btn-submit">Ingresar</button>
      </form>
    </div>
  </section>

</main>

</body>
</html>
