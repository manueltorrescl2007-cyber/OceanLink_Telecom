package servlets.supervisor;

import beans.capacityplanner.Solicitud;
import daos.capacityplanner.SolicitudDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;

@WebServlet(name = "SolicitudesServletSuper", value = "/SolicitudesServletSuper")
public class SolicitudesServletSuper extends HttpServlet {

  private static final int TAMANO_PAGINA = 10;

  @Override
  protected void doGet(HttpServletRequest request,
                       HttpServletResponse response)
    throws ServletException, IOException {

    String action = request.getParameter("action");
    if (action == null) {
      action = "lista";
    }

    SolicitudDao solicitudDao = new SolicitudDao();

    try {
      if ("lista".equals(action)) {
        String estado = request.getParameter("estado");
        ArrayList<Solicitud> solicitudes = solicitudDao.listarSolicitudes(estado);
        if (solicitudes == null) {
          solicitudes = new ArrayList<>();
        }

        request.setAttribute("listaSolicitudes", aplicarPaginacion(request, solicitudes));
        request.setAttribute("filtroEstado", estado == null ? "" : estado);

        int id = parseId(request.getParameter("id"));
        if (id > 0) {
          request.setAttribute("solicitudSeleccionada",
            solicitudDao.obtenerSolicitud(id));
        }

        request.getRequestDispatcher("/supervisor/solicitudes.jsp")
          .forward(request, response);
      } else {
        response.sendRedirect(
          request.getContextPath() + "/SolicitudesServletSuper"
        );
      }
    } catch (SQLException e) {
      throw new ServletException(
        "Error al consultar las solicitudes.", e
      );
    }
  }

  @Override
  protected void doPost(HttpServletRequest request,
                        HttpServletResponse response)
    throws ServletException, IOException {
    response.sendRedirect(request.getContextPath() + "/SolicitudesServletSuper");
  }

  private <T> ArrayList<T> aplicarPaginacion(HttpServletRequest request,
                                             ArrayList<T> listaCompleta) {
    int totalRegistros = listaCompleta.size();
    int totalPaginas = Math.max(1, (int) Math.ceil((double) totalRegistros / TAMANO_PAGINA));

    int paginaActual = parseId(request.getParameter("pagina"));
    if (paginaActual < 1) {
      paginaActual = 1;
    } else if (paginaActual > totalPaginas) {
      paginaActual = totalPaginas;
    }

    int indiceInicio = (paginaActual - 1) * TAMANO_PAGINA;
    int indiceFin = Math.min(indiceInicio + TAMANO_PAGINA, totalRegistros);

    ArrayList<T> sublista = new ArrayList<>();
    if (totalRegistros > 0 && indiceInicio < totalRegistros) {
      sublista.addAll(listaCompleta.subList(indiceInicio, indiceFin));
    }

    request.setAttribute("paginaActual", paginaActual);
    request.setAttribute("totalPaginas", totalPaginas);
    request.setAttribute("totalRegistros", totalRegistros);
    request.setAttribute("registroInicio", totalRegistros == 0 ? 0 : indiceInicio + 1);
    request.setAttribute("registroFin", indiceFin);

    return sublista;
  }

  private int parseId(String valor) {
    try {
      return Integer.parseInt(valor);
    } catch (NumberFormatException e) {
      return -1;
    }
  }
}
