<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.Segmento" %>
<%@ page import="beans.LandingStation" %>

<%!
    public String texto(String valor) {
        if (valor == null) return "";

        return valor.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<%
    String servlet = request.getContextPath() + "/SegmentoServlet";

    ArrayList<Segmento> segmentos =
            (ArrayList<Segmento>) request.getAttribute("listaSegmentos");

    ArrayList<LandingStation> estaciones =
            (ArrayList<LandingStation>) request.getAttribute("listaEstaciones");

    if (segmentos == null || estaciones == null) {
        response.sendRedirect(servlet);
        return;
    }

    String[] estados = {
            "Operativo",
            "Degradado",
            "En mantenimiento",
            "Fuera de servicio"
    };

    String editar = request.getParameter("editar");
    String detalle = request.getParameter("detalle");
    String filtro = request.getParameter("estado");

    if (filtro == null) filtro = "";

    String error = (String) request.getAttribute("error");
    if (error == null) error = "";

    boolean mostrarFormulario =
            "nuevo".equals(request.getParameter("ventana"))
                    || editar != null;

    String[] formulario = {
            "", "", "", "", "100", "0", "0", "Operativo"
    };

    // Cargar el segmento que se quiere editar.
    for (Segmento segmento : segmentos) {
        if (String.valueOf(segmento.getIdSegmento()).equals(editar)) {
            formulario = new String[]{
                    String.valueOf(segmento.getIdSegmento()),
                    segmento.getCodigo(),
                    String.valueOf(segmento.getIdLandingInicial()),
                    String.valueOf(segmento.getIdLandingFinal()),
                    String.valueOf(segmento.getCapacidadTotal()),
                    String.valueOf(segmento.getCapacidadOcupada()),
                    String.valueOf(segmento.getCapacidadReservada()),
                    segmento.getEstado()
            };
        }
    }

    // Recuperar lo escrito si el servlet devuelve un error.
    Segmento datos =
            (Segmento) request.getAttribute("segmentoFormulario");

    if (datos != null) {
        mostrarFormulario = true;

        formulario = new String[]{
                datos.getIdSegmento() > 0
                        ? String.valueOf(datos.getIdSegmento()) : "",
                datos.getCodigo(),
                String.valueOf(datos.getIdLandingInicial()),
                String.valueOf(datos.getIdLandingFinal()),
                String.valueOf(datos.getCapacidadTotal()),
                String.valueOf(datos.getCapacidadOcupada()),
                String.valueOf(datos.getCapacidadReservada()),
                datos.getEstado()
        };
    }

    int cantidad = 0;

    for (Segmento segmento : segmentos) {
        if (filtro.isEmpty() || segmento.getEstado().equals(filtro)) {
            cantidad++;
        }
    }
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Segmentos | OceanLink</title>
    <!-- CSS propio primero; barras comunes después. -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/capacity_planner/segmentos.css?v=1">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/barras.css">
</head>
<body class="vista-segmentos">
<input type="checkbox" id="controlMenu" class="control-menu" >
<header class="barra-superior">
    <div class="zona-logo">
        <label for="controlMenu" class="boton-menu" title="Ocultar o mostrar menú">☰</label>
        <a href="${pageContext.request.contextPath}/CapacityPlannerServlet" class="logo">OceanLink</a>
    </div>
    <div class="usuario">
        <div class="foto-usuario">
            CP
        </div>
        <div>
            <p class="nombre-usuario">Username</p>
            <p class="rol-usuario">Capacity Planner</p>
        </div>
    </div>
</header>
<div class="contenedor">
    <!-- MENÚ LATERAL: Segmentos es la opción activa de esta página -->
    <aside class="menu-lateral">
        <div class="contenido-menu">
            <h2>Menú</h2>
            <nav class="navegacion-lateral" aria-label="Menú principal">
                <a href="${pageContext.request.contextPath}/CapacityPlannerServlet">Dashboard</a>

                <a href="${pageContext.request.contextPath}/ClienteServlet">Clientes</a>

                <a href="${pageContext.request.contextPath}/SolicitudesServlet">Solicitudes</a>
                <!-- Checkbox y label abren Infraestructura sin JavaScript -->
                <div class="grupo-menu">
                    <input type="checkbox" id="control-infraestructura" class="control-submenu" checked>
                    <label for="control-infraestructura" class="titulo-grupo">
                        <span>Infraestructura</span>
                        <span class="flecha-submenu"></span>
                    </label>
                    <div class="contenido-submenu">
                        <a href="${pageContext.request.contextPath}/capacity_planner/rutas.jsp" class="subopcion">Rutas</a>

                        <a href="<%= servlet %>" class="subopcion activo">Segmentos</a>

                        <a href="${pageContext.request.contextPath}/LandingStationServlet" class="subopcion">Landing stations</a>
                    </div>
                </div>
                <a href="${pageContext.request.contextPath}/capacity_planner/servicios.jsp">Servicios</a>
            </nav>
        </div>
        <!-- OPCIONES DEL USUARIO: barras.css las coloca abajo -->
        <div class="configuracion">
            <nav aria-label="Opciones del usuario">
                <!-- Pendiente: colocar la dirección real de Perfil -->
                <a href="#">Perfil</a>
                <!-- Navega al login; el cierre real de sesión se conectará después -->
                <a href="${pageContext.request.contextPath}/login.jsp" class="cerrar-sesion">Cerrar sesión</a>
            </nav>
        </div>
    </aside>

    <!-- 4. ENCABEZADO Y FILTRO POR LOS ESTADOS DEL SQL. -->
    <main class="contenido-principal pagina-segmentos">
        <section class="encabezado-pagina">
            <div class="encabezado-panel">
                <h2>Capacity Planner</h2>
                <h1>Segmentos</h1>
            </div>
            <a href="<%= servlet %>?ventana=nuevo" class="boton primario">
                + Nuevo segmento
            </a>
        </section>
        <% if ("1".equals(request.getParameter("guardado"))) { %>
            <p class="mensaje-exito">Segmento guardado correctamente.</p>
        <% } %>
        <div class="barra-herramientas">
            <form action="<%= servlet %>" method="get" class="formulario-filtro">
                <label for="filtroEstado">Estado:</label>
                <select id="filtroEstado" name="estado">
                    <option value="">Todos</option>
                    <% for (String estado : estados) { %>
                        <option value="<%= estado %>" <%= estado.equals(filtro) ? "selected" : "" %>><%= estado %></option>
                    <% } %>
                </select>
                <button class="boton secundario" type="submit">Filtrar</button>
            </form>
            <span><%= cantidad %> segmentos</span>
        </div>

        <!-- 5. TABLA: disponible se calcula; no es otro campo del SQL. -->
        <section class="contenedor-tabla">
            <table>
                <thead><tr><th>Código</th><th>Inicio</th><th>Final</th><th>Total</th><th>Ocupada</th><th>Reservada</th><th>Disponible</th><th>Estado</th></tr></thead>
                <tbody>
                    <% for (Segmento segmento : segmentos) {
                        if (!filtro.isEmpty()
                                && !segmento.getEstado().equals(filtro)) {
                            continue;
                        }

                        String clase = "fuera";

                        if ("Operativo".equals(segmento.getEstado())) {
                            clase = "operativo";
                        } else if ("Degradado".equals(segmento.getEstado())) {
                            clase = "degradado";
                        } else if ("En mantenimiento".equals(segmento.getEstado())) {
                            clase = "mantenimiento";
                        }
                    %>
                        <tr>
                            <td>
                                <a class="enlace-segmento"
                                   href="<%= servlet %>?detalle=<%= segmento.getIdSegmento() %>#detalle">
                                    <%= texto(segmento.getCodigo()) %>
                                </a>
                            </td>

                            <td><%= texto(segmento.getNombreInicial()) %></td>
                            <td><%= texto(segmento.getNombreFinal()) %></td>
                            <td><%= segmento.getCapacidadTotal() %> Gbps</td>
                            <td><%= segmento.getCapacidadOcupada() %> Gbps</td>
                            <td><%= segmento.getCapacidadReservada() %> Gbps</td>

                            <td>
                                <strong>
                                    <%= segmento.getCapacidadDisponible() %> Gbps
                                </strong>
                            </td>

                            <td>
                                <span class="estado <%= clase %>">
                                    <%= texto(segmento.getEstado()) %>
                                </span>
                            </td>
                        </tr>
                    <% } %>

                    <% if (cantidad == 0) { %>
                        <tr>
                            <td colspan="8">No hay segmentos con este estado.</td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </section>


        <!-- 6. DETALLE DEL SEGMENTO SELECCIONADO. -->
        <% for (Segmento segmento : segmentos) {
            if (!String.valueOf(segmento.getIdSegmento()).equals(detalle)) {
                continue;
            }
        %>
            <section class="panel-detalle" id="detalle">
                <div class="encabezado-detalle">
                    <h2><%= texto(segmento.getCodigo()) %></h2>
                    <a href="<%= servlet %>" aria-label="Cerrar detalle">×</a>
                </div>

                <div class="datos-detalle">
                    <div>
                        <span>ID del segmento</span>
                        <strong><%= segmento.getIdSegmento() %></strong>
                    </div>

                    <div>
                        <span>Estación inicial</span>
                        <strong><%= texto(segmento.getNombreInicial()) %></strong>
                    </div>

                    <div>
                        <span>Estación final</span>
                        <strong><%= texto(segmento.getNombreFinal()) %></strong>
                    </div>

                    <div>
                        <span>Estado</span>
                        <strong><%= texto(segmento.getEstado()) %></strong>
                    </div>

                    <div>
                        <span>Total</span>
                        <strong><%= segmento.getCapacidadTotal() %> Gbps</strong>
                    </div>

                    <div>
                        <span>Ocupada</span>
                        <strong><%= segmento.getCapacidadOcupada() %> Gbps</strong>
                    </div>

                    <div>
                        <span>Reservada</span>
                        <strong><%= segmento.getCapacidadReservada() %> Gbps</strong>
                    </div>

                    <div>
                        <span>Disponible</span>
                        <strong><%= segmento.getCapacidadDisponible() %> Gbps</strong>
                    </div>
                </div>

                <p class="ayuda">
                    Disponible = total − ocupada − reservada.
                    El estado operativo es un dato diferente de la capacidad.
                </p>

                <div class="acciones">
                    <a href="<%= servlet %>?editar=<%= segmento.getIdSegmento() %>"
                       class="boton primario">
                        Editar segmento
                    </a>
                </div>
            </section>
        <% } %>
    </main>
</div>

<!-- 7. FORMULARIO: se abre mediante un enlace, sin JavaScript. -->
<% if (mostrarFormulario) { %>
<div class="modal" role="dialog" aria-modal="true" aria-labelledby="tituloFormulario">
    <section class="contenido-modal">
        <div class="encabezado-detalle">
            <h2 id="tituloFormulario"><%= formulario[0].isEmpty() ? "Nuevo segmento" : "Editar segmento" %></h2>
            <a href="<%= servlet %>" aria-label="Cerrar formulario">×</a>
        </div>
        <% if (!error.isEmpty()) { %><p class="mensaje-error"><%= error %></p><% } %>
        <form action="<%= servlet %>" method="post">
            <input type="hidden" name="accion" value="guardar">
            <input type="hidden" name="id" value="<%= texto(formulario[0]) %>">
            <div class="grupo-formulario">
                <label for="codigo">Código</label>
                <input id="codigo" name="codigo" maxlength="20" placeholder="Ejemplo: LAX-LUR-02" value="<%= texto(formulario[1]) %>" required>
            </div>
            <div class="grupo-formulario">
                <label for="inicial">Estación inicial</label>
                <select id="inicial" name="inicial" required>
                    <option value="">Seleccione una estación</option>

                    <% for (LandingStation estacion : estaciones) { %>
                        <option value="<%= estacion.getIdLanding() %>"
                                <%= String.valueOf(estacion.getIdLanding()).equals(formulario[2]) ? "selected" : "" %>>
                            <%= texto(estacion.getNombre()) %>
                        </option>
                    <% } %>
                </select>
            </div>
            <div class="grupo-formulario">
                <label for="final">Estación final</label>
                <select id="final" name="final" required>
                    <option value="">Seleccione una estación</option>

                    <% for (LandingStation estacion : estaciones) { %>
                        <option value="<%= estacion.getIdLanding() %>"
                                <%= String.valueOf(estacion.getIdLanding()).equals(formulario[3]) ? "selected" : "" %>>
                            <%= texto(estacion.getNombre()) %>
                        </option>
                    <% } %>
                </select>

            </div>
            <div class="grupo-formulario">
                <label for="total">Capacidad total (Gbps)</label>
                <input id="total" name="total" type="number" min="1" max="4294967295" step="1" value="<%= texto(formulario[4]) %>" required>
            </div>
            <div class="grupo-formulario">
                <label for="estadoSegmento">Estado</label>
                <select id="estadoSegmento" name="estadoSegmento" required>
                    <% for (String estado : estados) { %>
                        <option value="<%= estado %>" <%= estado.equals(formulario[7]) ? "selected" : "" %>><%= estado %></option>
                    <% } %>
                </select>
            </div>
            <!-- Ocupada y reservada se gestionarán automáticamente con los servicios y reservas. -->
            <p class="ayuda">La capacidad ocupada y reservada se muestran en el detalle; no se modifican desde este formulario.</p>
            <div class="acciones">
                <a href="<%= servlet %>" class="boton secundario">Cancelar</a>
                <button type="submit" class="boton primario">Guardar</button>
            </div>
        </form>
    </section>
</div>
<% } %>
</body>
</html>
