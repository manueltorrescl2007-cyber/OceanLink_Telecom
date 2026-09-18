<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="java.util.Map" %>

<%!
    private Map<String, String> crearServicio(
            String id,
            String cliente,
            String origen,
            String destino,
            String capacidad,
            String ruta,
            String estado,
            String fecha,
            String riesgo) {

        Map<String, String> servicio = new LinkedHashMap<>();

        servicio.put("id", id);
        servicio.put("cliente", cliente);
        servicio.put("origen", origen);
        servicio.put("destino", destino);
        servicio.put("capacidad", capacidad);
        servicio.put("ruta", ruta);
        servicio.put("estado", estado);
        servicio.put("fecha", fecha);
        servicio.put("riesgo", riesgo);

        return servicio;
    }

    private double convertirNumero(String valor) {

        try {
            return Double.parseDouble(valor);
        } catch (Exception e) {
            return 0;
        }
    }
%>

<%
    request.setCharacterEncoding("UTF-8");

    /*
     * Clientes registrados desde clientes.jsp.
     */
    ArrayList<Map<String, String>> clientesDisponibles =
            (ArrayList<Map<String, String>>)
                    session.getAttribute("clientes");

    /*
     * Clientes de prueba si todavía no se abrió clientes.jsp.
     */
    if (clientesDisponibles == null) {

        clientesDisponibles = new ArrayList<>();

        Map<String, String> cliente1 = new LinkedHashMap<>();
        cliente1.put("id", "CLI-001");
        cliente1.put("nombre", "Pacífico");
        clientesDisponibles.add(cliente1);

        Map<String, String> cliente2 = new LinkedHashMap<>();
        cliente2.put("id", "CLI-002");
        cliente2.put("nombre", "Atlántico");
        clientesDisponibles.add(cliente2);

        Map<String, String> cliente3 = new LinkedHashMap<>();
        cliente3.put("id", "CLI-003");
        cliente3.put("nombre", "Mediterráneo");
        clientesDisponibles.add(cliente3);
    }

    /*
     * Capacidad máxima de cada ruta.
     */
    Map<String, Double> capacidadRutas =
            new LinkedHashMap<>();

    capacidadRutas.put("RUT-001", 100.0);
    capacidadRutas.put("RUT-002", 50.0);
    capacidadRutas.put("RUT-003", 30.0);

    /*
     * Lista de servicios guardada en la sesión.
     */
    ArrayList<Map<String, String>> servicios =
            (ArrayList<Map<String, String>>)
                    session.getAttribute("servicios");

    /*
     * Casos de prueba iniciales.
     */
    if (servicios == null) {

        servicios = new ArrayList<>();

        servicios.add(crearServicio(
                "SER-001",
                "Pacífico",
                "Lima",
                "Valparaíso",
                "50",
                "RUT-001",
                "Activo",
                "2026-09-12",
                "Posible aumento del tráfico durante horas punta."
        ));

        servicios.add(crearServicio(
                "SER-002",
                "Mediterráneo",
                "Lima",
                "Valparaíso",
                "45",
                "RUT-001",
                "Activo",
                "2026-09-13",
                "La ruta se encuentra cerca de su capacidad máxima."
        ));

        servicios.add(crearServicio(
                "SER-003",
                "Atlántico",
                "Callao",
                "Barcelona",
                "20",
                "RUT-002",
                "Activo",
                "2026-09-14",
                "Posible congestión durante mantenimientos programados."
        ));

        servicios.add(crearServicio(
                "SER-004",
                "Mediterráneo",
                "Lima",
                "Valparaíso",
                "10",
                "RUT-001",
                "Límite",
                "2026-09-17",
                "No puede activarse porque la ruta ya está al límite."
        ));

        session.setAttribute("servicios", servicios);
    }

    /*
     * Convertimos estados antiguos a Límite.
     */
    for (Map<String, String> servicio : servicios) {

        String estadoAnterior = servicio.get("estado");

        if ("Pendiente".equals(estadoAnterior)
                || "Provisionado".equals(estadoAnterior)) {

            servicio.put("estado", "Límite");
        }

        if (servicio.get("riesgo") == null) {
            servicio.put("riesgo", "");
        }
    }

    /*
     * Procesamiento de los formularios.
     */
    if ("POST".equalsIgnoreCase(request.getMethod())) {

        String accion = request.getParameter("accion");

        /*
         * Crear o editar servicio.
         */
        if ("guardar".equals(accion)) {

            String id = request.getParameter("idServicio");
            String cliente = request.getParameter("cliente");
            String origen = request.getParameter("origen");
            String destino = request.getParameter("destino");
            String capacidad = request.getParameter("capacidad");
            String ruta = request.getParameter("ruta");
            String estadoSolicitado =
                    request.getParameter("estado");
            String fecha = request.getParameter("fecha");
            String riesgo = request.getParameter("riesgo");

            boolean nuevoServicio =
                    id == null || id.trim().isEmpty();

            /*
             * Generación automática de ID.
             */
            if (nuevoServicio) {

                int siguienteNumero = 1;

                for (Map<String, String> servicio : servicios) {

                    String numeroTexto =
                            servicio.get("id")
                                    .replace("SER-", "");

                    try {

                        int numero =
                                Integer.parseInt(numeroTexto);

                        if (numero >= siguienteNumero) {
                            siguienteNumero = numero + 1;
                        }

                    } catch (NumberFormatException ignored) {
                    }
                }

                id = String.format(
                        "SER-%03d",
                        siguienteNumero
                );
            }

            double capacidadSolicitada =
                    convertirNumero(capacidad);

            double capacidadOcupada = 0;

            /*
             * Se suman únicamente los servicios activos
             * que pertenecen a la misma ruta.
             *
             * Los servicios Límite y Cancelados no consumen
             * capacidad.
             */
            for (Map<String, String> servicio : servicios) {

                boolean mismoServicio =
                        id.equals(servicio.get("id"));

                boolean mismaRuta =
                        ruta.equals(servicio.get("ruta"));

                boolean servicioActivo =
                        "Activo".equals(
                                servicio.get("estado")
                        );

                if (!mismoServicio
                        && mismaRuta
                        && servicioActivo) {

                    capacidadOcupada += convertirNumero(
                            servicio.get("capacidad")
                    );
                }
            }

            double capacidadMaxima =
                    capacidadRutas.getOrDefault(
                            ruta,
                            100.0
                    );

            double limitePreventivo =
                    capacidadMaxima * 0.90;

            String estadoFinal = estadoSolicitado;

            /*
             * Regla de capacidad:
             *
             * Si la ruta ya tiene 90 % o más ocupado,
             * no se activa otro servicio.
             *
             * Tampoco se activa si la nueva capacidad
             * supera el máximo permitido.
             */
            if ("Activo".equals(estadoSolicitado)
                    && (capacidadOcupada >= limitePreventivo
                    || capacidadOcupada
                    + capacidadSolicitada
                    > capacidadMaxima)) {

                estadoFinal = "Límite";
            }

            Map<String, String> servicioEncontrado = null;

            for (Map<String, String> servicio : servicios) {

                if (id.equals(servicio.get("id"))) {
                    servicioEncontrado = servicio;
                    break;
                }
            }

            /*
             * Crear nuevo servicio.
             */
            if (servicioEncontrado == null) {

                servicios.add(crearServicio(
                        id,
                        cliente,
                        origen,
                        destino,
                        capacidad,
                        ruta,
                        estadoFinal,
                        fecha,
                        riesgo
                ));

            /*
             * Editar servicio existente.
             */
            } else {

                servicioEncontrado.put(
                        "cliente",
                        cliente
                );

                servicioEncontrado.put(
                        "origen",
                        origen
                );

                servicioEncontrado.put(
                        "destino",
                        destino
                );

                servicioEncontrado.put(
                        "capacidad",
                        capacidad
                );

                servicioEncontrado.put(
                        "ruta",
                        ruta
                );

                servicioEncontrado.put(
                        "estado",
                        estadoFinal
                );

                servicioEncontrado.put(
                        "fecha",
                        fecha
                );

                servicioEncontrado.put(
                        "riesgo",
                        riesgo
                );
            }

            session.setAttribute(
                    "servicios",
                    servicios
            );

            response.sendRedirect(
                    request.getContextPath()
                            + request.getServletPath()
                            + "?servicio="
                            + id
            );

            return;
        }

        /*
         * Eliminar servicio.
         */
        if ("eliminar".equals(accion)) {

            String id =
                    request.getParameter("idServicio");

            for (int i = 0;
                 i < servicios.size();
                 i++) {

                if (id.equals(
                        servicios.get(i).get("id"))) {

                    servicios.remove(i);
                    break;
                }
            }

            session.setAttribute(
                    "servicios",
                    servicios
            );

            response.sendRedirect(
                    request.getContextPath()
                            + request.getServletPath()
            );

            return;
        }

        /*
         * Cambiar estado.
         */
        if ("cambiarEstado".equals(accion)) {

            String id =
                    request.getParameter("idServicio");

            String nuevoEstado =
                    request.getParameter("nuevoEstado");

            for (Map<String, String> servicio : servicios) {

                if (!id.equals(servicio.get("id"))) {
                    continue;
                }

                /*
                 * Cancelar un servicio libera su capacidad.
                 */
                if ("Cancelado".equals(nuevoEstado)) {

                    servicio.put(
                            "estado",
                            "Cancelado"
                    );

                    break;
                }

                /*
                 * Intentar activar el servicio.
                 */
                if ("Activo".equals(nuevoEstado)) {

                    String ruta = servicio.get("ruta");

                    double capacidadOcupada = 0;

                    for (Map<String, String> otro
                            : servicios) {

                        boolean esOtroServicio =
                                !id.equals(
                                        otro.get("id")
                                );

                        boolean mismaRuta =
                                ruta.equals(
                                        otro.get("ruta")
                                );

                        boolean servicioActivo =
                                "Activo".equals(
                                        otro.get("estado")
                                );

                        if (esOtroServicio
                                && mismaRuta
                                && servicioActivo) {

                            capacidadOcupada +=
                                    convertirNumero(
                                            otro.get(
                                                    "capacidad"
                                            )
                                    );
                        }
                    }

                    double capacidadSolicitada =
                            convertirNumero(
                                    servicio.get(
                                            "capacidad"
                                    )
                            );

                    double capacidadMaxima =
                            capacidadRutas.getOrDefault(
                                    ruta,
                                    100.0
                            );

                    double limitePreventivo =
                            capacidadMaxima * 0.90;

                    if (capacidadOcupada
                            >= limitePreventivo
                            || capacidadOcupada
                            + capacidadSolicitada
                            > capacidadMaxima) {

                        servicio.put(
                                "estado",
                                "Límite"
                        );

                    } else {

                        servicio.put(
                                "estado",
                                "Activo"
                        );
                    }

                    break;
                }
            }

            session.setAttribute(
                    "servicios",
                    servicios
            );

            response.sendRedirect(
                    request.getContextPath()
                            + request.getServletPath()
                            + "?servicio="
                            + id
            );

            return;
        }
    }

    /*
     * Filtro.
     */
    String filtroEstado =
            request.getParameter("estado");

    if (filtroEstado == null
            || filtroEstado.trim().isEmpty()) {

        filtroEstado = "Todos";
    }

    /*
     * Servicio seleccionado.
     */
    String idSeleccionado =
            request.getParameter("servicio");

    String ventana =
            request.getParameter("ventana");

    Map<String, String> servicioSeleccionado = null;
    Map<String, String> servicioEditar = null;

    int cantidadVisible = 0;

    for (Map<String, String> servicio : servicios) {

        if ("Todos".equals(filtroEstado)
                || filtroEstado.equals(
                        servicio.get("estado")
                )) {

            cantidadVisible++;
        }

        if (idSeleccionado != null
                && idSeleccionado.equals(
                        servicio.get("id")
                )) {

            servicioSeleccionado = servicio;
        }

        if ("editar".equals(ventana)
                && idSeleccionado != null
                && idSeleccionado.equals(
                        servicio.get("id")
                )) {

            servicioEditar = servicio;
        }
    }

    boolean mostrarFormulario =
            "nuevo".equals(ventana)
                    || "editar".equals(ventana);
%>

<!doctype html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>OceanLink | Dashboard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/supervisor/servicios.css">
</head>

<body>

<!-- Control para abrir/cerrar el menú -->
<input
  type="checkbox"
  id="controlMenu"
  class="control-menu"
>

<!-- Barra superior -->
<header class="barra-superior">

  <div class="zona-logo">

    <label
            for="controlMenu"
            class="boton-menu">
        ☰
    </label>

    <a href="${pageContext.request.contextPath}/supervisor/supervisor_jsp/supervisor.jsp"
       class="logo">
        OceanLink
    </a>
  </div>

  <div class="usuario">

    <div class="foto-usuario">
        SU
    </div>

    <div>
        <p class="nombre-usuario">Username</p>
        <p class="rol-usuario">Supervisor</p>
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
          <a href="#">
              Cerrar sesión
          </a>
        </h4>
      </nav>
    </div>
  </aside>

    <!-- Contenido principal -->
    <main class="contenido-principal pagina-servicios">

            <section class="encabezado-pagina">

                <div class="encabezado-panel">

                    <h2>Servicios y clientes</h2>
                    <h1>Servicios</h1>

                </div>

            </section>

            <!-- Filtro -->

            <section class="barra-herramientas">

                <form
                    method="get"
                    action="servicios.jsp"
                    class="formulario-filtro"
                >

                    <label for="estado">
                        Estado:
                    </label>

                    <select
                        id="estado"
                        name="estado"
                        onchange="this.form.submit()"
                    >

                        <option
                            value="Todos"
                            <%= "Todos".equals(
                                    filtroEstado
                            ) ? "selected" : "" %>
                        >
                            Todos
                        </option>

                        <option
                            value="Activo"
                            <%= "Activo".equals(
                                    filtroEstado
                            ) ? "selected" : "" %>
                        >
                            Activo
                        </option>

                        <option
                            value="Límite"
                            <%= "Límite".equals(
                                    filtroEstado
                            ) ? "selected" : "" %>
                        >
                            Límite
                        </option>

                        <option
                            value="Cancelado"
                            <%= "Cancelado".equals(
                                    filtroEstado
                            ) ? "selected" : "" %>
                        >
                            Cancelado
                        </option>

                    </select>

                </form>

                <span class="cantidad-registros">

                    <%= cantidadVisible %>

                    <%= cantidadVisible == 1
                            ? "servicio"
                            : "servicios" %>

                </span>

            </section>

            <!-- Tabla -->

            <section class="contenedor-tabla">

                <table class="tabla-servicios">

                    <thead>

                    <tr>
                        <th>ID</th>
                        <th>Cliente</th>
                        <th>Origen</th>
                        <th>Destino</th>
                        <th>Capacidad</th>
                        <th>Ruta</th>
                        <th>Estado</th>
                    </tr>

                    </thead>

                    <tbody>

                    <%
                        for (Map<String, String> servicio
                                : servicios) {

                            boolean visible =
                                    "Todos".equals(
                                            filtroEstado
                                    )
                                    || filtroEstado.equals(
                                            servicio.get(
                                                    "estado"
                                            )
                                    );

                            if (!visible) {
                                continue;
                            }

                            boolean seleccionado =
                                    servicio.get("id")
                                            .equals(
                                                    idSeleccionado
                                            );

                            String claseEstado =
                                    servicio.get("estado")
                                            .toLowerCase()
                                            .replace("í", "i")
                                            .replace(" ", "-");
                    %>

                    <tr
                        class="fila-servicio
                        <%= seleccionado
                                ? "seleccionada"
                                : "" %>"

                        onclick="window.location.href=
                        'servicios.jsp?estado=<%= filtroEstado %>&servicio=<%= servicio.get("id") %>'"
                    >

                        <td>
                            <strong>
                                <%= servicio.get("id") %>
                            </strong>
                        </td>

                        <td>
                            <%= servicio.get("cliente") %>
                        </td>

                        <td>
                            <%= servicio.get("origen") %>
                        </td>

                        <td>
                            <%= servicio.get("destino") %>
                        </td>

                        <td>
                            <%= servicio.get("capacidad") %>
                            Gbps
                        </td>

                        <td>
                            <%= servicio.get("ruta") %>
                        </td>

                        <td>

                            <div
                                class="estado-servicio
                                <%= claseEstado %>"
                            >

                                <span class="punto-estado"></span>

                                <span>
                                    <%= servicio.get("estado") %>
                                </span>

                            </div>

                        </td>

                    </tr>

                    <% } %>

                    <% if (cantidadVisible == 0) { %>

                    <tr>
                        <td
                            colspan="7"
                            class="sin-resultados"
                        >
                            No existen servicios con ese estado.
                        </td>
                    </tr>

                    <% } %>

                    </tbody>

                </table>

            </section>

            <!-- Detalle -->

            <% if (servicioSeleccionado != null) {

                String claseDetalle =
                        servicioSeleccionado.get("estado")
                                .toLowerCase()
                                .replace("í", "i")
                                .replace(" ", "-");
            %>

            <section class="panel-detalle">

                <div class="encabezado-detalle">

                    <div>

                        <p>Detalle del servicio</p>

                        <h2>
                            <%= servicioSeleccionado.get("id") %>
                        </h2>

                    </div>

                    <a
                        href="servicios.jsp"
                        class="cerrar-detalle"
                    >
                        &times;
                    </a>

                </div>

                <div class="contenido-detalle">

                    <div class="dato-detalle">

                        <span>Cliente</span>

                        <strong>
                            <%= servicioSeleccionado
                                    .get("cliente") %>
                        </strong>

                    </div>

                    <div class="dato-detalle">

                        <span>Fecha de registro</span>

                        <strong>
                            <%= servicioSeleccionado
                                    .get("fecha") %>
                        </strong>

                    </div>

                    <div class="dato-detalle">

                        <span>Ruta asignada</span>

                        <strong>
                            <%= servicioSeleccionado
                                    .get("ruta") %>
                        </strong>

                    </div>

                    <div class="dato-detalle">

                        <span>Capacidad contratada</span>

                        <strong>
                            <%= servicioSeleccionado
                                    .get("capacidad") %>
                            Gbps
                        </strong>

                    </div>

                    <div class="dato-detalle">

                        <span>Origen</span>

                        <strong>
                            <%= servicioSeleccionado
                                    .get("origen") %>
                        </strong>

                    </div>

                    <div class="dato-detalle">

                        <span>Destino</span>

                        <strong>
                            <%= servicioSeleccionado
                                    .get("destino") %>
                        </strong>

                    </div>

                    <div class="dato-detalle">

                        <span>Estado</span>

                        <strong
                            class="texto-estado
                            <%= claseDetalle %>"
                        >
                            <%= servicioSeleccionado
                                    .get("estado") %>
                        </strong>

                    </div>

                </div>

                <!-- Riesgos -->

                <div class="apartado-riesgos">

                    <span>Riesgos</span>

                    <p>
                        <%
                            String riesgoSeleccionado =
                                    servicioSeleccionado
                                            .get("riesgo");

                            if (riesgoSeleccionado == null
                                    || riesgoSeleccionado
                                    .trim().isEmpty()) {
                        %>

                        No se registraron riesgos para este servicio.

                        <% } else { %>

                        <%= riesgoSeleccionado %>

                        <% } %>
                    </p>

                </div>

                <!-- Acciones -->

                <div class="acciones-detalle">

                    <a
                        href="servicios.jsp?servicio=<%= servicioSeleccionado.get("id") %>&ventana=editar"
                        class="boton secundario"
                    >
                        Editar servicio
                    </a>

                    <% if (!"Activo".equals(
                            servicioSeleccionado
                                    .get("estado"))) { %>

                    <form
                        method="post"
                        action="servicios.jsp"
                    >

                        <input
                            type="hidden"
                            name="accion"
                            value="cambiarEstado"
                        >

                        <input
                            type="hidden"
                            name="idServicio"
                            value="<%= servicioSeleccionado.get("id") %>"
                        >

                        <input
                            type="hidden"
                            name="nuevoEstado"
                            value="Activo"
                        >

                        <button
                            type="submit"
                            class="boton primario"
                        >
                            Intentar activar
                        </button>

                    </form>

                    <% } %>

                    <% if (!"Cancelado".equals(
                            servicioSeleccionado
                                    .get("estado"))) { %>

                    <form
                        method="post"
                        action="servicios.jsp"
                        onsubmit="return confirm(
                        '¿Seguro que desea cancelar este servicio?'
                        )"
                    >

                        <input
                            type="hidden"
                            name="accion"
                            value="cambiarEstado"
                        >

                        <input
                            type="hidden"
                            name="idServicio"
                            value="<%= servicioSeleccionado.get("id") %>"
                        >

                        <input
                            type="hidden"
                            name="nuevoEstado"
                            value="Cancelado"
                        >

                        <button
                            type="submit"
                            class="boton cancelar"
                        >
                            Cancelar servicio
                        </button>

                    </form>

                    <% } %>

                    <form
                        method="post"
                        action="servicios.jsp"
                        onsubmit="return confirm(
                        '¿Seguro que desea eliminar este servicio?'
                        )"
                    >

                        <input
                            type="hidden"
                            name="accion"
                            value="eliminar"
                        >

                        <input
                            type="hidden"
                            name="idServicio"
                            value="<%= servicioSeleccionado.get("id") %>"
                        >

                        <button
                            type="submit"
                            class="boton peligro"
                        >
                            Eliminar servicio
                        </button>

                    </form>

                </div>

            </section>

            <% } %>

        </main>
  </div>
</body>

</html>
