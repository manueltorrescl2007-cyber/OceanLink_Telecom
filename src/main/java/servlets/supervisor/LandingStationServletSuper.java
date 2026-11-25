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
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "LandingStationServletSuper", value = "/LandingStationServletSuper")
public class LandingStationServletSuper extends HttpServlet {

  private static final int REGISTROS_POR_PAGINA = 10;

  @Override
  protected void doGet(HttpServletRequest request,
                       HttpServletResponse response)
    throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");

    String estadoFiltro = texto(request.getParameter("estado"));
    int idDetalle = parseId(request.getParameter("detalle"));

    LandingStationDao dao = new LandingStationDao();

    try {
      ArrayList<LandingStation> todas = dao.listarEstaciones();
      ArrayList<LandingStation> filtradas = new ArrayList<>();
      LandingStation estacionDetalle = null;

      for (LandingStation e : todas) {
        if (e.getIdLanding() == idDetalle) {
          estacionDetalle = e;
        }
        if (!estadoFiltro.isEmpty() && !estadoFiltro.equals(e.getEstado())) {
          continue;
        }
        filtradas.add(e);
      }

      int totalRegistros = filtradas.size();
      int totalPaginas = (int) Math.ceil((double) totalRegistros / REGISTROS_POR_PAGINA);
      if (totalPaginas == 0) {
        totalPaginas = 1;
      }

      int paginaActual = parsePagina(request.getParameter("pagina"), totalPaginas);
      int inicio = (paginaActual - 1) * REGISTROS_POR_PAGINA;
      int fin = Math.min(inicio + REGISTROS_POR_PAGINA, totalRegistros);

      List<LandingStation> listaPaginada = new ArrayList<>();
      if (inicio < totalRegistros) {
        listaPaginada = filtradas.subList(inicio, fin);
      }

      int registroInicio = totalRegistros == 0 ? 0 : inicio + 1;
      int registroFin = fin;

      request.setAttribute("listaEstaciones", listaPaginada);
      request.setAttribute("filtroEstado", estadoFiltro);
      request.setAttribute("estacionDetalle", estacionDetalle);

      request.setAttribute("paginaActual", paginaActual);
      request.setAttribute("totalPaginas", totalPaginas);
      request.setAttribute("totalRegistros", totalRegistros);
      request.setAttribute("registroInicio", registroInicio);
      request.setAttribute("registroFin", registroFin);

      request.getRequestDispatcher("/supervisor/landing_stations.jsp")
        .forward(request, response);

    } catch (SQLException e) {
      throw new ServletException("No se pudieron cargar las estaciones.", e);
    }
  }

  private String texto(String valor) {
    return valor == null ? "" : valor.trim();
  }

  private int parseId(String valor) {
    try {
      return Integer.parseInt(valor);
    } catch (NumberFormatException e) {
      return -1;
    }
  }

  private int parsePagina(String valor, int maxPaginas) {
    try {
      int p = Integer.parseInt(valor);
      if (p < 1) return 1;
      if (p > maxPaginas) return maxPaginas;
      return p;
    } catch (NumberFormatException e) {
      return 1;
    }
  }
}

