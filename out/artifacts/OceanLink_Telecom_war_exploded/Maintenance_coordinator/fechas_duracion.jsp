<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Oceanlink - Fechas y duración</title>
    <link rel="stylesheet" href="../css/styles_MC.css">
</head>
<body>

<%
    /*
        En una implementación real, esta lista vendría de un Servlet/DAO
        (p. ej. request.getAttribute("mantenimientos")) que consulta la
        base de datos. Aquí se simula un único registro de ejemplo,
        tal como en el wireframe, y se completan filas vacías hasta 10
        para conservar el aspecto de "Vista de Tabla".
    */
    List<Map<String, String>> mantenimientos = new ArrayList<Map<String, String>>();
    Map<String, String> ejemplo = new HashMap<String, String>();
    ejemplo.put("segmento", "LIM-VLP-02");
    ejemplo.put("tipo", "Preventivo");
    ejemplo.put("fechaInicio", "4 de sep. de 2026");
    ejemplo.put("fechaFin", "30 de sep. de 2026");
    ejemplo.put("prioridad", "Leve");
    ejemplo.put("notas", "Verificar estado de conectores");
    mantenimientos.add(ejemplo);

    int totalFilas = 10;
%>

<div class="app-layout">

    <jsp:include page="sidebar.jsp">
        <jsp:param name="activePage" value="fechas" />
    </jsp:include>

    <div class="main-content">

        <jsp:include page="header.jsp">
            <jsp:param name="pageTitle" value="Registro y actualizaci&oacute;n de actividades de mantenimiento" />
        </jsp:include>

        <div class="content-container">
            <div class="card">
                <h2 class="card-title">Fechas y duración de mantenimientos programados</h2>

                <div class="table-toolbar">
                    <div class="table-toolbar-left">
                        <span>&#9638;</span> Vista de Tabla
                    </div>
                    <div class="table-toolbar-icons">
                        <span title="Expandir">&#8599;</span>
                        <span title="Más opciones">&#8942;</span>
                    </div>
                </div>

                <div class="data-table-wrapper">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Segmento</th>
                                <th>Tipo de mantenimiento</th>
                                <th>Fecha de inicio</th>
                                <th>Fecha de fin</th>
                                <th>Prioridad</th>
                                <th>Notas / Descripción</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                for (int i = 0; i < totalFilas; i++) {
                                    if (i < mantenimientos.size()) {
                                        Map<String, String> m = mantenimientos.get(i);
                                        String prioridad = m.get("prioridad");
                                        String badgeClass = "badge-leve";
                                        if ("Media".equalsIgnoreCase(prioridad)) badgeClass = "badge-media";
                                        else if ("Alta".equalsIgnoreCase(prioridad)) badgeClass = "badge-alta";
                                        else if ("Critica".equalsIgnoreCase(prioridad) || "Crítica".equalsIgnoreCase(prioridad)) badgeClass = "badge-critica";
                            %>
                                <tr>
                                    <td><%= m.get("segmento") %></td>
                                    <td><%= m.get("tipo") %></td>
                                    <td><%= m.get("fechaInicio") %></td>
                                    <td><%= m.get("fechaFin") %></td>
                                    <td><span class="badge <%= badgeClass %>"><%= prioridad %></span></td>
                                    <td><%= m.get("notas") %></td>
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
