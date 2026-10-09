<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!-- Datos estáticos, falta unir SQL -->
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="java.util.Map" %>
<%
    /*
     * DATOS DE PRUEBA (temporal, hasta tener base de datos).
     * Cada incidencia: { segmento, severidad, estado (1 a 6), detectada, cerrada,
     *                    servicios "ID:Cliente;ID:Cliente", bitácora "hora|autor|texto;..." }
     * Más adelante, esto lo reemplaza el Servlet con incidenciaDao.obtenerIncidencia(id).
     */
    Map<String, String[]> incidencias = new LinkedHashMap<>();
    // ---- Activas (las de "Visualizar") ----
    incidencias.put("INC-014", new String[]{"LIM-VLP-02", "Alta",    "2", "06 oct 2026", "",
            "SRV-118:Cliente XXYY;SRV-121:Cliente ZZUU",
            "10:32|J. Ramos|Caída de fibra óptica detectada.;11:05|J. Ramos|Se inicia análisis de la falla."});
    incidencias.put("INC-013", new String[]{"LIM-VLP-02", "Crítica", "4", "03 oct 2026", "",
            "SRV-118:Cliente XXYY;SRV-130:Cliente Andina",
            "08:15|M. Díaz|Corte total del segmento.;09:40|M. Díaz|Reparación programada con buque.;07:00|C. Mendoza|Inicia reparación en sitio."});
    incidencias.put("INC-011", new String[]{"LIM-GYE-01", "Media",   "3", "01 oct 2026", "",
            "SRV-140:Cliente Pacífico",
            "14:20|A. Torres|Degradación de señal en el segmento.;16:00|A. Torres|Reparación programada para el 10 oct."});
    incidencias.put("INC-010", new String[]{"LIM-GYE-04", "Alta",    "5", "28 sep 2026", "",
            "SRV-152:Cliente Norte",
            "09:10|J. Ramos|Pérdida de potencia detectada.;18:30|J. Ramos|Servicio restaurado, pendiente de cierre."});
    // ---- Cerradas (las de "Historial") ----
    incidencias.put("INC-009", new String[]{"LIM-VLP-01", "Media",   "6", "15 ago 2026", "18 ago 2026",
            "SRV-101:Cliente Sur",
            "10:00|A. Torres|Atenuación alta en el enlace.;17:45|A. Torres|Servicio restaurado y verificado.;09:00|L. Ramírez|Incidencia cerrada."});
    incidencias.put("INC-008", new String[]{"LIM-VLP-02", "Crítica", "6", "10 jul 2026", "13 jul 2026",
            "SRV-118:Cliente XXYY;SRV-121:Cliente ZZUU",
            "03:20|M. Díaz|Corte de cable por anclaje.;22:10|C. Mendoza|Empalme submarino completado.;08:30|L. Ramírez|Incidencia cerrada."});
    incidencias.put("INC-007", new String[]{"LIM-GYE-01", "Media",   "6", "20 ago 2025", "25 ago 2025",
            "SRV-140:Cliente Pacífico",
            "12:00|J. Ramos|Errores intermitentes de transmisión.;16:20|J. Ramos|Ajuste de amplificador, servicio estable.;10:15|L. Ramírez|Incidencia cerrada."});
    incidencias.put("INC-006", new String[]{"LIM-GYE-04", "Alta",    "6", "01 jul 2025", "05 jul 2025",
            "SRV-152:Cliente Norte",
            "07:30|A. Torres|Falla en estación de aterrizaje.;19:00|C. Mendoza|Equipo reemplazado.;09:45|L. Ramírez|Incidencia cerrada."});

    // Incidencia pedida en la URL: incidencias-detalle.jsp?id=INC-013
    String id = request.getParameter("id");
    String[] inc = (id != null) ? incidencias.get(id) : null;

    int estado = (inc != null) ? Integer.parseInt(inc[2]) : 0;
    boolean cerrada = (estado == 6);

    // Opción del menú y migas según si está activa o cerrada
    String paginaActiva = cerrada ? "historial" : "visualizar";
    String origen = cerrada ? "Historial" : "Visualizar";
    String paginaOrigen = cerrada ? "historial_incidencias.jsp" : "visualizar.jsp";

    // Clase CSS de la severidad: "Crítica" -> "severidad-critica"
    String claseSeveridad = "";
    if (inc != null) {
        claseSeveridad = "severidad-" + inc[1].toLowerCase().replace("í", "i");
    }

    String[] pasos = {"Detectada", "En análisis", "Rep. prog.", "En rep.", "Restaurado", "Cerrada"};
%>

<!-- Contenido JSP -->
<!doctype html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>OceanLink | Dashboard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/admin/incidencia.css?v=2">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/barras.css">
</head>

<body>

<jsp:include page="header.jsp" />

<div class="contenedor">

  <jsp:include page="sidebar.jsp">
      <jsp:param name="activePage" value="usuarios" />
  </jsp:include>
  <!-- Contenido principal -->
  <main class="contenido-principal">

    <section class="encabezado-panel">
        <h2>Administrador</h2>
        <h1>Detalle de incidencia</h1>
    </section>
    <% if (inc == null) { %>
    <section class="card">
      <h2 class="card-title">Incidencia no encontrada</h2>
      <p class="ayuda">
          No existe la incidencia solicitada.
          <a href="incidencias-visualizar.jsp">Volver a incidencias activas</a>
      </p>
    </section>
    <% } else { %>
    <section class="card">
      <p class="migas">
        Incidencias / <a href="<%= paginaOrigen %>"><%= origen %></a> / <%= id %>
      </p>

      <div class="titulo-incidencia">
        <h3><%= id %></h3>
        <span class="badge <%= claseSeveridad %>"><%= inc[1] %></span>
      </div>

      <p class="segment-context">
        Segmento: <strong><%= inc[0] %></strong> · Detectada el <%= inc[3] %>
        <% if (cerrada) { %> · Cerrada el <%= inc[4] %><% } %>
      </p>

      <!-- Stepper: flujo de la incidencia (RF18) -->
      <div class="stepper">
        <% for (int i = 1; i <= pasos.length; i++) {
               String clase = (i < estado || cerrada) ? "completado" : (i == estado ? "actual" : "");
        %>
        <div class="paso <%= clase %>">
            <div class="circulo"><%= clase.equals("completado") ? "&#10003;" : String.valueOf(i) %></div>
            <p><%= pasos[i - 1] %></p>
        </div>
        <% } %>
      </div>

      <!-- Dos columnas: servicios afectados / bitácora -->
      <div class="dos-columnas">
        <div class="columna">
          <h4>Servicios y clientes afectados</h4>
          <% for (String servicio : inc[5].split(";")) {
                 String[] partes = servicio.split(":"); %>
          <div class="tarjeta">
              <span><%= partes[0] %></span>
              <span><%= partes[1] %></span>
          </div>
          <% } %>
        </div>

        <div class="columna">
          <h4>Bitácora</h4>
          <% for (String registro : inc[6].split(";")) {
                 String[] partes = registro.split("\\|"); %>
          <div class="registro">
              <strong><%= partes[0] %> - <%= partes[1] %></strong>
              <p><%= partes[2] %></p>
          </div>
          <% } %>

          <% if (!cerrada) { %>
          <input type="text" class="bitacora-input" placeholder="Agregar observación...">
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
