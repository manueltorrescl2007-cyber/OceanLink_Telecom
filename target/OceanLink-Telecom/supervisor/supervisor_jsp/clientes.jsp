<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>

<%
    /*
     * Datos de prueba.
     * Posteriormente vendrán desde un Servlet y MySQL.
     */

    String clienteSeleccionado = request.getParameter("cliente");
    String registrarVisita = request.getParameter("visita");
    String detalleSeleccionado = request.getParameter("detalle");

    if (clienteSeleccionado == null) {
        clienteSeleccionado =
                (String) session.getAttribute("clienteSeleccionado");
    }

    if (clienteSeleccionado == null) {
        clienteSeleccionado = "pacifico";
    }

    /* Cantidad de selecciones guardadas en la sesión */

    Integer visitasPacifico =
            (Integer) session.getAttribute("visitasPacifico");

    Integer visitasMediterraneo =
            (Integer) session.getAttribute("visitasMediterraneo");

    Integer visitasAtlantico =
            (Integer) session.getAttribute("visitasAtlantico");

    if (visitasPacifico == null) {
        visitasPacifico = 0;
    }

    if (visitasMediterraneo == null) {
        visitasMediterraneo = 0;
    }

    if (visitasAtlantico == null) {
        visitasAtlantico = 0;
    }

    /*
     * La visita solo se registra cuando se presiona directamente
     * un cliente de la lista.
     */

    if ("1".equals(registrarVisita)) {

        switch (clienteSeleccionado) {

            case "mediterraneo":
                visitasMediterraneo++;
                break;

            case "atlantico":
                visitasAtlantico++;
                break;

            default:
                visitasPacifico++;
                break;
        }

        session.setAttribute(
                "visitasPacifico",
                visitasPacifico
        );

        session.setAttribute(
                "visitasMediterraneo",
                visitasMediterraneo
        );

        session.setAttribute(
                "visitasAtlantico",
                visitasAtlantico
        );
    }

    session.setAttribute(
            "clienteSeleccionado",
            clienteSeleccionado
    );

    /* Mapa con la cantidad de selecciones */

    Map<String, Integer> cantidadSelecciones =
            new HashMap<>();

    cantidadSelecciones.put(
            "pacifico",
            visitasPacifico
    );

    cantidadSelecciones.put(
            "mediterraneo",
            visitasMediterraneo
    );

    cantidadSelecciones.put(
            "atlantico",
            visitasAtlantico
    );

    /*
     * Orden original de los clientes.
     */

    List<String> ordenClientes = new ArrayList<>(
            Arrays.asList(
                    "pacifico",
                    "mediterraneo",
                    "atlantico"
            )
    );

    ordenClientes.sort((clienteA, clienteB) -> {

        int seleccionesA =
                cantidadSelecciones.get(clienteA);

        int seleccionesB =
                cantidadSelecciones.get(clienteB);

        boolean frecuenteA = seleccionesA >= 5;
        boolean frecuenteB = seleccionesB >= 5;

        if (frecuenteA && !frecuenteB) {
            return -1;
        }

        if (!frecuenteA && frecuenteB) {
            return 1;
        }

        if (frecuenteA && frecuenteB) {
            return Integer.compare(
                    seleccionesB,
                    seleccionesA
            );
        }

        return 0;
    });

    /*
         * Información del cliente seleccionado.
         */

        String idCliente;
        String nombreCliente;
        String tipoCliente;
        String contactoCliente;
        String correoCliente;
        String telefonoCliente;
        String estadoCliente;
        int totalSolicitudes;
        int totalServicios;

        switch (clienteSeleccionado) {

            case "atlantico":
                idCliente = "CLI-002";
                nombreCliente = "Atlántico";
                tipoCliente = "Empresa de telecomunicaciones";
                contactoCliente = "José Ramírez";
                correoCliente = "jose@atlantico.com";
                telefonoCliente = "+51 987 654 321";
                estadoCliente = "En evaluación";
                totalSolicitudes = 1;
                totalServicios = 1;
                break;

            case "mediterraneo":
                idCliente = "CLI-003";
                nombreCliente = "Mediterráneo";
                tipoCliente = "Empresa de red";
                contactoCliente = "Elena Vargas";
                correoCliente = "elena@mediterraneo.com";
                telefonoCliente = "+51 912 345 678";
                estadoCliente = "Activo";
                totalSolicitudes = 2;
                totalServicios = 1;
                break;

            default:
                clienteSeleccionado = "pacifico";
                idCliente = "CLI-001";
                nombreCliente = "Pacífico";
                tipoCliente = "Empresa de red";
                contactoCliente = "María Torres";
                correoCliente = "maria@pacifico.com";
                telefonoCliente = "+51 999 999 999";
                estadoCliente = "Activo";
                totalSolicitudes = 3;
                totalServicios = 2;
                break;
        }
    %>


<!DOCTYPE html>
<html lang="es">

<head>

    <meta charset="UTF-8">

    <meta
            name="viewport"
            content="width=device-width, initial-scale=1.0"
    >

    <title>OceanLink | Segmentos</title>

    <link
            rel="stylesheet"
            href="${pageContext.request.contextPath}/css/supervisor/clientes.css"
    >

</head>

<body>

  <input
          type="checkbox"
          id="controlMenu"
          class="control-menu"
    >

    <header class="barra-superior">

      <div class="zona-logo">

          <label
                  for="controlMenu"
                  class="boton-menu"
          >
              ☰
          </label>

          <a
                  href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/supervisor.jsp"
                  class="logo"
          >
              OceanLink
          </a>

      </div>

      <div class="usuario">

          <div class="foto-usuario">
              SU
          </div>

          <div>

              <p class="nombre-usuario">
                  Username
              </p>

              <p class="rol-usuario">
                  Supervisor
              </p>
          </div>
      </div>
    </header>

    <div class="contenedor">
      <!-- Barra lateral -->
      <aside class="menu-lateral">

        <div class="contenido-menu">

          <h2>Menú</h2>

          <nav class="navegacion-lateral">

            <!-- Dashboard -->
            <a href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/supervisor.jsp"
               class="activo">
                Dashboard general
            </a>

            <!-- Incidencias -->
            <div class="grupo-menu">

              <input
                type="checkbox"
                id="control-incidencias"
                class="control-submenu"
              >

              <label
                      for="control-incidencias"
                      class="titulo-grupo">

                <span class="texto-grupo">
                    Incidencias
                </span>

                <span class="flecha-submenu"></span>

              </label>


              <div class="contenido-submenu">

                <a
                        href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/visualizar.jsp"
                        class="subopcion">
                    Visualizar
                </a>

                <a
                        href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/historial_incidencias.jsp"
                        class="subopcion">
                    Historial de incidencias
                </a>
              </div>
            </div>

            <!-- Estado de la red -->
            <div class="grupo-menu">

              <input
                type="checkbox"
                id="controlEstadoRed"
                class="control-submenu"
              >

              <label
                      for="controlEstadoRed"
                      class="titulo-grupo">

                <span class="texto-grupo">
                    Estado de la red
                </span>

                <span class="flecha-submenu"></span>

              </label>


              <div class="contenido-submenu">

                <a
                        href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/capacidad.jsp"
                        class="subopcion">
                    Capacidad
                </a>

                <a
                        href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/segmentos.jsp"
                        class="subopcion">
                    Segmentos
                </a>
              </div>
            </div>

            <!-- Servicios y clientes -->
            <div class="grupo-menu">

              <input
                type="checkbox"
                id="control-servicios-clientes"
                class="control-submenu"
              >

              <label
                      for="control-servicios-clientes"
                      class="titulo-grupo">

                <span class="texto-grupo">
                    Servicios y clientes
                </span>

                <span class="flecha-submenu"></span>

              </label>


              <div class="contenido-submenu">

                <a
                        href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/clientes.jsp"
                        class="subopcion">
                    Clientes
                </a>

                <a
                        href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/servicios.jsp"
                        class="subopcion">
                    Servicios
                </a>
                <a
                        href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/solicitudes.jsp"
                        class="subopcion">
                    Solicitudes
                </a>
              </div>
            </div>

            <!-- Mantenimientos -->
            <div class="grupo-menu">

              <input
                type="checkbox"
                id="control-mantenimientos"
                class="control-submenu"
              >

              <label
                      for="control-mantenimientos"
                      class="titulo-grupo">

                <span class="texto-grupo">
                    Mantenimientos
                </span>

                <span class="flecha-submenu"></span>

              </label>

              <div class="contenido-submenu">

                <a
                        href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/programacion.jsp"
                        class="subopcion">
                    Programación
                </a>

                <a
                        href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/historial_programados.jsp"
                        class="subopcion">
                    Historial de programados
                </a>
              </div>
            </div>

            <!-- Reportes -->
            <a href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/reportes.jsp">
                Reportes
            </a>

            <!-- Históricos -->
            <a href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/historicos.jsp">
                Históricos
            </a>

          </nav>

        </div>


        <!-- parte baja -->
        <div class="configuracion">
          <nav>
            <h4>
              <a href="#">
                  Perfil
              </a>
            </h4>

            <h4>
              <a href="../../login.jsp">
                  Cerrar sesión
              </a>
            </h4>
          </nav>
        </div>
      </aside>


      <main class="contenido-principal">
        <main class="contenido-principal">

          <section class="encabezado-panel">
              <h2>Servicios y clientes</h2>
              <h1>Clientes</h1>
          </section>

          <section class="seccion-clientes">

            <!-- Lista de clientes -->
            <div class="panel-clientes">

              <div class="titulo-seccion">

                <div>
                    <h2>Clientes frecuentes</h2>
                </div>

                <span class="cantidad-clientes">
                    3
                </span>

              </div>

              <ul class="lista-clientes">
                <% for (String codigoCliente : ordenClientes) {

                    String inicialLista;
                    String nombreLista;
                    String tipoLista;
                    String serviciosLista;

                    switch (codigoCliente) {

                        case "mediterraneo":
                            inicialLista = "M";
                            nombreLista = "Mediterráneo";
                            tipoLista = "Empresa de red";
                            serviciosLista =
                                    "1 servicio contratado";
                            break;

                        case "atlantico":
                            inicialLista = "A";
                            nombreLista = "Atlántico";
                            tipoLista =
                                    "Empresa de telecomunicaciones";
                            serviciosLista =
                                    "1 servicio contratado";
                            break;

                        default:
                            inicialLista = "P";
                            nombreLista = "Pacífico";
                            tipoLista = "Empresa de red";
                            serviciosLista =
                                    "2 servicios contratados";
                            break;
                    }
                %>

                <li class="<%= clienteSeleccionado.equals(codigoCliente)
                        ? "cliente-seleccionado" : "" %>">

                    <a
                        class="cliente-enlace"
                        href="clientes.jsp?cliente=<%= codigoCliente %>&visita=1"
                    >
                        <span class="avatar-cliente">
                            <%= inicialLista %>
                        </span>

                        <span class="datos-cliente">

                            <strong>
                                <%= nombreLista %>
                            </strong>

                            <small>
                                <%= tipoLista %>
                            </small>

                            <small>
                                <%= serviciosLista %>
                            </small>

                        </span>
                    </a>

                </li>

                <% } %>

              </ul>

              </div>

              <!-- Resumen -->
              <div class="panel-resumen">
                  <div class="encabezado-resumen">
                      <span class="etiqueta-resumen">Resumen</span>

                      <strong class="titulo-resumen">
                          Identificadores
                      </strong>
                  </div>
                  <!-- Solicitudes -->
                  <a
                      class="opcion-resumen"
                      href="clientes.jsp?cliente=<%= clienteSeleccionado %>&detalle=solicitudes"
                  >
                      <span class="icono-opcion">★</span>

                      <span class="texto-opcion">

                          <strong>
                              Solicitudes asociadas
                          </strong>

                          <small>
                              <%= totalSolicitudes %>
                              <%= totalSolicitudes == 1
                                      ? "solicitud registrada"
                                      : "solicitudes registradas" %>
                          </small>

                      </span>

                      <span class="flecha">›</span>
                  </a>

                  <!-- Servicios -->
                  <a
                      class="opcion-resumen"
                      href="clientes.jsp?cliente=<%= clienteSeleccionado %>&detalle=servicios"
                  >
                      <span class="icono-opcion">★</span>

                      <span class="texto-opcion">

                          <strong>
                              Servicios contratados
                          </strong>

                          <small>
                              <%= totalServicios %>
                              <%= totalServicios == 1
                                      ? "servicio contratado"
                                      : "servicios contratados" %>
                          </small>

                      </span>

                      <span class="flecha">›</span>
                  </a>

                  <!-- Contacto -->
                  <a
                      class="opcion-resumen"
                      href="clientes.jsp?cliente=<%= clienteSeleccionado %>&detalle=contacto"
                  >
                      <span class="icono-opcion">★</span>

                      <span class="texto-opcion">

                          <strong>
                              Contacto
                          </strong>

                          <small>
                              <%= contactoCliente %>
                          </small>

                      </span>

                      <span class="flecha">›</span>
                  </a>

                  <!-- Estado -->
                  <a
                      class="opcion-resumen"
                      href="clientes.jsp?cliente=<%= clienteSeleccionado %>&detalle=estado"
                  >
                      <span class="icono-opcion">★</span>

                      <span class="texto-opcion">

                          <strong>
                              Estado
                          </strong>

                          <small>
                              <%= estadoCliente %>
                          </small>

                      </span>

                      <span class="flecha">›</span>
                  </a>

              </div>

          </section>

            <!-- Panel de detalle -->
            <% if (detalleSeleccionado != null) { %>

            <section class="panel-detalle">

                <div class="encabezado-detalle">

                    <div>

                        <p class="subtitulo-detalle">
                            Cliente <%= nombreCliente %>
                        </p>

                        <h2>
                            <%
                                switch (detalleSeleccionado) {

                                    case "servicios":
                                        out.print(
                                                "Servicios contratados"
                                        );
                                        break;

                                    case "contacto":
                                        out.print(
                                                "Información de contacto"
                                        );
                                        break;

                                    case "estado":
                                        out.print(
                                                "Estado del cliente"
                                        );
                                        break;

                                    default:
                                        out.print(
                                                "Solicitudes asociadas"
                                        );
                                        break;
                                }
                            %>
                        </h2>

                    </div>

                    <a
                        class="cerrar-detalle"
                        href="clientes.jsp?cliente=<%= clienteSeleccionado %>"
                        aria-label="Cerrar detalle"
                    >
                        &times;
                    </a>

                </div>

                <div class="contenido-detalle">

                    <!-- Solicitudes asociadas -->
                    <% if (detalleSeleccionado.equals("solicitudes")) { %>

                        <% if (clienteSeleccionado.equals("pacifico")) { %>

                        <article class="tarjeta-detalle">

                            <div>
                                <strong>
                                    SOL-001 · Lima — Valparaíso
                                </strong>

                                <p>
                                    Capacidad solicitada: 50 Gbps
                                </p>
                            </div>

                            <span class="badge pendiente">
                                Pendiente
                            </span>

                        </article>

                        <article class="tarjeta-detalle">

                            <div>
                                <strong>
                                    SOL-006 · Lima — Madrid
                                </strong>

                                <p>
                                    Capacidad solicitada: 20 Gbps
                                </p>
                            </div>

                            <span class="badge aprobada">
                                Aprobada
                            </span>

                        </article>

                        <article class="tarjeta-detalle">

                            <div>
                                <strong>
                                    SOL-011 · Callao — Miami
                                </strong>

                                <p>
                                    Capacidad solicitada: 10 Gbps
                                </p>
                            </div>

                            <span class="badge desaprobada">
                                Desaprobada
                            </span>

                        </article>

                        <% } else if (clienteSeleccionado.equals("mediterraneo")) { %>

                        <article class="tarjeta-detalle">

                            <div>
                                <strong>
                                    SOL-018 · Lima — Barcelona
                                </strong>

                                <p>
                                    Capacidad solicitada: 30 Gbps
                                </p>
                            </div>

                            <span class="badge pendiente">
                                Pendiente
                            </span>

                        </article>

                        <article class="tarjeta-detalle">

                            <div>
                                <strong>
                                    SOL-021 · Callao — Roma
                                </strong>

                                <p>
                                    Capacidad solicitada: 15 Gbps
                                </p>
                            </div>

                            <span class="badge aprobada">
                                Aprobada
                            </span>

                        </article>

                        <% } else { %>

                        <article class="tarjeta-detalle">

                            <div>
                                <strong>
                                    SOL-015 · Lima — Lisboa
                                </strong>

                                <p>
                                    Capacidad solicitada: 25 Gbps
                                </p>
                            </div>

                            <span class="badge pendiente">
                                Pendiente
                            </span>

                        </article>

                        <% } %>

                    <!-- Servicios contratados -->
                    <% } else if (detalleSeleccionado.equals("servicios")) { %>

                        <% if (clienteSeleccionado.equals("pacifico")) { %>

                        <article class="tarjeta-detalle servicio">

                            <strong>SER-008</strong>

                            <p>
                                <b>Ruta:</b> Lima — España
                            </p>

                            <p>
                                <b>Capacidad contratada:</b>
                                80 Mbps
                            </p>

                            <p>
                                <b>Riesgo de la ruta:</b>
                                Medio
                            </p>

                            <p>
                                <b>Estado:</b>
                                <span class="badge activa">
                                    Activo
                                </span>
                            </p>

                        </article>

                        <article class="tarjeta-detalle servicio">

                            <strong>SER-012</strong>

                            <p>
                                <b>Ruta:</b> Lima — Valparaíso
                            </p>

                            <p>
                                <b>Capacidad contratada:</b>
                                100 Mbps
                            </p>

                            <p>
                                <b>Riesgo de la ruta:</b>
                                Bajo
                            </p>

                            <p>
                                <b>Estado:</b>
                                <span class="badge activa">
                                    Activo
                                </span>
                            </p>

                        </article>

                        <% } else if (clienteSeleccionado.equals("mediterraneo")) { %>

                        <article class="tarjeta-detalle servicio">

                            <strong>SER-016</strong>

                            <p>
                                <b>Ruta:</b> Lima — Barcelona
                            </p>

                            <p>
                                <b>Capacidad contratada:</b>
                                40 Mbps
                            </p>

                            <p>
                                <b>Riesgo de la ruta:</b>
                                Medio
                            </p>

                            <p>
                                <b>Estado:</b>
                                <span class="badge activa">
                                    Activo
                                </span>
                            </p>

                        </article>

                        <% } else { %>

                        <article class="tarjeta-detalle servicio">

                            <strong>SER-015</strong>

                            <p>
                                <b>Ruta:</b> Lima — Lisboa
                            </p>

                            <p>
                                <b>Capacidad contratada:</b>
                                200 Mbps
                            </p>

                            <p>
                                <b>Riesgo de la ruta:</b>
                                Alto
                            </p>

                            <p>
                                <b>Estado:</b>
                                <span class="badge inactiva">
                                    Inactivo
                                </span>
                            </p>

                        </article>

                        <% } %>

                    <!-- Contacto -->
                    <% } else if (detalleSeleccionado.equals("contacto")) { %>

                        <article class="tarjeta-detalle contacto">

                            <p>
                                <b>Responsable:</b>
                                <%= contactoCliente %>
                            </p>

                            <p>
                                <b>Correo electrónico:</b>
                                <%= correoCliente %>
                            </p>

                            <p>
                                <b>Teléfono:</b>
                                <%= telefonoCliente %>
                            </p>

                            <p>
                                <b>Empresa:</b>
                                <%= nombreCliente %>
                            </p>

                        </article>

                    <!-- Estado -->
                    <% } else if (detalleSeleccionado.equals("estado")) { %>

                        <article class="tarjeta-detalle contacto">

                            <p>
                                <b>Identificador:</b>
                                <%= idCliente %>
                            </p>

                            <p>
                                <b>Empresa:</b>
                                <%= nombreCliente %>
                            </p>

                            <p>
                                <b>Tipo:</b>
                                <%= tipoCliente %>
                            </p>

                            <p>
                                <b>Estado actual:</b>

                                <span class="badge <%= estadoCliente.equals("Activo")
                                        ? "activa" : "evaluacion" %>">
                                    <%= estadoCliente %>
                                </span>
                            </p>

                        </article>
                    <% } %>
                </div>
            </section>
            <% } %>
      </main>
    </div>
</body>

</html>
