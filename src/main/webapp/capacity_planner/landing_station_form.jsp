<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="beans.capacityplanner.LandingStation" %>
<%!

    public String texto(String valor) {
        if (valor == null) return "";
        return valor.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                    .replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    String servlet = request.getContextPath() + "/LandingStationServlet";
    String filtro = (String) request.getAttribute("filtroEstado");
    int pagina = (Integer) request.getAttribute("paginaActual");
    String urlLista = servlet + "?estado=" + filtro + "&amp;pagina=" + pagina;
    String error = (String) request.getAttribute("error");
    String[] estados = {"Activa", "Inactiva"};
    LandingStation datos = (LandingStation) request.getAttribute("estacionFormulario");
    String[] formulario = {"", "", "", "", "Activa"};
    if (datos != null) {
        formulario = new String[]{"", datos.getNombre(), datos.getPais(),
                datos.getCiudad(), datos.getEstado()};
    }
%>

<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nueva estación | OceanLink</title>
    <!-- Estilos de la página primero; barras comunes después. -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/capacity_planner/landing_stations.css?v=1">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/barras.css">
    <style>
        .vista-landings .formulario-estacion {
            max-width: 860px;
            margin-inline: auto;
            padding: clamp(20px, 3vw, 32px);
        }

        .formulario-estacion form {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 22px;
        }

        .formulario-estacion .grupo-formulario {
            display: grid;
            gap: 8px;
            margin: 0;
        }

        .formulario-estacion label {
            color: var(--color-primario, #0b3d5c);
            font-weight: 600;
        }

        .formulario-estacion input[type="text"],
        .formulario-estacion select {
            box-sizing: border-box;
            width: 100%;
            min-height: 46px;
            padding: 10px 14px;
            border: 1px solid var(--color-borde, #d9e1e8);
            border-radius: 8px;
            background: #fff;
            color: var(--color-texto, #1e293b);
            font: inherit;
        }

        .formulario-estacion input[type="text"]:focus-visible,
        .formulario-estacion select:focus-visible {
            outline: 2px solid var(--color-acento, #1c8c9c);
            outline-offset: 2px;
        }

        .formulario-estacion .acciones {
            grid-column: 1 / -1;
            display: flex;
            justify-content: flex-end;
            flex-wrap: wrap;
            gap: 12px;
            margin: 2px 0 0;
        }

        @media (max-width: 760px) {
            .formulario-estacion form {
                grid-template-columns: minmax(0, 1fr);
            }
        }
    </style>
</head>
<body class="vista-landings">
<jsp:include page="header.jsp" />
<div class="contenedor">
    <!-- MENÚ LATERAL: Landing stations es la opción activa de esta página -->
    <aside class="menu-lateral">
        <div class="contenido-menu">
            <h2>Menú</h2>
            <nav class="navegacion-lateral" aria-label="Menú principal">
                <a href="${pageContext.request.contextPath}/CapacityPlannerServlet">Dashboard</a>
                <a href="${pageContext.request.contextPath}/ClienteServlet">Clientes</a>
                <a href="${pageContext.request.contextPath}/SolicitudesServlet">Solicitudes</a>
                <!-- Checkbox y label abren Infraestructura sin JavaScript -->
                <div class="grupo-menu">
                    <input type="checkbox" id="control-infraestructura" class="control-submenu" checked>
                    <label for="control-infraestructura" class="titulo-grupo">
                        <span>Infraestructura</span>
                        <span class="flecha-submenu"></span>
                    </label>
                    <div class="contenido-submenu">
                        <a href="${pageContext.request.contextPath}/capacity_planner/rutas.jsp" class="subopcion">Rutas</a>

                        <a href="${pageContext.request.contextPath}/capacity_planner/segmentos.jsp" class="subopcion">Segmentos</a>

                        <a href="<%= servlet %>" class="subopcion activo">Landing stations</a>
                    </div>
                </div>
                <a href="${pageContext.request.contextPath}/capacity_planner/servicios.jsp">Servicios</a>
            </nav>
        </div>
        <!-- OPCIONES DEL USUARIO: barras.css las coloca abajo -->
        <div class="configuracion">
            <nav aria-label="Opciones del usuario">
                <!-- Pendiente: colocar la dirección real de Perfil -->
                <a href="${pageContext.request.contextPath}/PerfilServlet">Perfil</a>
                <!-- Navega al login; el cierre real de sesión se conectará después -->
                <a href="${pageContext.request.contextPath}/login.jsp" class="cerrar-sesion">Cerrar sesión</a>
            </nav>
        </div>
    </aside>

    <main class="contenido-principal pagina-landings">
        <section class="encabezado-pagina">
            <div class="encabezado-panel">
                <h2>Landing stations</h2>
                <h1>Nueva estación</h1>
            </div>
        </section>
        <section class="panel-detalle formulario-estacion" aria-label="Nueva estación">
            <% if (error != null) { %>
                <p class="mensaje-error" role="alert"><%= texto(error) %></p>
            <% } %>
            <form action="<%= servlet %>" method="post">
                <input type="hidden" name="accion" value="guardar">
                <input type="hidden" name="estado" value="<%= filtro %>">
                <input type="hidden" name="pagina" value="<%= pagina %>">
                <div class="grupo-formulario">
                    <label for="nombre">Nombre</label>
                    <input type="text" id="nombre" name="nombre" maxlength="100" placeholder="Ejemplo: Callao Landing" value="<%= texto(formulario[1]) %>" required>
                </div>
                <div class="grupo-formulario">
                    <label for="pais">País</label>
                    <input type="text" id="pais" name="pais" maxlength="45" placeholder="Ejemplo: Perú" value="<%= texto(formulario[2]) %>" required>
                </div>
                <div class="grupo-formulario">
                    <label for="ciudad">Ciudad</label>
                    <input type="text" id="ciudad" name="ciudad" maxlength="45" placeholder="Ejemplo: Callao" value="<%= texto(formulario[3]) %>" required>
                </div>
                <div class="grupo-formulario">
                    <label for="estadoEstacion">Estado</label>
                    <select id="estadoEstacion" name="estadoEstacion" required>
                        <% for (String estado : estados) { %>
                            <option value="<%= estado %>" <%= estado.equals(formulario[4]) ? "selected" : "" %>><%= estado %></option>
                        <% } %>
                    </select>
                </div>
                <div class="acciones">
                    <a href="<%= urlLista %>" class="boton secundario">Cancelar</a>
                    <button type="submit" class="boton primario">Guardar</button>
                </div>
            </form>
        </section>
    </main>
</div>
</body>
</html>
