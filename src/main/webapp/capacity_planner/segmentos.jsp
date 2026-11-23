<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.capacityplanner.Segmento" %>
<%@ page import="beans.capacityplanner.LandingStation" %>

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

    String filtro = (String) request.getAttribute("filtroEstado");
    int pagina = (Integer) request.getAttribute("paginaActual");
    int totalPaginas = (Integer) request.getAttribute("totalPaginas");
    int cantidad = (Integer) request.getAttribute("totalSegmentos");
    String filtroUrl = java.net.URLEncoder.encode(filtro, "UTF-8");
    String urlPagina = servlet + "?estado=" + filtroUrl + "&amp;pagina=";
    String urlLista = urlPagina + pagina;
    String error = (String) request.getAttribute("error");
    if (error == null) error = "";
    Segmento datos = (Segmento) request.getAttribute("segmentoFormulario");
    String nombreInicial = request.getParameter("nombreInicial");
    String nombreFinal = request.getParameter("nombreFinal");
    String totalFormulario = request.getParameter("total");
    if (datos != null && nombreInicial == null && nombreFinal == null) {
        for (LandingStation estacion : estaciones) {
            if (estacion.getIdLanding() == datos.getIdLandingInicial()) {
                nombreInicial = estacion.getNombre();
            }
            if (estacion.getIdLanding() == datos.getIdLandingFinal()) {
                nombreFinal = estacion.getNombre();
            }
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
    <style>
        .paginacion-segmentos {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 8px;
        }

        .paginacion-segmentos .paginacion-controles {
            display: flex;
            gap: 8px;
            margin-inline-start: auto;
        }

        .paginacion-segmentos .boton.paginacion-boton {
            background: #fff;
            border: 1px solid var(--color-borde, #d9e1e8);
        }

        .paginacion-segmentos .paginacion-indicador {
            color: var(--color-texto-claro, #64748b);
            font-size: .875rem;
        }
        .selector-estacion { position: relative; }
        .selector-campo { position: relative; }
        .selector-campo input { padding-right: 42px; }
        .selector-flecha {
            position: absolute;
            right: 0;
            top: 0;
            bottom: 0;
            width: 42px;
            border: 0;
            background: transparent;
            color: #1e293b;
            cursor: pointer;
        }
        .selector-opciones {
            position: absolute;
            top: calc(100% + 4px);
            left: 0;
            right: 0;
            z-index: 2;
            max-height: 220px;
            overflow: auto;
            border: 1px solid #d9e1e8;
            border-radius: 8px;
            background: white;
            box-shadow: 0 6px 16px #1e293b1a;
        }
        .selector-opciones button {
            width: 100%;
            padding: 12px 15px;
            text-align: left;
            font: inherit;
            color: inherit;
            background: white;
            border: 0;
            cursor: pointer;
        }
        .selector-opciones button:hover,
        .selector-opciones button:focus-visible { background: #ebf3f6; }
    </style>
</head>
<body class="vista-segmentos">
<jsp:include page="header.jsp" />
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
                <a href="${pageContext.request.contextPath}/PerfilServlet">Perfil</a>
                <!-- Navega al login; el cierre real de sesión se conectará después -->
                <a href="${pageContext.request.contextPath}/LogoutServlet" class="cerrar-sesion">Cerrar sesión</a>
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
        </section>
        <% if ("1".equals(request.getParameter("guardado"))) { %>
            <p class="mensaje-exito">Segmento guardado correctamente.</p>
        <% } %>
        <% String eliminacion = request.getParameter("eliminacion");
           if ("ok".equals(eliminacion)) { %>
            <p class="mensaje-exito" role="status">Segmento eliminado correctamente.</p>
        <% } else if ("asociado".equals(eliminacion)) { %>
            <p class="mensaje-error" role="alert">El segmento está asociado a otros registros y no se puede eliminar.</p>
        <% } else if ("noDisponible".equals(eliminacion)) { %>
            <p class="mensaje-error" role="alert">El segmento ya no existe o tiene capacidad ocupada o reservada.</p>
        <% } else if ("error".equals(eliminacion)) { %>
            <p class="mensaje-error" role="alert">No se pudo eliminar el segmento. Intenta nuevamente.</p>
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
                        long total = segmento.getCapacidadTotal();
                        long ocupada = segmento.getCapacidadOcupada();
                        boolean critica = total > 0 && ocupada * 100 > total * 95;
                        boolean alta = total > 0 && ocupada * 100 >= total * 80;

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
                                   href="<%= urlLista %>&amp;detalle=<%= segmento.getIdSegmento() %>#detalle">
                                    <%= texto(segmento.getCodigo()) %>
                                </a>
                            </td>

                            <td><%= texto(segmento.getNombreInicial()) %></td>
                            <td><%= texto(segmento.getNombreFinal()) %></td>
                            <td><%= segmento.getCapacidadTotal() %> Gbps</td>
                            <td>
                                <%= ocupada %> Gbps
                                <% if (alta) { %>
                                    <span class="estado <%= critica ? "fuera" : "degradado" %>">
                                        <%= critica ? "Utilización crítica" : "Alta utilización" %>
                                    </span>
                                <% } %>
                            </td>
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


        <% if (totalPaginas > 1) { %>
        <nav class="paginacion-segmentos" aria-label="Paginación de segmentos">
            <span class="paginacion-indicador" aria-current="page">Página <%= pagina %> de <%= totalPaginas %></span>
            <div class="paginacion-controles">
                <% if (pagina > 1) { %>
                    <a class="boton secundario paginacion-boton" href="<%= urlPagina %><%= pagina - 1 %>">Anterior</a>
                <% } %>
                <% if (pagina < totalPaginas) { %>
                    <a class="boton secundario paginacion-boton" href="<%= urlPagina %><%= pagina + 1 %>">Siguiente</a>
                <% } %>
            </div>
        </nav>
        <% } %>

        <% Segmento segmento = (Segmento) request.getAttribute("segmentoDetalle");
           if (segmento != null) { %>
            <section class="panel-detalle" id="detalle">
                <div class="encabezado-detalle">
                    <h2><%= texto(segmento.getCodigo()) %></h2>
                    <a href="<%= urlLista %>" aria-label="Cerrar detalle">×</a>
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
                    <a href="<%= urlLista %>&amp;editar=<%= segmento.getIdSegmento() %>"
                       class="boton primario">
                        Editar segmento
                    </a>
                    <form action="<%= servlet %>" method="post"
                          onsubmit="return confirm('¿Eliminar este segmento de forma permanente?');">
                        <input type="hidden" name="accion" value="eliminar">
                        <input type="hidden" name="id" value="<%= segmento.getIdSegmento() %>">
                        <input type="hidden" name="estado" value="<%= texto(filtro) %>">
                        <input type="hidden" name="pagina" value="<%= pagina %>">
                        <input type="hidden" name="tokenEliminar" value="${sessionScope.tokenEliminarSegmento}">
                        <button type="submit" class="boton" style="color: #a61b1b;">Eliminar segmento</button>
                    </form>
                </div>
            </section>
        <% } %>
    </main>
</div>

<!-- 7. FORMULARIO: se abre mediante un enlace, sin JavaScript. -->
<% if (datos != null) { %>
<div class="modal" role="dialog" aria-modal="true" aria-labelledby="tituloFormulario">
    <section class="contenido-modal">
        <div class="encabezado-detalle">
            <h2 id="tituloFormulario">Editar segmento</h2>
            <a href="<%= urlLista %>" aria-label="Cerrar formulario">×</a>
        </div>
        <% if (!error.isEmpty()) { %><p class="mensaje-error"><%= texto(error) %></p><% } %>
        <form id="editarSegmento" action="<%= servlet %>" method="post">
            <input type="hidden" name="accion" value="guardar">
            <input type="hidden" name="estado" value="<%= filtro %>">
            <input type="hidden" name="pagina" value="<%= pagina %>">
            <input type="hidden" name="id" value="<%= datos.getIdSegmento() %>">
            <div class="grupo-formulario">
                <label for="codigo">Código</label>
                <input id="codigo" readonly aria-live="polite"
                       value="<%= texto(datos.getCodigo() == null ? (String) request.getAttribute("codigoActual") : datos.getCodigo()) %>">
            </div>
            <div class="grupo-formulario selector-estacion">
                <label for="nombreInicial">Estación inicial</label>
                <div class="selector-campo">
                    <input id="nombreInicial" name="nombreInicial" autocomplete="off"
                           aria-controls="opcionesInicial" placeholder="Escribe o selecciona una estación"
                           value="<%= texto(nombreInicial) %>" required>
                    <button type="button" class="selector-flecha" aria-label="Ver estaciones"
                            aria-controls="opcionesInicial" aria-expanded="false">▾</button>
                </div>
                <div class="selector-opciones" id="opcionesInicial" hidden>
                    <% for (LandingStation estacion : estaciones) { %>
                        <button type="button"><%= texto(estacion.getNombre()) %></button>
                    <% } %>
                </div>
            </div>
            <div class="grupo-formulario selector-estacion">
                <label for="nombreFinal">Estación final</label>
                <div class="selector-campo">
                    <input id="nombreFinal" name="nombreFinal" autocomplete="off"
                           aria-controls="opcionesFinal" placeholder="Escribe o selecciona una estación"
                           value="<%= texto(nombreFinal) %>" required>
                    <button type="button" class="selector-flecha" aria-label="Ver estaciones"
                            aria-controls="opcionesFinal" aria-expanded="false">▾</button>
                </div>
                <div class="selector-opciones" id="opcionesFinal" hidden>
                    <% for (LandingStation estacion : estaciones) { %>
                        <button type="button"><%= texto(estacion.getNombre()) %></button>
                    <% } %>
                </div>
            </div>
            <div class="grupo-formulario">
                <label for="total">Capacidad total (Gbps)</label>
                <input id="total" name="total" type="number" min="1" max="4294967295" step="1" value="<%= texto(totalFormulario == null ? String.valueOf(datos.getCapacidadTotal()) : totalFormulario) %>" required>
            </div>
            <div class="grupo-formulario">
                <label for="estadoSegmento">Estado</label>
                <select id="estadoSegmento" name="estadoSegmento" required>
                    <% for (String estado : estados) { %>
                        <option value="<%= estado %>" <%= estado.equals(datos.getEstado()) ? "selected" : "" %>><%= estado %></option>
                    <% } %>
                </select>
            </div>
            <!-- Ocupada y reservada se gestionarán automáticamente con los servicios y reservas. -->
            <p class="ayuda">La capacidad ocupada y reservada se muestran en el detalle; no se modifican desde este formulario.</p>
            <div class="acciones">
                <a href="<%= urlLista %>" class="boton secundario">Cancelar</a>
                <button type="submit" class="boton primario">Guardar</button>
            </div>
        </form>
    </section>
</div>
<script>
    (() => {
        const form = document.getElementById('editarSegmento');
        const codigo = form.querySelector('#codigo');
        const selectores = [...form.querySelectorAll('.selector-estacion')];
        const campos = selectores.map(selector => selector.querySelector('input'));
        const nombres = new Set([...selectores[0].querySelectorAll('.selector-opciones button')]
            .map(opcion => opcion.textContent));
        let solicitud;

        function actualizarCodigo() {
            solicitud?.abort();
            codigo.value = '';
            const [inicial, final] = campos.map(campo => campo.value.trim());
            if (!nombres.has(inicial) || !nombres.has(final) || inicial === final) {
                codigo.placeholder = 'Elige dos estaciones diferentes';
                return;
            }

            const peticion = new AbortController();
            solicitud = peticion;
            const url = new URL(form.action);
            url.search = new URLSearchParams({
                accion: 'previsualizarCodigo',
                id: form.elements.id.value,
                nombreInicial: inicial,
                nombreFinal: final
            });
            codigo.placeholder = 'Calculando código…';
            fetch(url, {signal: peticion.signal})
                .then(respuesta => {
                    if (!respuesta.ok) throw new Error('Código no disponible');
                    return respuesta.text();
                })
                .then(valor => {
                    if (!peticion.signal.aborted) codigo.value = valor;
                })
                .catch(() => {
                    if (!peticion.signal.aborted) codigo.placeholder = 'El código se calculará al guardar';
                });
        }

        selectores.forEach((selector, indice) => {
            const campo = campos[indice];
            const flecha = selector.querySelector('.selector-flecha');
            const lista = selector.querySelector('.selector-opciones');
            const opciones = [...lista.querySelectorAll('button')];
            const normalizar = texto => texto.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase();

            function cerrar() {
                lista.hidden = true;
                flecha.setAttribute('aria-expanded', 'false');
            }

            function abrir(busqueda = '') {
                opciones.forEach(opcion => {
                    opcion.hidden = !normalizar(opcion.textContent).includes(normalizar(busqueda.trim()));
                });
                lista.hidden = opciones.every(opcion => opcion.hidden);
                flecha.setAttribute('aria-expanded', String(!lista.hidden));
            }

            campo.addEventListener('click', () => abrir());
            campo.addEventListener('input', () => {
                abrir(campo.value);
                actualizarCodigo();
            });
            flecha.addEventListener('click', () => {
                if (lista.hidden) abrir();
                else cerrar();
            });
            opciones.forEach(opcion => opcion.addEventListener('click', () => {
                campo.value = opcion.textContent;
                campo.focus();
                cerrar();
                actualizarCodigo();
            }));
            selector.addEventListener('keydown', evento => {
                if (evento.key === 'Escape') {
                    campo.focus();
                    cerrar();
                }
                if (evento.key === 'ArrowDown' && evento.target === campo) {
                    evento.preventDefault();
                    if (lista.hidden) abrir();
                    opciones.find(opcion => !opcion.hidden)?.focus();
                }
            });
            selector.addEventListener('focusout', evento => {
                if (!selector.contains(evento.relatedTarget)) cerrar();
            });
            document.addEventListener('click', evento => {
                if (!selector.contains(evento.target)) cerrar();
            });
        });

        if (!codigo.value) actualizarCodigo();
    })();
</script>
<% } %>
</body>
</html>
