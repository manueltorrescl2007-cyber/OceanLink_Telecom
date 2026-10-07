<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    /* 1. DATOS DE PRUEBA
       Cada posición corresponde al mismo cliente en ambos arreglos. */
    String[] ordenClientes = {"pacifico", "claro", "movistar"};
    int[] clics = new int[3];
    /* 2. CLIENTE SELECCIONADO
       Lo obtenemos del enlace o recordamos el de la sesión. */
    String clienteSeleccionado = request.getParameter("cliente");
    if (clienteSeleccionado == null) {
        clienteSeleccionado = (String) session.getAttribute("clienteSeleccionado");
    }
    if (!"pacifico".equals(clienteSeleccionado)
            && !"claro".equals(clienteSeleccionado)
            && !"movistar".equals(clienteSeleccionado)) {
        clienteSeleccionado = "pacifico";
    }
    session.setAttribute("clienteSeleccionado", clienteSeleccionado);
    /* 3. CONTAR CLICS
       Recuperamos los contadores y aumentamos el del cliente pulsado.
       Se guardan en la sesión, no en MySQL. */
    String registrarVisita = request.getParameter("visita");
    for (int i = 0; i < ordenClientes.length; i++) {
        String clave = "clics_" + ordenClientes[i];
        Integer contador = (Integer) session.getAttribute(clave);
        if (contador != null) {
            clics[i] = contador;
        }
        if ("1".equals(registrarVisita)
                && ordenClientes[i].equals(clienteSeleccionado)) {
            clics[i]++;
        }
        session.setAttribute(clave, clics[i]);
    }
    /* Evita sumar otro clic si se recarga la página después de seleccionar.
       La nueva dirección conserva el cliente, pero ya no lleva visita=1. */
    if ("1".equals(registrarVisita)) {
        response.sendRedirect("clientes.jsp?cliente=" + clienteSeleccionado);
        return;
    }
    /* 4. ORDENAR CLIENTES
       Desde 5 clics, el cliente tiene prioridad.
       Entre clientes frecuentes, aparece primero el de más clics.
       Si ninguno es frecuente, conservamos su orden original. */
    for (int vuelta = 0; vuelta < ordenClientes.length - 1; vuelta++) {
        for (int i = 0; i < ordenClientes.length - 1 - vuelta; i++) {
            int prioridadActual = 0;
            int prioridadSiguiente = 0;
            if (clics[i] >= 5) {
                prioridadActual = clics[i];
            }
            if (clics[i + 1] >= 5) {
                prioridadSiguiente = clics[i + 1];
            }
            if (prioridadSiguiente > prioridadActual) {
                // Intercambiamos los nombres y sus contadores juntos.
                String clienteTemporal = ordenClientes[i];
                ordenClientes[i] = ordenClientes[i + 1];
                ordenClientes[i + 1] = clienteTemporal;
                int clicsTemporales = clics[i];
                clics[i] = clics[i + 1];
                clics[i + 1] = clicsTemporales;
            }
        }
    }
    /* 5. DETALLE QUE SE MOSTRARÁ
       Solo aceptamos las cuatro opciones del resumen. */
    String detalleSeleccionado = request.getParameter("detalle");
    if (detalleSeleccionado != null
            && !"solicitudes".equals(detalleSeleccionado)
            && !"servicios".equals(detalleSeleccionado)
            && !"contacto".equals(detalleSeleccionado)
            && !"estado".equals(detalleSeleccionado)) {
        detalleSeleccionado = null;
    }
    /* 6. DATOS DEL SQL: tres clientes de ejemplo del archivo recibido.
       El Servlet cargará después la lista completa desde MySQL. */
    int idCliente;
    String nombreCliente;
    String razonSocial;
    String rucCliente;
    String correoCliente;
    String telefonoCliente;
    String estadoCliente;

    switch (clienteSeleccionado) {
        case "claro":
            idCliente = 1;
            nombreCliente = "Claro";
            razonSocial = "Claro Telecomunicaciones S.A.C.";
            rucCliente = "20123456789";
            correoCliente = "contacto@claro.example";
            telefonoCliente = "900111222";
            estadoCliente = "activo";
            break;
        case "movistar":
            idCliente = 2;
            nombreCliente = "Movistar";
            razonSocial = "Movistar Servicios Digitales S.A.C.";
            rucCliente = "20234567890";
            correoCliente = "contacto@movistar.example";
            telefonoCliente = "900222333";
            estadoCliente = "activo";
            break;
        default:
            idCliente = 3;
            nombreCliente = "Pacifico";
            razonSocial = "Pacifico Conectividad S.A.C.";
            rucCliente = "20345678901";
            correoCliente = "contacto@pacifico.example";
            telefonoCliente = "900333444";
            estadoCliente = "activo";
            break;
    }
    /* DATOS FICTICIOS: solo para mostrar el diseño.
       No se insertan en MySQL. El Servlet los reemplazará después. */
    int totalSolicitudes = 3;
    int totalServicios = 2;
    if ("claro".equals(clienteSeleccionado)) {
        totalSolicitudes = 2;
        totalServicios = 1;
    } else if ("movistar".equals(clienteSeleccionado)) {
        totalSolicitudes = 1;
        totalServicios = 1;
    }
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
                <a href="${pageContext.request.contextPath}/capacity_planner/clientes.jsp" class="activo">Clientes</a>
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
    <!-- CLIENTES: el diseño muestra tres registros del SQL como ejemplo -->
    <main class="contenido-principal">
        <section class="encabezado-panel">
            <h2>Capacity Planner</h2>
            <h1>Clientes</h1>
        </section>
        <section class="seccion-clientes">
            <div class="panel-clientes">
                <div class="titulo-seccion">
                    <h2>Clientes frecuentes</h2>
                    <span class="cantidad-clientes">3</span>
                </div>
                <!-- LISTA: conserva el orden calculado a partir de los clics -->
                <ul class="lista-clientes">
                    <% for (String codigoCliente : ordenClientes) {
                        String nombreLista;
                        String razonLista;
                        switch (codigoCliente) {
                            case "claro":
                                nombreLista = "Claro";
                                razonLista = "Claro Telecomunicaciones S.A.C.";
                                break;
                            case "movistar":
                                nombreLista = "Movistar";
                                razonLista = "Movistar Servicios Digitales S.A.C.";
                                break;
                            default:
                                nombreLista = "Pacifico";
                                razonLista = "Pacifico Conectividad S.A.C.";
                                break;
                        }
                    %>
                    <li class="<%= clienteSeleccionado.equals(codigoCliente) ? "cliente-seleccionado" : "" %>">
                        <a class="cliente-enlace" href="clientes.jsp?cliente=<%= codigoCliente %>&amp;visita=1">
                            <span class="avatar-cliente"><%= nombreLista.substring(0, 1) %></span>
                            <span class="datos-cliente">
                                <strong><%= nombreLista %></strong>
                                <small><%= razonLista %></small>
                                <small><%= "pacifico".equals(codigoCliente) ? "2 servicios contratados" : "1 servicio contratado" %></small>
                            </span>
                        </a>
                    </li>
                    <% } %>
                </ul>
                <!-- VENTANAS: popovertarget abre los formularios sin JavaScript -->
                <div class="botones-clientes">
                    <button class="boton primario" type="button" popovertarget="modalNuevoCliente">+ Nuevo cliente</button>
                    <button class="boton secundario" type="button" popovertarget="modalEditarCliente">Editar cliente</button>
                    <button class="boton peligro" type="button" popovertarget="modalEliminarCliente">Eliminar cliente</button>
                </div>
            </div>
            <!-- RESUMEN: se actualiza según el cliente seleccionado -->
            <div class="panel-resumen">
                <div class="encabezado-resumen">
                    <span class="etiqueta-resumen">Resumen</span>
                    <strong class="titulo-resumen"><%= nombreCliente %></strong>
                </div>
                <a class="opcion-resumen" href="clientes.jsp?cliente=<%= clienteSeleccionado %>&amp;detalle=solicitudes">
                    <span class="icono-opcion">★</span>
                    <span class="texto-opcion">
                        <strong>Solicitudes asociadas</strong>
                        <small><%= totalSolicitudes %> solicitudes registradas</small>
                    </span>
                    <span class="flecha">›</span>
                </a>
                <a class="opcion-resumen" href="clientes.jsp?cliente=<%= clienteSeleccionado %>&amp;detalle=servicios">
                    <span class="icono-opcion">★</span>
                    <span class="texto-opcion">
                        <strong>Servicios contratados</strong>
                        <small><%= totalServicios %> servicios contratados</small>
                    </span>
                    <span class="flecha">›</span>
                </a>
                <a class="opcion-resumen" href="clientes.jsp?cliente=<%= clienteSeleccionado %>&amp;detalle=contacto">
                    <span class="icono-opcion">★</span>
                    <span class="texto-opcion">
                        <strong>Contacto</strong>
                        <small><%= correoCliente %></small>
                    </span>
                    <span class="flecha">›</span>
                </a>
                <a class="opcion-resumen" href="clientes.jsp?cliente=<%= clienteSeleccionado %>&amp;detalle=estado">
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
        <% if (detalleSeleccionado != null) { %>
        <section class="panel-detalle">
            <div class="encabezado-detalle">
                <div>
                    <p class="subtitulo-detalle">Cliente <%= nombreCliente %></p>
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
                <a class="cerrar-detalle" href="clientes.jsp?cliente=<%= clienteSeleccionado %>" aria-label="Cerrar detalle">&times;</a>
            </div>
            <div class="contenido-detalle">
                <% if ("solicitudes".equals(detalleSeleccionado)) { %>
                    <!-- Solicitudes ficticias del cliente seleccionado -->
                    <article class="tarjeta-detalle">
                        <div><strong>SOL-<%= idCliente %>01 · Los Ángeles — Lurín</strong><p>Capacidad solicitada: 50 Gbps</p></div>
                        <span class="badge aprobada">Aprobada</span>
                    </article>
                    <% if (totalSolicitudes >= 2) { %>
                    <article class="tarjeta-detalle">
                        <div><strong>SOL-<%= idCliente %>02 · Lurín — Valparaíso</strong><p>Capacidad solicitada: 20 Gbps</p></div>
                        <span class="badge pendiente">En evaluación</span>
                    </article>
                    <% } %>
                    <% if (totalSolicitudes >= 3) { %>
                    <article class="tarjeta-detalle">
                        <div><strong>SOL-<%= idCliente %>03 · Guayaquil — Lurín</strong><p>Capacidad solicitada: 30 Gbps</p></div>
                        <span class="badge aprobada">Activa</span>
                    </article>
                    <% } %>
                <% } else if ("servicios".equals(detalleSeleccionado)) { %>
                    <!-- Servicios ficticios: cada servicio tiene ruta y capacidad asignada -->
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
                        <p><b>Empresa:</b> <%= nombreCliente %></p>
                        <p><b>Correo:</b> <%= correoCliente %></p>
                        <p><b>Teléfono:</b> <%= telefonoCliente %></p>
                    </article>
                <% } else { %>
                    <article class="tarjeta-detalle contacto">
                        <p><b>ID:</b> <%= idCliente %></p>
                        <p><b>Nombre:</b> <%= nombreCliente %></p>
                        <p><b>Razón social:</b> <%= razonSocial %></p>
                        <p><b>RUC:</b> <%= rucCliente %></p>
                        <p><b>Estado:</b> <span class="badge <%= estadoCliente.equals("activo") ? "activa" : "inactiva" %>"><%= estadoCliente.equals("activo") ? "Activo" : "Inactivo" %></span></p>
                    </article>
                <% } %>
            </div>
        </section>
        <% } %>
    </main>
</div>
<!-- NUEVO CLIENTE: campos que existen en la tabla clientes.
     Guardar se conectará al Servlet; por ahora es un botón de maqueta. -->
<div id="modalNuevoCliente" class="modal" popover>
    <div class="contenido-modal">
        <div class="encabezado-modal">
            <h2>Nuevo cliente</h2>
            <button class="cerrar-modal" type="button" popovertarget="modalNuevoCliente" popovertargetaction="hide">&times;</button>
        </div>
        <form action="#" method="post">
            <div class="grupo-formulario">
                <label for="nuevo_nombre">Nombre</label>
                <input type="text" id="nuevo_nombre" name="nombre" maxlength="100" required>
            </div>
            <div class="grupo-formulario">
                <label for="nuevo_razon_social">Razón social</label>
                <input type="text" id="nuevo_razon_social" name="razon_social" maxlength="150" required>
            </div>
            <div class="grupo-formulario">
                <label for="nuevo_RUC">RUC</label>
                <input type="text" id="nuevo_RUC" name="RUC" minlength="11" maxlength="11" pattern="[0-9]{11}" inputmode="numeric" required>
            </div>
            <div class="grupo-formulario">
                <label for="nuevo_correo">Correo electrónico</label>
                <input type="email" id="nuevo_correo" name="correo" maxlength="100" required>
            </div>
            <div class="grupo-formulario">
                <label for="nuevo_telefono">Teléfono (opcional)</label>
                <input type="tel" id="nuevo_telefono" name="telefono" maxlength="15">
            </div>
            <div class="grupo-formulario">
                <label for="nuevo_estado">Estado</label>
                <select id="nuevo_estado" name="estado" required>
                    <option value="activo">Activo</option>
                    <option value="inactivo">Inactivo</option>
                </select>
            </div>
            <div class="botones-modal">
                <button class="boton-cancelar" type="button" popovertarget="modalNuevoCliente" popovertargetaction="hide">Cancelar</button>
                <button class="boton-guardar" type="button">Guardar cliente</button>
            </div>
        </form>
    </div>
</div>
<!-- EDITAR CLIENTE: campos que existen en la tabla clientes.
     Guardar se conectará al Servlet; por ahora es un botón de maqueta. -->
<div id="modalEditarCliente" class="modal" popover>
    <div class="contenido-modal">
        <div class="encabezado-modal">
            <h2>Editar cliente</h2>
            <button class="cerrar-modal" type="button" popovertarget="modalEditarCliente" popovertargetaction="hide">&times;</button>
        </div>
        <form action="#" method="post">
            <input type="hidden" name="id_cliente" value="<%= idCliente %>">
            <div class="grupo-formulario">
                <label for="editar_nombre">Nombre</label>
                <input type="text" id="editar_nombre" name="nombre" value="<%= nombreCliente %>" maxlength="100" required>
            </div>
            <div class="grupo-formulario">
                <label for="editar_razon_social">Razón social</label>
                <input type="text" id="editar_razon_social" name="razon_social" value="<%= razonSocial %>" maxlength="150" required>
            </div>
            <div class="grupo-formulario">
                <label for="editar_RUC">RUC</label>
                <input type="text" id="editar_RUC" name="RUC" value="<%= rucCliente %>" minlength="11" maxlength="11" pattern="[0-9]{11}" inputmode="numeric" required>
            </div>
            <div class="grupo-formulario">
                <label for="editar_correo">Correo electrónico</label>
                <input type="email" id="editar_correo" name="correo" value="<%= correoCliente %>" maxlength="100" required>
            </div>
            <div class="grupo-formulario">
                <label for="editar_telefono">Teléfono (opcional)</label>
                <input type="tel" id="editar_telefono" name="telefono" value="<%= telefonoCliente %>" maxlength="15">
            </div>
            <div class="grupo-formulario">
                <label for="editar_estado">Estado</label>
                <select id="editar_estado" name="estado" required>
                    <option value="activo" <%= estadoCliente.equals("activo") ? "selected" : "" %>>Activo</option>
                    <option value="inactivo" <%= estadoCliente.equals("inactivo") ? "selected" : "" %>>Inactivo</option>
                </select>
            </div>
            <div class="botones-modal">
                <button class="boton-cancelar" type="button" popovertarget="modalEditarCliente" popovertargetaction="hide">Cancelar</button>
                <button class="boton-guardar" type="button">Guardar cambios</button>
            </div>
        </form>
    </div>
</div>
<!-- ELIMINAR: confirmación visual; todavía no borra registros -->
<div id="modalEliminarCliente" class="modal modal-confirmacion" popover>
    <div class="contenido-modal">
        <div class="encabezado-modal">
            <h2>Eliminar cliente</h2>
            <button class="cerrar-modal" type="button" popovertarget="modalEliminarCliente" popovertargetaction="hide">&times;</button>
        </div>
        <p class="mensaje-confirmacion">¿Desea eliminar al cliente <strong><%= nombreCliente %></strong>?</p>
        <div class="botones-modal">
            <button class="boton-cancelar" type="button" popovertarget="modalEliminarCliente" popovertargetaction="hide">Cancelar</button>
            <button class="boton-confirmar-eliminar" type="button">Eliminar</button>
        </div>
    </div>
</div>
</body>
</html>
