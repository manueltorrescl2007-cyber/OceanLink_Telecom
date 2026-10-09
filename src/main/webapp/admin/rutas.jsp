<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!-- Datos estáticos, falta unir con SQL -->
<%@ page import="java.util.ArrayList" %>
<%!
    // Escapa texto escrito por el usuario antes de mostrarlo en HTML.
    private String texto(String valor) {
        return valor == null ? "" : valor.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
    // Busca una fila por su ID; devuelve -1 cuando no existe.
    private int buscar(String[][] datos, String id) {
        for (int i = 0; i < datos.length; i++) if (datos[i][0].equals(id)) return i;
        return -1;
    }
    // La capacidad disponible es la menor capacidad libre de sus segmentos.
    // No se suma: el tráfico debe atravesar todos los segmentos de la ruta.
    private int disponible(String codigos, String[][] segmentos) {
        int menor = Integer.MAX_VALUE;
        for (String codigo : codigos.split(",")) {
            for (String[] segmento : segmentos) {
                if (segmento[1].equals(codigo.trim())) {
                    int libre = Integer.parseInt(segmento[4]) - Integer.parseInt(segmento[5]) - Integer.parseInt(segmento[6]);
                    if (libre < menor) menor = libre;
                }
            }
        }
        return menor == Integer.MAX_VALUE ? 0 : Math.max(0, menor);
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    // 1. CATÁLOGOS: IDs y datos copiados del SQL, sin consultar MySQL.
    // Landing stations: ID y ciudad.
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
    // Segmentos: ID, código, inicio, final, total, ocupada, reservada, estado.
    String[][] segmentos = {
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
    // Rutas: ID, nombre, origen, destino, estado y códigos ordenados.
    // Los códigos representan la relación ruta_segmentos y su campo orden.
    String[][] ejemplos = {
        {"1", "VAN-BAL-R01", "1", "12", "activa", "VAN-SEA-01, SEA-SFO-01, SFO-LAX-01, LAX-BAL-01"},
        {"2", "LAX-BAL-R01", "4", "12", "activa", "LAX-BAL-01"},
        {"3", "SFO-BAL-R01", "3", "12", "activa", "SFO-LAX-01, LAX-BAL-01"},
        {"4", "LAX-LUR-R01", "4", "17", "activa", "LAX-LUR-01"},
        {"5", "LAX-GYE-R01", "4", "15", "activa", "LAX-BAL-01, BAL-GYE-01"},
        {"6", "SFO-BUE-R01", "3", "13", "activa", "SFO-BUE-01"},
        {"7", "VAN-LUR-R01", "1", "17", "activa", "VAN-SEA-01, SEA-SFO-01, SFO-LAX-01, LAX-LUR-01"},
        {"8", "BAL-LUR-R01", "12", "17", "activa", "BAL-LUR-01"},
        {"9", "BAL-GYE-R01", "12", "15", "activa", "BAL-GYE-01"},
        {"10", "BAL-BUE-R01", "12", "13", "activa", "BAL-BUE-01"},
        {"11", "BUE-LUR-R01", "13", "17", "activa", "BUE-MAN-01, MAN-GYE-01, GYE-PAI-01, PAI-LUR-01"},
        {"12", "GYE-LUR-R01", "15", "17", "activa", "GYE-LUR-01"},
        {"13", "LUR-VAL-R01", "17", "19", "activa", "LUR-VAL-01"},
        {"14", "LUR-CON-R01", "17", "20", "activa", "LUR-VAL-01, VAL-CON-01"},
        {"15", "GYE-VAL-R01", "15", "19", "activa", "GYE-LUR-01, LUR-VAL-01"},
        {"16", "VAN-CON-R01", "1", "20", "activa", "VAN-SEA-01, SEA-SFO-01, SFO-LAX-01, LAX-SDG-01, SDG-TIJ-01, TIJ-MAN-01, MAN-PCH-01, PCH-PQZ-01, PQZ-ACJ-01, ACJ-PUN-01, PUN-BAL-01, BAL-BUE-01, BUE-MAN-01, MAN-GYE-01, GYE-PAI-01, PAI-LUR-01, LUR-ARI-01, ARI-VAL-01, VAL-CON-01"},
        {"17", "LAX-VAL-R01", "4", "19", "activa", "LAX-LUR-01, LUR-VAL-01"},
        {"18", "LAX-CON-R01", "4", "20", "activa", "LAX-LUR-01, LUR-VAL-01, VAL-CON-01"},
        {"19", "SFO-LUR-R01", "3", "17", "activa", "SFO-BUE-01, BUE-MAN-01, MAN-GYE-01, GYE-PAI-01, PAI-LUR-01"},
        {"20", "BAL-VAL-R01", "12", "19", "activa", "BAL-LUR-01, LUR-VAL-01"}
    };
    // 2. SESIÓN: Rutas tiene sus propios datos, sin modificar otras páginas.
    ArrayList<String[]> rutas = (ArrayList<String[]>) session.getAttribute("rutasMockupIndependiente");
    if (rutas == null) {
        rutas = new ArrayList<String[]>();
        for (String[] ruta : ejemplos) rutas.add(ruta);
        session.setAttribute("rutasMockupIndependiente", rutas);
    }
    String error = "";
    String[] valor = {"", "", "", "", "activa", ""};
    boolean formulario = "nuevo".equals(request.getParameter("ventana"));
    int editar = -1;
    for (int i = 0; i < rutas.size(); i++) {
        if (rutas.get(i)[0].equals(request.getParameter("editar"))) {
            editar = i; valor = rutas.get(i).clone(); formulario = true;
        }
    }
    // 3. ACCIONES DE PRUEBA: después se moverán al servlet.
    if ("POST".equals(request.getMethod())) {
        String accion = request.getParameter("accion");
        String id = request.getParameter("id_ruta");
        int indice = -1;
        for (int i = 0; i < rutas.size(); i++) if (rutas.get(i)[0].equals(id)) indice = i;
        if ("eliminar".equals(accion) && indice >= 0) {
            rutas.remove(indice);
            response.sendRedirect("rutas.jsp"); return;
        }
        if ("guardar".equals(accion)) {
            String nombre = request.getParameter("nombre");
            String origen = request.getParameter("id_landing_origen");
            String destino = request.getParameter("id_landing_destino");
            String estado = request.getParameter("estado_ruta");
            String codigos = request.getParameter("segmentos");
            nombre = nombre == null ? "" : nombre.trim();
            codigos = codigos == null ? "" : codigos.trim();
            valor = new String[]{id, nombre, origen, destino, estado, codigos};
            formulario = true; editar = indice;
            if (nombre.isEmpty() || nombre.length() > 100 || buscar(estaciones, origen) < 0 || buscar(estaciones, destino) < 0 || origen.equals(destino)) {
                error = "Ingrese un nombre de hasta 100 caracteres y seleccione un origen y destino diferentes.";
            } else if (!"activa".equals(estado) && !"inactiva".equals(estado)) {
                error = "Seleccione un estado válido.";
            } else {
                // Revisa que los segmentos existan y formen un recorrido continuo.
                String actual = origen;
                String[] partes = codigos.split(",", -1);
                ArrayList<String> usados = new ArrayList<String>();
                for (String parte : partes) {
                    String codigo = parte.trim();
                    int seleccionado = -1;
                    for (int i = 0; i < segmentos.length; i++) if (segmentos[i][1].equals(codigo)) seleccionado = i;
                    if (seleccionado < 0 || usados.contains(codigo)) {
                        error = "Use códigos de segmentos existentes, sin repetirlos."; break;
                    }
                    String[] segmento = segmentos[seleccionado];
                    if (!segmento[2].equals(actual)) {
                        error = "Los segmentos deben ir en orden y conectar el origen con el destino."; break;
                    }
                    actual = segmento[3]; usados.add(codigo);
                }
                if (error.isEmpty() && !actual.equals(destino)) error = "El último segmento debe terminar en el destino seleccionado.";
                for (String[] ruta : rutas) {
                    if (!ruta[0].equals(id) && ruta[1].equalsIgnoreCase(nombre)) error = "Ya existe una ruta con ese nombre.";
                }
            }
            if (error.isEmpty()) {
                if (indice >= 0) rutas.set(indice, valor);
                else {
                    int siguiente = 1;
                    for (String[] ruta : rutas) if (Integer.parseInt(ruta[0]) >= siguiente) siguiente = Integer.parseInt(ruta[0]) + 1;
                    valor[0] = String.valueOf(siguiente); rutas.add(valor);
                }
                response.sendRedirect("rutas.jsp?guardado=1&detalle=" + valor[0]); return;
            }
        }
    }
    // 4. FILTRO Y DETALLE: funcionan al recargar esta misma página.
    String filtro = request.getParameter("filtro");
    if (filtro == null) filtro = "Todas";
    int cantidad = 0; int detalle = -1;
    for (int i = 0; i < rutas.size(); i++) {
        if (filtro.equals("Todas") || filtro.equals(rutas.get(i)[4])) cantidad++;
        if (rutas.get(i)[0].equals(request.getParameter("detalle"))) detalle = i;
    }
%>

<!-- Contenido JSP -->
<!doctype html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>OceanLink | Dashboard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/admin/rutas.css?v=2">
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
   <main class="contenido-principal pagina-rutas">
      <section class="encabezado-pagina">
        <div class="encabezado-panel"><h2>Administrador</h2><h1>Rutas</h1></div>
      </section>
      <% if ("1".equals(request.getParameter("guardado"))) { %><p class="mensaje-exito">Ruta guardada.</p><% } %>
      <section class="barra-herramientas">
        <form method="get" action="rutas.jsp" class="formulario-filtro">
          <label for="filtro">Estado:</label>
          <select id="filtro" name="filtro">
            <option value="Todas">Todas</option>
            <option value="activa" <%= filtro.equals("activa") ? "selected" : "" %>>Activa</option>
            <option value="inactiva" <%= filtro.equals("inactiva") ? "selected" : "" %>>Inactiva</option>
          </select>
          <button class="boton secundario" type="submit">Filtrar</button>
        </form>
        <span><%= cantidad %> rutas</span>
      </section>
      <section class="contenedor-tabla">
        <table><thead><tr><th>ID</th><th>Nombre</th><th>Origen</th><th>Destino</th><th>Segmentos</th><th>Capacidad disponible</th><th>Estado</th></tr></thead>
        <tbody>
        <% for (String[] ruta : rutas) { if (filtro.equals("Todas") || filtro.equals(ruta[4])) { %>
        <tr>
          <td><a class="enlace-ruta" href="rutas.jsp?detalle=<%= ruta[0] %>">RUT-<%= ruta[0] %></a></td>
          <td><%= texto(ruta[1]) %></td>
          <td><%= estaciones[buscar(estaciones, ruta[2])][1] %></td>
          <td><%= estaciones[buscar(estaciones, ruta[3])][1] %></td>
          <td><%= ruta[5].split(",").length %></td>
          <td><%= disponible(ruta[5], segmentos) %> Gbps</td>
          <td><span class="estado <%= ruta[4] %>"><%= ruta[4].equals("activa") ? "Activa" : "Inactiva" %></span></td>
        </tr>
        <% } } %>
        <% if (cantidad == 0) { %><tr><td colspan="7">No hay rutas con este estado.</td></tr><% } %>
        </tbody></table>
      </section>
      <!-- 6. DETALLE: muestra los segmentos en el orden del recorrido. -->
      <% if (detalle >= 0) { String[] ruta = rutas.get(detalle); int orden = 1; %>
      <section class="panel-detalle">
        <div class="encabezado-detalle"><h2><%= texto(ruta[1]) %></h2><a href="rutas.jsp" aria-label="Cerrar detalle">&times;</a></div>
        <p class="resumen-ruta"><%= estaciones[buscar(estaciones, ruta[2])][1] %> → <%= estaciones[buscar(estaciones, ruta[3])][1] %></p>
        <h3>Segmentos de la ruta</h3>
        <div class="contenedor-tabla">
          <table><thead><tr><th>Orden</th><th>Segmento</th><th>Total</th><th>Ocupada</th><th>Reservada</th><th>Estado</th></tr></thead><tbody>
          <% for (String codigo : ruta[5].split(",")) { for (String[] segmento : segmentos) { if (segmento[1].equals(codigo.trim())) { %>
          <tr><td><%= orden++ %></td><td><%= segmento[1] %></td><td><%= segmento[4] %> Gbps</td><td><%= segmento[5] %> Gbps</td><td><%= segmento[6] %> Gbps</td><td><%= segmento[7] %></td></tr>
          <% } } } %>
          </tbody></table>
        </div>
        <p class="ayuda">Disponible = menor valor de (total − ocupada − reservada) entre los segmentos.</p>
      </section>
      <% } %>
   </main>
</div>
</body>
</html>
