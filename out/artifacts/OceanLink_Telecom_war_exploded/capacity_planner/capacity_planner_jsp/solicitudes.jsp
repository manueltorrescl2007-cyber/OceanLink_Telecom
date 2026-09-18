<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>

<%!
    private Map<String, String> crearSolicitud(
            String id,
            String cliente,
            String origen,
            String destino,
            String capacidad,
            String fecha,
            String estado,
            String justificacion) {

        Map<String, String> solicitud = new LinkedHashMap<>();

        solicitud.put("id", id);
        solicitud.put("cliente", cliente);
        solicitud.put("origen", origen);
        solicitud.put("destino", destino);
        solicitud.put("capacidad", capacidad);
        solicitud.put("fecha", fecha);
        solicitud.put("estado", estado);
        solicitud.put("justificacion", justificacion);

        return solicitud;
    }

    private Map<String, String> buscarSolicitud(
            List<Map<String, String>> solicitudes,
            String id) {

        if (id != null) {
            for (Map<String, String> solicitud : solicitudes) {
                if (id.equals(solicitud.get("id"))) {
                    return solicitud;
                }
            }
        }

        return null;
    }
%>

<%
    request.setCharacterEncoding("UTF-8");

    List<Map<String, String>> solicitudes =
            (List<Map<String, String>>) session.getAttribute("solicitudesDemo");

    if (solicitudes == null) {
        solicitudes = new ArrayList<>();

        solicitudes.add(crearSolicitud(
                "SOL-001",
                "Pacífico",
                "Lima",
                "Valparaíso",
                "50 Gbps",
                "15/09/2026",
                "Pendiente",
                "La empresa requiere ampliar su capacidad para brindar nuevos servicios."
        ));

        solicitudes.add(crearSolicitud(
                "SOL-002",
                "Mediterráneo",
                "Callao",
                "Barcelona",
                "20 Gbps",
                "16/09/2026",
                "Aprobado",
                "Se necesita una conexión internacional para las operaciones de la empresa."
        ));

        solicitudes.add(crearSolicitud(
                "SOL-003",
                "Atlántico",
                "Lima",
                "Miami",
                "35 Gbps",
                "17/09/2026",
                "Desaprobado",
                "La ruta seleccionada no dispone de capacidad suficiente actualmente."
        ));

        session.setAttribute("solicitudesDemo", solicitudes);
    }

    String accion = request.getParameter("accion");

    if ("crear".equals(accion)) {
        int numeroMayor = 0;

        for (Map<String, String> solicitud : solicitudes) {
            try {
                int numero = Integer.parseInt(
                        solicitud.get("id").replace("SOL-", "")
                );

                numeroMayor = Math.max(numeroMayor, numero);

            } catch (NumberFormatException ignored) {
            }
        }

        String nuevoId = String.format("SOL-%03d", numeroMayor + 1);

        solicitudes.add(crearSolicitud(
                nuevoId,
                request.getParameter("cliente"),
                request.getParameter("origen"),
                request.getParameter("destino"),
                request.getParameter("capacidad"),
                request.getParameter("fecha"),
                "Pendiente",
                request.getParameter("justificacion")
        ));

        session.setAttribute("solicitudesDemo", solicitudes);

        response.sendRedirect("solicitudes.jsp");
        return;
    }

    if ("cambiarEstado".equals(accion)) {
        Map<String, String> solicitud = buscarSolicitud(
                solicitudes,
                request.getParameter("id")
        );

        if (solicitud != null) {
            solicitud.put("estado", request.getParameter("estado"));
        }

        session.setAttribute("solicitudesDemo", solicitudes);

        response.sendRedirect("solicitudes.jsp");
        return;
    }

    if ("editar".equals(accion)) {
        Map<String, String> solicitud = buscarSolicitud(
                solicitudes,
                request.getParameter("id")
        );

        if (solicitud != null) {
            solicitud.put("cliente", request.getParameter("cliente"));
            solicitud.put("origen", request.getParameter("origen"));
            solicitud.put("destino", request.getParameter("destino"));
            solicitud.put("capacidad", request.getParameter("capacidad"));
            solicitud.put("fecha", request.getParameter("fecha"));
            solicitud.put(
                    "justificacion",
                    request.getParameter("justificacion")
            );
        }

        session.setAttribute("solicitudesDemo", solicitudes);

        response.sendRedirect(
                "solicitudes.jsp?detalle=" + request.getParameter("id")
        );

        return;
    }

    if ("eliminar".equals(accion)) {
        String idEliminar = request.getParameter("id");

        solicitudes.removeIf(
                solicitud -> idEliminar.equals(solicitud.get("id"))
        );

        session.setAttribute("solicitudesDemo", solicitudes);

        response.sendRedirect("solicitudes.jsp");
        return;
    }

    String filtro = request.getParameter("filtro");

    if (filtro == null || filtro.isBlank()) {
        filtro = "Todos";
    }

    Map<String, String> solicitudDetalle = buscarSolicitud(
            solicitudes,
            request.getParameter("detalle")
    );

    int cantidadVisible = 0;

    for (Map<String, String> solicitud : solicitudes) {
        if ("Todos".equals(filtro)
                || filtro.equals(solicitud.get("estado"))) {

            cantidadVisible++;
        }
    }
%>

<!doctype html>
<html lang="es">

<head>
    <meta charset="UTF-8">

    <meta
            name="viewport"
            content="width=device-width, initial-scale=1.0"
    >

    <title>Solicitudes | OceanLink</title>

    <link
            rel="stylesheet"
            href="../../css/capacity_planner/solicitudes.css"
    >

    <link
        rel="stylesheet"
        href="../../css/capacity_planner/comun.css"
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

        <a href="../../index.html" class="logo">
            OceanLink
        </a>

    </div>

    <div class="usuario">

        <div class="foto-usuario">CP</div>

        <div>
            <p class="nombre-usuario">Username</p>
            <p class="rol-usuario">Capacity Planner</p>
        </div>

    </div>

</header>

<div class="contenedor">

    <aside class="menu-lateral">

        <div>

            <h2>Menú</h2>

            <nav>
                <a href="capacity_planner.jsp">Dashboard</a>
                <a href="clientes.jsp">Clientes</a>

                <a href="solicitudes.jsp" class="activo">
                    Solicitudes
                </a>

                <a href="rutas.jsp">Rutas</a>
                <a href="servicios.jsp">Servicios</a>
            </nav>

        </div>

        <div class="configuracion">
            <h3>Configuración</h3>
            <a href="#">Perfil</a>
            <a href="../../index.html">Cerrar sesión</a>
        </div>

    </aside>

    <main class="contenido-principal">

        <section class="encabezado-panel">

            <div>
                <h2>Capacity Planner</h2>
                <h1>Solicitudes</h1>
            </div>

            <button
                    class="boton primario"
                    type="button"
                    popovertarget="modalNuevaSolicitud"
            >
                + Nueva solicitud
            </button>

        </section>

        <section class="barra-filtros">

            <form
                    method="get"
                    action="solicitudes.jsp"
                    class="formulario-filtro"
            >

                <label for="filtroEstado">Estado:</label>

                <select
                        id="filtroEstado"
                        name="filtro"
                        onchange="this.form.submit()"
                >
                    <option
                            value="Todos"
                            <%= "Todos".equals(filtro)
                                    ? "selected" : "" %>
                    >
                        Todos
                    </option>

                    <option
                            value="Pendiente"
                            <%= "Pendiente".equals(filtro)
                                    ? "selected" : "" %>
                    >
                        Pendiente
                    </option>

                    <option
                            value="Aprobado"
                            <%= "Aprobado".equals(filtro)
                                    ? "selected" : "" %>
                    >
                        Aprobado
                    </option>

                    <option
                            value="Desaprobado"
                            <%= "Desaprobado".equals(filtro)
                                    ? "selected" : "" %>
                    >
                        Desaprobado
                    </option>

                </select>

            </form>

            <span class="cantidad-solicitudes">
                <%= cantidadVisible %> solicitudes
            </span>

        </section>

        <section class="tabla-contenedor">

            <table class="tabla-solicitudes">

                <thead>
                <tr>
                    <th>ID</th>
                    <th>Cliente</th>
                    <th>Origen</th>
                    <th>Destino</th>
                    <th>Capacidad</th>
                    <th>Estado</th>
                </tr>
                </thead>

                <tbody>

                <%
                    for (Map<String, String> solicitud : solicitudes) {

                        if (!"Todos".equals(filtro)
                                && !filtro.equals(solicitud.get("estado"))) {
                            continue;
                        }

                        String claseEstado =
                                solicitud.get("estado").toLowerCase();

                        boolean estaSeleccionada =
                                solicitudDetalle != null
                                        && solicitud.get("id").equals(
                                        solicitudDetalle.get("id")
                                );
                %>

                <tr
                        class="fila-solicitud <%= estaSeleccionada
                                ? "fila-seleccionada" : "" %>"

                        onclick="window.location.href=
                                'solicitudes.jsp?detalle=<%= solicitud.get("id") %>'"
                >

                    <td class="id-solicitud">
                        <%= solicitud.get("id") %>
                    </td>

                    <td><%= solicitud.get("cliente") %></td>
                    <td><%= solicitud.get("origen") %></td>
                    <td><%= solicitud.get("destino") %></td>
                    <td><%= solicitud.get("capacidad") %></td>

                    <td onclick="event.stopPropagation()">

                        <form
                                method="post"
                                action="solicitudes.jsp"
                                class="formulario-estado"
                                onclick="event.stopPropagation()"
                        >

                            <input
                                    type="hidden"
                                    name="accion"
                                    value="cambiarEstado"
                            >

                            <input
                                    type="hidden"
                                    name="id"
                                    value="<%= solicitud.get("id") %>"
                            >

                            <select
                                    name="estado"
                                    class="selector-estado <%= claseEstado %>"
                                    onchange="this.form.submit()"
                                    onclick="event.stopPropagation()"
                            >

                                <option
                                        value="Pendiente"
                                        <%= "Pendiente".equals(
                                                solicitud.get("estado")
                                        ) ? "selected" : "" %>
                                >
                                    Pendiente
                                </option>

                                <option
                                        value="Aprobado"
                                        <%= "Aprobado".equals(
                                                solicitud.get("estado")
                                        ) ? "selected" : "" %>
                                >
                                    Aprobado
                                </option>

                                <option
                                        value="Desaprobado"
                                        <%= "Desaprobado".equals(
                                                solicitud.get("estado")
                                        ) ? "selected" : "" %>
                                >
                                    Desaprobado
                                </option>

                            </select>

                        </form>

                    </td>

                </tr>

                <% } %>

                <% if (cantidadVisible == 0) { %>

                <tr>
                    <td colspan="6" class="sin-resultados">
                        No existen solicitudes con este estado.
                    </td>
                </tr>

                <% } %>

                </tbody>

            </table>

        </section>



        <% if (solicitudDetalle != null) { %>

        <section class="panel-detalle">

            <div class="encabezado-detalle">

                <div>
                    <span>Detalle de solicitud</span>
                    <h2><%= solicitudDetalle.get("id") %></h2>
                </div>

                <a
                        href="solicitudes.jsp"
                        class="cerrar-detalle"
                        title="Cerrar detalle"
                >
                    &times;
                </a>

            </div>

            <div class="cuadricula-detalle">

                <div>
                    <span>Cliente</span>

                    <strong>
                        <%= solicitudDetalle.get("cliente") %>
                    </strong>
                </div>

                <div>
                    <span>Fecha de registro</span>

                    <strong>
                        <%= solicitudDetalle.get("fecha") %>
                    </strong>
                </div>

                <div>
                    <span>Origen</span>

                    <strong>
                        <%= solicitudDetalle.get("origen") %>
                    </strong>
                </div>

                <div>
                    <span>Destino</span>

                    <strong>
                        <%= solicitudDetalle.get("destino") %>
                    </strong>
                </div>

                <div>
                    <span>Capacidad requerida</span>

                    <strong>
                        <%= solicitudDetalle.get("capacidad") %>
                    </strong>
                </div>

                <div>
                    <span>Estado</span>

                    <strong class="estado-detalle <%= solicitudDetalle
                            .get("estado").toLowerCase() %>">

                        <%= solicitudDetalle.get("estado") %>

                    </strong>
                </div>

            </div>

            <div class="justificacion-detalle">

                <span>Justificación</span>

                <p>
                    <%= solicitudDetalle.get("justificacion") %>
                </p>

            </div>

            <div class="acciones-detalle">

                <details
                        id="editarSolicitud"
                        class="editar-solicitud"
                >

                    <summary>Editar solicitud</summary>

                    <form
                            method="post"
                            action="solicitudes.jsp"
                            class="formulario-solicitud"
                    >

                        <input
                                type="hidden"
                                name="accion"
                                value="editar"
                        >

                        <input
                                type="hidden"
                                name="id"
                                value="<%= solicitudDetalle.get("id") %>"
                        >

                        <label>
                            Cliente

                            <input
                                    type="text"
                                    name="cliente"
                                    value="<%= solicitudDetalle.get("cliente") %>"
                                    required
                            >
                        </label>

                        <label>
                            Origen

                            <input
                                    type="text"
                                    name="origen"
                                    value="<%= solicitudDetalle.get("origen") %>"
                                    required
                            >
                        </label>

                        <label>
                            Destino

                            <input
                                    type="text"
                                    name="destino"
                                    value="<%= solicitudDetalle.get("destino") %>"
                                    required
                            >
                        </label>

                        <label>
                            Capacidad

                            <input
                                    type="text"
                                    name="capacidad"
                                    value="<%= solicitudDetalle.get("capacidad") %>"
                                    required
                            >
                        </label>

                        <label>
                            Fecha

                            <input
                                    type="text"
                                    name="fecha"
                                    value="<%= solicitudDetalle.get("fecha") %>"
                                    required
                            >
                        </label>

                        <label class="ancho-completo">
                            Justificación

                            <textarea
                                    name="justificacion"
                                    required
                            ><%= solicitudDetalle.get("justificacion") %></textarea>

                        </label>

                        <div class="botones-formulario ancho-completo">

                            <button
                                    type="submit"
                                    class="boton primario"
                            >
                                Guardar cambios
                            </button>

                        </div>

                    </form>

                </details>

                <form
                        method="post"
                        action="solicitudes.jsp"
                        class="formulario-eliminar"
                        onsubmit="return confirm(
                                '¿Está seguro de eliminar esta solicitud?'
                        )"
                >

                    <input
                            type="hidden"
                            name="accion"
                            value="eliminar"
                    >

                    <input
                            type="hidden"
                            name="id"
                            value="<%= solicitudDetalle.get("id") %>"
                    >

                    <button
                            type="submit"
                            class="boton-eliminar-solicitud"
                    >
                        Eliminar solicitud
                    </button>

                </form>

            </div>

        </section>

        <% } %>

    </main>

</div>

<div
        id="modalNuevaSolicitud"
        class="modal"
        popover
>

    <div class="encabezado-modal">

        <h2>Nueva solicitud</h2>

        <button
                type="button"
                class="cerrar-modal"
                popovertarget="modalNuevaSolicitud"
                popovertargetaction="hide"
        >
            &times;
        </button>

    </div>

    <form
            method="post"
            action="solicitudes.jsp"
            class="formulario-solicitud"
    >

        <input
                type="hidden"
                name="accion"
                value="crear"
        >

        <label>
            Cliente

            <select name="cliente" required>
                <option value="">Seleccione un cliente</option>
                <option value="Pacífico">Pacífico</option>
                <option value="Mediterráneo">Mediterráneo</option>
                <option value="Atlántico">Atlántico</option>
            </select>
        </label>

        <label>
            Origen
            <input type="text" name="origen" required>
        </label>

        <label>
            Destino
            <input type="text" name="destino" required>
        </label>

        <label>
            Capacidad requerida

            <input
                    type="text"
                    name="capacidad"
                    placeholder="Ejemplo: 25 Gbps"
                    required
            >
        </label>

        <label>
            Fecha de registro

            <input
                    type="date"
                    name="fecha"
                    required
            >
        </label>

        <label class="ancho-completo">
            Justificación

            <textarea
                    name="justificacion"
                    placeholder="Indique el motivo de la solicitud"
                    required
            ></textarea>

        </label>

        <div class="botones-formulario ancho-completo">

            <button
                    type="button"
                    class="boton secundario"
                    popovertarget="modalNuevaSolicitud"
                    popovertargetaction="hide"
            >
                Cancelar
            </button>

            <button
                    type="submit"
                    class="boton primario"
            >
                Guardar solicitud
            </button>

        </div>

    </form>

</div>

</body>
</html>
