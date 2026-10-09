<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!-- Datos estáticos, falta unir SQL -->
<%
    // DATOS DE EJEMPLO: independientes de las demás páginas y de MySQL.
    // Campos: ID, solicitud, ruta, capacidad, fecha de activación, estado.
    // Cliente, origen y destino son datos que luego se obtendrán de la solicitud.
    String[][] ejemplos = {
        {"1", "1", "LAX-LUR-R01", "50", "06/10/2026 10:30", "Activo", "Pacifico", "Los Ángeles", "Lurín"},
        {"2", "2", "LUR-VAL-R01", "20", "Sin activar", "Pendiente", "Claro", "Lurín", "Valparaíso"},
        {"3", "3", "GYE-LUR-R01", "30", "06/10/2026 12:00", "Suspendido", "Movistar", "Guayaquil", "Lurín"}
    };
    // La sesión conserva únicamente los servicios de este mockup.
    String[][] servicios = (String[][]) session.getAttribute("serviciosMockupIndependiente");
    if (servicios == null) {
        servicios = ejemplos;
        session.setAttribute("serviciosMockupIndependiente", servicios);
    }
    String error = "";

    // GUARDADO DE PRUEBA HABILITADO: recibe el formulario y agrega una fila al arreglo.
    if ("POST".equals(request.getMethod()) && "guardar".equals(request.getParameter("accion"))) {
        String solicitud = request.getParameter("id_solicitud");
        String ruta = request.getParameter("id_ruta");
        int capacidad = 0;
        try {
            capacidad = Integer.parseInt(request.getParameter("capacidad_asignada"));
        } catch (NumberFormatException e) {
            // Si no es un número entero válido, queda en cero.
        }

        // Opciones de ejemplo: solicitud, ruta compatible, cliente, origen y destino.
        String[][] opciones = {
            {"1", "4", "Pacifico", "Los Ángeles", "Lurín", "LAX-LUR-R01"},
            {"2", "13", "Claro", "Lurín", "Valparaíso", "LUR-VAL-R01"},
            {"3", "12", "Movistar", "Guayaquil", "Lurín", "GYE-LUR-R01"}
        };
        int seleccion = -1;
        for (int i = 0; i < opciones.length; i++) {
            if (opciones[i][0].equals(solicitud)) seleccion = i;
        }
        if (seleccion < 0 || capacidad <= 0) {
            error = "Seleccione una solicitud e ingrese una capacidad entera mayor que cero.";
        } else if (!opciones[seleccion][1].equals(ruta)) {
            error = "Seleccione una ruta que coincida con el origen y destino de la solicitud.";
        } else {
            // Busca el siguiente ID y copia los servicios al arreglo más grande.
            int siguienteId = 1;
            String[][] nuevos = new String[servicios.length + 1][];
            for (int i = 0; i < servicios.length; i++) {
                nuevos[i] = servicios[i];
                int id = Integer.parseInt(servicios[i][0]);
                if (id >= siguienteId) siguienteId = id + 1;
            }
            String[] opcion = opciones[seleccion];
            nuevos[servicios.length] = new String[] {
                String.valueOf(siguienteId), solicitud, opcion[5], String.valueOf(capacidad),
                "Sin activar", "Pendiente", opcion[2], opcion[3], opcion[4]
            };
            session.setAttribute("serviciosMockupIndependiente", nuevos);
            // Evita guardar otra vez cuando se actualiza el navegador.
            response.sendRedirect("servicios.jsp?guardado=1&servicio=" + siguienteId);
            return;
        }
    }
    // Los cuatro estados permitidos en servicios.estado del SQL.
    String[] estados = {"Pendiente", "Activo", "Suspendido", "Cancelado"};
    String filtro = request.getParameter("estado");
    if (filtro == null) filtro = "Todos";
    int detalle = -1;
    int cantidad = 0;
    for (int i = 0; i < servicios.length; i++) {
        if (servicios[i][0].equals(request.getParameter("servicio"))) detalle = i;
        if (filtro.equals("Todos") || filtro.equals(servicios[i][5])) cantidad++;
    }
    boolean nuevo = "nuevo".equals(request.getParameter("ventana")) || !error.isEmpty();
%>

<!-- Contenido JSP -->
<!doctype html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>OceanLink | Dashboard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/admin/servicios.css?v=2">
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
  <main class="contenido-principal pagina-servicios">
    <section class="encabezado-pagina">
        <div class="encabezado-panel"><h2>Administrador</h2><h1>Servicios</h1></div>
    </section>
    <% if ("1".equals(request.getParameter("guardado"))) { %>
    <p role="status" style="margin-bottom: 16px; color: #237b51;">Servicio guardado. Ya aparece en la tabla como Pendiente.</p>
    <% } %>
    <!-- FILTRO: recarga únicamente esta página. -->
    <section class="barra-herramientas">
        <form method="get" action="servicios.jsp" class="formulario-filtro">
            <label for="estado">Estado:</label>
            <select id="estado" name="estado">
                <option value="Todos">Todos</option>
                <% for (String estado : estados) { %>
                <option value="<%= estado %>" <%= estado.equals(filtro) ? "selected" : "" %>><%= estado %></option>
                <% } %>
            </select>
            <button class="boton secundario" type="submit">Filtrar</button>
        </form>
        <span><%= cantidad %> servicios</span>
    </section>
    <!-- TABLA: pulsa el ID para abrir el detalle. -->
    <section class="contenedor-tabla">
        <table>
            <thead><tr><th>ID</th><th>Cliente</th><th>Origen</th><th>Destino</th><th>Capacidad</th><th>Ruta</th><th>Estado</th></tr></thead>
            <tbody>
            <% for (String[] servicio : servicios) {
                if (filtro.equals("Todos") || filtro.equals(servicio[5])) { %>
            <tr>
                <td><a class="enlace-servicio" href="servicios.jsp?servicio=<%= servicio[0] %>">SER-<%= servicio[0] %></a></td>
                <td><%= servicio[6] %></td><td><%= servicio[7] %></td><td><%= servicio[8] %></td>
                <td><%= servicio[3] %> Gbps</td><td><%= servicio[2] %></td>
                <td><span class="estado <%= servicio[5].toLowerCase() %>"><%= servicio[5] %></span></td>
            </tr>
            <% } } %>
            <% if (cantidad == 0) { %><tr><td colspan="7">No hay servicios con este estado.</td></tr><% } %>
            </tbody>
        </table>
    </section>
    <!-- DETALLE: solo muestra datos, no modifica Solicitudes. -->
    <% if (detalle >= 0) { String[] servicio = servicios[detalle]; %>
    <section class="panel-detalle">
        <div class="encabezado-detalle"><h2>Detalle de SER-<%= servicio[0] %></h2><a href="servicios.jsp" aria-label="Cerrar detalle">&times;</a></div>
        <div class="datos-detalle">
            <div><span>Solicitud asociada</span><strong>SOL-<%= servicio[1] %></strong></div>
            <div><span>Cliente</span><strong><%= servicio[6] %></strong></div>
            <div><span>Ruta asignada</span><strong><%= servicio[2] %></strong></div>
            <div><span>Capacidad asignada</span><strong><%= servicio[3] %> Gbps</strong></div>
            <div><span>Fecha de activación</span><strong><%= servicio[4] %></strong></div>
            <div><span>Estado</span><strong><%= servicio[5] %></strong></div>
            <div><span>Origen</span><strong><%= servicio[7] %></strong></div>
            <div><span>Destino</span><strong><%= servicio[8] %></strong></div>
        </div>
    </section>
    <% } %>
  </main>
</div>
</body>
</html>
