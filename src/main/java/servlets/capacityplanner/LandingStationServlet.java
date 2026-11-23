package servlets.capacityplanner;

import beans.capacityplanner.LandingStation;
import daos.capacityplanner.LandingStationDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;

@WebServlet(name = "LandingStationServlet", value = "/LandingStationServlet")
public class LandingStationServlet extends HttpServlet {

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
    cargarEstaciones(request, response);
  }

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
    request.setCharacterEncoding("UTF-8");

    if (!"guardar".equals(request.getParameter("accion"))) {
      response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Acción no válida.");
      return;
    }

    int id = parseId(texto(request.getParameter("id")));
    if (id <= 0) {
      response.sendError(HttpServletResponse.SC_BAD_REQUEST, "El ID no es válido.");
      return;
    }

    LandingStation estacion = new LandingStation();
    estacion.setIdLanding(id);
    estacion.setNombre(texto(request.getParameter("nombre")));
    estacion.setPais(texto(request.getParameter("pais")));
    estacion.setCiudad(texto(request.getParameter("ciudad")));
    estacion.setEstado(texto(request.getParameter("estadoEstacion")));
    request.setAttribute("estacionFormulario", estacion);

    String error = validarEstacion(estacion);
    if (error != null) {
      mostrarError(request, response, error);
      return;
    }

    LandingStationDao dao = new LandingStationDao();
    try {
      if (!dao.actualizarEstacion(estacion)) {
        mostrarError(request, response, "No se pudo guardar. La estación podría no existir.");
        return;
      }

      String destino = request.getContextPath() + "/LandingStationServlet?guardado=1"
        + "&estado=" + filtroEstado(request)
        + "&pagina=" + Math.max(1, parseId(request.getParameter("pagina")));
      response.sendRedirect(destino);
    } catch (SQLException e) {
      getServletContext().log("Error al guardar la estación", e);
      String mensaje = e.getErrorCode() == 1062
        ? "Ya existe una estación con ese nombre."
        : "No se pudo guardar la estación.";
      mostrarError(request, response, mensaje);
    }
  }

  private void cargarEstaciones(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
    try {
      mostrarEstaciones(request, response);
    } catch (SQLException e) {
      throw new ServletException("No se pudieron cargar las estaciones.", e);
    }
  }

  private void mostrarEstaciones(HttpServletRequest request, HttpServletResponse response)
    throws SQLException, ServletException, IOException {
    LandingStationDao dao = new LandingStationDao();
    String filtro = filtroEstado(request);
    int idDetalle = parseId(request.getParameter("detalle"));
    int idEditar = parseId(request.getParameter("editar"));
    boolean cargarEdicion = request.getAttribute("estacionFormulario") == null;
    ArrayList<LandingStation> filtradas = new ArrayList<>();

    for (LandingStation estacion : dao.listarEstaciones()) {
      if (filtro.isEmpty() || filtro.equals(estacion.getEstado())) {
        filtradas.add(estacion);
      }
      if (estacion.getIdLanding() == idDetalle) {
        request.setAttribute("estacionDetalle", estacion);
      }
      if (cargarEdicion && estacion.getIdLanding() == idEditar) {
        request.setAttribute("estacionFormulario", estacion);
      }
    }

    final int porPagina = 10;
    int total = filtradas.size();
    int totalPaginas = Math.max(1, (total + porPagina - 1) / porPagina);
    int pagina = Math.max(1, Math.min(parseId(request.getParameter("pagina")), totalPaginas));
    int desde = (pagina - 1) * porPagina;
    int hasta = Math.min(desde + porPagina, total);

    request.setAttribute("listaEstaciones", new ArrayList<>(filtradas.subList(desde, hasta)));
    request.setAttribute("totalEstaciones", total);
    request.setAttribute("totalPaginas", totalPaginas);
    request.setAttribute("paginaActual", pagina);
    request.setAttribute("filtroEstado", filtro);
    request.getRequestDispatcher("/capacity_planner/landing_stations.jsp")
      .forward(request, response);
  }

  private void mostrarError(HttpServletRequest request, HttpServletResponse response,
                            String mensaje) throws ServletException, IOException {
    request.setAttribute("error", mensaje);
    cargarEstaciones(request, response);
  }

  private String filtroEstado(HttpServletRequest request) {
    String estado = request.getParameter("estado");
    return "Activa".equals(estado) || "Inactiva".equals(estado) ? estado : "";
  }

  private int parseId(String valor) {
    try {
      return Integer.parseInt(valor);
    } catch (NumberFormatException e) {
      return -1;
    }
  }

  private String validarEstacion(LandingStation estacion) {
    if (estacion.getNombre().isEmpty() || estacion.getNombre().length() > 100) {
      return "Escribe un nombre de hasta 100 caracteres.";
    }
    if (estacion.getPais().isEmpty() || estacion.getPais().length() > 45) {
      return "Escribe un país de hasta 45 caracteres.";
    }
    if (estacion.getCiudad().isEmpty() || estacion.getCiudad().length() > 45) {
      return "Escribe una ciudad de hasta 45 caracteres.";
    }
    if (!"Activa".equals(estacion.getEstado()) && !"Inactiva".equals(estacion.getEstado())) {
      return "Selecciona un estado válido.";
    }
    return null;
  }

  private String texto(String valor) {
    return valor == null ? "" : valor.trim();
  }
}
