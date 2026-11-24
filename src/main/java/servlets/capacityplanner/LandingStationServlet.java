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
    ArrayList<LandingStation> filtradas = new ArrayList<>();

    for (LandingStation estacion : dao.listarEstaciones()) {
      if (filtro.isEmpty() || filtro.equals(estacion.getEstado())) {
        filtradas.add(estacion);
      }
      if (estacion.getIdLanding() == idDetalle) {
        request.setAttribute("estacionDetalle", estacion);
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
}
