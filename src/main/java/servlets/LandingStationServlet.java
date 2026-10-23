package servlets;

import beans.LandingStation;
import daos.LandingStationDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "LandingStationServlet", value = "/LandingStationServlet")
public class LandingStationServlet extends HttpServlet {

  @Override
  protected void doGet(HttpServletRequest request,
                       HttpServletResponse response)
    throws ServletException, IOException {

    try {
      mostrarEstaciones(request, response);
    } catch (SQLException e) {
      throw new ServletException(
        "No se pudieron cargar las estaciones.", e);
    }
  }

  @Override
  protected void doPost(HttpServletRequest request,
                        HttpServletResponse response)
    throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");

    String accion = request.getParameter("accion");

    if (!"guardar".equals(accion)) {
      response.sendError(
        HttpServletResponse.SC_BAD_REQUEST,
        "Acción no válida.");
      return;
    }

    String idTexto = texto(request.getParameter("id"));
    boolean esNuevo = idTexto.isEmpty();

    LandingStation estacion = new LandingStation();

    if (!esNuevo) {
      try {
        estacion.setIdLanding(Integer.parseInt(idTexto));
      } catch (NumberFormatException e) {
        response.sendError(
          HttpServletResponse.SC_BAD_REQUEST,
          "El ID no es válido.");
        return;
      }

      if (estacion.getIdLanding() <= 0) {
        response.sendError(
          HttpServletResponse.SC_BAD_REQUEST,
          "El ID no es válido.");
        return;
      }
    }

    estacion.setNombre(texto(request.getParameter("nombre")));
    estacion.setPais(texto(request.getParameter("pais")));
    estacion.setCiudad(texto(request.getParameter("ciudad")));
    estacion.setEstado(texto(request.getParameter("estadoEstacion")));

    // Conservar los datos del formulario si ocurre un error.
    request.setAttribute("estacionFormulario", estacion);

    String error = validarEstacion(estacion);

    if (error != null) {
      mostrarError(request, response, error);
      return;
    }

    LandingStationDao dao = new LandingStationDao();

    try {
      boolean guardado;

      if (esNuevo) {
        guardado = dao.crearEstacion(estacion);
      } else {
        guardado = dao.actualizarEstacion(estacion);
      }

      if (!guardado) {
        mostrarError(request, response,
          "No se pudo guardar. La estación podría no existir.");
        return;
      }

      response.sendRedirect(
        request.getContextPath()
          + "/LandingStationServlet?guardado=1");

    } catch (SQLException e) {
      getServletContext().log("Error al guardar la estación", e);

      String mensaje = e.getErrorCode() == 1062
        ? "Ya existe una estación con ese nombre."
        : "No se pudo guardar la estación.";

      mostrarError(request, response, mensaje);
    }
  }

  private void mostrarEstaciones(HttpServletRequest request,
                                 HttpServletResponse response)
    throws SQLException, ServletException, IOException {

    LandingStationDao dao = new LandingStationDao();

    request.setAttribute("listaEstaciones", dao.listarEstaciones());

    request.getRequestDispatcher(
      "/capacity_planner/landing_stations.jsp"
    ).forward(request, response);
  }

  private void mostrarError(HttpServletRequest request,
                            HttpServletResponse response,
                            String mensaje)
    throws ServletException, IOException {

    request.setAttribute("error", mensaje);

    try {
      mostrarEstaciones(request, response);
    } catch (SQLException e) {
      throw new ServletException(
        "No se pudieron cargar las estaciones.", e);
    }
  }

  private String validarEstacion(LandingStation estacion) {

    if (estacion.getNombre().isEmpty()
      || estacion.getNombre().length() > 100) {
      return "Escribe un nombre de hasta 100 caracteres.";
    }

    if (estacion.getPais().isEmpty()
      || estacion.getPais().length() > 45) {
      return "Escribe un país de hasta 45 caracteres.";
    }

    if (estacion.getCiudad().isEmpty()
      || estacion.getCiudad().length() > 45) {
      return "Escribe una ciudad de hasta 45 caracteres.";
    }

    if (!"Activa".equals(estacion.getEstado())
      && !"Inactiva".equals(estacion.getEstado())) {
      return "Selecciona un estado válido.";
    }

    return null;
  }

  private String texto(String valor) {
    return valor == null ? "" : valor.trim();
  }
}
