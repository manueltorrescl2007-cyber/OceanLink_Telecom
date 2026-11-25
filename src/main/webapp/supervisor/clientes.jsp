<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.capacityplanner.Cliente" %>
<%@ page import="beans.capacityplanner.Solicitud" %>
<%@ page import="beans.capacityplanner.Servicio" %>
<%!
  private String texto(String valor) {
    if (valor == null) return "";

    return valor.replace("&", "&amp;")
      .replace("<", "&lt;")
      .replace(">", "&gt;")
      .replace("\"", "&quot;")
      .replace("'", "&#39;");
  }
%>
<%
  ArrayList<Cliente> clientes = (ArrayList<Cliente>) request.getAttribute("listaClientes");
  String servlet = request.getContextPath() + "/ClienteServletSuper";
  if (clientes == null) {
    response.sendRedirect(servlet);
    return;
  }

  Cliente cliente = (Cliente) request.getAttribute("clienteSeleccionado");
  if (cliente == null && !clientes.isEmpty()) cliente = clientes.get(0);

  int idCliente = cliente != null ? cliente.getIdCliente() : 0;
  String nombreCliente = cliente != null ? cliente.getNombre() : "Seleccione un cliente";
  String correoCliente = cliente != null ? cliente.getCorreo() : "";
  String telefonoCliente = cliente != null ? cliente.getTelefono() : "";
  String estadoCliente = cliente != null ? cliente.getEstado() : "";
  String detalleSeleccionado = request.getParameter("detalle");
  String error = (String) request.getAttribute("error");

  int[] clics = new int[clientes.size()];
  for (int i = 0; i < clientes.size(); i++) {
    String clave = "clics_cliente_" + clientes.get(i).getIdCliente();
    Integer contador = (Integer) session.getAttribute(clave);
    clics[i] = contador != null ? contador : 0;
    if ("1".equals(request.getParameter("visita"))
      && clientes.get(i).getIdCliente() == idCliente) {
      clics[i]++;
      session.setAttribute(clave, clics[i]);
    }
  }
  if ("1".equals(request.getParameter("visita"))) {
    response.sendRedirect(servlet + "?id=" + idCliente);
    return;
  }
  for (int vuelta = 0; vuelta < clientes.size() - 1; vuelta++) {
    for (int i = 0; i < clientes.size() - 1 - vuelta; i++) {
      int actual = clics[i] >= 5 ? clics[i] : 0;
      int siguiente = clics[i + 1] >= 5 ? clics[i + 1] : 0;
      if (siguiente > actual) {
        Cliente temporal = clientes.get(i);
        clientes.set(i, clientes.get(i + 1));
        clientes.set(i + 1, temporal);
        int clicTemporal = clics[i];
        clics[i] = clics[i + 1];
        clics[i + 1] = clicTemporal;
      }
    }
  }

  ArrayList<Solicitud> solicitudesCliente =
    (ArrayList<Solicitud>) request.getAttribute("solicitudesCliente");

  ArrayList<Servicio> serviciosCliente =
    (ArrayList<Servicio>) request.getAttribute("listaServiciosCliente");

  if (solicitudesCliente == null) {
    solicitudesCliente = new ArrayList<>();
  }

  if (serviciosCliente == null) {
    serviciosCliente = new ArrayList<>();
  }

  int totalSolicitudes = solicitudesCliente.size();
  int totalServicios = serviciosCliente.size();
%>

<!doctype html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Clientes | OceanLink</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/supervisor/clientes.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/barras.css">
</head>
<body>
<jsp:include page="header.jsp" />

<div class="contenedor">
  <aside class="menu-lateral">
    <div class="contenido-menu">
      <h2>Menú</h2>
      <nav class="navegacion-lateral" aria-label="Menú principal">
        <a href="${pageContext.request.contextPath}/DashboardServletSuper">Dashboard general</a>

        <div class="grupo-menu">
          <input type="checkbox" id="control-incidencias" class="control-submenu">
          <label for="control-incidencias" class="titulo-grupo">
            <span>Incidencias</span>
            <span class="flecha-submenu"></span>
          </label>
          <div class="contenido-submenu">
            <a href="${pageContext.request.contextPath}/IncidenciaServletSuper" class="subopcion">Visualizar</a>
            <a href="${pageContext.request.contextPath}/IncidenciaServletSuper?action=historial" class="subopcion">Historial de incidencias</a>
          </div>
        </div>

        <div class="grupo-menu">
          <input type="checkbox" id="controlEstadoRed" class="control-submenu">
          <label for="controlEstadoRed" class="titulo-grupo">
            <span class="texto-grupo">Estado de la red</span>
            <span class="flecha-submenu"></span>
          </label>
          <div class="contenido-submenu">
            <a href="${pageContext.request.contextPath}/TarjetasServletSuper" class="subopcion">Capacidad</a>
            <a href="${pageContext.request.contextPath}/RutaServletSuper" class="subopcion">Rutas</a>
            <a href="${pageContext.request.contextPath}/SegmentoServletSuper" class="subopcion">Segmentos</a>
            <a href="${pageContext.request.contextPath}/LandingStationServletSuper" class="subopcion">Landing stations</a>
          </div>
        </div>

        <div class="grupo-menu">
          <input type="checkbox" id="control-servicios-clientes" class="control-submenu" checked>
          <label for="control-servicios-clientes" class="titulo-grupo">
            <span class="texto-grupo">Servicios y clientes</span>
            <span class="flecha-submenu"></span>
          </label>
          <div class="contenido-submenu">
            <a href="${pageContext.request.contextPath}/ClienteServletSuper" class="subopcion activo">Clientes</a>
            <a href="${pageContext.request.contextPath}/ServicioServletSuper" class="subopcion">Servicios</a>
            <a href="${pageContext.request.contextPath}/SolicitudesServletSuper" class="subopcion">Solicitudes</a>
          </div>
        </div>

        <div class="grupo-menu">
          <input type="checkbox" id="control-mantenimientos" class="control-submenu">
          <label for="control-mantenimientos" class="titulo-grupo">
            <span class="texto-grupo">Mantenimientos</span>
            <span class="flecha-submenu"></span>
          </label>
          <div class="contenido-submenu">
            <a href="${pageContext.request.contextPath}/MantenimientoServletSuper" class="subopcion">Programación</a>
            <a href="${pageContext.request.contextPath}/MantenimientoServletSuper?accion=historial" class="subopcion">Historial de programados</a>
          </div>
        </div>

        <a href="${pageContext.request.contextPath}/ReporteServletSuper">Reportes</a>
        <a href="${pageContext.request.contextPath}/HistoricoServletSuper">Históricos</a>
      </nav>
    </div>

    <div class="configuracion">
      <nav aria-label="Opciones del usuario">
        <a href="${pageContext.request.contextPath}/PerfilServlet">Perfil</a>
        <a href="${pageContext.request.contextPath}/LogoutServlet" class="cerrar-sesion">Cerrar sesión</a>
      </nav>
    </div>
  </aside>

  <main class="contenido-principal">
    <section class="encabezado-panel">
      <h2>Supervisor</h2>
      <h1>Clientes</h1>
    </section>
    <% if (error != null) { %><p role="alert"><%= texto(error) %></p><% } %>
    <section class="seccion-clientes">
      <div class="panel-clientes">
        <div class="titulo-seccion titulo-clientes">
          <h2>Clientes frecuentes</h2>
          <div class="herramientas-clientes">
            <input type="search" id="buscarCliente" class="busqueda-clientes"
                   placeholder="Buscar cliente" aria-label="Buscar cliente por nombre"
                   autocomplete="off" hidden>
            <button type="button" id="abrirBusquedaCliente" class="lupa-clientes"
                    aria-label="Buscar clientes" aria-controls="buscarCliente"
                    aria-expanded="false">
              <svg width="23" height="23" viewBox="0 0 24 24"
                   fill="none" stroke="currentColor" stroke-width="2"
                   stroke-linecap="round" aria-hidden="true">
                <circle cx="10.5" cy="10.5" r="6.5"></circle>
                <path d="M16 16L21 21"></path>
              </svg>
            </button>
            <span id="cantidadClientes" class="cantidad-clientes" aria-live="polite">
                            <%= clientes.size() %>
                        </span>
          </div>
        </div>

        <ul class="lista-clientes" id="listaClientes">
          <% for (Cliente c : clientes) { %>
          <li data-id="<%= c.getIdCliente() %>" data-nombre="<%= texto(c.getNombre()) %>"
              class="<%= c.getIdCliente() == idCliente ? "cliente-seleccionado" : "" %>">
            <a class="cliente-enlace" href="<%= servlet %>?id=<%= c.getIdCliente() %>&visita=1">
              <span class="avatar-cliente"><%= texto(c.getNombre().isEmpty() ? "" : c.getNombre().substring(0, 1)) %></span>
              <span class="datos-cliente">
                                <strong><%= texto(c.getNombre()) %></strong>
                                <small><%= texto(c.getRazonSocial()) %></small>
                                <small><%= "activo".equals(c.getEstado()) ? "Activo" : "Inactivo" %></small>
                            </span>
            </a>
          </li>
          <% } %>
        </ul>
        <% if (clientes.isEmpty()) { %><p class="sin-clientes">No hay clientes registrados.</p><% } %>
        <p id="sinCoincidenciasClientes" class="sin-clientes" role="status" hidden>No hay clientes con ese nombre.</p>
      </div>

      <div class="panel-resumen">
        <div class="encabezado-resumen">
          <span class="etiqueta-resumen">Resumen</span>
          <strong class="titulo-resumen"><%= texto(nombreCliente) %></strong>
        </div>
        <a class="opcion-resumen" href="<%= servlet %>?id=<%= idCliente %>&detalle=solicitudes">
          <span class="icono-opcion">★</span>
          <span class="texto-opcion">
                        <strong>Solicitudes asociadas</strong>
                        <small><%= totalSolicitudes %> solicitud(es) registradas</small>
                    </span>
          <span class="flecha">›</span>
        </a>
        <a class="opcion-resumen" href="<%= servlet %>?id=<%= idCliente %>&detalle=servicios">
          <span class="icono-opcion">★</span>
          <span class="texto-opcion">
                        <strong>Servicios contratados</strong>
                        <small><%= totalServicios %> servicio(s) registrados</small>
                    </span>
          <span class="flecha">›</span>
        </a>
        <a class="opcion-resumen" href="<%= servlet %>?id=<%= idCliente %>&detalle=contacto">
          <span class="icono-opcion">★</span>
          <span class="texto-opcion">
                        <strong>Contacto</strong>
                        <small><%= texto(correoCliente) %></small>
                    </span>
          <span class="flecha">›</span>
        </a>
        <a class="opcion-resumen" href="<%= servlet %>?id=<%= idCliente %>&detalle=estado">
          <span class="icono-opcion">★</span>
          <span class="texto-opcion">
                        <strong>Estado</strong>
                        <small><%= "activo".equals(estadoCliente) ? "Activo" : "Inactivo" %></small>
                    </span>
          <span class="flecha">›</span>
        </a>
      </div>
    </section>

    <% if (cliente != null && detalleSeleccionado != null) { %>
    <section class="panel-detalle">
      <div class="encabezado-detalle">
        <div>
          <p class="subtitulo-detalle">
            Cliente <%= texto(nombreCliente) %>
          </p>

          <h2>
            <% if ("solicitudes".equals(detalleSeleccionado)) { %>
            Solicitudes asociadas
            <% } else if ("servicios".equals(detalleSeleccionado)) { %>
            Servicios contratados
            <% } else if ("contacto".equals(detalleSeleccionado)) { %>
            Información de contacto
            <% } else { %>
            Estado del cliente
            <% } %>
          </h2>
        </div>

        <a class="cerrar-detalle"
           href="<%= servlet %>?id=<%= idCliente %>"
           aria-label="Cerrar detalle">×</a>
      </div>

      <div class="contenido-detalle">

        <% if ("solicitudes".equals(detalleSeleccionado)) { %>

        <% if (solicitudesCliente.isEmpty()) { %>
        <p>Este cliente todavía no tiene solicitudes registradas.</p>
        <% } else {
          for (Solicitud s : solicitudesCliente) {
            String claseEstado = "pendiente";

            if ("Rechazada".equals(s.getEstado())) {
              claseEstado = "desaprobada";
            } else if ("Aprobada".equals(s.getEstado())
              || "Provisionada".equals(s.getEstado())
              || "Activa".equals(s.getEstado())) {
              claseEstado = "aprobada";
            }
        %>
        <article class="tarjeta-detalle">
          <div>
            <strong>
              SOL-<%= s.getIdSolicitud() %> ·
              <%= texto(s.getNombreOrigen()) %> —
              <%= texto(s.getNombreDestino()) %>
            </strong>

            <p>
              Capacidad solicitada:
              <%= s.getCapacidadSolicitada() %> Gbps
            </p>

            <a class="enlace-ver-solicitud"
               href="${pageContext.request.contextPath}/SolicitudesServletSuper?id=<%= s.getIdSolicitud() %>#detalle-solicitud">
              Ver solicitud →
            </a>
          </div>

          <span class="badge <%= claseEstado %>">
                                <%= texto(s.getEstado()) %>
                            </span>
        </article>
        <%  }
        } %>

        <% } else if ("servicios".equals(detalleSeleccionado)) { %>

        <% if (serviciosCliente.isEmpty()) { %>
        <p>Este cliente todavía no tiene servicios registrados.</p>
        <% } else {
          for (Servicio servicio : serviciosCliente) {
            String claseEstado = "pendiente";

            if ("Activo".equals(servicio.getEstado())) {
              claseEstado = "activa";
            } else if ("Cancelado".equals(servicio.getEstado())) {
              claseEstado = "inactiva";
            }
        %>
        <article class="tarjeta-detalle servicio">

          <strong>
            SER-<%= servicio.getIdServicio() %>
          </strong>

          <div>
            <p>Solicitud</p>
            <strong>SOL-<%= servicio.getIdSolicitud() %></strong>
          </div>

          <div>
            <p>Ruta</p>
            <strong><%= texto(servicio.getNombreRuta()) %></strong>
          </div>

          <div>
            <p>Capacidad asignada</p>
            <strong><%= servicio.getCapacidadAsignada() %> Gbps</strong>
          </div>

          <div>
            <p>Estado</p>
            <span class="badge <%= claseEstado %>">
                                    <%= texto(servicio.getEstado()) %>
                                </span>
          </div>

          <a class="enlace-ver-solicitud"
             href="${pageContext.request.contextPath}/ServicioServletSuper?servicio=<%= servicio.getIdServicio() %>">
            Ver servicio →
          </a>

        </article>
        <%  }
        } %>

        <% } else if ("contacto".equals(detalleSeleccionado)) { %>

        <article class="tarjeta-detalle servicio">

          <div>
            <p>Empresa</p>
            <strong><%= texto(nombreCliente) %></strong>
          </div>

          <div>
            <p>Correo electrónico</p>
            <strong><%= texto(correoCliente) %></strong>
          </div>

          <div>
            <p>Teléfono</p>
            <strong><%= texto(telefonoCliente) %></strong>
          </div>

        </article>

        <% } else { %>

        <article class="tarjeta-detalle servicio">

          <div>
            <p>Cliente</p>
            <strong><%= texto(nombreCliente) %></strong>
          </div>

          <div>
            <p>Estado actual</p>
            <span class="badge <%= "activo".equals(estadoCliente)
                                    ? "activa" : "inactiva" %>">
                                <%= "activo".equals(estadoCliente) ? "Activo" : "Inactivo" %>
                            </span>
          </div>

        </article>

        <% } %>

      </div>
    </section>
    <% } %>
  </main>
</div>

<script>
  (() => {
    const lupa = document.getElementById('abrirBusquedaCliente');
    const campo = document.getElementById('buscarCliente');
    const lista = document.getElementById('listaClientes');
    const filas = lista.querySelectorAll('li[data-id]');
    const claveVista = location.pathname + ':vista-clientes';
    const cantidad = document.getElementById('cantidadClientes');
    const sinCoincidencias = document.getElementById('sinCoincidenciasClientes');

    const normalizar = texto => texto.trim().toLowerCase()
      .normalize('NFD').replace(/[\u0300-\u036f]/g, '');

    function filtrar() {
      const consulta = normalizar(campo.value);
      let visibles = 0;
      for (const fila of filas) {
        const coincide = normalizar(fila.dataset.nombre).startsWith(consulta);
        fila.hidden = !coincide;
        if (coincide) visibles++;
      }
      cantidad.textContent = visibles;
      sinCoincidencias.hidden = !consulta || visibles > 0;
    }

    function mostrarBusqueda(abrir) {
      campo.hidden = !abrir;
      lupa.setAttribute('aria-expanded', String(abrir));
      if (abrir) {
        campo.focus();
      } else {
        campo.value = '';
        filtrar();
        lupa.focus();
      }
    }

    lupa.addEventListener('click', () => mostrarBusqueda(campo.hidden));
    campo.addEventListener('input', filtrar);
    campo.addEventListener('blur', evento => {
      if (!campo.value.trim() && evento.relatedTarget !== lupa) {
        campo.hidden = true;
        lupa.setAttribute('aria-expanded', 'false');
      }
    });

    lista.addEventListener('click', evento => {
      const enlace = evento.target.closest('.cliente-enlace');
      if (!enlace || evento.ctrlKey || evento.metaKey || evento.shiftKey || evento.altKey) return;

      const destino = enlace.closest('li').dataset.id;
      try {
        sessionStorage.setItem(claveVista, JSON.stringify({
          destino,
          orden: Array.from(lista.querySelectorAll('li[data-id]'), fila => fila.dataset.id),
          desplazamiento: lista.scrollTop,
          consulta: campo.value,
          abierta: !campo.hidden
        }));
      } catch {
      }
    });

    let vista = null;
    try {
      vista = JSON.parse(sessionStorage.getItem(claveVista));
      sessionStorage.removeItem(claveVista);
    } catch {
    }

    const seleccionado = lista.querySelector('.cliente-seleccionado');
    if (vista && seleccionado && vista.destino === seleccionado.dataset.id) {
      const porId = new Map(Array.from(filas, fila => [fila.dataset.id, fila]));
      for (const id of vista.orden) {
        const fila = porId.get(id);
        if (fila) lista.appendChild(fila);
      }
      campo.value = vista.consulta;
      campo.hidden = !vista.abierta;
      lupa.setAttribute('aria-expanded', String(vista.abierta));
      filtrar();
      lista.scrollTop = vista.desplazamiento;
    }

    if (seleccionado && !seleccionado.hidden) {
      const limites = lista.getBoundingClientRect();
      const fila = seleccionado.getBoundingClientRect();
      if (fila.top < limites.top) {
        lista.scrollTop += fila.top - limites.top;
      } else if (fila.bottom > limites.bottom) {
        lista.scrollTop += fila.bottom - limites.bottom;
      }
    }
    campo.addEventListener('keydown', evento => {
      if (evento.key === 'Escape') {
        evento.preventDefault();
        mostrarBusqueda(false);
      }
    });
  })();
</script>
</body>
</html>
