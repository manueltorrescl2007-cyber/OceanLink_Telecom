<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.Ruta" %>
<%@ page import="beans.Segmento" %>
<%@ page import="beans.LandingStation" %>
<%!
    private String texto(String valor) {
        return valor == null ? "" : valor.replace("&", "&amp;")
                .replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    String servlet = request.getContextPath() + "/RutaServlet";

    ArrayList<Ruta> rutas =
            (ArrayList<Ruta>) request.getAttribute("listaRutas");

    ArrayList<LandingStation> estaciones =
            (ArrayList<LandingStation>) request.getAttribute("listaEstaciones");

    ArrayList<Segmento> segmentos =
            (ArrayList<Segmento>) request.getAttribute("listaSegmentos");

    // Si se abre el JSP directamente, pasar primero por el servlet
    if (rutas == null || estaciones == null || segmentos == null) {
        response.sendRedirect(servlet);
        return;
    }

    String error = (String) request.getAttribute("error");
    if (error == null) {
        error = "";
    }

    String filtro = request.getParameter("filtro");
    if (!"activa".equals(filtro) && !"inactiva".equals(filtro)) {
        filtro = "Todas";
    }

    int cantidad = 0;
    Ruta rutaDetalle = null;
    Ruta rutaFormulario = null;

    boolean formulario = "nuevo".equals(request.getParameter("ventana"));

    for (Ruta ruta : rutas) {
        if ("Todas".equals(filtro) || filtro.equals(ruta.getEstado())) {
            cantidad++;
        }

        String idRuta = String.valueOf(ruta.getIdRuta());

        if (idRuta.equals(request.getParameter("detalle"))) {
            rutaDetalle = ruta;
        }

        if (idRuta.equals(request.getParameter("editar"))) {
            rutaFormulario = ruta;
            formulario = true;
        }
    }

    // Recuperar los datos enviados si hubo un error al guardar
    Ruta datosEnviados =
            (Ruta) request.getAttribute("rutaFormulario");

    if (datosEnviados != null) {
        rutaFormulario = datosEnviados;
        formulario = true;
    }

    boolean esEdicion =
            rutaFormulario != null && rutaFormulario.getIdRuta() > 0;

    // ID, nombre, origen, destino, estado y códigos de segmentos
    String[] valor = {"", "", "", "", "activa", ""};

    if (rutaFormulario != null) {
        valor[0] = esEdicion
                ? String.valueOf(rutaFormulario.getIdRuta()) : "";
        valor[1] = rutaFormulario.getNombre();
        valor[2] = String.valueOf(rutaFormulario.getIdLandingOrigen());
        valor[3] = String.valueOf(rutaFormulario.getIdLandingDestino());
        valor[4] = rutaFormulario.getEstado();

        for (Segmento segmento : rutaFormulario.getSegmentos()) {
            if (!valor[5].isEmpty()) {
                valor[5] += ", ";
            }
            valor[5] += segmento.getCodigo();
        }
    }

    String codigosEnviados =
            (String) request.getAttribute("segmentosFormulario");

    if (codigosEnviados != null) {
        valor[5] = codigosEnviados;
    }
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rutas | OceanLink</title>
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/capacity_planner/rutas.css?v=4">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/barras.css">
</head>
<body class="vista-rutas">

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
                           class="control-submenu" checked>
                    <label for="control-infraestructura" class="titulo-grupo">
                        <span>Infraestructura</span>
                        <span class="flecha-submenu"></span>
                    </label>
                    <div class="contenido-submenu">
                        <a href="<%= servlet %>" class="subopcion activo">
                            Rutas
                        </a>
                        <a href="${pageContext.request.contextPath}/SegmentoServlet"
                           class="subopcion">Segmentos</a>
                        <a href="${pageContext.request.contextPath}/LandingStationServlet"
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

    <main class="contenido-principal pagina-rutas">
        <section class="encabezado-pagina">
            <div class="encabezado-panel">
                <h2>Capacity Planner</h2>
                <h1>Rutas</h1>
            </div>
            <a class="boton primario"
               href="<%= servlet %>?ventana=nuevo">+ Nueva ruta</a>
        </section>

        <% if ("1".equals(request.getParameter("guardado"))) { %>
            <p class="mensaje-exito">Ruta guardada.</p>
        <% } %>

        <% if ("1".equals(request.getParameter("eliminado"))) { %>
            <p class="mensaje-exito">Ruta eliminada.</p>
        <% } %>

        <% if (!error.isEmpty() && !formulario) { %>
            <p class="mensaje-error" role="alert"><%= texto(error) %></p>
        <% } %>

        <section class="barra-herramientas">
            <form method="get" action="<%= servlet %>" class="formulario-filtro">
                <label for="filtro">Estado:</label>
                <select id="filtro" name="filtro">
                    <option value="Todas"
                            <%= "Todas".equals(filtro) ? "selected" : "" %>>
                        Todas
                    </option>
                    <option value="activa"
                            <%= "activa".equals(filtro) ? "selected" : "" %>>
                        Activa
                    </option>
                    <option value="inactiva"
                            <%= "inactiva".equals(filtro) ? "selected" : "" %>>
                        Inactiva
                    </option>
                </select>
                <button class="boton secundario" type="submit">Filtrar</button>
            </form>
            <span><%= cantidad %> rutas</span>
        </section>

        <section class="contenedor-tabla">
            <table>
                <thead>
                <tr>
                    <th>ID</th>
                    <th>Nombre</th>
                    <th>Origen</th>
                    <th>Destino</th>
                    <th>Segmentos</th>
                    <th>Capacidad disponible</th>
                    <th>Estado</th>
                </tr>
                </thead>
                <tbody>
                <% for (Ruta ruta : rutas) {
                    if ("Todas".equals(filtro)
                            || filtro.equals(ruta.getEstado())) { %>
                    <tr>
                        <td>
                            <a class="enlace-ruta"
                               href="<%= servlet %>?detalle=<%= ruta.getIdRuta() %>">
                                RUT-<%= ruta.getIdRuta() %>
                            </a>
                        </td>
                        <td><%= texto(ruta.getNombre()) %></td>
                        <td><%= texto(ruta.getNombreOrigen()) %></td>
                        <td><%= texto(ruta.getNombreDestino()) %></td>
                        <td><%= ruta.getSegmentos().size() %></td>
                        <td><%= ruta.getCapacidadDisponible() %> Gbps</td>
                        <td>
                            <span class="estado <%= texto(ruta.getEstado()) %>">
                                <%= "activa".equals(ruta.getEstado())
                                        ? "Activa" : "Inactiva" %>
                            </span>
                        </td>
                    </tr>
                <%  }
                } %>

                <% if (cantidad == 0) { %>
                    <tr>
                        <td colspan="7">No hay rutas con este estado.</td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </section>

        <% if (rutaDetalle != null) {
            int orden = 1;
        %>
        <section class="panel-detalle">
            <div class="encabezado-detalle">
                <h2><%= texto(rutaDetalle.getNombre()) %></h2>
                <a href="<%= servlet %>" aria-label="Cerrar detalle">&times;</a>
            </div>

            <p class="resumen-ruta">
                <%= texto(rutaDetalle.getNombreOrigen()) %>
                →
                <%= texto(rutaDetalle.getNombreDestino()) %>
            </p>

            <h3>Segmentos de la ruta</h3>

            <div class="contenedor-tabla">
                <table>
                    <thead>
                    <tr>
                        <th>Orden</th>
                        <th>Segmento</th>
                        <th>Total</th>
                        <th>Ocupada</th>
                        <th>Reservada</th>
                        <th>Estado</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (Segmento segmento : rutaDetalle.getSegmentos()) { %>
                        <tr>
                            <td><%= orden++ %></td>
                            <td><%= texto(segmento.getCodigo()) %></td>
                            <td><%= segmento.getCapacidadTotal() %> Gbps</td>
                            <td><%= segmento.getCapacidadOcupada() %> Gbps</td>
                            <td><%= segmento.getCapacidadReservada() %> Gbps</td>
                            <td><%= texto(segmento.getEstado()) %></td>
                        </tr>
                    <% } %>

                    <% if (rutaDetalle.getSegmentos().isEmpty()) { %>
                        <tr>
                            <td colspan="6">Esta ruta no tiene segmentos.</td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>

            <p class="ayuda">
                Disponible = menor valor de (total − ocupada − reservada)
                entre los segmentos.
            </p>

            <div class="acciones">
                <a class="boton secundario"
                   href="<%= servlet %>?editar=<%= rutaDetalle.getIdRuta() %>">
                    Editar ruta
                </a>
                <button class="boton peligro" type="button"
                        popovertarget="confirmar-eliminar">
                    Eliminar ruta
                </button>
            </div>

            <div id="confirmar-eliminar" class="confirmacion" popover>
                <h2>Eliminar ruta</h2>
                <p>¿Deseas eliminar <%= texto(rutaDetalle.getNombre()) %>?</p>

                <form method="post" action="<%= servlet %>" class="acciones">
                    <input type="hidden" name="id_ruta"
                           value="<%= rutaDetalle.getIdRuta() %>">
                    <button class="boton secundario" type="button"
                            popovertarget="confirmar-eliminar"
                            popovertargetaction="hide">
                        Volver
                    </button>
                    <button class="boton peligro" name="accion"
                            value="eliminar" type="submit">
                        Eliminar
                    </button>
                </form>
            </div>
        </section>
        <% } %>
    </main>
</div>

<% if (formulario) { %>
<div class="modal">
    <section class="contenido-modal" role="dialog"
             aria-modal="true" aria-labelledby="titulo-modal">

        <div class="encabezado-detalle">
            <h2 id="titulo-modal">
                <%= esEdicion ? "Editar ruta" : "Nueva ruta" %>
            </h2>
            <a href="<%= servlet %>" aria-label="Cerrar formulario">&times;</a>
        </div>

        <% if (!error.isEmpty()) { %>
            <p class="mensaje-error" role="alert"><%= texto(error) %></p>
        <% } %>

        <form method="post" action="<%= servlet %>">
            <input type="hidden" name="accion" value="guardar">
            <input type="hidden" name="id_ruta" value="<%= texto(valor[0]) %>">

            <div class="grupo-formulario">
                <label for="nombre">Nombre de la ruta</label>
                <input id="nombre" name="nombre" maxlength="100"
                       value="<%= texto(valor[1]) %>"
                       placeholder="Ejemplo: LAX-LUR-R02" required>
            </div>

            <div class="cuadricula-formulario">
                <div class="grupo-formulario">
                    <label for="origen">Origen</label>
                    <select id="origen" name="id_landing_origen" required>
                        <option value="">Seleccione</option>
                        <% for (LandingStation estacion : estaciones) { %>
                            <option value="<%= estacion.getIdLanding() %>"
                                    <%= String.valueOf(estacion.getIdLanding())
                                            .equals(valor[2]) ? "selected" : "" %>>
                                <%= texto(estacion.getNombre()) %>
                            </option>
                        <% } %>
                    </select>
                </div>

                <div class="grupo-formulario">
                    <label for="destino">Destino</label>
                    <select id="destino" name="id_landing_destino" required>
                        <option value="">Seleccione</option>
                        <% for (LandingStation estacion : estaciones) { %>
                            <option value="<%= estacion.getIdLanding() %>"
                                    <%= String.valueOf(estacion.getIdLanding())
                                            .equals(valor[3]) ? "selected" : "" %>>
                                <%= texto(estacion.getNombre()) %>
                            </option>
                        <% } %>
                    </select>
                </div>
            </div>

            <div class="grupo-formulario">
                <label for="segmentos">
                    Segmentos en orden, separados por comas
                </label>
                <textarea id="segmentos" name="segmentos" rows="3"
                          placeholder="Ejemplo: LAX-LUR-01, LUR-VAL-01"
                          required><%= texto(valor[5]) %></textarea>
            </div>

            <details class="catalogo">
                <summary>Ver segmentos disponibles</summary>
                <% for (Segmento segmento : segmentos) { %>
                    <p>
                        <strong><%= texto(segmento.getCodigo()) %></strong>:
                        <%= texto(segmento.getNombreInicial()) %>
                        →
                        <%= texto(segmento.getNombreFinal()) %>
                    </p>
                <% } %>
            </details>

            <div class="grupo-formulario">
                <label for="estado-ruta">Estado</label>
                <select id="estado-ruta" name="estado_ruta">
                    <option value="activa"
                            <%= "activa".equals(valor[4]) ? "selected" : "" %>>
                        Activa
                    </option>
                    <option value="inactiva"
                            <%= "inactiva".equals(valor[4]) ? "selected" : "" %>>
                        Inactiva
                    </option>
                </select>
            </div>

            <div class="acciones">
                <a class="boton secundario" href="<%= servlet %>">Volver</a>
                <button class="boton primario" type="submit">
                    Guardar ruta
                </button>
            </div>
        </form>
    </section>
</div>
<% } %>

</body>
</html>
