<%@ page contentType="text/html;charset=UTF-8"
         pageEncoding="UTF-8"
         language="java" %>

<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="java.util.Map" %>

<%!
    private Map<String, String> crearUsuario(
            String id,
            String nombre,
            String correo,
            String iniciales,
            String rol) {

        Map<String, String> usuario = new LinkedHashMap<>();

        usuario.put("id", id);
        usuario.put("nombre", nombre);
        usuario.put("correo", correo);
        usuario.put("iniciales", iniciales);
        usuario.put("rol", rol);

        return usuario;
    }

    private Map<String, String> buscarUsuario(
            ArrayList<Map<String, String>> usuarios,
            String id) {

        if (id != null) {

            for (Map<String, String> usuario : usuarios) {

                if (id.equals(usuario.get("id"))) {
                    return usuario;
                }
            }
        }

        return null;
    }
%>

<%
    request.setCharacterEncoding("UTF-8");

    ArrayList<Map<String, String>> usuarios =
            (ArrayList<Map<String, String>>)
                    session.getAttribute("usuariosSupervisor");

    if (usuarios == null) {

        usuarios = new ArrayList<>();

        usuarios.add(crearUsuario(
                "USR-001",
                "Carlos Mendoza",
                "carlos.mendoza@oceanlink.com",
                "CM",
                "Maintenance Coordinator"
        ));

        usuarios.add(crearUsuario(
                "USR-002",
                "Andrea Torres",
                "andrea.torres@oceanlink.com",
                "AT",
                "Network Operator"
        ));

        usuarios.add(crearUsuario(
                "USR-003",
                "Luis Ramírez",
                "luis.ramirez@oceanlink.com",
                "LR",
                "Supervisor"
        ));

        usuarios.add(crearUsuario(
                "USR-004",
                "María López",
                "maria.lopez@oceanlink.com",
                "ML",
                "Capacity Planner"
        ));

        usuarios.add(crearUsuario(
                "USR-005",
                "José Castillo",
                "jose.castillo@oceanlink.com",
                "JC",
                "Network Operator"
        ));

        session.setAttribute(
                "usuariosSupervisor",
                usuarios
        );
    }

    String accion = request.getParameter("accion");

    if ("actualizarRol".equals(accion)) {

        String id = request.getParameter("id");
        String nuevoRol = request.getParameter("rol");

        Map<String, String> usuario =
                buscarUsuario(usuarios, id);

        if (usuario != null
                && nuevoRol != null
                && !nuevoRol.isBlank()) {

            usuario.put("rol", nuevoRol);

            session.setAttribute(
                    "usuariosSupervisor",
                    usuarios
            );
        }

        response.sendRedirect(
                "usuarios.jsp?mensaje=actualizado"
        );

        return;
    }

    if ("eliminar".equals(accion)) {

        String idEliminar = request.getParameter("id");

        if (idEliminar != null) {

            usuarios.removeIf(
                    usuario ->
                            idEliminar.equals(usuario.get("id"))
            );

            session.setAttribute(
                    "usuariosSupervisor",
                    usuarios
            );
        }

        response.sendRedirect(
                "usuarios.jsp?mensaje=eliminado"
        );

        return;
    }

    String mensaje = request.getParameter("mensaje");
%>

<!DOCTYPE html>
<html lang="es">

<head>

    <meta charset="UTF-8">

    <meta
            name="viewport"
            content="width=device-width, initial-scale=1.0"
    >

    <title>Gestión de usuarios | OceanLink</title>

    <link
            rel="stylesheet"
            href="${pageContext.request.contextPath}/css/supervisor/usuarios.css"
    >

</head>

<body>

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
                title="Mostrar u ocultar menú"
        >
            ☰
        </label>

        <a
                href="${pageContext.request.contextPath}/supervisor/supervisor.html"
                class="logo"
        >
            OceanLink
        </a>

    </div>

    <div class="usuario-sesion">

        <div class="foto-usuario">
            SU
        </div>

        <div>
            <p class="nombre-usuario">Username</p>
            <p class="rol-usuario">Supervisor</p>
        </div>

    </div>

</header>

<div class="contenedor">

    <aside class="menu-lateral">

        <div class="contenido-menu">

            <h2>Menú</h2>

            <nav class="navegacion-lateral">

                <a href="${pageContext.request.contextPath}/supervisor/supervisor.html">
                    Dashboard general
                </a>

                <a href="${pageContext.request.contextPath}/supervisor/incidencias.html">
                    Incidencias
                </a>

                <div class="grupo-menu">

                    <input
                            type="checkbox"
                            id="controlEstadoRed"
                            class="control-submenu"
                    >

                    <label
                            for="controlEstadoRed"
                            class="titulo-grupo"
                    >
                        <span class="texto-grupo">
                            Estado de la red
                        </span>

                        <span class="flecha-submenu"></span>
                    </label>

                    <div class="contenido-submenu">

                        <a
                                href="${pageContext.request.contextPath}/supervisor/estado_red.html"
                                class="subopcion"
                        >
                            Capacidad
                        </a>

                        <a
                                href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/segmentos.jsp"
                                class="subopcion"
                        >
                            Segmentos
                        </a>

                    </div>

                </div>

                <a href="${pageContext.request.contextPath}/supervisor/servicios_clientes.html">
                    Servicios y clientes
                </a>

                <a href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/reportes.jsp">
                    Reportes
                </a>

                <a href="${pageContext.request.contextPath}/supervisor/historicos.html">
                    Históricos
                </a>

                <a
                        href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/usuarios.jsp"
                        class="activo"
                >
                    Gestión de usuarios
                </a>

            </nav>

        </div>

        <div class="configuracion">

            <h3>Configuración</h3>

            <a href="#">
                Mi perfil
            </a>

            <a href="../../login.jsp">
                Cerrar sesión
            </a>

        </div>

    </aside>

    <main class="contenido-principal">

        <section class="encabezado-panel">

            <h2>Supervisor</h2>
            <h1>Gestión de usuarios</h1>

        </section>

        <section class="panel-usuarios">

            <div class="encabezado-lista">

                <div>
                    <h2>Tablero de usuarios</h2>

                    <p>
                        Administra los roles y accesos del sistema.
                    </p>
                </div>

                <span class="cantidad-usuarios">
                    <%= usuarios.size() %>
                </span>

            </div>

            <% if ("actualizado".equals(mensaje)) { %>

            <div class="mensaje correcto">
                El rol del usuario fue actualizado correctamente.
            </div>

            <% } %>

            <% if ("eliminado".equals(mensaje)) { %>

            <div class="mensaje eliminado">
                El usuario fue eliminado correctamente.
            </div>

            <% } %>

            <% if (usuarios.isEmpty()) { %>

            <div class="sin-usuarios">

                <div class="icono-sin-usuarios">
                    SU
                </div>

                <h3>No hay usuarios registrados</h3>

                <p>
                    Actualmente no existen usuarios para administrar.
                </p>

            </div>

            <% } else { %>

            <div class="tabla-usuarios">

                <div class="fila encabezado-tabla">

                    <div>Usuario</div>
                    <div>Rol asignado</div>
                    <div>Acciones</div>

                </div>

                <%
                    for (Map<String, String> usuario : usuarios) {
                %>

                <article class="fila fila-usuario">

                    <div class="datos-usuario">

                        <div class="avatar-usuario">
                            <%= usuario.get("iniciales") %>
                        </div>

                        <div class="informacion-usuario">

                            <strong>
                                <%= usuario.get("nombre") %>
                            </strong>

                            <span>
                                <%= usuario.get("correo") %>
                            </span>

                            <small>
                                <%= usuario.get("id") %>
                            </small>

                        </div>

                    </div>

                    <form
                            method="post"
                            action="usuarios.jsp"
                            class="formulario-rol"
                    >

                        <input
                                type="hidden"
                                name="accion"
                                value="actualizarRol"
                        >

                        <input
                                type="hidden"
                                name="id"
                                value="<%= usuario.get("id") %>"
                        >

                        <label
                                for="rol-<%= usuario.get("id") %>"
                                class="etiqueta-rol"
                        >
                            Rol
                        </label>

                        <select
                                id="rol-<%= usuario.get("id") %>"
                                name="rol"
                        >

                            <option
                                    value="Maintenance Coordinator"
                                    <%=
                                        "Maintenance Coordinator".equals(
                                                usuario.get("rol")
                                        ) ? "selected" : ""
                                    %>
                            >
                                Maintenance Coordinator
                            </option>

                            <option
                                    value="Network Operator"
                                    <%=
                                        "Network Operator".equals(
                                                usuario.get("rol")
                                        ) ? "selected" : ""
                                    %>
                            >
                                Network Operator
                            </option>

                            <option
                                    value="Supervisor"
                                    <%=
                                        "Supervisor".equals(
                                                usuario.get("rol")
                                        ) ? "selected" : ""
                                    %>
                            >
                                Supervisor
                            </option>

                            <option
                                    value="Capacity Planner"
                                    <%=
                                        "Capacity Planner".equals(
                                                usuario.get("rol")
                                        ) ? "selected" : ""
                                    %>
                            >
                                Capacity Planner
                            </option>

                        </select>

                        <button
                                type="submit"
                                class="boton-guardar"
                        >
                            Guardar
                        </button>

                    </form>

                    <form
                            method="post"
                            action="usuarios.jsp"
                            class="formulario-eliminar"
                    >

                        <input
                                type="hidden"
                                name="accion"
                                value="eliminar"
                        >

                        <input
                                type="hidden"
                                name="id"
                                value="<%= usuario.get("id") %>"
                        >

                        <button
                                type="submit"
                                class="boton-eliminar"
                                title="Eliminar usuario"
                                aria-label="Eliminar usuario"
                        >
                            <span class="tapa-papelera"></span>
                            <span class="cuerpo-papelera"></span>
                        </button>

                    </form>

                </article>

                <% } %>

            </div>

            <% } %>

        </section>

    </main>

</div>

</body>
</html>
