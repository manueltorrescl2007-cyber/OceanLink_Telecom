package servlets.supervisor;

import beans.capacityplanner.Solicitud;
import daos.capacityplanner.ClienteDao;
import daos.capacityplanner.SolicitudDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "SolicitudesServletSuper", value = "/SolicitudesServletSuper")
public class SolicitudesServletSuper extends HttpServlet {

  // Temporal, hasta conectar el inicio de sesión.
  private static final int ID_USUARIO_PRUEBA = 4;

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
      switch (action) {

        case "lista":
          String estado = request.getParameter("estado");

          request.setAttribute("listaSolicitudes",
            solicitudDao.listarSolicitudes(estado));

          request.setAttribute("filtroEstado",
            estado == null ? "" : estado);

          int id = parseId(request.getParameter("id"));

          if (id > 0) {
            request.setAttribute("solicitudSeleccionada",
              solicitudDao.obtenerSolicitud(id));
          }

          request.getRequestDispatcher(
            "/supervisor/solicitudes.jsp"
          ).forward(request, response);
          break;

        default:
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

  private int parseId(String valor) {
    try {
      return Integer.parseInt(valor);
    } catch (NumberFormatException e) {
      return -1;
    }
  }
}
