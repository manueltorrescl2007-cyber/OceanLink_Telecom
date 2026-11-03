<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.capacityplanner.Cliente" %>
<%@ page import="beans.capacityplanner.Solicitud" %>
<%@ page import="beans.capacityplanner.Servicio" %>
<%!
    // Mostrar texto de la base de datos sin interpretarlo como HTML.
    private String texto(String valor) {
        if (valor == null) return "";
        return valor.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>
<%
    ArrayList<Cliente> clientes = (ArrayList<Cliente>) request.getAttribute("listaClientes");
    String servlet = request.getContextPath() + "/ClienteServlet";
    if (clientes == null) {
        response.sendRedirect(servlet);
        return;
    }

    // Usar el formulario que ya agregaste, sin cambiar el servlet.
    if ("formulario".equals(request.getParameter("vista"))
            || request.getAttribute("clienteFormulario") != null) {
        request.getRequestDispatcher("/capacity_planner/cliente_form.jsp").forward(request, response);
        return;
    }

    Cliente cliente = (Cliente) request.getAttribute("clienteSeleccionado");
    if (cliente == null && !clientes.isEmpty()) cliente = clientes.get(0);

    int idCliente = cliente != null ? cliente.getIdCliente() : 0;
    String nombreCliente = cliente != null ? cliente.getNombre() : "Seleccione un cliente";
    String razonSocial = cliente != null ? cliente.getRazonSocial() : "";
    String rucCliente = cliente != null ? cliente.getRuc() : "";
    String correoCliente = cliente != null ? cliente.getCorreo() : "";
    String telefonoCliente = cliente != null ? cliente.getTelefono() : "";
    String estadoCliente = cliente != null ? cliente.getEstado() : "";
    String detalleSeleccionado = request.getParameter("detalle");
    String error = (String) request.getAttribute("error");
    String mensaje = request.getParameter("mensaje");

    // Conservar tu orden de clientes frecuentes según los clics.
    int[] clics = new int[clientes.size()];
    for (int i = 0; i < clientes.size(); i++) {
        String clave = "clics_cliente_" + clientes.get(i).getIdCliente();
        Integer contador = (Integer) session.getAttribute(clave);
        clics[i] = contador != null ? contador : 0;
        if ("1".equals(request.getParameter("visita"))
                && clientes.get(i).getIdCliente() == idCliente) {
            clics[i]++;
            session.setAttribute(clave, clics[i]);
        }
    }
    if ("1".equals(request.getParameter("visita"))) {
        response.sendRedirect(servlet + "?id=" + idCliente);
        return;
    }
    for (int vuelta = 0; vuelta < clientes.size() - 1; vuelta++) {
        for (int i = 0; i < clientes.size() - 1 - vuelta; i++) {
            int actual = clics[i] >= 5 ? clics[i] : 0;
            int siguiente = clics[i + 1] >= 5 ? clics[i + 1] : 0;
            if (siguiente > actual) {
                Cliente temporal = clientes.get(i);
                clientes.set(i, clientes.get(i + 1));
                clientes.set(i + 1, temporal);
                int clicTemporal = clics[i];
                clics[i] = clics[i + 1];
                clics[i + 1] = clicTemporal;
            }
        }
    }

        ArrayList<Solicitud> solicitudesCliente =
                (ArrayList<Solicitud>) request.getAttribute("solicitudesCliente");

        ArrayList<Servicio> serviciosCliente =
                (ArrayList<Servicio>) request.getAttribute("listaServiciosCliente");

        if (solicitudesCliente == null) {
            solicitudesCliente = new ArrayList<>();
        }

        if (serviciosCliente == null) {
            serviciosCliente = new ArrayList<>();
        }

        int totalSolicitudes = solicitudesCliente.size();
        int totalServicios = serviciosCliente.size();
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0" >
    <title>Clientes | OceanLink</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/capacity_planner/clientes.css" >
    <!-- CSS compartido: colores, animaciones y tamaño de las barras -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/barras.css">
</head>
<body>
<!-- Barra superior -->
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
<!-- Control del menú lateral -->
<input type="checkbox" id="controlMenu" class="control-menu" >
<div class="contenedor">
    <!-- MENÚ LATERAL: Clientes es la opción activa de esta página -->
    <aside class="menu-lateral">
        <div class="contenido-menu">
            <h2>Menú</h2>
            <nav class="navegacion-lateral" aria-label="Menú principal">
                <a href="${pageContext.request.contextPath}/CapacityPlannerServlet">Dashboard</a>
                <a href="<%= servlet %>" class="activo">Clientes</a>
                <a href="${pageContext.request.contextPath}/capacity_planner/solicitudes.jsp">Solicitudes</a>
                <!-- Checkbox y label abren Infraestructura sin JavaScript -->
                <div class="grupo-menu">
                    <input type="checkbox" id="control-infraestructura" class="control-submenu">
                    <label for="control-infraestructura" class="titulo-grupo">
                        <span>Infraestructura</span>
                        <span class="flecha-submenu"></span>
                    </label>
                    <div class="contenido-submenu">
                        <a href="${pageContext.request.contextPath}/capacity_planner/rutas.jsp" class="subopcion">Rutas</a>
                        <a href="${pageContext.request.contextPath}/capacity_planner/segmentos.jsp" class="subopcion">Segmentos</a>
                        <a href="${pageContext.request.contextPath}/capacity_planner/landing_stations.jsp" class="subopcion">Landing stations</a>
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
    <!-- Clientes consultados por el servlet -->
    <main class="contenido-principal">
        <section class="encabezado-panel">
            <h2>Capacity Planner</h2>
            <h1>Clientes</h1>
        </section>
        <% if (error != null) { %><p role="alert"><%= texto(error) %></p><% } %>
        <% if ("creado".equals(mensaje) || "actualizado".equals(mensaje)
                || "activado".equals(mensaje) || "desactivado".equals(mensaje)) { %>
            <p role="status">Operación realizada correctamente.</p>
        <% } %>
        <section class="seccion-clientes">
            <div class="panel-clientes">
                <div class="titulo-seccion"
                     style="display: flex; align-items: center;
                            justify-content: space-between; gap: 16px;">

                    <h2>Clientes frecuentes</h2>

                    <div style="display: flex; align-items: center; gap: 16px;">

                        <details style="position: relative;">
                            <summary aria-label="Buscar clientes"
                                     title="Buscar clientes"
                                     style="display: flex; align-items: center;
                                            cursor: pointer; color: #1c8c9c;">
                                <svg width="23" height="23" viewBox="0 0 24 24"
                                     fill="none" stroke="currentColor"
                                     stroke-width="2" stroke-linecap="round"
                                     aria-hidden="true">
                                    <circle cx="10.5" cy="10.5" r="6.5"></circle>
                                    <path d="M16 16L21 21"></path>
                                </svg>
                            </summary>

                            <form method="get" action="<%= servlet %>"
                                  style="position: absolute; right: 0; top: 36px;
                                         z-index: 10; width: 280px;
                                         max-width: 70vw; padding: 16px;
                                         box-sizing: border-box; background: white;
                                         border: 1px solid #d9e1e8;
                                         border-radius: 10px;
                                         box-shadow: 0 4px 16px #00000015;">

                                <div style="display: flex; align-items: center;
                                            justify-content: space-between; margin-bottom: 8px;">

                                    <label for="buscarCliente"
                                           style="font-size: 14px; color: #0b3d5c;">
                                        Buscar cliente
                                    </label>

                                    <button type="button"
                                            aria-label="Cerrar buscador"
                                            onclick="this.closest('details').open = false;"
                                            style="border: none; background: transparent;
                                                   color: #64748b; font-size: 22px;
                                                   line-height: 1; cursor: pointer;
                                                   padding: 4px;">
                                        &times;
                                    </button>

                                </div>

                                <input type="search"
                                       id="buscarCliente"
                                       name="buscar"
                                       placeholder="Escribe tu búsqueda..."
                                       value="<%= texto(request.getParameter("buscar")) %>"
                                       style="width: 100%; box-sizing: border-box;
                                              padding: 10px 12px;
                                              border: 1px solid #d9e1e8;
                                              border-radius: 6px;
                                              font-size: 14px;">

                                <div style="display: flex; align-items: center;
                                            gap: 12px; margin-top: 12px;">
                                    <button type="submit" class="boton primario">
                                        Buscar
                                    </button>
                                </div>
                            </form>
                        </details>

                        <span class="cantidad-clientes">
                            <%= clientes.size() %>
                        </span>

                    </div>
                </div>
                <!-- LISTA: conserva el orden calculado a partir de los clics -->
                <ul class="lista-clientes">
                    <% for (Cliente c : clientes) { %>
                    <li class="<%= c.getIdCliente() == idCliente ? "cliente-seleccionado" : "" %>">
                        <a class="cliente-enlace" href="<%= servlet %>?id=<%= c.getIdCliente() %>&amp;visita=1">
                            <span class="avatar-cliente"><%= texto(c.getNombre().isEmpty() ? "" : c.getNombre().substring(0, 1)) %></span>
                            <span class="datos-cliente">
                                <strong><%= texto(c.getNombre()) %></strong>
                                <small><%= texto(c.getRazonSocial()) %></small>
                                <small><%= "activo".equals(c.getEstado()) ? "Activo" : "Inactivo" %></small>
                            </span>
                        </a>
                    </li>
                    <% } %>
                </ul>
                <% if (clientes.isEmpty()) { %><p>No hay clientes registrados.</p><% } %>
                <!-- Formularios separados; conservamos el estilo de los botones -->
                <div class="botones-clientes">
                    <button class="boton primario" type="button" onclick="location.href='${pageContext.request.contextPath}/capacity_planner/cliente_form.jsp'">+ Nuevo cliente</button>
                    <button class="boton secundario" type="button" <%= cliente == null ? "disabled" : "" %> onclick="location.href='<%= servlet %>?id=<%= idCliente %>&amp;vista=formulario'">Editar cliente</button>
                    <button class="boton peligro" type="button" <%= cliente == null ? "disabled" : "" %> popovertarget="modalEliminarCliente"><%= "activo".equals(estadoCliente) ? "Desactivar" : "Activar" %> cliente</button>
                </div>
            </div>
            <!-- RESUMEN: se actualiza según el cliente seleccionado -->
            <div class="panel-resumen">
                <div class="encabezado-resumen">
                    <span class="etiqueta-resumen">Resumen</span>
                    <strong class="titulo-resumen"><%= texto(nombreCliente) %></strong>
                </div>
                <a class="opcion-resumen" href="<%= servlet %>?id=<%= idCliente %>&amp;detalle=solicitudes">
                    <span class="icono-opcion">★</span>
                    <span class="texto-opcion">
                        <strong>Solicitudes asociadas</strong>
                        <small><%= totalSolicitudes %> solicitud(es) registradas</small>
                    </span>
                    <span class="flecha">›</span>
                </a>
                <a class="opcion-resumen" href="<%= servlet %>?id=<%= idCliente %>&amp;detalle=servicios">
                    <span class="icono-opcion">★</span>
                    <span class="texto-opcion">
                        <strong>Servicios contratados</strong>
                        <small><%= totalServicios %> servicio(s) registrados</small>
                    </span>
                    <span class="flecha">›</span>
                </a>
                <a class="opcion-resumen" href="<%= servlet %>?id=<%= idCliente %>&amp;detalle=contacto">
                    <span class="icono-opcion">★</span>
                    <span class="texto-opcion">
                        <strong>Contacto</strong>
                        <small><%= texto(correoCliente) %></small>
                    </span>
                    <span class="flecha">›</span>
                </a>
                <a class="opcion-resumen" href="<%= servlet %>?id=<%= idCliente %>&amp;detalle=estado">
                    <span class="icono-opcion">★</span>
                    <span class="texto-opcion">
                        <strong>Estado</strong>
                        <small><%= estadoCliente.equals("activo") ? "Activo" : "Inactivo" %></small>
                    </span>
                    <span class="flecha">›</span>
                </a>
            </div>
        </section>
        <!-- DETALLE del cliente seleccionado -->
        <% if (cliente != null && detalleSeleccionado != null) { %>
        <section class="panel-detalle">
            <div class="encabezado-detalle">
                <div>
                    <p class="subtitulo-detalle">
                        Cliente <%= texto(nombreCliente) %>
                    </p>

                    <h2>
                        <% if ("solicitudes".equals(detalleSeleccionado)) { %>
                            Solicitudes asociadas
                        <% } else if ("servicios".equals(detalleSeleccionado)) { %>
                            Servicios contratados
                        <% } else if ("contacto".equals(detalleSeleccionado)) { %>
                            Información de contacto
                        <% } else { %>
                            Estado del cliente
                        <% } %>
                    </h2>
                </div>

                <a class="cerrar-detalle"
                   href="<%= servlet %>?id=<%= idCliente %>"
                   aria-label="Cerrar detalle">&times;</a>
            </div>

            <div class="contenido-detalle">

                <% if ("solicitudes".equals(detalleSeleccionado)) { %>

                    <% if (solicitudesCliente.isEmpty()) { %>
                        <p>Este cliente todavía no tiene solicitudes registradas.</p>
                    <% } else {
                        for (Solicitud s : solicitudesCliente) {
                            String claseEstado = "pendiente";

                            if ("Rechazada".equals(s.getEstado())) {
                                claseEstado = "rechazada";
                            } else if ("Aprobada".equals(s.getEstado())
                                    || "Provisionada".equals(s.getEstado())
                                    || "Activa".equals(s.getEstado())) {
                                claseEstado = "aprobada";
                            }
                    %>
                        <article class="tarjeta-detalle">
                            <div>
                                <strong>
                                    SOL-<%= s.getIdSolicitud() %> ·
                                    <%= texto(s.getNombreOrigen()) %> —
                                    <%= texto(s.getNombreDestino()) %>
                                </strong>

                                <p>
                                    Capacidad solicitada:
                                    <%= s.getCapacidadSolicitada() %> Gbps
                                </p>

                                <a href="${pageContext.request.contextPath}/SolicitudesServlet?id=<%= s.getIdSolicitud() %>"
                                   style="display: inline-block;
                                          margin-top: 10px;
                                          padding: 6px 12px;
                                          font-size: 13px;
                                          font-weight: 600;
                                          line-height: 1.4;
                                          color: #0b3d5c;
                                          background: #e5eef3;
                                          border-radius: 6px;
                                          text-decoration: none;">
                                    Ver solicitud →
                                </a>
                            </div>

                            <span class="badge <%= claseEstado %>">
                                <%= texto(s.getEstado()) %>
                            </span>
                        </article>
                    <%  }
                       } %>

                <% } else if ("servicios".equals(detalleSeleccionado)) { %>

                    <% if (serviciosCliente.isEmpty()) { %>
                        <p>Este cliente todavía no tiene servicios registrados.</p>
                    <% } else {
                        for (Servicio servicio : serviciosCliente) {
                            String claseEstado = "pendiente";

                            if ("Activo".equals(servicio.getEstado())) {
                                claseEstado = "activa";
                            } else if ("Cancelado".equals(servicio.getEstado())) {
                                claseEstado = "inactiva";
                            }
                    %>
                        <article class="tarjeta-detalle servicio"
                                 style="display: flex; flex-direction: row; flex-wrap: wrap;
                                        align-items: center; justify-content: space-between;
                                        gap: 24px; padding: 24px;">

                            <strong style="margin: 0; font-size: 17px;">
                                SER-<%= servicio.getIdServicio() %>
                            </strong>

                            <div>
                                <p style="margin: 0 0 8px;">Solicitud</p>
                                <strong>SOL-<%= servicio.getIdSolicitud() %></strong>
                            </div>

                            <div>
                                <p style="margin: 0 0 8px;">Ruta</p>
                                <strong><%= texto(servicio.getNombreRuta()) %></strong>
                            </div>

                            <div>
                                <p style="margin: 0 0 8px;">Capacidad asignada</p>
                                <strong><%= servicio.getCapacidadAsignada() %> Gbps</strong>
                            </div>

                            <div>
                                <p style="margin: 0 0 8px;">Estado</p>
                                <span class="badge <%= claseEstado %>">
                                    <%= texto(servicio.getEstado()) %>
                                </span>
                            </div>

                            <a href="${pageContext.request.contextPath}/ServicioServlet?servicio=<%= servicio.getIdServicio() %>"
                               style="display: inline-block; margin: 0; padding: 8px 14px;
                                      font-size: 13px; font-weight: 600; line-height: 1.4;
                                      color: #0b3d5c; background: #e5eef3;
                                      border-radius: 6px; text-decoration: none;
                                      white-space: nowrap;">
                                Ver servicio →
                            </a>

                        </article>
                    <%  }
                       } %>

                <% } else if ("contacto".equals(detalleSeleccionado)) { %>

                    <article class="tarjeta-detalle contacto"
                             style="display: flex; flex-direction: row; flex-wrap: wrap;
                                    align-items: center; justify-content: space-between;
                                    gap: 24px; padding: 24px;">

                        <div>
                            <p style="margin: 0 0 8px;">Empresa</p>
                            <strong><%= texto(nombreCliente) %></strong>
                        </div>

                        <div>
                            <p style="margin: 0 0 8px;">Correo electrónico</p>
                            <strong><%= texto(correoCliente) %></strong>
                        </div>

                        <div>
                            <p style="margin: 0 0 8px;">Teléfono</p>
                            <strong><%= texto(telefonoCliente) %></strong>
                        </div>

                    </article>

                <% } else { %>

                    <article class="tarjeta-detalle contacto"
                             style="display: flex; flex-direction: row; flex-wrap: wrap;
                                    align-items: center; justify-content: space-between;
                                    gap: 24px; padding: 24px;">

                        <div>
                            <p style="margin: 0 0 8px;">Cliente</p>
                            <strong><%= texto(nombreCliente) %></strong>
                        </div>

                        <div>
                            <p style="margin: 0 0 8px;">Estado actual</p>
                            <span class="badge <%= "activo".equals(estadoCliente)
                                    ? "activa" : "inactiva" %>">
                                <%= "activo".equals(estadoCliente) ? "Activo" : "Inactivo" %>
                            </span>
                        </div>

                        <button class="boton <%= "activo".equals(estadoCliente)
                                    ? "peligro" : "primario" %>"
                                type="button"
                                popovertarget="modalEliminarCliente">
                            <%= "activo".equals(estadoCliente)
                                    ? "Desactivar cliente" : "Activar cliente" %>
                        </button>

                    </article>

                <% } %>

            </div>
        </section>
        <% } %>
    </main>
</div>
<!-- Confirmación para activar o desactivar -->
<div id="modalEliminarCliente" class="modal modal-confirmacion" popover>
    <div class="contenido-modal">
        <div class="encabezado-modal">
            <h2><%= "activo".equals(estadoCliente) ? "Desactivar" : "Activar" %> cliente</h2>
            <button class="cerrar-modal" type="button" popovertarget="modalEliminarCliente" popovertargetaction="hide">&times;</button>
        </div>
        <p class="mensaje-confirmacion">¿Desea <%= "activo".equals(estadoCliente) ? "desactivar" : "activar" %> al cliente <strong><%= texto(nombreCliente) %></strong>?</p>
        <form action="<%= servlet %>" method="post">
            <input type="hidden" name="action" value="<%= "activo".equals(estadoCliente) ? "desactivar" : "activar" %>">
            <input type="hidden" name="id_cliente" value="<%= idCliente %>">
        <div class="botones-modal">
            <button class="boton-cancelar" type="button" popovertarget="modalEliminarCliente" popovertargetaction="hide">Cancelar</button>
            <button class="boton-confirmar-eliminar" type="submit">Confirmar</button>
        </div>
        </form>
    </div>
</div>
</body>
</html>
