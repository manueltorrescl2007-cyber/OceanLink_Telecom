<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!-- Datos estáticos, falta unirlo al SQL -->
<%@ page import="java.util.ArrayList" %>
<%!
    // Protege el texto del formulario al mostrarlo en HTML.
    public String texto(String valor) {
        if (valor == null) return "";
        return valor.replace("&", "&amp;").replace("<", "&lt;")
                    .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
    // Busca un ID dentro de un catálogo; -1 significa que no existe.
    public int buscar(String[][] datos, String id) {
        for (int i = 0; i < datos.length; i++) {
            if (datos[i][0].equals(id)) return i;
        }
        return -1;
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    // 1. DATOS DEL SQL: estaciones y los 30 segmentos iniciales.
    // Segmento: ID, código, estación inicial, final, total, ocupada, reservada, estado.
    String[][] estaciones = {
        {"1", "Vancouver"},
        {"2", "Seattle"},
        {"3", "San Francisco"},
        {"4", "Los Ángeles"},
        {"5", "San Diego"},
        {"6", "Tijuana"},
        {"7", "Manzanillo"},
        {"8", "Puerto Chiapas"},
        {"9", "Puerto Quetzal"},
        {"10", "Acajutla"},
        {"11", "Puntarenas"},
        {"12", "Balboa"},
        {"13", "Buenaventura"},
        {"14", "Manta"},
        {"15", "Guayaquil"},
        {"16", "Paita"},
        {"17", "Lurín"},
        {"18", "Arica"},
        {"19", "Valparaíso"},
        {"20", "Concepción"}
    };
    String[][] ejemplos = {
        {"1", "VAN-SEA-01", "1", "2", "200", "0", "0", "Operativo"},
        {"2", "SEA-SFO-01", "2", "3", "200", "0", "0", "Operativo"},
        {"3", "SFO-LAX-01", "3", "4", "400", "0", "0", "Operativo"},
        {"4", "LAX-SDG-01", "4", "5", "400", "0", "0", "Operativo"},
        {"5", "SDG-TIJ-01", "5", "6", "200", "0", "0", "Operativo"},
        {"6", "TIJ-MAN-01", "6", "7", "200", "0", "0", "Operativo"},
        {"7", "MAN-PCH-01", "7", "8", "100", "0", "0", "Operativo"},
        {"8", "PCH-PQZ-01", "8", "9", "100", "0", "0", "Operativo"},
        {"9", "PQZ-ACJ-01", "9", "10", "100", "0", "0", "Operativo"},
        {"10", "ACJ-PUN-01", "10", "11", "100", "0", "0", "Operativo"},
        {"11", "PUN-BAL-01", "11", "12", "200", "0", "0", "Operativo"},
        {"12", "BAL-BUE-01", "12", "13", "200", "0", "0", "Operativo"},
        {"13", "BUE-MAN-01", "13", "14", "200", "0", "0", "Operativo"},
        {"14", "MAN-GYE-01", "14", "15", "200", "0", "0", "Operativo"},
        {"15", "GYE-PAI-01", "15", "16", "200", "0", "0", "Operativo"},
        {"16", "PAI-LUR-01", "16", "17", "400", "0", "0", "Operativo"},
        {"17", "LUR-ARI-01", "17", "18", "200", "0", "0", "Operativo"},
        {"18", "ARI-VAL-01", "18", "19", "200", "0", "0", "Operativo"},
        {"19", "VAL-CON-01", "19", "20", "100", "0", "0", "Operativo"},
        {"20", "LAX-BAL-01", "4", "12", "400", "0", "0", "Operativo"},
        {"21", "SFO-BUE-01", "3", "13", "400", "0", "0", "Operativo"},
        {"22", "LAX-LUR-01", "4", "17", "600", "0", "0", "Operativo"},
        {"23", "BAL-LUR-01", "12", "17", "400", "0", "0", "Operativo"},
        {"24", "BAL-GYE-01", "12", "15", "400", "0", "0", "Operativo"},
        {"25", "LUR-VAL-01", "17", "19", "400", "0", "0", "Operativo"},
        {"26", "MAN-BAL-01", "7", "12", "200", "0", "0", "Operativo"},
        {"27", "SEA-LAX-01", "2", "4", "200", "0", "0", "Operativo"},
        {"28", "SDG-MAN-01", "5", "7", "200", "0", "0", "Operativo"},
        {"29", "GYE-LUR-01", "15", "17", "300", "0", "0", "Operativo"},
        {"30", "ARI-CON-01", "18", "20", "100", "0", "0", "Operativo"}
    };
    String[] estados = {"Operativo", "Degradado", "En mantenimiento", "Fuera de servicio"};

    // 2. MOCKUP INDEPENDIENTE: conserva los cambios en esta sesión, sin MySQL.
    // Después el Servlet enviará la lista consultada desde la base de datos.
    ArrayList<String[]> segmentos = (ArrayList<String[]>) session.getAttribute("segmentosMockupIndependiente");
    if (segmentos == null) {
        segmentos = new ArrayList<String[]>();
        for (String[] fila : ejemplos) segmentos.add(fila.clone());
        session.setAttribute("segmentosMockupIndependiente", segmentos);
    }

    String error = "";
    String editar = request.getParameter("editar");
    String detalle = request.getParameter("detalle");
    String filtro = request.getParameter("estado");
    if (filtro == null) filtro = "";
    boolean mostrarFormulario = "nuevo".equals(request.getParameter("ventana")) || editar != null;
    String[] formulario = {"", "", "1", "2", "100", "0", "0", "Operativo"};
    for (String[] fila : segmentos) {
        if (fila[0].equals(editar)) formulario = fila.clone();
    }

    // 3. GUARDAR: registra o edita solamente los datos del segmento.
    if ("POST".equals(request.getMethod()) && "guardar".equals(request.getParameter("accion"))) {
        mostrarFormulario = true;
        String id = request.getParameter("id");
        String codigo = request.getParameter("codigo");
        String inicial = request.getParameter("inicial");
        String fin = request.getParameter("final");
        String estado = request.getParameter("estadoSegmento");
        if (id == null) id = "";
        if (codigo == null) codigo = "";
        codigo = codigo.trim();
        int posicion = -1;
        int nuevoId = 1;
        for (int i = 0; i < segmentos.size(); i++) {
            String[] fila = segmentos.get(i);
            nuevoId = Math.max(nuevoId, Integer.parseInt(fila[0]) + 1);
            if (fila[0].equals(id)) posicion = i;
        }
        long total = -1;
        try { total = Long.parseLong(request.getParameter("total")); }
        catch (NumberFormatException e) { /* La validación de abajo muestra el error. */ }
        String ocupada = posicion >= 0 ? segmentos.get(posicion)[5] : "0";
        String reservada = posicion >= 0 ? segmentos.get(posicion)[6] : "0";
        formulario = new String[] {id, codigo, inicial, fin, request.getParameter("total"), ocupada, reservada, estado};
        boolean estadoValido = false;
        for (String opcion : estados) if (opcion.equals(estado)) estadoValido = true;
        if (!id.isEmpty() && posicion < 0) error = "El segmento que quieres editar no existe.";
        else if (codigo.isEmpty() || codigo.length() > 20) error = "Escribe un código de hasta 20 caracteres.";
        else if (buscar(estaciones, inicial) < 0 || buscar(estaciones, fin) < 0 || inicial.equals(fin))
            error = "Selecciona dos estaciones diferentes.";
        else if (total <= 0 || total > 4294967295L) error = "La capacidad total debe ser un entero positivo válido.";
        else if (total < Long.parseLong(ocupada) + Long.parseLong(reservada))
            error = "El total no puede ser menor que la capacidad ocupada más la reservada.";
        else if (!estadoValido) error = "Selecciona un estado válido.";
        for (String[] fila : segmentos) {
            if (!fila[0].equals(id) && fila[1].equalsIgnoreCase(codigo)) error = "Ya existe un segmento con ese código.";
        }
        if (error.isEmpty()) {
            String[] guardado = {posicion >= 0 ? id : String.valueOf(nuevoId), codigo, inicial, fin,
                                String.valueOf(total), ocupada, reservada, estado};
            if (posicion >= 0) segmentos.set(posicion, guardado);
            else segmentos.add(guardado);
            response.sendRedirect("segmentos.jsp?guardado=1&detalle=" + guardado[0] + "#detalle");
            return;
        }
    }
    int cantidad = 0;
    for (String[] fila : segmentos) if (filtro.isEmpty() || fila[7].equals(filtro)) cantidad++;
%>

<!-- Contenido JSP -->
<!doctype html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>OceanLink | Dashboard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/admin/segmentos.css?v=2">
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
  <main class="contenido-principal pagina-segmentos">
    <section class="encabezado-pagina">
      <div class="encabezado-panel">
          <h2>Administrador</h2>
          <h1>Segmentos</h1>
      </div>
    </section>
    <% if ("1".equals(request.getParameter("guardado"))) { %>
      <p class="mensaje-exito">Segmento guardado correctamente.</p>
    <% } %>
    <div class="barra-herramientas">
      <form action="segmentos.jsp" method="get" class="formulario-filtro">
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
        <% for (String[] fila : segmentos) {
          if (!filtro.isEmpty() && !fila[7].equals(filtro)) continue;
          long disponible = Long.parseLong(fila[4]) - Long.parseLong(fila[5]) - Long.parseLong(fila[6]);
          String clase = fila[7].equals("Operativo") ? "operativo" : fila[7].equals("Degradado") ? "degradado" : fila[7].equals("En mantenimiento") ? "mantenimiento" : "fuera";
        %>
          <tr>
            <td><a class="enlace-segmento" href="segmentos.jsp?detalle=<%= fila[0] %>#detalle"><%= texto(fila[1]) %></a></td>
            <td><%= estaciones[buscar(estaciones, fila[2])][1] %></td>
            <td><%= estaciones[buscar(estaciones, fila[3])][1] %></td>
            <td><%= fila[4] %> Gbps</td>
            <td><%= fila[5] %> Gbps</td>
            <td><%= fila[6] %> Gbps</td>
            <td><strong><%= disponible %> Gbps</strong></td>
            <td><span class="estado <%= clase %>"><%= fila[7] %></span></td>
          </tr>
        <% } %>
        <% if (cantidad == 0) { %><tr><td colspan="8">No hay segmentos con este estado.</td></tr><% } %>
        </tbody>
      </table>
    </section>
    <p class="ayuda">Haz clic en un código para ver su detalle. Capacidades expresadas en Gbps.</p>

    <!-- 6. DETALLE DEL SEGMENTO SELECCIONADO. -->
    <% for (String[] fila : segmentos) {
        if (!fila[0].equals(detalle)) continue;
        long disponible = Long.parseLong(fila[4]) - Long.parseLong(fila[5]) - Long.parseLong(fila[6]);
    %>
        <section class="panel-detalle" id="detalle">
            <div class="encabezado-detalle">
                <h2><%= texto(fila[1]) %></h2>
                <a href="segmentos.jsp" aria-label="Cerrar detalle">×</a>
            </div>
            <div class="datos-detalle">
                <div><span>ID del segmento</span><strong><%= fila[0] %></strong></div>
                <div><span>Estación inicial</span><strong><%= estaciones[buscar(estaciones, fila[2])][1] %></strong></div>
                <div><span>Estación final</span><strong><%= estaciones[buscar(estaciones, fila[3])][1] %></strong></div>
                <div><span>Estado</span><strong><%= fila[7] %></strong></div>
                <div><span>Total</span><strong><%= fila[4] %> Gbps</strong></div>
                <div><span>Ocupada</span><strong><%= fila[5] %> Gbps</strong></div>
                <div><span>Reservada</span><strong><%= fila[6] %> Gbps</strong></div>
                <div><span>Disponible</span><strong><%= disponible %> Gbps</strong></div>
            </div>
            <p class="ayuda">Disponible = total − ocupada − reservada. El estado operativo es un dato diferente de la capacidad.</p>
        </section>
    <% } %>
  </main>
</div>
</body>
</html>
