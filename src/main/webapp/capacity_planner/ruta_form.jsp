<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="beans.capacityplanner.Ruta" %>
<%@ page import="beans.capacityplanner.Segmento" %>
<%@ page import="beans.capacityplanner.LandingStation" %>
<%!
    private int paginaValida(String valor) {
        try { return Integer.parseInt(valor); }
        catch (NumberFormatException e) { return 1; }
    }

    private String texto(String valor) {
        return valor == null ? "" : valor.replace("&", "&amp;")
                .replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    String servlet = request.getContextPath() + "/RutaServlet";

    boolean formulario = Boolean.TRUE.equals(request.getAttribute("vistaFormulario"));
    if (!formulario) {
        response.sendRedirect(servlet + "?ventana=nuevo");
        return;
    }
    String error = (String) request.getAttribute("error");
    if (error == null) error = "";
    String filtro = request.getParameter("filtro");
    if (!"activa".equals(filtro) && !"inactiva".equals(filtro)) filtro = "Todas";
    int pagina = formulario ? Math.max(1, paginaValida(request.getParameter("pagina")))
                            : (Integer) request.getAttribute("paginaActual");
    String urlLista = servlet + "?filtro=" + filtro + "&amp;pagina=" + pagina;
    String titulo = formulario
        ? (request.getAttribute("rutaFormulario") == null
            || ((Ruta) request.getAttribute("rutaFormulario")).getIdRuta() == 0 ? "Nueva ruta" : "Editar ruta")
        : "Rutas";
%>

<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= titulo %> | OceanLink</title>
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/capacity_planner/rutas.css?v=4">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/barras.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/capacity_planner/rutas_formulario.css">
</head>
<body class="vista-rutas">


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

    <main class="contenido-principal pagina-rutas pagina-ruta-form">
        <div class="ruta-contenido">
        <section class="encabezado-pagina">
            <div class="encabezado-panel">
                <h2>Capacity Planner</h2>
                <h1><%= titulo %></h1>
            </div>
            <% if (formulario) { %>
                <a class="boton secundario" href="<%= urlLista %>">Volver a rutas</a>
            <% } else { %>
                <a class="boton primario" href="<%= urlLista %>&amp;ventana=nuevo">+ Nueva ruta</a>
            <% } %>
        </section>

<%
    Ruta datosRuta = (Ruta) request.getAttribute("rutaFormulario");
    List<LandingStation> estaciones = (List<LandingStation>) request.getAttribute("listaEstaciones");
    List<Segmento> segmentos = (List<Segmento>) request.getAttribute("listaSegmentos");
    int idRuta = datosRuta == null ? 0 : datosRuta.getIdRuta();
    int origen = datosRuta == null ? 0 : datosRuta.getIdLandingOrigen();
    int destino = datosRuta == null ? 0 : datosRuta.getIdLandingDestino();
    String estadoRuta = datosRuta == null ? "activa" : datosRuta.getEstado();
    String codigos = (String) request.getAttribute("segmentosFormulario");
    if (codigos == null) {
        codigos = datosRuta == null ? "" : datosRuta.getSegmentos().stream()
                .map(Segmento::getCodigo).collect(java.util.stream.Collectors.joining(","));
    }
%>
<form id="ruta-form" method="post" action="<%= servlet %>" class="ruta-formulario">
    <button type="submit" name="accion" value="actualizar" hidden>Aplicar estaciones</button>
    <input type="hidden" name="id_ruta" value="<%= idRuta > 0 ? String.valueOf(idRuta) : "" %>">
    <input type="hidden" name="filtro" value="<%= filtro %>">
    <input type="hidden" name="pagina" value="<%= pagina %>">
    <input type="hidden" name="segmentos" value="<%= texto(codigos) %>">

    <% if (!error.isEmpty()) { %>
        <p class="mensaje-error" role="alert"><%= texto(error) %></p>
    <% } %>

    <div class="ruta-campos">
        <% for (String extremo : List.of("origen", "destino")) {
            int seleccion = "origen".equals(extremo) ? origen : destino;
            String etiqueta = "origen".equals(extremo) ? "Origen" : "Destino";
            String nombreEstacion = "";
            for (LandingStation estacion : estaciones) {
                if (estacion.getIdLanding() == seleccion) nombreEstacion = estacion.getNombre();
            }
            String entrada = (String) request.getAttribute("estacion_" + extremo);
            if (entrada == null) entrada = request.getParameter(extremo);
        %>
            <div class="ruta-selector">
                <label for="<%= extremo %>"><%= etiqueta %></label>
                <div class="ruta-selector-campo">
                    <input id="<%= extremo %>" name="<%= extremo %>" required autocomplete="off"
                           placeholder="Escribe o selecciona una estación"
                           value="<%= texto(entrada == null ? nombreEstacion : entrada) %>">
                    <details class="ruta-selector-lista">
                        <summary aria-label="Ver estaciones de <%= extremo %>"
                                 title="Ver estaciones de <%= extremo %>">▾</summary>
                        <div class="ruta-opciones">
                            <% for (LandingStation estacion : estaciones) { %>
                                <button type="submit" name="accion" value="actualizar" formnovalidate
                                        formaction="<%= servlet %>?elegir_<%= extremo %>=<%= estacion.getIdLanding() %>"
                                        <%= estacion.getIdLanding() == seleccion ? "class=seleccionada" : "" %>>
                                    <%= texto(estacion.getNombre()) %>
                                </button>
                            <% } %>
                        </div>
                    </details>
                </div>
            </div>
        <% } %>

        <div>
            <label for="nombre-ruta">Nombre de la ruta</label>
            <input id="nombre-ruta" readonly placeholder="Se genera al aplicar las estaciones"
                   value="<%= texto(datosRuta == null ? "" : datosRuta.getNombre()) %>">
        </div>
        <div>
            <label for="estado-ruta">Estado</label>
            <select id="estado-ruta" name="estado_ruta">
                <option value="activa" <%= "activa".equals(estadoRuta) ? "selected" : "" %>>Activa</option>
                <option value="inactiva" <%= "inactiva".equals(estadoRuta) ? "selected" : "" %>>Inactiva</option>
            </select>
        </div>
    </div>

    <div class="acciones">
        <button class="boton secundario" name="accion" value="actualizar" type="submit">Aplicar estaciones</button>
    </div>

    <%
        java.util.Map<String, Segmento> porCodigo = new java.util.HashMap<>();
        for (Segmento segmento : segmentos) {
            porCodigo.put(segmento.getCodigo().toUpperCase(java.util.Locale.ROOT), segmento);
        }
        java.util.Set<String> usados = new java.util.HashSet<>();
        int actual = origen;
        boolean continuo = true;
        String[] recorrido = codigos.isEmpty() ? new String[0] : codigos.split(",", -1);
    %>
    <fieldset class="ruta-recorrido">
        <legend>Recorrido</legend>
        <ol aria-label="Segmentos en orden">
            <% for (String codigo : recorrido) {
                String clave = codigo.trim().toUpperCase(java.util.Locale.ROOT);
                Segmento tramo = porCodigo.get(clave);
                boolean repetido = !usados.add(clave);
                continuo = continuo && tramo != null && !repetido && tramo.getIdLandingInicial() == actual;
                if (tramo != null) actual = tramo.getIdLandingFinal();
            %>
                <li>
                    <strong><%= texto(codigo.trim()) %></strong>
                    <% if (tramo != null) { %>
                        · <%= texto(tramo.getNombreInicial()) %> → <%= texto(tramo.getNombreFinal()) %>
                    <% } else { %>
                        · Segmento no disponible
                    <% } %>
                </li>
            <% } %>
        </ol>
        <%
            boolean extremos = origen > 0 && destino > 0 && origen != destino;
            boolean completo = extremos && continuo && recorrido.length > 0 && actual == destino;
            List<Segmento> siguientes = new java.util.ArrayList<>();
            if (extremos && continuo && !completo) {
                for (Segmento tramo : segmentos) {
                    if (tramo.getIdLandingInicial() == actual
                            && !usados.contains(tramo.getCodigo().toUpperCase(java.util.Locale.ROOT))) {
                        siguientes.add(tramo);
                    }
                }
            }
        %>
        <p><%= !extremos ? "Elige un origen y un destino diferentes y pulsa Aplicar estaciones."
            : !continuo ? "Quita tramos desde el final para corregir el recorrido."
            : completo ? "El recorrido llega al destino."
            : siguientes.isEmpty() ? "No hay tramos que continúen desde aquí."
            : "Elige un tramo que salga de la estación actual." %></p>
        <div class="ruta-controles">
            <% if (!siguientes.isEmpty()) { %>
                <div>
                    <label for="siguiente-segmento">Siguiente segmento</label>
                    <select id="siguiente-segmento" name="siguiente">
                        <option value="">Selecciona un segmento</option>
                        <% for (Segmento tramo : siguientes) { %>
                            <option value="<%= texto(tramo.getCodigo()) %>">
                                <%= texto(tramo.getCodigo()) %> · <%= texto(tramo.getNombreFinal()) %>
                            </option>
                        <% } %>
                    </select>
                </div>
                <button class="boton secundario" name="accion" value="agregar" type="submit">Añadir segmento</button>
            <% } %>
            <% if (recorrido.length > 0) { %>
                <button class="boton secundario" name="accion" value="quitar" type="submit" formnovalidate>Quitar último</button>
            <% } %>
        </div>
    </fieldset>

    <div class="acciones">
        <a class="boton secundario" href="<%= urlLista %>">Cancelar</a>
        <button class="boton primario" name="accion" value="guardar" type="submit"
                <%= completo ? "" : "disabled" %>>Guardar ruta</button>
    </div>
</form>
        </div>
    </main>
</div>
</body>
</html>
