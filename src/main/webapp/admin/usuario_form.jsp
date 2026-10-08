<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.Usuario" %>
<%@ page import="beans.Rol" %>
<%
    // Si viene "usuario" es EDITAR (case "editar"); si es null es CREAR (case "formCrear")
    Usuario usuario = (Usuario) request.getAttribute("usuario");
    ArrayList<Rol> listaRoles = (ArrayList<Rol>) request.getAttribute("listaRoles");
    boolean esEdicion = (usuario != null);
    String paginaActiva = esEdicion ? "usuarios" : "nuevo";   // opción resaltada en el menú

    String idUsuario = esEdicion ? String.valueOf(usuario.getIdUsuario()) : "";
    String nombre    = esEdicion ? usuario.getNombre() : "";
    String correo    = esEdicion ? usuario.getCorreo() : "";
    int idRolActual  = esEdicion ? usuario.getRol().getIdRol() : -1;

    String servlet = request.getContextPath() + "/UsuarioServlet";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OceanLink - <%= esEdicion ? "Editar usuario" : "Nuevo usuario" %></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/barras.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin/admin.css">
</head>
<body>

<jsp:include page="header.jsp" />

<div class="contenedor">

    <jsp:include page="sidebar.jsp">
        <jsp:param name="activePage" value="<%= paginaActiva %>" />
    </jsp:include>

    <main class="contenido-principal">

        <section class="encabezado-panel">
            <h2>Usuarios</h2>
            <h1><%= esEdicion ? "Editar usuario" : "Nuevo usuario" %></h1>
        </section>

        <section class="card">
            <form method="POST" action="<%= servlet %>?action=guardar">

                <%-- Oculto: vacío = crear, con número = actualizar --%>
                <input type="hidden" name="idUsuario" value="<%= idUsuario %>">

                <div class="form-row">
                    <div class="form-group">
                        <label for="nombre">Nombre *</label>
                        <input type="text" id="nombre" name="nombre" maxlength="100"
                               value="<%= nombre %>" required>
                    </div>

                    <div class="form-group">
                        <label for="correo">Correo *</label>
                        <input type="email" id="correo" name="correo" maxlength="100"
                               value="<%= correo %>" required>
                    </div>
                </div>

                <div class="form-row">
                    <% if (!esEdicion) { %>
                    <div class="form-group">
                        <label for="contrasena">Contraseña *</label>
                        <input type="password" id="contrasena" name="contrasena" required>
                    </div>
                    <% } %>

                    <div class="form-group">
                        <label for="idRol">Rol *</label>
                        <select id="idRol" name="idRol" required>
                            <option value="" disabled <%= esEdicion ? "" : "selected" %>>Seleccionar</option>
                            <% if (listaRoles != null) {
                                   for (Rol r : listaRoles) { %>
                                <option value="<%= r.getIdRol() %>"
                                        <%= r.getIdRol() == idRolActual ? "selected" : "" %>>
                                    <%= r.getNombre() %>
                                </option>
                            <%     }
                               } %>
                        </select>
                    </div>
                </div>

                <div class="form-actions">
                    <a class="btn-secundario" href="<%= servlet %>">Cancelar</a>
                    <button type="submit" class="btn-primary">
                        <%= esEdicion ? "Guardar cambios" : "Crear usuario" %>
                    </button>
                </div>

            </form>
        </section>

    </main>
</div>

</body>
</html>
