<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!-- Datos estáticos, no hay conexion con SQL todavía -->
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
          href="${pageContext.request.contextPath}/css/admin/capacidad.css">
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
    <div class="encabezado-panel">
      <h2>Administrador</h2>
      <h1>Utilización de la red</h1>
    </div>
    <section class="card chart-section">
      <div class="chart-header">
        <h2 class="card-title">Utilización de la Red (50%)</h2>
        <p class="stat-trend stat-trend-positive">↗ +4.2% los últimos 7 días</p>
      </div>

      <figure class="chart-figure">
        <img class="chart-image"
             src="${pageContext.request.contextPath}/img/grafico_utilizacion.svg"
             alt="Gráfico de utilización de la red en los últimos 7 días: sube de 45.8% a 50%">
      </figure>
    </section>

    <div class="encabezado-panel">
      <h1>Detalles generales</h1>
    </div>
    <!-- Las tres tarjetas conservan el diseño existente -->
    <section class="tarjetas">
      <article class="tarjeta tarjeta-resumen">
        <h3>Resumen</h3>
        <div class="fila">
          <span>Solicitudes registradas</span>
          <strong>12</strong>
        </div>
        <div class="fila">
          <span>Pendientes de evaluación</span>
          <strong>4</strong>
        </div>
        <div class="fila">
          <span>Solicitudes aprobadas</span>
          <strong>6</strong>
        </div>
        <div class="fila">
          <span>Pendientes por capacidad</span>
          <strong>2</strong>
        </div>
        <div class="fila">
          <span>Servicios activos</span>
          <strong>2</strong>
        </div>
      </article>
      <!-- ==========================================
           5. UTILIZACIÓN DE SEGMENTOS

           Propuesta de cálculo:
           (ocupada + reservada) / total * 100

           Normal: menor al 80%.
           Alta: del 80% al 95%, inclusive.
           Crítica: mayor al 95%.

           Los conteos siguientes son ejemplos.
           ========================================== -->
      <article class="tarjeta tarjeta-segmentos">
        <h3>Estado de segmentos</h3>

        <div class="fila">
            <span>25 estables</span>
            <span class="estado disponible"
                  aria-label="Normal"></span>
        </div>

        <div class="fila">
            <span>3 limitados</span>
            <span class="estado limitada"
                  aria-label="Alta utilización"></span>
        </div>

        <div class="fila">
            <span>2 críticos</span>
            <span class="estado insuficiente"
                  aria-label="Utilización crítica"></span>
        </div>

        <div class="fila enlace-segmentos">
            <a href="${pageContext.request.contextPath}/admin/segmentos.jsp">
                Ver segmentos →
            </a>
        </div>
      </article>
      <!-- ==========================================
           6. ACCIONES PENDIENTES

           Ya no se registran manualmente.
           Después se generarán según el estado
           de cada solicitud consultada en MySQL.

           Aquí mostramos ejemplos del resultado.
           ========================================== -->
      <article class="tarjeta acciones">
        <div class="encabezado-acciones">
            <h3>Acciones pendientes</h3>
            <!-- Después mostrará el total obtenido
                 de la consulta de solicitudes -->
            <span class="cantidad-acciones">4</span>
        </div>
        <ul class="lista-acciones">
          <!-- Solicitud registrada -->
          <li>
            <div class="informacion-accion">

                <!-- Por ahora abre la lista de solicitudes -->
                <a href="${pageContext.request.contextPath}/admin/solicitudes.jsp">
                    <strong>SOL-014</strong>
                </a>

                <span>Evaluar solicitud</span>
            </div>
          </li>

          <!-- Solicitud en evaluación -->
          <li>
            <div class="informacion-accion">

                <a href="${pageContext.request.contextPath}/admin/solicitudes.jsp">
                    <strong>SOL-018</strong>
                </a>

                <span>Revisar capacidad de segmentos</span>
            </div>
          </li>
          <!-- Solicitud pendiente por capacidad -->
          <li>
              <div class="informacion-accion">

                  <a href="${pageContext.request.contextPath}/admin/solicitudes.jsp">
                      <strong>SOL-021</strong>
                  </a>

                  <span>Revisar alternativas de capacidad</span>
              </div>
          </li>

          <!-- Solicitud aprobada -->
          <li>
              <div class="informacion-accion">

                  <a href="${pageContext.request.contextPath}/admin/solicitudes.jsp">
                      <strong>SOL-022</strong>
                  </a>

                  <span>Gestionar reserva de capacidad</span>
              </div>
          </li>
        </ul>
      </article>
    </section>
  </main>
</body>
</html>
