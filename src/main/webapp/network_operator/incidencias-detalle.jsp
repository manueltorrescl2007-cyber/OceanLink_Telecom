<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.networkoperator.Incidencia" %>
<%@ page import="beans.networkoperator.Observacion" %>
<%@ page import="beans.networkoperator.Servicio" %>
<%
    Incidencia inc = (Incidencia) request.getAttribute("incidencia");
    String siguienteEstado = (String) request.getAttribute("siguienteEstado");
    ArrayList<Observacion> listaObservaciones = (ArrayList<Observacion>) request.getAttribute("listaObservaciones");
    ArrayList<Servicio> listaServicios = (ArrayList<Servicio>) request.getAttribute("listaServicios");
    if (listaObservaciones == null) { listaObservaciones = new ArrayList<>(); }
    if (listaServicios == null) { listaServicios = new ArrayList<>(); }

    String ok = request.getParameter("ok");
    String error = request.getParameter("error");

    String servlet = request.getContextPath() + "/IncidenciaServlet";

    String[] estados = {"Detectada", "En analisis", "Reparacion programada", "En reparacion", "Servicio restaurado", "Cerrada"};
    String[] pasos   = {"Detectada", "En análisis", "Rep. programada", "En reparación", "Restaurado", "Cerrada"};
    String[] severidades = {"Leve", "Media", "Alta", "Critica"};

    int pasoActual = 0;
    boolean cerrada = false;
    if (inc != null) {
        for (int i = 0; i < estados.length; i++) {
            if (estados[i].equals(inc.getEstado())) {
                pasoActual = i + 1;
            }
        }
        cerrada = "Cerrada".equals(inc.getEstado());
    }

    String textoBoton = "";
    if (siguienteEstado != null) {
        if ("Servicio restaurado".equals(siguienteEstado)) {
            textoBoton = "Registrar restauración del servicio";
        } else if ("Cerrada".equals(siguienteEstado)) {
            textoBoton = "Cerrar incidencia";
        } else {

            String[] textos = {"Detectada", "En análisis", "Reparación programada", "En reparación", "Restaurado", "Cerrada"};
            for (int i = 0; i < estados.length; i++) {
                if (estados[i].equals(siguienteEstado)) {
                    textoBoton = "Pasar a: " + textos[i];
                }
            }
        }
    }

    String paginaActiva = cerrada ? "historial" : "visualizar";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OceanLink - <%= inc != null ? inc.getCodigo() : "Incidencia no encontrada" %></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/barras.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/network_operator/network_operator.css?v=5">
</head>
<body>

<jsp:include page="header.jsp" />

<div class="contenedor">

    <jsp:include page="sidebar.jsp">
        <jsp:param name="activePage" value="<%= paginaActiva %>" />
    </jsp:include>

    <main class="contenido-principal">

        <section class="encabezado-panel">
            <h2>Incidencias</h2>
            <h1>Detalle de incidencia</h1>
        </section>

        <% if (inc == null) { %>

        <section class="card">
            <h2 class="card-title">Incidencia no encontrada</h2>
            <p class="ayuda"><a href="<%= servlet %>">Volver a incidencias activas</a></p>
        </section>

        <% } else { %>

        <% if ("creada".equals(ok)) { %>
            <p class="mensaje mensaje-ok">Incidencia <strong><%= inc.getCodigo() %></strong> registrada correctamente.</p>
        <% } %>
        <% if ("estado".equals(error)) { %>
            <p class="mensaje mensaje-error">No se pudo cambiar el estado: la incidencia ya no estaba en el paso esperado. No se pueden saltar pasos.</p>
        <% } %>

        <section class="card">
            <p class="migas">
                Incidencias /
                <% if (cerrada) { %>
                    <a href="<%= servlet %>?action=historial">Historial</a>
                <% } else { %>
                    <a href="<%= servlet %>">Visualizar</a>
                <% } %>
                / <%= inc.getCodigo() %>
            </p>

            <div class="titulo-incidencia">
                <h3><%= inc.getCodigo() %></h3>
                <span class="badge <%= inc.getClaseSeveridad() %>"><%= inc.getSeveridadTexto() %></span>
            </div>

            <p class="segment-context">
                Segmento: <strong><%= inc.getCodigosSegmentos() %></strong> · Detectada el <%= inc.getFechaRegistro() %>
                <% if (inc.getFechaRestauracion() != null) { %> · Restaurada el <%= inc.getFechaRestauracion() %><% } %>
                <% if (cerrada) { %> · Cerrada el <%= inc.getFechaCierre() %><% } %>
            </p>

            <p class="descripcion-incidencia">
                <strong><%= inc.getTitulo() %>.</strong> <%= inc.getDescripcion() %>
                <span class="ayuda">(registrada por <%= inc.getUsuario().getNombre() %>)</span>
            </p>

            <div class="stepper">
                <% for (int i = 1; i <= pasos.length; i++) {
                       String clase = (i < pasoActual || cerrada) ? "completado" : (i == pasoActual ? "actual" : "");
                %>
                <div class="paso <%= clase %>">
                    <div class="circulo"><%= "completado".equals(clase) ? "&#10003;" : String.valueOf(i) %></div>
                    <p><%= pasos[i - 1] %></p>
                </div>
                <% } %>
            </div>

            <% if (!cerrada) { %>

            <div class="acciones-incidencia">

                <form method="POST" action="<%= servlet %>?action=avanzar">
                    <input type="hidden" name="idIncidencia" value="<%= inc.getIdIncidencia() %>">
                    <input type="hidden" name="estadoActual" value="<%= inc.getEstado() %>">
                    <button type="submit" class="btn-primary"><%= textoBoton %></button>
                </form>

                <form method="POST" action="<%= servlet %>?action=severidad" class="form-en-linea">
                    <input type="hidden" name="idIncidencia" value="<%= inc.getIdIncidencia() %>">
                    <label for="severidad">Severidad:</label>
                    <select id="severidad" name="severidad">
                        <% for (String sev : severidades) { %>
                            <option value="<%= sev %>" <%= sev.equals(inc.getSeveridad()) ? "selected" : "" %>>
                                <%= "Critica".equals(sev) ? "Crítica" : sev %>
                            </option>
                        <% } %>
                    </select>
                    <button type="submit" class="btn-secundario">Guardar</button>
                </form>

            </div>
            <% } %>

            <div class="dos-columnas">
                <div class="columna">

                    <h4>Servicios y clientes afectados</h4>
                    <% if (listaServicios.isEmpty()) { %>
                        <p class="ayuda">Ningún servicio activo pasa por los segmentos de esta incidencia.</p>
                    <% } else {
                           for (Servicio sv : listaServicios) { %>
                    <div class="tarjeta">
                        <span>SRV-<%= sv.getIdServicio() %></span>
                        <span><%= sv.getSolicitud().getCliente().getNombre() %></span>
                    </div>
                    <%     }
                       } %>
                </div>

                <div class="columna">

                    <h4>Bitácora</h4>
                    <% if (listaObservaciones.isEmpty()) { %>
                        <p class="ayuda">Aún no hay observaciones.</p>
                    <% } else {
                           for (Observacion o : listaObservaciones) { %>
                    <div class="registro">
                        <strong><%= o.getFechaHora() %> - <%= o.getUsuario().getNombre() %></strong>
                        <p><%= o.getMensaje() %></p>
                    </div>
                    <%     }
                       } %>

                    <% if (!cerrada) { %>

                    <form method="POST" action="<%= servlet %>?action=observar" class="form-bitacora">
                        <input type="hidden" name="idIncidencia" value="<%= inc.getIdIncidencia() %>">
                        <input type="text" name="mensaje" class="bitacora-input" placeholder="Agregar observación..." required>
                        <button type="submit" class="btn-primary btn-chico">Agregar</button>
                    </form>
                    <% } else { %>
                    <p class="ayuda">Incidencia cerrada: ya no se pueden agregar observaciones.</p>
                    <% } %>
                </div>
            </div>
        </section>

        <% } %>

    </main>

</div>

</body>
</html>
