<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="beans.maintenance.Mantenimiento" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="java.util.List" %>
<%@ page import="beans.maintenance.ActividadMantenimiento" %>
<%@ page import ="java.time.format.DateTimeFormatter"%>
<%@ page import ="java.util.ArrayList"%>

<%
  // Recuperamos el mantenimiento enviado por MantenimientoServlet.
  Mantenimiento mantenimiento =
    (Mantenimiento) request.getAttribute("mantenimiento");

  List<ActividadMantenimiento> actividades = (List<ActividadMantenimiento>) request.getAttribute("actividades");

  if (actividades == null) {
    actividades = new ArrayList<>();
  }

  DateTimeFormatter formatoFechaHora = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

  // Si no recibimos el objeto, no podemos mostrar el seguimiento.
  if (mantenimiento == null) {
    response.sendError(
      HttpServletResponse.SC_NOT_FOUND,
      "No se encontró la información del mantenimiento."
    );
    return;
  }

  String estadoActual = mantenimiento.getEstado();

  // Resultado final (solo existe si el mantenimiento finalizó y ya se registró)
  String resultado = (String) request.getAttribute("resultado");
  boolean finalizado = "Finalizado".equals(estadoActual);

  // Etapas normales del mantenimiento.
  List<String> pasos = Arrays.asList(
    "Programado",
    "En ejecucion",
    "Finalizado"
  );

  int indiceActual = pasos.indexOf(estadoActual);

  // Formateamos las fechas para mostrarlas en la vista.
  java.time.format.DateTimeFormatter formato =
    java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

  String fechaInicio = mantenimiento.getFechaInicio() != null
    ? mantenimiento.getFechaInicio().format(formato)
    : "No definida";

  String fechaFin = mantenimiento.getFechaFin() != null
    ? mantenimiento.getFechaFin().format(formato)
    : "No definida";

  boolean cancelado = "Cancelado".equals(estadoActual);
%>

<%!
  private String escaparHtml(String valor) {
    if (valor == null) return "";

    return valor.replace("&", "&amp;")
      .replace("<", "&lt;")
      .replace(">", "&gt;")
      .replace("\"", "&quot;")
      .replace("'", "&#39;");
  }
%>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Oceanlink - Estado</title>

  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/barras.css">

  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/styles_MC.css">
</head>

<body>

<jsp:include page="header.jsp">
  <jsp:param name="pageTitle"
             value="Registro y actualización de actividades de mantenimiento" />
</jsp:include>

<div class="contenedor">

  <jsp:include page="sidebar.jsp">
    <jsp:param name="activePage" value="fechas" />
  </jsp:include>

  <main class="contenido-principal">

    <div class="content-container">
      <div class="card">

        <h2 class="card-title">
          Seguimiento del mantenimiento #<%= mantenimiento.getIdMantenimiento() %>
        </h2>

        <div class="detalle-mantenimiento">

          <%
            String claseEstado;

            switch (estadoActual) {
              case "Programado":
                claseEstado = "badge-programado";
                break;

              case "En ejecucion":
                claseEstado = "badge-en-progreso";
                break;

              case "Finalizado":
                claseEstado = "badge-finalizado";
                break;

              case "Cancelado":
                claseEstado = "badge-cancelado";
                break;

              default:
                claseEstado = "";
            }

            String nombreEstado = "En ejecucion".equals(estadoActual)
              ? "En ejecución"
              : estadoActual;
          %>

          <p>
            <strong>Estado actual:</strong>

            <span class="badge <%= claseEstado %>">
              <%= nombreEstado %>
            </span>
          </p>

          <p>
            <strong>Tipo:</strong>
            <%= mantenimiento.getTipo() %>
          </p>

          <p>
            <strong>Prioridad:</strong>
            <%= mantenimiento.getPrioridad() %>
          </p>

          <p>
            <strong>Fecha de inicio:</strong>
            <%= fechaInicio %>
          </p>

          <p>
            <strong>Fecha de fin:</strong>
            <%= fechaFin %>
          </p>

          <p>
            <strong>Descripción:</strong>
            <%= mantenimiento.getDescripcionGeneral() %>
          </p>

        </div>

        <h3>Progreso del mantenimiento</h3>

        <% if (cancelado) { %>

        <div class="estado-cancelado">
          Este mantenimiento ha sido cancelado.
        </div>

        <% } else { %>

        <div class="stepper">

          <% for (int i = 0; i < pasos.size(); i++) {

            String stepClass = "";

            if (i < indiceActual) {
              stepClass = "completed";
            } else if (i == indiceActual) {
              stepClass = "active";
            }

          %>

          <div class="stepper-step <%= stepClass %>">

            <div class="stepper-circle"></div>

            <span class="stepper-label">
              <%= pasos.get(i).equals("En ejecucion")
                ? "En ejecución"
                : pasos.get(i) %>
            </span>

          </div>

          <% } %>

        </div>

        <% } %>

        <div class="bitacora">
          <strong>BITÁCORA DE INTERVENCIÓN</strong>

          <% if (actividades.isEmpty()) { %>

          <p> Aún no hay actividades registradas </p>

          <% } else { %>

          <% for (ActividadMantenimiento actividad: actividades) { %>
          <div class="actividad-bitacora">

            <p>
              <strong>
                <%= escaparHtml(actividad.getNombreUsuario())%>
              </strong>

              <span>
                    <%=
                    actividad.getFechaHora() != null ?
                      actividad.getFechaHora().format(formatoFechaHora) : ""
                    %>
                  </span>

            </p>

            <p>
              <%= escaparHtml(actividad.getDescripcionBitacora())%>
            </p>

            <small>
              <%= escaparHtml(actividad.getTipoActividad())%>
            </small>

          </div>

          <% } %>

          <% } %>

        </div>

        <% if (finalizado && resultado != null) { %>

        <!-- Ya tiene resultado: se muestra y no se puede escribir más -->
        <div class="formulario-comentario resultado-registrado">
          <h3>Resultado del mantenimiento</h3>
          <p><%= escaparHtml(resultado) %></p>
        </div>

        <% } else { %>

        <div class="formulario-comentario">

          <h3>
            <%= finalizado ? "Registrar resultado del mantenimiento" : "Agregar comentario" %>
          </h3>

          <% if (finalizado) { %>
          <p class="resultado-pendiente">
            El mantenimiento finalizó. Registre un resumen de lo que se hizo.
          </p>
          <% } %>

          <form action="<%=request.getContextPath()%>/MantenimientoServlet"
                method="POST">
            <input type="hidden" name="accion" value="comentar">

            <input type="hidden" name="idMantenimiento" value="<%=mantenimiento.getIdMantenimiento()%>">

            <textarea
              name="comentario"
              rows="4"
              placeholder="<%= finalizado
                ? "Ej.: Se reemplazó el tramo de fibra dañado. Señal restablecida al 100%."
                : "Escriba un comentario/reporte sobre este mantenimiento..." %>"
              required></textarea>

            <button type="submit">
              <%= finalizado ? "Registrar resultado" : "Registrar" %>
            </button>
          </form>

        </div>

        <% } %>

      </div>
    </div>

  </main>

</div>

</body>
</html>
