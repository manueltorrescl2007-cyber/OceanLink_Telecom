<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="beans.networkoperator.Segmento" %>
<%@ page import="beans.networkoperator.UtilizacionDiaria" %>
<%
    ArrayList<Segmento> listaSegmentos = (ArrayList<Segmento>) request.getAttribute("listaSegmentos");
    String filtroEstado = (String) request.getAttribute("filtroEstado");
    UtilizacionDiaria fotoHoy = (UtilizacionDiaria) request.getAttribute("fotoHoy");
    UtilizacionDiaria[] semana = (UtilizacionDiaria[]) request.getAttribute("semana");
    String[] fechasSemana = (String[]) request.getAttribute("fechasSemana");
    Integer indiceHoy = (Integer) request.getAttribute("indiceHoy");
    Integer cantSegmentos = (Integer) request.getAttribute("cantSegmentos");
    Integer cantNormal = (Integer) request.getAttribute("cantNormal");
    Integer cantAlta = (Integer) request.getAttribute("cantAlta");
    Integer cantCritica = (Integer) request.getAttribute("cantCritica");

    if (listaSegmentos == null) { listaSegmentos = new ArrayList<>(); }
    if (filtroEstado == null) { filtroEstado = ""; }
    if (fotoHoy == null) { fotoHoy = new UtilizacionDiaria(); }
    if (semana == null) { semana = new UtilizacionDiaria[7]; }
    if (fechasSemana == null) { fechasSemana = new String[]{"", "", "", "", "", "", ""}; }
    if (indiceHoy == null) { indiceHoy = 0; }
    if (cantSegmentos == null) { cantSegmentos = 0; cantNormal = 0; cantAlta = 0; cantCritica = 0; }

    String[] dias = {"Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"};
    String etiquetasJs = "[", ocupadaJs = "[", reservadaJs = "[", disponibleJs = "[";
    String ocupadaGbpsJs = "[", reservadaGbpsJs = "[", disponibleGbpsJs = "[";
    for (int i = 0; i < 7; i++) {
        String coma = (i == 0) ? "" : ", ";
        UtilizacionDiaria d = semana[i];
        etiquetasJs      += coma + "'" + dias[i] + " " + fechasSemana[i] + "'";
        ocupadaJs        += coma + (d == null ? "null" : String.valueOf(d.getPorcentajeOcupada()));
        reservadaJs      += coma + (d == null ? "null" : String.valueOf(d.getPorcentajeReservada()));
        disponibleJs     += coma + (d == null ? "null" : String.valueOf(d.getPorcentajeDisponible()));
        ocupadaGbpsJs    += coma + (d == null ? "null" : String.valueOf(d.getCapacidadOcupada()));
        reservadaGbpsJs  += coma + (d == null ? "null" : String.valueOf(d.getCapacidadReservada()));
        disponibleGbpsJs += coma + (d == null ? "null" : String.valueOf(d.getCapacidadDisponible()));
    }
    etiquetasJs += "]"; ocupadaJs += "]"; reservadaJs += "]"; disponibleJs += "]";
    ocupadaGbpsJs += "]"; reservadaGbpsJs += "]"; disponibleGbpsJs += "]";

    String[] estados = {"Operativo", "Degradado", "En mantenimiento", "Fuera de servicio"};
    String servlet = request.getContextPath() + "/EstadoRedServlet";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OceanLink - Estado de la Red</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/network_operator/network_operator.css?v=5">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/barras.css">

    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.js"></script>
</head>
<body>

<jsp:include page="header.jsp" />

<div class="contenedor">

    <jsp:include page="sidebar.jsp">
        <jsp:param name="activePage" value="estado" />
    </jsp:include>

    <main class="contenido-principal">

        <div class="encabezado-panel">
            <h1>Utilización de la red y Visualizador de segmentos</h1>
        </div>

        <section class="card">
            <div class="chart-header">
                <h2 class="card-title">Utilización de la red (<%= fotoHoy.getPorcentajeOcupada() %>%)</h2>
                <p class="ayuda">Semana del <%= fechasSemana[0] %> al <%= fechasSemana[6] %> · <%= cantSegmentos %> segmento(s)</p>
            </div>

            <div class="grafico-semana">
                <canvas id="graficoSemana" aria-label="Utilización de la red de lunes a domingo"></canvas>
            </div>
            <noscript><p class="ayuda">Activa JavaScript para ver la gráfica.</p></noscript>

            <ul class="leyenda">
                <li><span class="punto tramo-ocupada"></span>Ocupada hoy: <strong><%= fotoHoy.getCapacidadOcupada() %> Gbps</strong> (<%= fotoHoy.getPorcentajeOcupada() %>%)</li>
                <li><span class="punto tramo-reservada"></span>Reservada: <strong><%= fotoHoy.getCapacidadReservada() %> Gbps</strong> (<%= fotoHoy.getPorcentajeReservada() %>%)</li>
                <li><span class="punto tramo-disponible"></span>Disponible: <strong><%= fotoHoy.getCapacidadDisponible() %> Gbps</strong> (<%= fotoHoy.getPorcentajeDisponible() %>%)</li>
                <li>Capacidad total: <strong><%= fotoHoy.getCapacidadTotal() %> Gbps</strong></li>
            </ul>

            <div class="resumen-niveles">
                <div class="nivel-caja nivel-normal"><strong><%= cantNormal %></strong><span>Normal (&lt; 80%)</span></div>
                <div class="nivel-caja nivel-alta"><strong><%= cantAlta %></strong><span>Alta (80% - 95%)</span></div>
                <div class="nivel-caja nivel-critica"><strong><%= cantCritica %></strong><span>Crítica (&gt; 95%)</span></div>
            </div>
        </section>

        <section class="card segments-section">
            <h2 class="card-title">Segmentos</h2>

            <form class="filtros" method="GET" action="<%= servlet %>">
                <select name="estado" aria-label="Filtrar por estado">
                    <option value="">Todos los estados</option>
                    <% for (String e : estados) { %>
                        <option value="<%= e %>" <%= e.equals(filtroEstado) ? "selected" : "" %>><%= e %></option>
                    <% } %>
                </select>
                <button type="submit" class="btn-primary btn-chico">Filtrar</button>
                <% if (!filtroEstado.isEmpty()) { %>
                    <a class="btn-secundario" href="<%= servlet %>">Limpiar</a>
                <% } %>
                <span class="contador"><%= listaSegmentos.size() %> segmento(s)</span>
            </form>

            <div class="table-wrapper">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th scope="col">Segmento</th>
                            <th scope="col">Tramo</th>
                            <th scope="col">Total (Gbps)</th>
                            <th scope="col">Ocupada</th>
                            <th scope="col">Reservada</th>
                            <th scope="col">Disponible</th>
                            <th scope="col">Uso</th>
                            <th scope="col">Estado</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% if (listaSegmentos.isEmpty()) { %>
                        <tr>
                            <td colspan="8" class="vacio">No hay segmentos con ese estado.</td>
                        </tr>
                    <% } else {
                           for (Segmento s : listaSegmentos) {

                               String claseEstado = "badge-" + s.getEstado().toLowerCase().replace(" ", "-");
                    %>
                        <tr>
                            <td><strong><%= s.getCodigo() %></strong></td>
                            <td><%= s.getLandingInicial().getNombre() %> &rarr; <%= s.getLandingFinal().getNombre() %></td>
                            <td><%= s.getCapacidadTotal() %></td>
                            <td><%= s.getCapacidadOcupada() %></td>
                            <td><%= s.getCapacidadReservada() %></td>
                            <td><%= s.getCapacidadDisponible() %></td>
                            <td>
                                <div class="mini-barra">
                                    <div class="relleno nivel-<%= s.getNivelUso() %>" style="width: <%= s.getPorcentajeUso() %>%"></div>
                                </div>
                                <span class="texto-uso"><%= s.getPorcentajeUso() %>%</span>
                            </td>
                            <td><span class="badge <%= claseEstado %>"><%= s.getEstado() %></span></td>
                        </tr>
                    <%     }
                       } %>
                    </tbody>
                </table>
            </div>
        </section>

    </main>

</div>

<script>

    const etiquetas      = <%= etiquetasJs %>;
    const ocupada        = <%= ocupadaJs %>;
    const reservada      = <%= reservadaJs %>;
    const disponible     = <%= disponibleJs %>;
    const ocupadaGbps    = <%= ocupadaGbpsJs %>;
    const reservadaGbps  = <%= reservadaGbpsJs %>;
    const disponibleGbps = <%= disponibleGbpsJs %>;
    const indiceHoy      = <%= indiceHoy %>;

    const css = getComputedStyle(document.documentElement);
    const colorOcupada   = css.getPropertyValue('--color-primario').trim() || '#0b3d5c';
    const colorReservada = css.getPropertyValue('--color-media').trim()    || '#ecb84a';
    const colorDisponible = '#1c8c9c';

    const radioPuntos = etiquetas.map((e, i) => i === indiceHoy ? 7 : 4);

    function linea(nombre, datos, gbps, color) {
        return {
            label: nombre,
            data: datos,
            gbps: gbps,
            borderColor: color,
            backgroundColor: color,
            pointRadius: radioPuntos,
            tension: 0.3,
            spanGaps: true
        };
    }

    new Chart(document.getElementById('graficoSemana'), {
        type: 'line',
        data: {
            labels: etiquetas,
            datasets: [
                linea('Ocupada', ocupada, ocupadaGbps, colorOcupada),
                linea('Reservada', reservada, reservadaGbps, colorReservada),
                linea('Disponible', disponible, disponibleGbps, colorDisponible)
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: { mode: 'index', intersect: false },
            scales: {
                y: { min: 0, max: 100, ticks: { callback: valor => valor + '%' } }
            },
            plugins: {
                legend: { position: 'bottom' },
                tooltip: {
                    callbacks: {

                        label: ctx => ctx.dataset.label + ': ' + ctx.parsed.y + '% ('
                                      + ctx.dataset.gbps[ctx.dataIndex] + ' Gbps)'
                    }
                }
            }
        }
    });
</script>

</body>
</html>
