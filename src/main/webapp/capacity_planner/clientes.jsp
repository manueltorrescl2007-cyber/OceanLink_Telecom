<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.Cliente" %>
<%@ page import="beans.Solicitud" %>
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

    // Cantidad de tarjetas de EJEMPLO: todavía no se consulta ese módulo.
    ArrayList<Solicitud> solicitudesCliente =
            (ArrayList<Solicitud>) request.getAttribute("solicitudesCliente");

    int totalSolicitudes = solicitudesCliente.size();
    int totalServicios = 2;
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
        <a href="${pageContext.request.contextPath}/capacity_planner/capacity_planner.jsp" class="logo">OceanLink</a>
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
                <a href="${pageContext.request.contextPath}/capacity_planner/capacity_planner.jsp">Dashboard</a>
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
                <div class="titulo-seccion">
                    <h2>Clientes frecuentes</h2>
                    <span class="cantidad-clientes"><%= clientes.size() %></span>
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
                        <small>Vista de ejemplo · pendiente de conectar</small>
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
        <!-- DETALLE: solo aparece después de pulsar una opción del resumen -->
        <% if (cliente != null && detalleSeleccionado != null) { %>
        <section class="panel-detalle">
            <div class="encabezado-detalle">
                <div>
                    <p class="subtitulo-detalle">Cliente <%= texto(nombreCliente) %></p>
                    <h2>
                        <% if ("solicitudes".equals(detalleSeleccionado)) { %>
                            Solicitudes asociadas
                        <% } else if ("servicios".equals(detalleSeleccionado)) { %>
                            Servicios contratados
                        <% } else if ("contacto".equals(detalleSeleccionado)) { %>
                            Información de contacto
                        <% } else { %>
                            Datos del cliente
                        <% } %>
                    </h2>
                </div>
                <a class="cerrar-detalle" href="<%= servlet %>?id=<%= idCliente %>" aria-label="Cerrar detalle">&times;</a>
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

                                <a href="${pageContext.request.contextPath}/SolicitudesServlet?id=<%= s.getIdSolicitud() %>">
                                    Ver solicitud
                                </a>
                            </div>

                            <span class="badge <%= claseEstado %>">
                                <%= texto(s.getEstado()) %>
                            </span>
                        </article>

                    <%  }
                       } %>
                <% } else if ("servicios".equals(detalleSeleccionado)) { %>
                    <p>Estas tarjetas son ejemplos del diseño; no corresponden a servicios reales de este cliente.</p>
                    <!-- Tarjetas de ejemplo -->
                    <article class="tarjeta-detalle servicio">
                        <strong>SER-<%= idCliente %>01</strong>
                        <p><b>Solicitud:</b> SOL-<%= idCliente %>01</p>
                        <p><b>Ruta:</b> LAX-LUR-R01</p>
                        <p><b>Capacidad asignada:</b> 50 Gbps</p>
                        <p><b>Estado:</b> <span class="badge pendiente">Pendiente</span></p>
                    </article>
                    <% if (totalServicios >= 2) { %>
                    <article class="tarjeta-detalle servicio">
                        <strong>SER-<%= idCliente %>02</strong>
                        <p><b>Solicitud:</b> SOL-<%= idCliente %>03</p>
                        <p><b>Ruta:</b> GYE-LUR-R01</p>
                        <p><b>Capacidad asignada:</b> 30 Gbps</p>
                        <p><b>Estado:</b> <span class="badge activa">Activo</span></p>
                    </article>
                    <% } %>
                <% } else if ("contacto".equals(detalleSeleccionado)) { %>
                    <article class="tarjeta-detalle contacto">
                        <p><b>Empresa:</b> <%= texto(nombreCliente) %></p>
                        <p><b>Correo:</b> <%= texto(correoCliente) %></p>
                        <p><b>Teléfono:</b> <%= texto(telefonoCliente) %></p>
                    </article>
                <% } else { %>
                    <article class="tarjeta-detalle contacto">
                        <p><b>ID:</b> <%= idCliente %></p>
                        <p><b>Nombre:</b> <%= texto(nombreCliente) %></p>
                        <p><b>Razón social:</b> <%= texto(razonSocial) %></p>
                        <p><b>RUC:</b> <%= texto(rucCliente) %></p>
                        <p><b>Estado:</b> <span class="badge <%= estadoCliente.equals("activo") ? "activa" : "inactiva" %>"><%= estadoCliente.equals("activo") ? "Activo" : "Inactivo" %></span></p>
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
