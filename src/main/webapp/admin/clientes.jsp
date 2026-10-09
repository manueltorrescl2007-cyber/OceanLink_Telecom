<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!-- Datos estáticos, falta unir SQL -->
<%
    /* 1. DATOS DE PRUEBA
       Cada posición corresponde al mismo cliente en ambos arreglos. */
    String[] ordenClientes = {"pacifico", "claro", "movistar"};
    int[] clics = new int[3];
    /* 2. CLIENTE SELECCIONADO
       Lo obtenemos del enlace o recordamos el de la sesión. */
    String clienteSeleccionado = request.getParameter("cliente");
    if (clienteSeleccionado == null) {
        clienteSeleccionado = (String) session.getAttribute("clienteSeleccionado");
    }
    if (!"pacifico".equals(clienteSeleccionado)
            && !"claro".equals(clienteSeleccionado)
            && !"movistar".equals(clienteSeleccionado)) {
        clienteSeleccionado = "pacifico";
    }
    session.setAttribute("clienteSeleccionado", clienteSeleccionado);
    /* 3. CONTAR CLICS
       Recuperamos los contadores y aumentamos el del cliente pulsado.
       Se guardan en la sesión, no en MySQL. */
    String registrarVisita = request.getParameter("visita");
    for (int i = 0; i < ordenClientes.length; i++) {
        String clave = "clics_" + ordenClientes[i];
        Integer contador = (Integer) session.getAttribute(clave);
        if (contador != null) {
            clics[i] = contador;
        }
        if ("1".equals(registrarVisita)
                && ordenClientes[i].equals(clienteSeleccionado)) {
            clics[i]++;
        }
        session.setAttribute(clave, clics[i]);
    }
    /* Evita sumar otro clic si se recarga la página después de seleccionar.
       La nueva dirección conserva el cliente, pero ya no lleva visita=1. */
    if ("1".equals(registrarVisita)) {
        response.sendRedirect("clientes.jsp?cliente=" + clienteSeleccionado);
        return;
    }
    /* 4. ORDENAR CLIENTES
       Desde 5 clics, el cliente tiene prioridad.
       Entre clientes frecuentes, aparece primero el de más clics.
       Si ninguno es frecuente, conservamos su orden original. */
    for (int vuelta = 0; vuelta < ordenClientes.length - 1; vuelta++) {
        for (int i = 0; i < ordenClientes.length - 1 - vuelta; i++) {
            int prioridadActual = 0;
            int prioridadSiguiente = 0;
            if (clics[i] >= 5) {
                prioridadActual = clics[i];
            }
            if (clics[i + 1] >= 5) {
                prioridadSiguiente = clics[i + 1];
            }
            if (prioridadSiguiente > prioridadActual) {
                // Intercambiamos los nombres y sus contadores juntos.
                String clienteTemporal = ordenClientes[i];
                ordenClientes[i] = ordenClientes[i + 1];
                ordenClientes[i + 1] = clienteTemporal;
                int clicsTemporales = clics[i];
                clics[i] = clics[i + 1];
                clics[i + 1] = clicsTemporales;
            }
        }
    }
    /* 5. DETALLE QUE SE MOSTRARÁ
       Solo aceptamos las cuatro opciones del resumen. */
    String detalleSeleccionado = request.getParameter("detalle");
    if (detalleSeleccionado != null
            && !"solicitudes".equals(detalleSeleccionado)
            && !"servicios".equals(detalleSeleccionado)
            && !"contacto".equals(detalleSeleccionado)
            && !"estado".equals(detalleSeleccionado)) {
        detalleSeleccionado = null;
    }
    /* 6. DATOS DEL SQL: tres clientes de ejemplo del archivo recibido.
       El Servlet cargará después la lista completa desde MySQL. */
    int idCliente;
    String nombreCliente;
    String razonSocial;
    String rucCliente;
    String correoCliente;
    String telefonoCliente;
    String estadoCliente;

    switch (clienteSeleccionado) {
        case "claro":
            idCliente = 1;
            nombreCliente = "Claro";
            razonSocial = "Claro Telecomunicaciones S.A.C.";
            rucCliente = "20123456789";
            correoCliente = "contacto@claro.example";
            telefonoCliente = "900111222";
            estadoCliente = "activo";
            break;
        case "movistar":
            idCliente = 2;
            nombreCliente = "Movistar";
            razonSocial = "Movistar Servicios Digitales S.A.C.";
            rucCliente = "20234567890";
            correoCliente = "contacto@movistar.example";
            telefonoCliente = "900222333";
            estadoCliente = "activo";
            break;
        default:
            idCliente = 3;
            nombreCliente = "Pacifico";
            razonSocial = "Pacifico Conectividad S.A.C.";
            rucCliente = "20345678901";
            correoCliente = "contacto@pacifico.example";
            telefonoCliente = "900333444";
            estadoCliente = "activo";
            break;
    }
    /* DATOS FICTICIOS: solo para mostrar el diseño.
       No se insertan en MySQL. El Servlet los reemplazará después. */
    int totalSolicitudes = 3;
    int totalServicios = 2;
    if ("claro".equals(clienteSeleccionado)) {
        totalSolicitudes = 2;
        totalServicios = 1;
    } else if ("movistar".equals(clienteSeleccionado)) {
        totalSolicitudes = 1;
        totalServicios = 1;
    }
%>

<!doctype html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>OceanLink | Dashboard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/admin/clientes.css?v=2">
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
        <h1>Clientes</h1>
    </section>
    <section class="seccion-clientes">
      <div class="panel-clientes">
          <div class="titulo-seccion">
              <h2>Clientes frecuentes</h2>
              <span class="cantidad-clientes">3</span>
          </div>
          <!-- LISTA: conserva el orden calculado a partir de los clics -->
          <ul class="lista-clientes">
              <% for (String codigoCliente : ordenClientes) {
                  String nombreLista;
                  String razonLista;
                  switch (codigoCliente) {
                      case "claro":
                          nombreLista = "Claro";
                          razonLista = "Claro Telecomunicaciones S.A.C.";
                          break;
                      case "movistar":
                          nombreLista = "Movistar";
                          razonLista = "Movistar Servicios Digitales S.A.C.";
                          break;
                      default:
                          nombreLista = "Pacifico";
                          razonLista = "Pacifico Conectividad S.A.C.";
                          break;
                  }
              %>
              <li class="<%= clienteSeleccionado.equals(codigoCliente) ? "cliente-seleccionado" : "" %>">
                  <a class="cliente-enlace" href="clientes.jsp?cliente=<%= codigoCliente %>&amp;visita=1">
                      <span class="avatar-cliente"><%= nombreLista.substring(0, 1) %></span>
                      <span class="datos-cliente">
                          <strong><%= nombreLista %></strong>
                          <small><%= razonLista %></small>
                          <small><%= "pacifico".equals(codigoCliente) ? "2 servicios contratados" : "1 servicio contratado" %></small>
                      </span>
                  </a>
              </li>
              <% } %>
          </ul>
      </div>
      <!-- RESUMEN: se actualiza según el cliente seleccionado -->
      <div class="panel-resumen">
          <div class="encabezado-resumen">
              <span class="etiqueta-resumen">Resumen</span>
              <strong class="titulo-resumen"><%= nombreCliente %></strong>
          </div>
          <a class="opcion-resumen" href="clientes.jsp?cliente=<%= clienteSeleccionado %>&amp;detalle=solicitudes">
              <span class="icono-opcion">★</span>
              <span class="texto-opcion">
                  <strong>Solicitudes asociadas</strong>
                  <small><%= totalSolicitudes %> solicitudes registradas</small>
              </span>
              <span class="flecha">›</span>
          </a>
          <a class="opcion-resumen" href="clientes.jsp?cliente=<%= clienteSeleccionado %>&amp;detalle=servicios">
              <span class="icono-opcion">★</span>
              <span class="texto-opcion">
                  <strong>Servicios contratados</strong>
                  <small><%= totalServicios %> servicios contratados</small>
              </span>
              <span class="flecha">›</span>
          </a>
          <a class="opcion-resumen" href="clientes.jsp?cliente=<%= clienteSeleccionado %>&amp;detalle=contacto">
              <span class="icono-opcion">★</span>
              <span class="texto-opcion">
                  <strong>Contacto</strong>
                  <small><%= correoCliente %></small>
              </span>
              <span class="flecha">›</span>
          </a>
          <a class="opcion-resumen" href="clientes.jsp?cliente=<%= clienteSeleccionado %>&amp;detalle=estado">
              <span class="icono-opcion">★</span>
              <span class="texto-opcion">
                  <strong>Estado</strong>
                  <small><%= estadoCliente.equals("activo") ? "Activo" : "Inactivo" %></small>
              </span>
              <span class="flecha">›</span>
          </a>
      </div>
    </section>
    <!-- DETALLE: solo aparece después de pulsar una opción del resumen -->
    <% if (detalleSeleccionado != null) { %>
    <section class="panel-detalle">
      <div class="encabezado-detalle">
        <div>
            <p class="subtitulo-detalle">Cliente <%= nombreCliente %></p>
            <h2>
                <% if ("solicitudes".equals(detalleSeleccionado)) { %>
                    Solicitudes asociadas
                <% } else if ("servicios".equals(detalleSeleccionado)) { %>
                    Servicios contratados
                <% } else if ("contacto".equals(detalleSeleccionado)) { %>
                    Información de contacto
                <% } else { %>
                    Datos del cliente
                <% } %>
            </h2>
        </div>
        <a class="cerrar-detalle" href="clientes.jsp?cliente=<%= clienteSeleccionado %>" aria-label="Cerrar detalle">&times;</a>
      </div>
      <div class="contenido-detalle">
        <% if ("solicitudes".equals(detalleSeleccionado)) { %>
            <!-- Solicitudes ficticias del cliente seleccionado -->
            <article class="tarjeta-detalle">
                <div><strong>SOL-<%= idCliente %>01 · Los Ángeles — Lurín</strong><p>Capacidad solicitada: 50 Gbps</p></div>
                <span class="badge aprobada">Aprobada</span>
            </article>
            <% if (totalSolicitudes >= 2) { %>
            <article class="tarjeta-detalle">
                <div><strong>SOL-<%= idCliente %>02 · Lurín — Valparaíso</strong><p>Capacidad solicitada: 20 Gbps</p></div>
                <span class="badge pendiente">En evaluación</span>
            </article>
            <% } %>
            <% if (totalSolicitudes >= 3) { %>
            <article class="tarjeta-detalle">
                <div><strong>SOL-<%= idCliente %>03 · Guayaquil — Lurín</strong><p>Capacidad solicitada: 30 Gbps</p></div>
                <span class="badge aprobada">Activa</span>
            </article>
            <% } %>
        <% } else if ("servicios".equals(detalleSeleccionado)) { %>
            <!-- Servicios ficticios: cada servicio tiene ruta y capacidad asignada -->
            <article class="tarjeta-detalle servicio">
                <strong>SER-<%= idCliente %>01</strong>
                <p><b>Solicitud:</b> SOL-<%= idCliente %>01</p>
                <p><b>Ruta:</b> LAX-LUR-R01</p>
                <p><b>Capacidad asignada:</b> 50 Gbps</p>
                <p><b>Estado:</b> <span class="badge pendiente">Pendiente</span></p>
            </article>
            <% if (totalServicios >= 2) { %>
            <article class="tarjeta-detalle servicio">
                <strong>SER-<%= idCliente %>02</strong>
                <p><b>Solicitud:</b> SOL-<%= idCliente %>03</p>
                <p><b>Ruta:</b> GYE-LUR-R01</p>
                <p><b>Capacidad asignada:</b> 30 Gbps</p>
                <p><b>Estado:</b> <span class="badge activa">Activo</span></p>
            </article>
            <% } %>
        <% } else if ("contacto".equals(detalleSeleccionado)) { %>
            <article class="tarjeta-detalle contacto">
                <p><b>Empresa:</b> <%= nombreCliente %></p>
                <p><b>Correo:</b> <%= correoCliente %></p>
                <p><b>Teléfono:</b> <%= telefonoCliente %></p>
            </article>
        <% } else { %>
            <article class="tarjeta-detalle contacto">
                <p><b>ID:</b> <%= idCliente %></p>
                <p><b>Nombre:</b> <%= nombreCliente %></p>
                <p><b>Razón social:</b> <%= razonSocial %></p>
                <p><b>RUC:</b> <%= rucCliente %></p>
                <p><b>Estado:</b> <span class="badge <%= estadoCliente.equals("activo") ? "activa" : "inactiva" %>"><%= estadoCliente.equals("activo") ? "Activo" : "Inactivo" %></span></p>
            </article>
        <% } %>
      </div>
    </section>
    <% } %>
  </main>
</div>
</body>
</html>
