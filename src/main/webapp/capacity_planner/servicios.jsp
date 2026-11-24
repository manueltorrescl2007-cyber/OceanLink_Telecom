<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Objects" %>
<%@ page import="beans.capacityplanner.Servicio" %>
<%@ page import="beans.capacityplanner.Solicitud" %>
<%@ page import="beans.capacityplanner.Ruta" %>
<%@ page import="beans.capacityplanner.Segmento" %>
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
    private boolean compatible(Ruta ruta, Solicitud solicitud) {
        if (!"activa".equals(ruta.getEstado())
                || !Objects.equals(ruta.getNombreOrigen(), solicitud.getNombreOrigen())
                || !Objects.equals(ruta.getNombreDestino(), solicitud.getNombreDestino())
                || ruta.getCapacidadDisponible() < solicitud.getCapacidadSolicitada()
                || ruta.getSegmentos() == null || ruta.getSegmentos().isEmpty()) {
            return false;
        }
        int estacion = ruta.getIdLandingOrigen();
        for (Segmento segmento : ruta.getSegmentos()) {
            if (segmento.getIdLandingInicial() != estacion
                    || "Fuera de servicio".equals(segmento.getEstado())) {
                return false;
            }
            estacion = segmento.getIdLandingFinal();
        }
        return estacion == ruta.getIdLandingDestino();
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

    String solicitudElegida = formulario != null
            ? String.valueOf(idSolicitudActual) : request.getParameter("solicitud");
    Solicitud solicitudActual = null;
    ArrayList<Ruta> rutasCompatibles = new ArrayList<>();
    if (nuevo && solicitudElegida != null) {
        for (Solicitud solicitud : solicitudes) {
            if (String.valueOf(solicitud.getIdSolicitud()).equals(solicitudElegida)) {
                solicitudActual = solicitud;
                break;
            }
        }
        if (solicitudActual != null) {
            for (Ruta ruta : rutas) {
                if (compatible(ruta, solicitudActual)) rutasCompatibles.add(ruta);
            }
        }
    }
%>

<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= nuevo ? "Nuevo servicio" : "Servicios" %> | OceanLink</title>
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/capacity_planner/servicios.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/barras.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/capacity_planner/servicio_form.css?v=2">
</head>
<body>
<jsp:include page="header.jsp" />

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
                <a href="${pageContext.request.contextPath}/PerfilServlet">Perfil</a>
                <a href="${pageContext.request.contextPath}/LogoutServlet"
                   class="cerrar-sesion">Cerrar sesión</a>
            </nav>
        </div>
    </aside>

    <main class="contenido-principal pagina-servicios">
        <% if (nuevo) { %>
<div class="servicio-contenido">
    <section class="encabezado-pagina">
        <div class="encabezado-panel">
            <h2>Capacity Planner</h2>
            <h1>Nuevo servicio</h1>
        </div>
        <a class="boton secundario" href="<%= servlet %>">Volver a servicios</a>
    </section>

    <section class="servicio-tarjeta" aria-labelledby="titulo-solicitud">
        <h2 id="titulo-solicitud">Solicitud aprobada</h2>
        <% if (!error.isEmpty()) { %>
            <p class="mensaje-error" role="alert"><%= texto(error) %></p>
        <% } %>

        <% if (solicitudActual == null) { %>
            <% if (solicitudes.isEmpty()) { %>
                <p class="servicio-ayuda">No hay solicitudes aprobadas disponibles para asignar.</p>
            <% } else { %>
                <% if (solicitudElegida != null) { %>
                    <p class="mensaje-error" role="alert">La solicitud seleccionada ya no está disponible.</p>
                <% } %>
                <form method="get" action="<%= servlet %>" class="servicio-opciones">
                    <input type="hidden" name="ventana" value="nuevo">
                    <% for (Solicitud solicitud : solicitudes) { %>
                        <button type="submit" name="solicitud" value="<%= solicitud.getIdSolicitud() %>"
                                class="servicio-opcion">
                            <span>
                                <strong>SOL-<%= solicitud.getIdSolicitud() %> · <%= texto(solicitud.getNombreCliente()) %></strong>
                                <small><%= texto(solicitud.getNombreOrigen()) %> → <%= texto(solicitud.getNombreDestino()) %></small>
                            </span>
                            <span class="servicio-capacidad"><%= solicitud.getCapacidadSolicitada() %> Gbps</span>
                        </button>
                    <% } %>
                </form>
            <% } %>
        <% } else { %>
            <dl class="servicio-datos">
                <div><dt>Solicitud</dt><dd>SOL-<%= solicitudActual.getIdSolicitud() %></dd></div>
                <div><dt>Cliente</dt><dd><%= texto(solicitudActual.getNombreCliente()) %></dd></div>
                <div><dt>Origen</dt><dd><%= texto(solicitudActual.getNombreOrigen()) %></dd></div>
                <div><dt>Destino</dt><dd><%= texto(solicitudActual.getNombreDestino()) %></dd></div>
                <div><dt>Capacidad solicitada</dt><dd><%= solicitudActual.getCapacidadSolicitada() %> Gbps</dd></div>
            </dl>
            <a class="boton secundario" href="<%= servlet %>?ventana=nuevo">Cambiar solicitud</a>
        <% } %>
    </section>

    <% if (solicitudActual != null) { %>
        <section class="servicio-tarjeta" aria-labelledby="titulo-rutas">
            <h2 id="titulo-rutas">Rutas compatibles</h2>
            <% if (rutasCompatibles.isEmpty()) { %>
                <p class="servicio-ayuda">No hay rutas activas con ese recorrido y capacidad suficiente.</p>
            <% } else { %>
                <form method="post" action="<%= servlet %>">
                    <input type="hidden" name="accion" value="guardar">
                    <input type="hidden" name="id_solicitud" value="<%= solicitudActual.getIdSolicitud() %>">
                    <div class="servicio-opciones" role="group" aria-labelledby="titulo-rutas">
                        <% for (Ruta ruta : rutasCompatibles) { %>
                            <label class="servicio-opcion">
                                <input type="radio" name="id_ruta" value="<%= ruta.getIdRuta() %>" required
                                       <%= ruta.getIdRuta() == idRutaActual ? "checked" : "" %>>
                                <strong><%= texto(ruta.getNombre()) %></strong>
                                <span class="servicio-capacidad"><%= ruta.getCapacidadDisponible() %> Gbps disponibles</span>
                            </label>
                        <% } %>
                    </div>
                    <p class="servicio-ayuda">Al guardar, el servicio queda Pendiente y reserva la capacidad solicitada.</p>
                    <div class="acciones">
                        <a class="boton secundario" href="<%= servlet %>">Cancelar</a>
                        <button class="boton primario" type="submit">Guardar servicio</button>
                    </div>
                </form>
            <% } %>
        </section>
    <% } %>
</div>
        <% } else { %>
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
            <span><%= servicios.size() %> <%= servicios.size() == 1 ? "servicio" : "servicios" %></span>
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
                    <details class="servicio-confirmacion">
                        <summary class="boton secundario">Suspender servicio</summary>
                        <form method="post" action="<%= servlet %>">
                            <input type="hidden" name="accion" value="suspender">
                            <input type="hidden" name="id_servicio"
                                   value="<%= seleccionado.getIdServicio() %>">
                            <p>¿Deseas suspender este servicio?</p>
                            <button class="boton secundario" type="submit">Confirmar</button>
                        </form>
                    </details>
                <% } %>

                <% if ("Pendiente".equals(seleccionado.getEstado())
                        || "Activo".equals(seleccionado.getEstado())
                        || "Suspendido".equals(seleccionado.getEstado())) { %>

                    <details class="servicio-confirmacion">
                        <summary class="boton peligro">Cancelar servicio</summary>
                        <form method="post" action="<%= servlet %>">
                            <input type="hidden" name="accion" value="cancelar">
                            <input type="hidden" name="id_servicio"
                                   value="<%= seleccionado.getIdServicio() %>">
                            <p>¿Deseas cancelar este servicio y liberar su capacidad?</p>
                            <button class="boton peligro" type="submit">Confirmar</button>
                        </form>
                    </details>
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
        <% } %>
    </main>
</div>
</body>
</html>

