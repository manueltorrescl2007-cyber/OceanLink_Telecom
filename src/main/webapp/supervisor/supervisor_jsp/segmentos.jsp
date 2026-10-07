<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="java.util.Map" %>

<%!
    private Map<String, String> crearSegmento(
            String id,
            String ruta,
            String origen,
            String destino,
            String capacidadTotal,
            String capacidadUsada,
            String riesgo) {

        Map<String, String> segmento = new LinkedHashMap<>();

        double total = Double.parseDouble(capacidadTotal);
        double usada = Double.parseDouble(capacidadUsada);
        double disponible = total - usada;
        double porcentaje = (usada / total) * 100;

        String estado;

        if (porcentaje >= 95) {
            estado = "Insuficiente";
        } else if (porcentaje >= 80) {
            estado = "Limitada";
        } else {
            estado = "Disponible";
        }

        segmento.put("id", id);
        segmento.put("ruta", ruta);
        segmento.put("origen", origen);
        segmento.put("destino", destino);
        segmento.put("capacidadTotal", capacidadTotal);
        segmento.put("capacidadUsada", capacidadUsada);
        segmento.put(
                "capacidadDisponible",
                String.valueOf(disponible)
        );
        segmento.put(
                "porcentaje",
                String.format("%.0f", porcentaje)
        );
        segmento.put("estado", estado);
        segmento.put("riesgo", riesgo);

        return segmento;
    }
%>

<%
    ArrayList<Map<String, String>> segmentos =
            (ArrayList<Map<String, String>>)
                    session.getAttribute("segmentosSupervisor");

    if (segmentos == null) {

        segmentos = new ArrayList<>();

        segmentos.add(crearSegmento(
                "LIM-VLP-01",
                "RUT-001",
                "Lima",
                "Valparaíso",
                "100",
                "50",
                "Operación normal."
        ));

        segmentos.add(crearSegmento(
                "LIM-VLP-02",
                "RUT-001",
                "Lima",
                "Valparaíso",
                "100",
                "65",
                "Sin riesgos importantes registrados."
        ));

        segmentos.add(crearSegmento(
                "CAL-BCN-01",
                "RUT-002",
                "Callao",
                "Barcelona",
                "100",
                "70",
                "Uso elevado durante las horas punta."
        ));

        segmentos.add(crearSegmento(
                "CAL-BCN-02",
                "RUT-002",
                "Callao",
                "Barcelona",
                "100",
                "78",
                "Posible congestión por aumento del tráfico."
        ));

        segmentos.add(crearSegmento(
                "CAL-BCN-03",
                "RUT-002",
                "Callao",
                "Barcelona",
                "100",
                "85",
                "Capacidad cercana al límite."
        ));

        segmentos.add(crearSegmento(
                "CAL-BCN-04",
                "RUT-002",
                "Callao",
                "Barcelona",
                "100",
                "92",
                "Segmento con solamente 8 Gbps disponibles."
        ));

        segmentos.add(crearSegmento(
                "CAL-BCN-05",
                "RUT-002",
                "Callao",
                "Barcelona",
                "100",
                "88",
                "Requiere seguimiento periódico."
        ));

        segmentos.add(crearSegmento(
                "LIM-MIA-01",
                "RUT-003",
                "Lima",
                "Miami",
                "100",
                "80",
                "Tráfico elevado."
        ));

        segmentos.add(crearSegmento(
                "LIM-MIA-02",
                "RUT-003",
                "Lima",
                "Miami",
                "100",
                "90",
                "Capacidad muy limitada."
        ));

        segmentos.add(crearSegmento(
                "LIM-MIA-03",
                "RUT-003",
                "Lima",
                "Miami",
                "100",
                "106",
                "La demanda supera la capacidad en 6 Gbps."
        ));

        segmentos.add(crearSegmento(
                "LIM-MIA-04",
                "RUT-003",
                "Lima",
                "Miami",
                "100",
                "95",
                "Segmento en su máxima capacidad."
        ));

        session.setAttribute("segmentosSupervisor", segmentos);
    }

    String filtroEstado = request.getParameter("estado");

    if (filtroEstado == null || filtroEstado.trim().isEmpty()) {
        filtroEstado = "Todos";
    }

    String idSeleccionado = request.getParameter("segmento");

    Map<String, String> segmentoSeleccionado = null;

    int cantidadVisible = 0;

    for (Map<String, String> segmento : segmentos) {

        if ("Todos".equals(filtroEstado)
                || filtroEstado.equals(segmento.get("estado"))) {

            cantidadVisible++;
        }

        if (idSeleccionado != null
                && idSeleccionado.equals(segmento.get("id"))) {

            segmentoSeleccionado = segmento;
        }
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
            href="${pageContext.request.contextPath}/css/supervisor/segmentos.css?=v2"
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

        <section class="encabezado-panel">

            <h2>Estado de la red</h2>

            <h1>Segmentos</h1>

        </section>

        <section class="barra-herramientas">

            <form
                    method="get"
                    action="segmentos.jsp"
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
                            <%= "Todos".equals(filtroEstado)
                                    ? "selected" : "" %>
                    >
                        Todos
                    </option>

                    <option
                            value="Disponible"
                            <%= "Disponible".equals(filtroEstado)
                                    ? "selected" : "" %>
                    >
                        Disponible
                    </option>

                    <option
                            value="Limitada"
                            <%= "Limitada".equals(filtroEstado)
                                    ? "selected" : "" %>
                    >
                        Limitada
                    </option>

                    <option
                            value="Insuficiente"
                            <%= "Insuficiente".equals(filtroEstado)
                                    ? "selected" : "" %>
                    >
                        Insuficiente
                    </option>

                </select>

            </form>

            <span class="cantidad-registros">

                <%= cantidadVisible %>

                <%= cantidadVisible == 1
                        ? "segmento"
                        : "segmentos" %>

            </span>

        </section>

        <section class="contenedor-tabla">

            <table class="tabla-segmentos">

                <thead>

                <tr>
                    <th>Segmento</th>
                    <th>Uso</th>
                    <th>Estado</th>
                </tr>

                </thead>

                <tbody>

                <%
                    for (Map<String, String> segmento : segmentos) {

                        boolean visible =
                                "Todos".equals(filtroEstado)
                                || filtroEstado.equals(
                                        segmento.get("estado")
                                );

                        if (!visible) {
                            continue;
                        }

                        boolean seleccionado =
                                segmento.get("id")
                                        .equals(idSeleccionado);

                        String claseEstado =
                                segmento.get("estado")
                                        .toLowerCase();
                %>

                <tr
                        class="fila-segmento
                        <%= seleccionado
                                ? "seleccionada"
                                : "" %>"

                        onclick="window.location.href=
                        'segmentos.jsp?estado=<%= filtroEstado %>&segmento=<%= segmento.get("id") %>'"
                >

                    <td>

                        <strong>
                            <%= segmento.get("id") %>
                        </strong>

                    </td>

                    <td>
                        <%= segmento.get("porcentaje") %>%
                    </td>

                    <td>

                        <div class="estado-segmento <%= claseEstado %>">

                            <span class="punto-estado"></span>

                            <span>
                                <%= segmento.get("estado") %>
                            </span>

                        </div>

                    </td>

                </tr>

                <% } %>

                <% if (cantidadVisible == 0) { %>

                <tr>

                    <td
                            colspan="3"
                            class="sin-resultados"
                    >
                        No existen segmentos con ese estado.
                    </td>

                </tr>

                <% } %>

                </tbody>

            </table>

        </section>

        <p class="indicacion-tabla">
            Selecciona una fila para visualizar el detalle del segmento.
        </p>

        <% if (segmentoSeleccionado != null) {

            String claseDetalle =
                    segmentoSeleccionado.get("estado")
                            .toLowerCase();
        %>

        <section class="panel-detalle">

            <div class="encabezado-detalle">

                <div>

                    <p>Detalle del segmento</p>

                    <h2>
                        <%= segmentoSeleccionado.get("id") %>
                    </h2>

                </div>

                <a
                        href="segmentos.jsp?estado=<%= filtroEstado %>"
                        class="cerrar-detalle"
                >
                    &times;
                </a>

            </div>

            <div class="contenido-detalle">

                <div class="dato-detalle">

                    <span>Ruta asociada</span>

                    <strong>
                        <%= segmentoSeleccionado.get("ruta") %>
                    </strong>

                </div>

                <div class="dato-detalle">

                    <span>Origen</span>

                    <strong>
                        <%= segmentoSeleccionado.get("origen") %>
                    </strong>

                </div>

                <div class="dato-detalle">

                    <span>Destino</span>

                    <strong>
                        <%= segmentoSeleccionado.get("destino") %>
                    </strong>

                </div>

                <div class="dato-detalle">

                    <span>Estado</span>

                    <strong class="texto-estado <%= claseDetalle %>">

                        <%= segmentoSeleccionado.get("estado") %>

                    </strong>

                </div>

                <div class="dato-detalle">

                    <span>Capacidad total</span>

                    <strong>

                        <%= segmentoSeleccionado
                                .get("capacidadTotal") %>
                        Gbps

                    </strong>

                </div>

                <div class="dato-detalle">

                    <span>Capacidad utilizada</span>

                    <strong>

                        <%= segmentoSeleccionado
                                .get("capacidadUsada") %>
                        Gbps

                    </strong>

                </div>

                <div class="dato-detalle">

                    <span>Capacidad disponible</span>

                    <strong>

                        <%= String.format(
                                "%.0f",
                                Double.parseDouble(
                                        segmentoSeleccionado.get(
                                                "capacidadDisponible"
                                        )
                                )
                        ) %>
                        Gbps

                    </strong>

                </div>

                <div class="dato-detalle">

                    <span>Porcentaje de uso</span>

                    <strong>

                        <%= segmentoSeleccionado
                                .get("porcentaje") %>%

                    </strong>

                </div>

            </div>

            <div class="apartado-riesgo">

                <span>
                    Observación de riesgo
                </span>

                <p>
                    <%= segmentoSeleccionado.get("riesgo") %>
                </p>

            </div>

        </section>

        <% } %>

    </main>

</div>

</body>

</html>
