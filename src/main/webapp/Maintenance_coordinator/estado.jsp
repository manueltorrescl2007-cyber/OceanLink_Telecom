<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Oceanlink - Estado</title>
    <link rel="stylesheet" href="../css/styles_MC.css">
</head>
<body>

<%
    /*
        En una implementación real "estadoActual" vendría de un Servlet/DAO
        según el ID de mantenimiento seleccionado. Valores posibles:
        "programado" | "en-progreso" | "testing" | "finalizado".
        Aquí se deja fijo en "testing" para reflejar el wireframe.
    */
    String estadoActual = "testing";

    List<String> pasos = Arrays.asList("programado", "en-progreso", "testing", "finalizado");
    List<String> etiquetas = Arrays.asList("Programado", "En progreso", "Testing", "Finalizado");
    int indiceActual = pasos.indexOf(estadoActual);
%>

<div class="app-layout">

    <jsp:include page="sidebar.jsp">
        <jsp:param name="activePage" value="estado" />
    </jsp:include>

    <div class="main-content">

        <jsp:include page="header.jsp">
            <jsp:param name="pageTitle" value="Registro y actualizaci&oacute;n de actividades de mantenimiento" />
        </jsp:include>

        <div class="content-container">
            <div class="card">
                <h2 class="card-title">Estado de mantenimientos programados</h2>

                <div class="inline-field">
                    <label for="idMantenimiento">ID</label>
                    <select id="idMantenimiento" name="idMantenimiento">
                        <option value="" selected disabled>Seleccione un ID</option>
                        <option value="REV-0405">REV-0405</option>
                        <option value="REV-0406">REV-0406</option>
                        <option value="REV-0407">REV-0407</option>
                    </select>
                </div>

                <div class="stepper">
                    <%
                        for (int i = 0; i < pasos.size(); i++) {
                            String stepClass = "";
                            if (i < indiceActual) {
                                stepClass = "completed";
                            } else if (i == indiceActual) {
                                stepClass = "active";
                            }
                    %>
                        <div class="stepper-step <%= stepClass %>">
                            <div class="stepper-circle"></div>
                            <span class="stepper-label"><%= etiquetas.get(i) %></span>
                        </div>
                    <%
                        }
                    %>
                </div>

                <div class="bitacora">BITACORA DE INTERVENCIÓN

14:42 - Técnico llegó al sitio de inserción
14:46 - Inicio de revisión de conectores ópticos
15:09 - Detección de degradación leve en fibra secundaria, se procede a reemplazarlo</div>

                <form action="RegistrarIncidenciaServlet" method="post">
                    <input type="text"
                           name="nuevaIncidencia"
                           class="bitacora-input"
                           placeholder="Registrar nueva incidencia">
                </form>

            </div>
        </div>

    </div>
</div>

</body>
</html>
