<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.Servicio" %>
<%@ page import="beans.Solicitud" %>
<%@ page import="beans.Ruta" %>
<%@ page import="beans.Segmento" %>
<%!
    private String texto(String valor) {
        return valor == null ? "" : valor.replace("&", "&amp;")
                .replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }

    private Ruta buscarRuta(ArrayList<Ruta> rutas, int idRuta) {
        for (Ruta ruta : rutas) {
            if (ruta.getIdRuta() == idRuta) {
                return ruta;
            }
        }
        return null;
    }
%>
<%
    String servlet = request.getContextPath() + "/ServicioServlet";

    ArrayList<Servicio> servicios =
            (ArrayList<Servicio>) request.getAttribute("listaServicios");

    ArrayList<Solicitud> solicitudes =
            (ArrayList<Solicitud>) request.getAttribute("listaSolicitudes");

    ArrayList<Ruta> rutas =
            (ArrayList<Ruta>) request.getAttribute("listaRutas");

    if (servicios == null || solicitudes == null || rutas == null) {
        response.sendRedirect(servlet);
        return;
    }

    Servicio seleccionado =
            (Servicio) request.getAttribute("servicioSeleccionado");

    ArrayList<Segmento> segmentosServicio =
            (ArrayList<Segmento>) request.getAttribute("segmentosServicio");

    Servicio formulario =
            (Servicio) request.getAttribute("servicioFormulario");

    int idSolicitudActual = formulario != null
            ? formulario.getIdSolicitud() : -1;

    int idRutaActual = formulario != null
            ? formulario.getIdRuta() : -1;

    String error = (String) request.getAttribute("error");
    if (error == null) {
        error = "";
    }

    String filtro = (String) request.getAttribute("filtroEstado");
    if (filtro == null) {
        filtro = "";
    }

    String[] estados = {"Pendiente", "Activo", "Suspendido", "Cancelado"};

    boolean nuevo = "nuevo".equals(request.getParameter("ventana"))
            || Boolean.TRUE.equals(request.getAttribute("mostrarFormulario"));

    int rutasActivas = 0;
    for (Ruta ruta : rutas) {
        if ("activa".equals(ruta.getEstado())) {
            rutasActivas++;
        }
    }

    boolean puedeCrear = !solicitudes.isEmpty() && rutasActivas > 0;
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Servicios | OceanLink</title>
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/capacity_planner/servicios.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/barras.css">
</head>
<body>

<input type="checkbox" id="controlMenu" class="control-menu">

<header class="barra-superior">
    <div class="zona-logo">
        <label for="controlMenu" class="boton-menu"
               title="Ocultar o mostrar menú">☰</label>
        <a href="${pageContext.request.contextPath}/CapacityPlannerServlet"
           class="logo">OceanLink</a>
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
        <div class="contenido-menu">
            <h2>Menú</h2>

            <nav class="navegacion-lateral" aria-label="Menú principal">
                <a href="${pageContext.request.contextPath}/CapacityPlannerServlet">
                    Dashboard
                </a>
                <a href="${pageContext.request.contextPath}/ClienteServlet">
                    Clientes
                </a>
                <a href="${pageContext.request.contextPath}/SolicitudesServlet">
                    Solicitudes
                </a>

                <div class="grupo-menu">
                    <input type="checkbox" id="control-infraestructura"
                           class="control-submenu">

                    <label for="control-infraestructura" class="titulo-grupo">
                        <span>Infraestructura</span>
                        <span class="flecha-submenu"></span>
                    </label>

                    <div class="contenido-submenu">
                        <a href="${pageContext.request.contextPath}/RutaServlet"
                           class="subopcion">Rutas</a>
                        <a href="${pageContext.request.contextPath}/SegmentoServlet"
                           class="subopcion">Segmentos</a>
                        <a href="${pageContext.request.contextPath}/LandingStationServlet"
                           class="subopcion">Landing stations</a>
                    </div>
                </div>

                <a href="<%= servlet %>" class="activo">Servicios</a>
            </nav>
        </div>

        <div class="configuracion">
            <nav aria-label="Opciones del usuario">
                <a href="#">Perfil</a>
                <a href="${pageContext.request.contextPath}/login.jsp"
                   class="cerrar-sesion">Cerrar sesión</a>
            </nav>
        </div>
    </aside>

    <main class="contenido-principal pagina-servicios">
        <section class="encabezado-pagina">
            <div class="encabezado-panel">
                <h2>Capacity Planner</h2>
                <h1>Servicios</h1>
            </div>
            <a class="boton primario"
               href="<%= servlet %>?ventana=nuevo">+ Nuevo servicio</a>
        </section>

        <% if ("1".equals(request.getParameter("guardado"))) { %>
            <p role="status" style="margin-bottom: 16px; color: #237b51;">
                Servicio creado como Pendiente. La capacidad quedó reservada.
            </p>
        <% } %>

        <% if ("1".equals(request.getParameter("activado"))) { %>
            <p role="status" style="margin-bottom: 16px; color: #237b51;">
                Servicio activado. La capacidad reservada pasó a ocupada.
            </p>
        <% } %>

        <% if ("1".equals(request.getParameter("cancelado"))) { %>
            <p role="status" style="margin-bottom: 16px; color: #237b51;">
                Servicio cancelado. Su capacidad fue liberada.
            </p>
        <% } %>

        <% if (!error.isEmpty() && !nuevo) { %>
            <p class="mensaje-error" role="alert"><%= texto(error) %></p>
        <% } %>

        <% if ("1".equals(request.getParameter("suspendido"))) { %>
            <p role="status" style="margin-bottom: 16px; color: #237b51;">
                Servicio suspendido. Su capacidad permanece asignada.
            </p>
        <% } %>

        <% if ("1".equals(request.getParameter("reactivado"))) { %>
            <p role="status" style="margin-bottom: 16px; color: #237b51;">
                Servicio reactivado. Conserva su capacidad asignada.
            </p>
        <% } %>

        <section class="barra-herramientas">
            <form method="get" action="<%= servlet %>"
                  class="formulario-filtro">
                <label for="estado">Estado:</label>
                <select id="estado" name="estado">
                    <option value="">Todos</option>
                    <% for (String estado : estados) { %>
                        <option value="<%= estado %>"
                                <%= estado.equals(filtro) ? "selected" : "" %>>
                            <%= estado %>
                        </option>
                    <% } %>
                </select>
                <button class="boton secundario" type="submit">Filtrar</button>
            </form>
            <span><%= servicios.size() %> servicios</span>
        </section>

        <section class="contenedor-tabla">
            <table>
                <thead>
                <tr>
                    <th>ID</th>
                    <th>Cliente</th>
                    <th>Origen</th>
                    <th>Destino</th>
                    <th>Capacidad</th>
                    <th>Ruta</th>
                    <th>Estado</th>
                </tr>
                </thead>
                <tbody>
                <% for (Servicio servicio : servicios) {
                    Ruta ruta = buscarRuta(rutas, servicio.getIdRuta());
                %>
                    <tr>
                        <td>
                            <a class="enlace-servicio"
                               href="<%= servlet %>?servicio=<%= servicio.getIdServicio() %>">
                                SER-<%= servicio.getIdServicio() %>
                            </a>
                        </td>
                        <td><%= texto(servicio.getNombreCliente()) %></td>
                        <td>
                            <%= ruta != null
                                    ? texto(ruta.getNombreOrigen()) : "—" %>
                        </td>
                        <td>
                            <%= ruta != null
                                    ? texto(ruta.getNombreDestino()) : "—" %>
                        </td>
                        <td><%= servicio.getCapacidadAsignada() %> Gbps</td>
                        <td><%= texto(servicio.getNombreRuta()) %></td>
                        <td>
                            <span class="estado <%= texto(servicio.getEstado()).toLowerCase(java.util.Locale.ROOT) %>">
                                <%= texto(servicio.getEstado()) %>
                            </span>
                        </td>
                    </tr>
                <% } %>

                <% if (servicios.isEmpty()) { %>
                    <tr>
                        <td colspan="7">No hay servicios con este estado.</td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </section>

        <% if (seleccionado != null) {
            Ruta rutaDetalle = buscarRuta(rutas, seleccionado.getIdRuta());
        %>
        <section class="panel-detalle">
            <div class="encabezado-detalle">
                <h2>Detalle de SER-<%= seleccionado.getIdServicio() %></h2>
                <a href="<%= servlet %>" aria-label="Cerrar detalle">&times;</a>
            </div>

            <div class="datos-detalle">
                <div>
                    <span>Solicitud asociada</span>
                    <strong>
                        <a href="${pageContext.request.contextPath}/SolicitudesServlet?id=<%= seleccionado.getIdSolicitud() %>">
                            SOL-<%= seleccionado.getIdSolicitud() %>
                        </a>
                    </strong>
                </div>
                <div>
                    <span>Cliente</span>
                    <strong><%= texto(seleccionado.getNombreCliente()) %></strong>
                </div>
                <div>
                    <span>Ruta asignada</span>
                    <strong>
                        <a href="${pageContext.request.contextPath}/RutaServlet?detalle=<%= seleccionado.getIdRuta() %>">
                            <%= texto(seleccionado.getNombreRuta()) %>
                        </a>
                    </strong>
                </div>
                <div>
                    <span>Capacidad asignada</span>
                    <strong><%= seleccionado.getCapacidadAsignada() %> Gbps</strong>
                </div>
                <div>
                    <span>Fecha de activación</span>
                    <strong>
                        <%= seleccionado.getFechaActivacion() == null
                                ? "Sin activar"
                                : seleccionado.getFechaActivacion().toString() %>
                    </strong>
                </div>
                <div>
                    <span>Estado del servicio</span>
                    <strong><%= texto(seleccionado.getEstado()) %></strong>
                </div>
                <div>
                    <span>Origen</span>
                    <strong>
                        <%= rutaDetalle != null
                                ? texto(rutaDetalle.getNombreOrigen()) : "—" %>
                    </strong>
                </div>
                <div>
                    <span>Destino</span>
                    <strong>
                        <%= rutaDetalle != null
                                ? texto(rutaDetalle.getNombreDestino()) : "—" %>
                    </strong>
                </div>
                <div>
                    <span>Estado de la solicitud</span>
                    <strong><%= texto(seleccionado.getEstadoSolicitud()) %></strong>
                </div>
            </div>

            <% if (segmentosServicio != null && !segmentosServicio.isEmpty()) {
                int orden = 1;
            %>
                <h3>Segmentos de la ruta</h3>
                <div class="contenedor-tabla">
                    <table>
                        <thead>
                        <tr>
                            <th>Orden</th>
                            <th>Segmento</th>
                            <th>Reservada total</th>
                            <th>Ocupada total</th>
                            <th>Estado</th>
                        </tr>
                        </thead>
                        <tbody>
                        <% for (Segmento segmento : segmentosServicio) { %>
                            <tr>
                                <td><%= orden++ %></td>
                                <td><%= texto(segmento.getCodigo()) %></td>
                                <td><%= segmento.getCapacidadReservada() %> Gbps</td>
                                <td><%= segmento.getCapacidadOcupada() %> Gbps</td>
                                <td><%= texto(segmento.getEstado()) %></td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
                <p class="ayuda">
                    Las capacidades de cada segmento incluyen todos
                    los servicios que lo utilizan.
                </p>
            <% } %>

            <div class="acciones">

                <% if ("Pendiente".equals(seleccionado.getEstado())) { %>
                    <form method="post" action="<%= servlet %>">
                        <input type="hidden" name="accion" value="activar">
                        <input type="hidden" name="id_servicio"
                               value="<%= seleccionado.getIdServicio() %>">

                        <button class="boton primario" type="submit">
                            Activar servicio
                        </button>
                    </form>
                <% } %>

                <% if ("Activo".equals(seleccionado.getEstado())) { %>
                    <form method="post" action="<%= servlet %>"
                          onsubmit="return confirm('¿Deseas suspender este servicio?');">
                        <input type="hidden" name="accion" value="suspender">
                        <input type="hidden" name="id_servicio"
                               value="<%= seleccionado.getIdServicio() %>">

                        <button class="boton secundario" type="submit">
                            Suspender servicio
                        </button>
                    </form>
                <% } %>

                <% if ("Pendiente".equals(seleccionado.getEstado())
                        || "Activo".equals(seleccionado.getEstado())
                        || "Suspendido".equals(seleccionado.getEstado())) { %>

                    <form method="post" action="<%= servlet %>"
                          onsubmit="return confirm('¿Deseas cancelar este servicio y liberar su capacidad?');">
                        <input type="hidden" name="accion" value="cancelar">
                        <input type="hidden" name="id_servicio"
                               value="<%= seleccionado.getIdServicio() %>">

                        <button class="boton peligro" type="submit">
                            Cancelar servicio
                        </button>
                    </form>
                <% } %>

                <% if ("Suspendido".equals(seleccionado.getEstado())) { %>
                    <form method="post" action="<%= servlet %>">
                        <input type="hidden" name="accion" value="reactivar">
                        <input type="hidden" name="id_servicio"
                               value="<%= seleccionado.getIdServicio() %>">

                        <button class="boton primario" type="submit">
                            Reactivar servicio
                        </button>
                    </form>
                <% } %>

            </div>
        </section>
        <% } %>
    </main>
</div>

<% if (nuevo) { %>
<div class="modal">
    <section class="contenido-modal" role="dialog"
             aria-modal="true" aria-labelledby="titulo-modal">

        <div class="encabezado-detalle">
            <h2 id="titulo-modal">Nuevo servicio</h2>
            <a href="<%= servlet %>" aria-label="Cerrar formulario">&times;</a>
        </div>

        <form method="post" action="<%= servlet %>">
            <input type="hidden" name="accion" value="guardar">

            <% if (!error.isEmpty()) { %>
                <p class="mensaje-error" role="alert"><%= texto(error) %></p>
            <% } %>

            <% if (!puedeCrear) { %>
                <p class="mensaje-error">
                    Necesitas una solicitud aprobada y una ruta activa
                    para crear un servicio.
                </p>
            <% } %>

            <div class="grupo-formulario">
                <label for="solicitud">Solicitud aprobada</label>
                <select id="solicitud" name="id_solicitud" required>
                    <option value="">Seleccione una solicitud</option>
                    <% for (Solicitud solicitud : solicitudes) { %>
                        <option value="<%= solicitud.getIdSolicitud() %>"
                                <%= solicitud.getIdSolicitud() == idSolicitudActual
                                        ? "selected" : "" %>>
                            SOL-<%= solicitud.getIdSolicitud() %>
                            · <%= texto(solicitud.getNombreCliente()) %>
                            · <%= texto(solicitud.getNombreOrigen()) %>
                            → <%= texto(solicitud.getNombreDestino()) %>
                            · <%= solicitud.getCapacidadSolicitada() %> Gbps
                        </option>
                    <% } %>
                </select>
            </div>

            <div class="grupo-formulario">
                <label for="ruta">Ruta activa</label>
                <select id="ruta" name="id_ruta" required>
                    <option value="">Seleccione una ruta</option>
                    <% for (Ruta ruta : rutas) {
                        if ("activa".equals(ruta.getEstado())) { %>
                            <option value="<%= ruta.getIdRuta() %>"
                                    <%= ruta.getIdRuta() == idRutaActual
                                            ? "selected" : "" %>>
                                <%= texto(ruta.getNombre()) %>
                                · <%= texto(ruta.getNombreOrigen()) %>
                                → <%= texto(ruta.getNombreDestino()) %>
                                · <%= ruta.getCapacidadDisponible() %> Gbps disponibles
                            </option>
                    <%  }
                    } %>
                </select>
            </div>

            <p class="ayuda">
                Se asignará la capacidad indicada en la solicitud.
                Elige una ruta con el mismo origen y destino y con
                capacidad suficiente.
            </p>
            <p class="ayuda">
                El servicio se creará como Pendiente y reservará
                capacidad en cada segmento. Después podrás activarlo.
            </p>

            <div class="acciones">
                <a class="boton secundario" href="<%= servlet %>">Volver</a>
                <button class="boton primario" type="submit"
                        <%= puedeCrear ? "" : "disabled" %>>
                    Guardar servicio
                </button>
            </div>
        </form>
    </section>
</div>
<% } %>

</body>
</html>

