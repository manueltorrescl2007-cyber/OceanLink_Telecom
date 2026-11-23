package servlets.maintenance;

import beans.maintenance.ServicioAfectado;
import daos.manteinance.ServiciosAfectadosDao;
import daos.manteinance.SegmentoDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/ServiciosAfectadosServlet")
public class ServiciosAfectadosServlet extends HttpServlet {

  private final ServiciosAfectadosDao serviciosAfectadosDao =
    new ServiciosAfectadosDao();

  @Override
  protected void doGet(
    HttpServletRequest request,
    HttpServletResponse response
  ) throws ServletException, IOException {

    try {
      String clienteParam = request.getParameter("idCliente");
      String segmentoParam = request.getParameter("idSegmento");

      Integer idCliente = null;
      Integer idSegmento = null;

      if (clienteParam != null && !clienteParam.isBlank()) {
        idCliente = Integer.parseInt(clienteParam);

        if (idCliente <= 0) {
          throw new NumberFormatException();
        }
      }

      if (segmentoParam != null && !segmentoParam.isBlank()) {
        idSegmento = Integer.parseInt(segmentoParam);

        if (idSegmento <= 0) {
          throw new NumberFormatException();
        }
      }

      if (segmentoParam != null && !segmentoParam.isBlank()) {
        idSegmento = Integer.parseInt(segmentoParam);

        if (idSegmento <= 0) {
          throw new NumberFormatException();
        }
      }

      // 3. Consultar los servicios con los filtros seleccionados.
      List<ServicioAfectado> servicios =
        serviciosAfectadosDao.listarServiciosAfectados(
          idCliente,
          idSegmento
        );

      SegmentoDao segmentoDao = new SegmentoDao();

      request.setAttribute(
        "segmentos",
        segmentoDao.listarSegmentos()
      );

      request.setAttribute(
        "clientes",
        serviciosAfectadosDao.listarClientesConServiciosAfectados()
      );

      // 5. Enviar resultados y filtros seleccionados a la JSP.
      request.setAttribute("serviciosAfectados", servicios);
      request.setAttribute("idClienteSeleccionado", idCliente);
      request.setAttribute("idSegmentoSeleccionado", idSegmento);

      // 6. Mostrar la vista.
      request.getRequestDispatcher(
        "/Maintenance_coordinator/serviciosAfectados.jsp"
      ).forward(request, response);

    } catch (NumberFormatException e) {
      response.sendError(
        HttpServletResponse.SC_BAD_REQUEST,
        "Los filtros deben contener identificadores válidos."
      );

    } catch (IllegalStateException e) {
      throw new ServletException(
        "No se pudieron obtener los servicios afectados", e
      );
    }
  }
}
