<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.capacityplanner.Cliente" %>
<%@ page import="beans.capacityplanner.Solicitud" %>

<%!
    private String texto(String valor) {
        if (valor == null) return "";
        return valor.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<%
    String servlet = request.getContextPath() + "/SolicitudesServlet";

    Solicitud solicitud =
            (Solicitud) request.getAttribute("solicitud");

    ArrayList<Cliente> clientes =
            (ArrayList<Cliente>) request.getAttribute("listaClientes");

    ArrayList<String[]> estaciones =
            (ArrayList<String[]>) request.getAttribute("listaEstaciones");

    if (clientes == null || estaciones == null) {
        response.sendRedirect(servlet + "?action=formCrear");
        return;
    }

    boolean esEdicion =
            solicitud != null && solicitud.getIdSolicitud() > 0;

    String id = esEdicion
            ? String.valueOf(solicitud.getIdSolicitud()) : "";

    int idCliente = solicitud != null
            ? solicitud.getIdCliente() : -1;

    String origen = solicitud != null
            ? String.valueOf(solicitud.getIdLandingOrigen()) : "";

    String destino = solicitud != null
            ? String.valueOf(solicitud.getIdLandingDestino()) : "";

    String capacidad = solicitud != null
            ? String.valueOf(solicitud.getCapacidadSolicitada()) : "";

    String motivo = solicitud != null
            ? solicitud.getJustificacion() : "";

    String error = (String) request.getAttribute("error");

    String nombreCliente = "";
    String nombreOrigen = "";
    String nombreDestino = "";

    for (Cliente c : clientes) {
        if (c.getIdCliente() == idCliente) {
            nombreCliente = c.getNombre();
        }
    }

    for (String[] estacion : estaciones) {
        if (estacion[0].equals(origen)) {
            nombreOrigen = estacion[1];
        }

        if (estacion[0].equals(destino)) {
            nombreDestino = estacion[1];
        }
    }
%>

<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title><%= esEdicion ? "Editar solicitud" : "Nueva solicitud" %> | OceanLink</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/capacity_planner/solicitudes.css?v=2">

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/barras.css">

    <style>
        /* Selectores con búsqueda */
        .formulario-solicitud .selector-busqueda {
            position: relative;
            min-width: 0;
        }

        .formulario-solicitud .selector-busqueda > label {
            display: block;
            margin-bottom: 8px;
            font-size: 16px;
            font-weight: 600;
            color: #0b3d5c;
        }

        .selector-busqueda .campo-busqueda {
            position: relative;
        }

        .formulario-solicitud .campo-busqueda input {
            width: 100%;
            height: 46px;
            box-sizing: border-box;
            margin: 0;
            padding: 11px 44px 11px 15px;
            border: 1px solid #d9e1e8;
            border-radius: 6px;
            background: white;
            color: #1e293b;
            font-family: inherit;
            font-size: 16px;
            font-weight: normal;
        }

        .campo-busqueda input::placeholder {
            color: #64748b;
            opacity: 1;
        }

        .formulario-solicitud .campo-busqueda input:focus {
            outline: 2px solid #1c8c9c33;
            border-color: #1c8c9c;
        }

        .selector-busqueda .flecha-busqueda {
            position: absolute;
            top: 0;
            right: 0;
            width: 40px;
            height: 46px;
            padding: 0;
            margin: 0;
            border: none;
            background: transparent;
            color: #1e293b;
            font-size: 19px;
            cursor: pointer;
        }

        .selector-busqueda .lista-busqueda {
            position: absolute;
            top: calc(100% + 5px);
            left: 0;
            right: 0;
            z-index: 30;
            max-height: 220px;
            overflow-y: auto;
            padding: 5px;
            border: 1px solid #d9e1e8;
            border-radius: 7px;
            background: white;
            box-shadow: 0 5px 15px #00000015;
        }

        .lista-busqueda .opcion-busqueda {
            display: block;
            width: 100%;
            box-sizing: border-box;
            margin: 0;
            padding: 11px 12px;
            border: none;
            border-radius: 4px;
            background: white;
            color: #1e293b;
            text-align: left;
            font-family: inherit;
            font-size: 15px;
            font-weight: normal;
            line-height: 1.4;
            cursor: pointer;
        }

        .lista-busqueda .opcion-busqueda:hover,
        .lista-busqueda .opcion-busqueda:focus-visible {
            outline: none;
            background: #eaf4f6;
            color: #0b3d5c;
        }

        .lista-busqueda .sin-resultados {
            margin: 0;
            padding: 12px;
            font-size: 14px;
            color: #64748b;
        }

        .selector-busqueda [hidden] {
            display: none;
        }
    </style>
</head>

<body>

<input type="checkbox" id="controlMenu" class="control-menu">

<header class="barra-superior">
    <div class="zona-logo">
        <label for="controlMenu"
               class="boton-menu"
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

                <a href="<%= servlet %>" class="activo">
                    Solicitudes
                </a>

                <div class="grupo-menu">
                    <input type="checkbox"
                           id="control-infraestructura"
                           class="control-submenu">

                    <label for="control-infraestructura" class="titulo-grupo">
                        <span>Infraestructura</span>
                        <span class="flecha-submenu"></span>
                    </label>

                    <div class="contenido-submenu">
                        <a href="${pageContext.request.contextPath}/capacity_planner/rutas.jsp"
                           class="subopcion">Rutas</a>

                        <a href="${pageContext.request.contextPath}/capacity_planner/segmentos.jsp"
                           class="subopcion">Segmentos</a>

                        <a href="${pageContext.request.contextPath}/capacity_planner/landing_stations.jsp"
                           class="subopcion">Landing stations</a>
                    </div>
                </div>

                <a href="${pageContext.request.contextPath}/capacity_planner/servicios.jsp">
                    Servicios
                </a>
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

    <main class="contenido-principal">
        <section class="encabezado-panel">
            <div>
                <h2>Solicitudes</h2>
                <h1><%= esEdicion ? "Editar solicitud" : "Nueva solicitud" %></h1>
            </div>
        </section>

        <section class="panel-detalle">
            <% if (error != null) { %>
                <p class="mensaje-error" role="alert">
                    <%= texto(error) %>
                </p>
            <% } %>

            <% if (clientes.isEmpty() || estaciones.size() < 2) { %>
                <p class="mensaje-error">
                    Necesitas al menos un cliente activo y dos estaciones activas.
                </p>
            <% } %>

            <form method="post"
                  action="<%= servlet %>?action=guardar"
                  class="formulario-solicitud">

                <input type="hidden"
                       name="id_solicitud"
                       value="<%= id %>">

                <!-- Cliente -->
                <div class="selector-busqueda">
                    <label for="nombreCliente">Cliente</label>

                    <div class="campo-busqueda">
                        <input type="text"
                               id="nombreCliente"
                               value="<%= texto(nombreCliente) %>"
                               placeholder="Seleccione un cliente activo"
                               autocomplete="off"
                               aria-controls="opcionesClientes"
                               required>

                        <button type="button"
                                class="flecha-busqueda"
                                aria-label="Mostrar clientes"
                                aria-controls="opcionesClientes"
                                aria-expanded="false">▾</button>
                    </div>

                    <input type="hidden"
                           name="id_cliente"
                           value="<%= idCliente > 0 ? String.valueOf(idCliente) : "" %>">

                    <div id="opcionesClientes" class="lista-busqueda" hidden>
                        <% for (Cliente c : clientes) { %>
                            <button type="button"
                                    class="opcion-busqueda"
                                    data-id="<%= c.getIdCliente() %>"
                                    data-nombre="<%= texto(c.getNombre()) %>">
                                <%= texto(c.getNombre()) %>
                            </button>
                        <% } %>

                        <p class="sin-resultados" hidden>
                            No hay clientes que coincidan.
                        </p>
                    </div>
                </div>

                <!-- Origen -->
                <div class="selector-busqueda">
                    <label for="nombreOrigen">Estación de origen</label>

                    <div class="campo-busqueda">
                        <input type="text"
                               id="nombreOrigen"
                               value="<%= texto(nombreOrigen) %>"
                               placeholder="Seleccione una estación activa"
                               autocomplete="off"
                               aria-controls="opcionesOrigen"
                               required>

                        <button type="button"
                                class="flecha-busqueda"
                                aria-label="Mostrar estaciones de origen"
                                aria-controls="opcionesOrigen"
                                aria-expanded="false">▾</button>
                    </div>

                    <input type="hidden"
                           name="id_landing_origen"
                           value="<%= texto(origen) %>">

                    <div id="opcionesOrigen" class="lista-busqueda" hidden>
                        <% for (String[] estacion : estaciones) { %>
                            <button type="button"
                                    class="opcion-busqueda"
                                    data-id="<%= texto(estacion[0]) %>"
                                    data-nombre="<%= texto(estacion[1]) %>">
                                <%= texto(estacion[1]) %>
                            </button>
                        <% } %>

                        <p class="sin-resultados" hidden>
                            No hay estaciones que coincidan.
                        </p>
                    </div>
                </div>

                <!-- Destino -->
                <div class="selector-busqueda">
                    <label for="nombreDestino">Estación de destino</label>

                    <div class="campo-busqueda">
                        <input type="text"
                               id="nombreDestino"
                               value="<%= texto(nombreDestino) %>"
                               placeholder="Seleccione una estación activa"
                               autocomplete="off"
                               aria-controls="opcionesDestino"
                               required>

                        <button type="button"
                                class="flecha-busqueda"
                                aria-label="Mostrar estaciones de destino"
                                aria-controls="opcionesDestino"
                                aria-expanded="false">▾</button>
                    </div>

                    <input type="hidden"
                           name="id_landing_destino"
                           value="<%= texto(destino) %>">

                    <div id="opcionesDestino" class="lista-busqueda" hidden>
                        <% for (String[] estacion : estaciones) { %>
                            <button type="button"
                                    class="opcion-busqueda"
                                    data-id="<%= texto(estacion[0]) %>"
                                    data-nombre="<%= texto(estacion[1]) %>">
                                <%= texto(estacion[1]) %>
                            </button>
                        <% } %>

                        <p class="sin-resultados" hidden>
                            No hay estaciones que coincidan.
                        </p>
                    </div>
                </div>

                <label>Capacidad solicitada (Gbps)
                    <input type="number"
                           name="capacidad_solicitada"
                           min="1"
                           max="4294967295"
                           step="1"
                           value="<%= capacidad %>"
                           required>
                </label>

                <label class="ancho-completo">Justificación
                    <textarea name="justificacion"
                              rows="4"
                              required><%= texto(motivo) %></textarea>
                </label>

                <div class="botones-formulario ancho-completo">
                    <a class="boton secundario" href="<%= servlet %>">
                        Cancelar
                    </a>

                    <button class="boton primario"
                            type="submit"
                            <%= clientes.isEmpty() || estaciones.size() < 2
                                    ? "disabled" : "" %>>
                        <%= esEdicion ? "Guardar cambios" : "Crear solicitud" %>
                    </button>
                </div>
            </form>
        </section>
    </main>
</div>

<script>
    // Buscar sin distinguir mayúsculas ni tildes.
    function normalizar(valor) {
        return valor.toLowerCase().normalize("NFD")
                .replace(/[\u0300-\u036f]/g, "").trim();
    }

    document.querySelectorAll(".selector-busqueda").forEach(function(selector) {
        const campo = selector.querySelector('input[type="text"]');
        const oculto = selector.querySelector('input[type="hidden"]');
        const flecha = selector.querySelector(".flecha-busqueda");
        const lista = selector.querySelector(".lista-busqueda");
        const opciones = Array.from(lista.querySelectorAll(".opcion-busqueda"));
        const aviso = lista.querySelector(".sin-resultados");

        function cerrar() {
            lista.hidden = true;
            flecha.setAttribute("aria-expanded", "false");
        }

        function abrir(todas) {
            let cantidad = 0;

            opciones.forEach(function(opcion) {
                opcion.hidden = !todas &&
                    !normalizar(opcion.dataset.nombre).startsWith(
                        normalizar(campo.value)
                    );

                if (!opcion.hidden) cantidad++;
            });

            aviso.hidden = cantidad > 0;
            lista.hidden = false;
            flecha.setAttribute("aria-expanded", "true");
        }

        function validar() {
            campo.setCustomValidity(
                oculto.value ? "" : "Selecciona una opción de la lista."
            );
        }

        campo.addEventListener("input", function() {
            // No enviar el ID anterior si se modifica el nombre.
            oculto.value = "";
            validar();
            abrir(false);
        });

        campo.addEventListener("focus", function() {
            abrir(oculto.value !== "");
        });

        campo.addEventListener("click", function() {
            abrir(oculto.value !== "");
        });

        flecha.addEventListener("click", function() {
            if (lista.hidden) {
                campo.focus();
                abrir(true);
            } else {
                cerrar();
            }
        });

        opciones.forEach(function(opcion) {
            opcion.addEventListener("click", function() {
                campo.value = opcion.dataset.nombre;
                oculto.value = opcion.dataset.id;
                validar();
                campo.focus();
                cerrar();
            });
        });

        // Permitir seleccionar también con el teclado.
        selector.addEventListener("keydown", function(evento) {
            if (evento.key === "Escape") {
                if (evento.target !== campo) campo.focus();
                cerrar();
                return;
            }

            if (evento.key !== "ArrowDown" && evento.key !== "ArrowUp") {
                return;
            }

            evento.preventDefault();

            if (lista.hidden) abrir(oculto.value !== "");

            const visibles = opciones.filter(function(opcion) {
                return !opcion.hidden;
            });

            if (visibles.length === 0) return;

            let indice = visibles.indexOf(document.activeElement);

            if (evento.key === "ArrowDown") {
                indice = (indice + 1) % visibles.length;
            } else {
                indice = indice <= 0 ? visibles.length - 1 : indice - 1;
            }

            visibles[indice].focus();
        });

        selector.addEventListener("focusout", function(evento) {
            if (!selector.contains(evento.relatedTarget)) cerrar();
        });

        document.addEventListener("click", function(evento) {
            if (!selector.contains(evento.target)) cerrar();
        });

        // Mantener solo selecciones existentes al cargar el formulario.
        const seleccion = opciones.find(function(opcion) {
            return opcion.dataset.id === oculto.value;
        });

        if (seleccion) {
            campo.value = seleccion.dataset.nombre;
        } else {
            oculto.value = "";
        }

        validar();
    });
</script>
<script>
    // Copiar el tamaño del campo original de capacidad.
    const referencia = document.querySelector(
        'input[name="capacidad_solicitada"]'
    );

    const estiloCampo = getComputedStyle(referencia);
    const estiloEtiqueta = getComputedStyle(referencia.parentElement);

    document.querySelectorAll(".selector-busqueda").forEach(function(selector) {
        const etiqueta = selector.querySelector("label");
        const campo = selector.querySelector('input[type="text"]');
        const flecha = selector.querySelector(".flecha-busqueda");

        etiqueta.style.fontSize = estiloEtiqueta.fontSize;
        etiqueta.style.fontWeight = estiloEtiqueta.fontWeight;
        etiqueta.style.lineHeight = estiloEtiqueta.lineHeight;
        etiqueta.style.marginBottom = "8px";

        campo.style.fontSize = estiloCampo.fontSize;
        campo.style.fontFamily = estiloCampo.fontFamily;
        campo.style.lineHeight = estiloCampo.lineHeight;
        campo.style.height = estiloCampo.height;
        campo.style.paddingTop = estiloCampo.paddingTop;
        campo.style.paddingBottom = estiloCampo.paddingBottom;
        campo.style.paddingLeft = estiloCampo.paddingLeft;
        campo.style.marginTop = estiloCampo.marginTop;
        campo.style.marginBottom = estiloCampo.marginBottom;

        flecha.style.height = estiloCampo.height;
        flecha.style.top = estiloCampo.marginTop;

        selector.querySelectorAll(".opcion-busqueda").forEach(function(opcion) {
            opcion.style.fontSize = estiloCampo.fontSize;
        });
    });
</script>
</body>
</html>
