<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%
  String errorMsg = (String) request.getAttribute("errorMsg");
%>

<!DOCTYPE html>
<html lang="es">

<head>
  <meta charset="UTF-8">
  <meta name="viewport"
        content="width=device-width, initial-scale=1.0">

  <title>OceanLink | Inicio de sesión</title>

  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/login.css">
</head>

<body class="login-page">

<main class="login-container">

  <section class="brand-section">
    <div class="brand-content">
      <h1 class="brand-name">OceanLink</h1>

      <img
        class="brand-icon"
        src="${pageContext.request.contextPath}/LOGO.png"
        alt="Icono OceanLink">
    </div>
  </section>

  <section class="form-section">
    <div class="form-content">

      <h2 class="welcome-message">
        Bienvenido, registra tus credenciales para continuar
      </h2>

      <% if (errorMsg != null) { %>
      <div
        role="alert"
        style="color: #ff0000;
                           margin-bottom: 15px;
                           font-weight: bold;
                           text-align: center;">
        <%= errorMsg %>
      </div>
      <% } %>

      <form
        class="login-form"
        action="${pageContext.request.contextPath}/LoginServlet"
        method="POST">

        <div class="form-group">
          <label
            for="correo"
            class="visually-hidden">
            Correo electrónico
          </label>

          <input
            type="email"
            id="correo"
            name="correo"
            class="input-field"
            placeholder="Correo electrónico"
            autocomplete="username"
            maxlength="100"
            required>
        </div>

        <div class="form-group">
          <label
            for="password"
            class="visually-hidden">
            Contraseña
          </label>

          <input
            type="password"
            id="password"
            name="password"
            class="input-field"
            placeholder="Contraseña"
            autocomplete="current-password"
            required>
        </div>

        <a href="#" class="forgot-password-link">
          Olvidé mi contraseña
        </a>

        <button type="submit" class="btn-submit">
          Ingresar
        </button>

      </form>

    </div>
  </section>

</main>

</body>
</html>
