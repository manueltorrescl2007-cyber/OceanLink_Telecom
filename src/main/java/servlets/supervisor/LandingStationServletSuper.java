package servlets.supervisor;

import beans.capacityplanner.LandingStation;
import daos.capacityplanner.LandingStationDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "LandingStationServletSuper", value = "/LandingStationServletSuper")
public class LandingStationServletSuper extends HttpServlet {

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

  private void mostrarEstaciones(HttpServletRequest request,
                                 HttpServletResponse response)
    throws SQLException, ServletException, IOException {

    LandingStationDao dao = new LandingStationDao();

    request.setAttribute("listaEstaciones", dao.listarEstaciones());

    request.getRequestDispatcher(
      "/supervisor/landing_stations.jsp"
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

