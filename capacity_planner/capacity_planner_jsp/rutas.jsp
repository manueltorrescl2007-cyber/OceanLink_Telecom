<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>

<%!
    private Map<String, String> crearRuta(
            String id,
            String origen,
            String destino,
            String segmentos,
            String capacidadTotal,
            String capacidadUtilizada) {

        Map<String, String> ruta = new LinkedHashMap<>();

        ruta.put("id", id);
        ruta.put("origen", origen);
        ruta.put("destino", destino);
        ruta.put("segmentos", segmentos);
        ruta.put("capacidadTotal", capacidadTotal);
        ruta.put("capacidadUtilizada", capacidadUtilizada);

        return ruta;
    }

    private Map<String, String> buscarRuta(
            List<Map<String, String>> rutas,
            String id) {

        if (id != null) {
            for (Map<String, String> ruta : rutas) {
                if (id.equals(ruta.get("id"))) {
                    return ruta;
                }
            }
        }

        return null;
    }

    private double convertirNumero(String valor) {
        try {
            return Double.parseDouble(valor);
        } catch (Exception error) {
            return 0;
        }
    }

    private double capacidadDisponible(Map<String, String> ruta) {
        double capacidadTotal =
                convertirNumero(ruta.get("capacidadTotal"));

        double capacidadUtilizada =
                convertirNumero(ruta.get("capacidadUtilizada"));

        return capacidadTotal - capacidadUtilizada;
    }

    private double porcentajeUtilizado(Map<String, String> ruta) {
        double capacidadTotal =
                convertirNumero(ruta.get("capacidadTotal"));

        double capacidadUtilizada =
                convertirNumero(ruta.get("capacidadUtilizada"));

        if (capacidadTotal <= 0) {
            return 0;
        }

        return (capacidadUtilizada / capacidadTotal) * 100;
    }

    private String obtenerEstado(Map<String, String> ruta) {
        double porcentaje = porcentajeUtilizado(ruta);

        if (porcentaje > 100) {
            return "Insuficiente";
        }

        if (porcentaje > 70) {
            return "Limitada";
        }

        return "Disponible";
    }

    private String claseEstado(Map<String, String> ruta) {
        return obtenerEstado(ruta).toLowerCase();
    }

    private String mostrarCapacidad(double capacidad) {
        if (capacidad == Math.floor(capacidad)) {
            return String.format("%.0f", capacidad);
        }

        return String.format("%.2f", capacidad);
    }
%>

<%
    request.setCharacterEncoding("UTF-8");

    List<Map<String, String>> rutas =
            (List<Map<String, String>>) session.getAttribute("rutasDemo");

    if (rutas == null) {
        rutas = new ArrayList<>();

        /* Caso disponible: utilización menor al 70% */
        rutas.add(crearRuta(
                "RUT-001",
                "Lima",
                "Valparaíso",
                "2",
                "100",
                "50"
        ));

        /* Caso limitado: utilización mayor al 70% */
        rutas.add(crearRuta(
                "RUT-002",
                "Callao",
                "Barcelona",
                "5",
                "50",
                "42"
        ));

        /* Caso insuficiente: utilización mayor al 100% */
        rutas.add(crearRuta(
                "RUT-003",
                "Lima",
                "Miami",
                "4",
                "30",
                "36"
        ));

        session.setAttribute("rutasDemo", rutas);
    }

    String accion = request.getParameter("accion");

    /* Registrar ruta */

    if ("crear".equals(accion)) {
        int numeroMayor = 0;

        for (Map<String, String> ruta : rutas) {
            try {
                int numero = Integer.parseInt(
                        ruta.get("id").replace("RUT-", "")
                );

                numeroMayor = Math.max(numeroMayor, numero);

            } catch (NumberFormatException ignored) {
            }
        }

        String nuevoId = String.format(
                "RUT-%03d",
                numeroMayor + 1
        );

        rutas.add(crearRuta(
                nuevoId,
                request.getParameter("origen"),
                request.getParameter("destino"),
                request.getParameter("segmentos"),
                request.getParameter("capacidadTotal"),
                request.getParameter("capacidadUtilizada")
        ));

        session.setAttribute("rutasDemo", rutas);

        response.sendRedirect("rutas.jsp");
        return;
    }

    /* Editar ruta */

    if ("editar".equals(accion)) {
        Map<String, String> ruta = buscarRuta(
                rutas,
                request.getParameter("id")
        );

        if (ruta != null) {
            ruta.put("origen", request.getParameter("origen"));
            ruta.put("destino", request.getParameter("destino"));
            ruta.put("segmentos", request.getParameter("segmentos"));

            ruta.put(
                    "capacidadTotal",
                    request.getParameter("capacidadTotal")
            );

            ruta.put(
                    "capacidadUtilizada",
                    request.getParameter("capacidadUtilizada")
            );
        }

        session.setAttribute("rutasDemo", rutas);

        response.sendRedirect(
                "rutas.jsp?detalle=" + request.getParameter("id")
        );

        return;
    }

    /* Eliminar ruta */

    if ("eliminar".equals(accion)) {
        String idEliminar = request.getParameter("id");

        rutas.removeIf(
                ruta -> idEliminar.equals(ruta.get("id"))
        );

        session.setAttribute("rutasDemo", rutas);

        response.sendRedirect("rutas.jsp");
        return;
    }

    String filtro = request.getParameter("filtro");

    if (filtro == null || filtro.isBlank()) {
        filtro = "Todos";
    }

    Map<String, String> rutaDetalle = buscarRuta(
            rutas,
            request.getParameter("detalle")
    );

    int cantidadVisible = 0;

    for (Map<String, String> ruta : rutas) {
        String estadoRuta = obtenerEstado(ruta);

        if ("Todos".equals(filtro)
                || filtro.equals(estadoRuta)) {

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

    <title>Rutas | OceanLink</title>

    <link
            rel="stylesheet"
            href="../../css/capacity_planner/rutas.css"
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
                <a href="solicitudes.jsp">Solicitudes</a>

                <a href="rutas.jsp" class="activo">
                    Rutas
                </a>

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
                <h1>Rutas</h1>
            </div>

            <button
                    class="boton primario"
                    type="button"
                    popovertarget="modalNuevaRuta"
            >
                + Asignar ruta
            </button>

        </section>

        <section class="barra-filtros">

            <form
                    method="get"
                    action="rutas.jsp"
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
                            value="Disponible"
                            <%= "Disponible".equals(filtro)
                                    ? "selected" : "" %>
                    >
                        Disponible
                    </option>

                    <option
                            value="Limitada"
                            <%= "Limitada".equals(filtro)
                                    ? "selected" : "" %>
                    >
                        Limitada
                    </option>

                    <option
                            value="Insuficiente"
                            <%= "Insuficiente".equals(filtro)
                                    ? "selected" : "" %>
                    >
                        Insuficiente
                    </option>

                </select>

            </form>

            <span class="cantidad-rutas">
                <%= cantidadVisible %> rutas
            </span>

        </section>

        <section class="tabla-contenedor">

            <table class="tabla-rutas">

                <thead>
                <tr>
                    <th>ID</th>
                    <th>Origen</th>
                    <th>Destino</th>
                    <th>Segmentos</th>
                    <th>Capacidad disponible</th>
                    <th>Estado</th>
                </tr>
                </thead>

                <tbody>

                <%
                    for (Map<String, String> ruta : rutas) {

                        String estadoRuta = obtenerEstado(ruta);

                        if (!"Todos".equals(filtro)
                                && !filtro.equals(estadoRuta)) {
                            continue;
                        }

                        double disponible =
                                capacidadDisponible(ruta);

                        boolean seleccionada =
                                rutaDetalle != null
                                        && ruta.get("id").equals(
                                        rutaDetalle.get("id")
                                );
                %>

                <tr
                        class="fila-ruta <%= seleccionada
                                ? "fila-seleccionada" : "" %>"

                        onclick="window.location.href=
                                'rutas.jsp?detalle=<%= ruta.get("id") %>'"
                >

                    <td class="id-ruta">
                        <%= ruta.get("id") %>
                    </td>

                    <td><%= ruta.get("origen") %></td>
                    <td><%= ruta.get("destino") %></td>
                    <td><%= ruta.get("segmentos") %></td>

                    <td>
                        <%= mostrarCapacidad(disponible) %> Gbps
                    </td>

                    <td>

                        <span class="estado-ruta <%= claseEstado(ruta) %>">

                            <span class="punto-estado"></span>

                            <%= estadoRuta %>

                        </span>

                    </td>

                </tr>

                <% } %>

                <% if (cantidadVisible == 0) { %>

                <tr>
                    <td colspan="6" class="sin-resultados">
                        No existen rutas con este estado.
                    </td>
                </tr>

                <% } %>

                </tbody>

            </table>

        </section>

        <% if (rutaDetalle != null) {

            double totalDetalle =
                    convertirNumero(
                            rutaDetalle.get("capacidadTotal")
                    );

            double utilizadaDetalle =
                    convertirNumero(
                            rutaDetalle.get("capacidadUtilizada")
                    );

            double disponibleDetalle =
                    capacidadDisponible(rutaDetalle);

            double porcentajeDetalle =
                    porcentajeUtilizado(rutaDetalle);

            String estadoDetalle =
                    obtenerEstado(rutaDetalle);
        %>

        <section class="panel-detalle">

            <div class="encabezado-detalle">

                <div>
                    <span>Detalle de ruta</span>
                    <h2><%= rutaDetalle.get("id") %></h2>
                </div>

                <a
                        href="rutas.jsp"
                        class="cerrar-detalle"
                        title="Cerrar detalle"
                >
                    &times;
                </a>

            </div>

            <div class="cuadricula-detalle">

                <div>
                    <span>Origen</span>
                    <strong>
                        <%= rutaDetalle.get("origen") %>
                    </strong>
                </div>

                <div>
                    <span>Destino</span>
                    <strong>
                        <%= rutaDetalle.get("destino") %>
                    </strong>
                </div>

                <div>
                    <span>Número de segmentos</span>
                    <strong>
                        <%= rutaDetalle.get("segmentos") %>
                    </strong>
                </div>

                <div>
                    <span>Capacidad total</span>

                    <strong>
                        <%= mostrarCapacidad(totalDetalle) %> Gbps
                    </strong>
                </div>

                <div>
                    <span>Capacidad utilizada</span>

                    <strong>
                        <%= mostrarCapacidad(utilizadaDetalle) %> Gbps
                    </strong>
                </div>

                <div>
                    <span>Capacidad disponible</span>

                    <strong>
                        <%= mostrarCapacidad(disponibleDetalle) %> Gbps
                    </strong>
                </div>

                <div>
                    <span>Porcentaje utilizado</span>

                    <strong>
                        <%= mostrarCapacidad(porcentajeDetalle) %>%
                    </strong>
                </div>

                <div>
                    <span>Estado automático</span>

                    <strong class="texto-estado <%= claseEstado(rutaDetalle) %>">
                        <%= estadoDetalle %>
                    </strong>
                </div>

            </div>

            <div class="aviso-automatico">
                El estado se calcula automáticamente según la capacidad
                utilizada y no puede modificarse manualmente.
            </div>

            <div class="acciones-detalle">

                <details
                        id="editarRuta"
                        class="editar-ruta"
                >

                    <summary>Editar ruta</summary>

                    <form
                            method="post"
                            action="rutas.jsp"
                            class="formulario-ruta"
                    >

                        <input
                                type="hidden"
                                name="accion"
                                value="editar"
                        >

                        <input
                                type="hidden"
                                name="id"
                                value="<%= rutaDetalle.get("id") %>"
                        >

                        <label>
                            Origen

                            <input
                                    type="text"
                                    name="origen"
                                    value="<%= rutaDetalle.get("origen") %>"
                                    required
                            >
                        </label>

                        <label>
                            Destino

                            <input
                                    type="text"
                                    name="destino"
                                    value="<%= rutaDetalle.get("destino") %>"
                                    required
                            >
                        </label>

                        <label>
                            Segmentos

                            <input
                                    type="number"
                                    name="segmentos"
                                    min="1"
                                    value="<%= rutaDetalle.get("segmentos") %>"
                                    required
                            >
                        </label>

                        <label>
                            Capacidad total en Gbps

                            <input
                                    type="number"
                                    name="capacidadTotal"
                                    min="1"
                                    step="0.01"
                                    value="<%= rutaDetalle.get("capacidadTotal") %>"
                                    required
                            >
                        </label>

                        <label>
                            Capacidad utilizada en Gbps

                            <input
                                    type="number"
                                    name="capacidadUtilizada"
                                    min="0"
                                    step="0.01"
                                    value="<%= rutaDetalle.get("capacidadUtilizada") %>"
                                    required
                            >
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
                        action="rutas.jsp"
                        class="formulario-eliminar"
                        onsubmit="return confirm(
                                '¿Está seguro de eliminar esta ruta?'
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
                            value="<%= rutaDetalle.get("id") %>"
                    >

                    <button
                            type="submit"
                            class="boton-eliminar"
                    >
                        Eliminar ruta
                    </button>

                </form>

            </div>

        </section>

        <% } %>

    </main>

</div>

<!-- Ventana para asignar una ruta -->

<div
        id="modalNuevaRuta"
        class="modal"
        popover
>

    <div class="encabezado-modal">

        <h2>Asignar nueva ruta</h2>

        <button
                type="button"
                class="cerrar-modal"
                popovertarget="modalNuevaRuta"
                popovertargetaction="hide"
        >
            &times;
        </button>

    </div>

    <form
            method="post"
            action="rutas.jsp"
            class="formulario-ruta"
    >

        <input
                type="hidden"
                name="accion"
                value="crear"
        >

        <label>
            Origen
            <input type="text" name="origen" required>
        </label>

        <label>
            Destino
            <input type="text" name="destino" required>
        </label>

        <label>
            Número de segmentos

            <input
                    type="number"
                    name="segmentos"
                    min="1"
                    required
            >
        </label>

        <label>
            Capacidad total en Gbps

            <input
                    type="number"
                    name="capacidadTotal"
                    min="1"
                    step="0.01"
                    required
            >
        </label>

        <label>
            Capacidad utilizada en Gbps

            <input
                    type="number"
                    name="capacidadUtilizada"
                    min="0"
                    step="0.01"
                    value="0"
                    required
            >
        </label>

        <div class="botones-formulario ancho-completo">

            <button
                    type="button"
                    class="boton secundario"
                    popovertarget="modalNuevaRuta"
                    popovertargetaction="hide"
            >
                Cancelar
            </button>

            <button
                    type="submit"
                    class="boton primario"
            >
                Guardar ruta
            </button>

        </div>

    </form>

</div>

</body>
</html>
