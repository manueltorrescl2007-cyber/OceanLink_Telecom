<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Oceanlink - Historial</title>
    <link rel="stylesheet" href="../css/styles_MC.css">
</head>
<body>

<%
    /*
        En una implementación real esta lista vendría filtrada desde un
        Servlet/DAO según los parámetros "fechaFin", "estado" y
        "nombreClave" enviados por el formulario de filtros (GET).
        Aquí se simula un único registro de ejemplo, igual que en el
        wireframe, y se completan filas vacías hasta 5.
    */
    List<Map<String, String>> historial = new ArrayList<Map<String, String>>();
    Map<String, String> ejemplo = new HashMap<String, String>();
    ejemplo.put("id", "REV-0405");
    ejemplo.put("segmento", "LIM-VLP-01");
    ejemplo.put("tipo", "Preventivo");
    ejemplo.put("fechaCierre", "2 de sep. de 2026");
    ejemplo.put("estado", "Finalizado");
    historial.add(ejemplo);

    int totalFilas = 5;
%>

<div class="app-layout">

    <jsp:include page="sidebar.jsp">
        <jsp:param name="activePage" value="historial" />
    </jsp:include>

    <div class="main-content">

        <jsp:include page="header.jsp">
            <jsp:param name="pageTitle" value="Registro y actualizaci&oacute;n de actividades de mantenimiento" />
        </jsp:include>

        <div class="content-container">
            <div class="card">
                <h2 class="card-title">Historial de mantenimientos</h2>

                <form action="historial.jsp" method="get" class="filters-bar">
                    <div class="form-field">
                        <select name="fechaFin">
                            <option value="" selected>Fecha fin</option>
                            <option value="7d">Últimos 7 días</option>
                            <option value="30d">Últimos 30 días</option>
                            <option value="custom">Rango personalizado</option>
                        </select>
                    </div>
                    <div class="form-field">
                        <select name="estado">
                            <option value="" selected>Estado</option>
                            <option value="Programado">Programado</option>
                            <option value="En progreso">En progreso</option>
                            <option value="Testing">Testing</option>
                            <option value="Finalizado">Finalizado</option>
                        </select>
                    </div>
                    <div class="form-field">
                        <select name="nombreClave">
                            <option value="" selected>Nombre en clave</option>
                            <option value="LIM-VLP-01">LIM-VLP-01</option>
                            <option value="LIM-VLP-02">LIM-VLP-02</option>
                            <option value="LIM-VLP-03">LIM-VLP-03</option>
                        </select>
                    </div>
                </form>

                <div class="table-toolbar">
                    <div class="table-toolbar-left">
                        <span>&#9638;</span> Vista de Tabla
                    </div>
                    <div class="table-toolbar-icons">
                        <span title="Expandir">&#8599;</span>
                        <span title="Más opciones">&#8942;</span>
                    </div>
                </div>

                <div class="table-icons-row">
                    <span title="Actualizar">&#8635;</span>
                    <span title="Vistas">&#9638;</span>
                    <span title="Agrupar">&#9776;</span>
                    <span title="Filtrar">&#9660;</span>
                    <span title="Ordenar">&#8645;</span>
                    <span title="Lista de campos">&#9776;</span>
                    <span title="Compartir">&#8646;</span>
                    <span title="Ver como cuadrícula">&#9638;</span>
                    <span title="Buscar">&#128269;</span>
                </div>

                <div class="data-table-wrapper">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Segmento</th>
                                <th>Tipo</th>
                                <th>Fecha de cierre</th>
                                <th>Estado</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                for (int i = 0; i < totalFilas; i++) {
                                    if (i < historial.size()) {
                                        Map<String, String> h = historial.get(i);
                                        String estado = h.get("estado");
                                        String badgeClass = "badge-programado";
                                        if ("En progreso".equalsIgnoreCase(estado)) badgeClass = "badge-en-progreso";
                                        else if ("Testing".equalsIgnoreCase(estado)) badgeClass = "badge-testing";
                                        else if ("Finalizado".equalsIgnoreCase(estado)) badgeClass = "badge-finalizado";
                            %>
                                <tr>
                                    <td><%= h.get("id") %></td>
                                    <td><span class="badge badge-segmento"><%= h.get("segmento") %></span></td>
                                    <td><%= h.get("tipo") %></td>
                                    <td><%= h.get("fechaCierre") %></td>
                                    <td><span class="badge <%= badgeClass %>"><%= estado %></span></td>
                                </tr>
                            <%
                                    } else {
                            %>
                                <tr class="row-empty">
                                    <td>&nbsp;</td>
                                    <td>&nbsp;</td>
                                    <td>&nbsp;</td>
                                    <td>&nbsp;</td>
                                    <td>&nbsp;</td>
                                </tr>
                            <%
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </div>
</div>

</body>
</html>
