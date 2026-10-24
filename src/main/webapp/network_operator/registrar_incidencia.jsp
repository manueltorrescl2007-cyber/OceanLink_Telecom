<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.networkoperator.Segmento" %>
<%@ page import="beans.networkoperator.Servicio" %>
<%
    ArrayList<Segmento> elegidos = (ArrayList<Segmento>) request.getAttribute("segmentosElegidos");
    ArrayList<Segmento> disponibles = (ArrayList<Segmento>) request.getAttribute("segmentosDisponibles");
    ArrayList<Servicio> listaServicios = (ArrayList<Servicio>) request.getAttribute("listaServicios");
    String titulo = (String) request.getAttribute("titulo");
    String descripcion = (String) request.getAttribute("descripcion");
    String severidad = (String) request.getAttribute("severidad");
    String error = (String) request.getAttribute("error");

    if (elegidos == null) { elegidos = new ArrayList<>(); }
    if (disponibles == null) { disponibles = new ArrayList<>(); }
    if (listaServicios == null) { listaServicios = new ArrayList<>(); }
    if (titulo == null) { titulo = ""; }
    if (descripcion == null) { descripcion = ""; }
    if (severidad == null) { severidad = ""; }

    String codigosElegidos = "";
    for (Segmento s : elegidos) {
        codigosElegidos += codigosElegidos.isEmpty() ? s.getCodigo() : ", " + s.getCodigo();
    }

    String tituloHtml = titulo.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;");
    String descripcionHtml = descripcion.replace("&", "&amp;").replace("<", "&lt;");

    String[] severidades = {"Leve", "Media", "Alta", "Critica"};
    String servlet = request.getContextPath() + "/IncidenciaServlet";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OceanLink - Registrar Incidencia</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/barras.css">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/network_operator/network_operator.css?v=5">
</head>
<body>

<jsp:include page="header.jsp" />

<div class="contenedor">

    <jsp:include page="sidebar.jsp">
        <jsp:param name="activePage" value="registrar" />
    </jsp:include>

    <main class="contenido-principal">

        <section class="encabezado-panel">
            <h2>Incidencias</h2>
            <h1>Registrar incidencia</h1>
        </section>

        <section class="card">
            <h2 class="card-title">Registrar una nueva incidencia</h2>
            <p class="segment-context">Segmento: <%= codigosElegidos.isEmpty() ? "ninguno seleccionado" : codigosElegidos %></p>

            <% if (error != null) { %>
                <p class="mensaje mensaje-error"><%= error %></p>
            <% } %>

            <form class="incident-form" action="<%= servlet %>?action=crear" method="POST">

                <button type="submit" name="boton" value="registrar" class="boton-oculto" tabindex="-1" aria-hidden="true"></button>

                <div class="form-group form-group-full">
                    <label for="segmentoNuevo">Segmento(s) *</label>

                    <% if (!elegidos.isEmpty()) { %>
                    <div class="chips">
                        <% for (Segmento s : elegidos) { %>
                            <span class="chip">
                                <%= s.getCodigo() %>
                                <input type="hidden" name="segmentos" value="<%= s.getIdSegmento() %>">
                                <button type="submit" name="quitar" value="<%= s.getIdSegmento() %>"
                                        class="chip-x" formnovalidate title="Quitar <%= s.getCodigo() %>">&times;</button>
                            </span>
                        <% } %>
                    </div>
                    <% } %>

                    <div class="agregar-segmento">
                        <select id="segmentoNuevo" name="segmentoNuevo">
                            <option value="" selected>Seleccionar segmento</option>
                            <% for (Segmento s : disponibles) { %>
                                <option value="<%= s.getIdSegmento() %>">
                                    <%= s.getCodigo() %> · <%= s.getLandingInicial().getNombre() %> &rarr; <%= s.getLandingFinal().getNombre() %>
                                </option>
                            <% } %>
                        </select>
                        <button type="submit" name="boton" value="agregar" class="btn-secundario" formnovalidate>+ Agregar</button>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="titulo">Título *</label>
                        <input type="text" id="titulo" name="titulo" maxlength="150"
                               value="<%= tituloHtml %>" placeholder="Ej. Corte de cable zona norte" required>
                    </div>

                    <div class="form-group">
                        <label for="severidad">Severidad *</label>

                        <select id="severidad" name="severidad" required>
                            <option value="" disabled <%= severidad.isEmpty() ? "selected" : "" %>>Seleccionar</option>
                            <% for (String sev : severidades) { %>
                                <option value="<%= sev %>" <%= sev.equals(severidad) ? "selected" : "" %>>
                                    <%= "Critica".equals(sev) ? "Crítica" : sev %>
                                </option>
                            <% } %>
                        </select>
                    </div>
                </div>

                <fieldset class="form-group form-group-full affected-services">
                    <legend>Servicios y clientes potencialmente afectados</legend>
                    <% if (elegidos.isEmpty()) { %>
                        <p class="ayuda">Agrega un segmento para ver los servicios que pasan por él.</p>
                    <% } else if (listaServicios.isEmpty()) { %>
                        <p class="ayuda">Ningún servicio activo pasa por los segmentos elegidos.</p>
                    <% } else { %>
                    <ul class="affected-services-list">
                        <% for (Servicio sv : listaServicios) { %>
                        <li class="affected-service-item">
                            <span class="service-id">SRV-<%= sv.getIdServicio() %></span>
                            <span class="client-name"><%= sv.getSolicitud().getCliente().getNombre() %></span>
                        </li>
                        <% } %>
                    </ul>
                    <% } %>
                </fieldset>

                <div class="form-group form-group-full">
                    <label for="descripcion">Notas / Descripción *</label>
                    <textarea id="descripcion" name="descripcion" rows="5" required><%= descripcionHtml %></textarea>
                </div>

                <div class="form-actions">
                    <button type="submit" name="boton" value="registrar" class="btn-primary">Registrar</button>
                </div>

            </form>
        </section>

    </main>

</div>

</body>
</html>
