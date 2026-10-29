package servlets;

import beans.Segmento;
import beans.Solicitud;
import daos.SegmentoDao;
import daos.ServicioDao;
import daos.SolicitudDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;

@WebServlet(name = "CapacityPlannerServlet", value = "/CapacityPlannerServlet")
public class CapacityPlannerServlet extends HttpServlet {

  @Override
  protected void doGet(HttpServletRequest request,
                       HttpServletResponse response)
    throws ServletException, IOException {

    SolicitudDao solicitudDao = new SolicitudDao();
    SegmentoDao segmentoDao = new SegmentoDao();
    ServicioDao servicioDao = new ServicioDao();

    try {
      ArrayList<Solicitud> solicitudes =
        solicitudDao.listarSolicitudes();

      ArrayList<Segmento> segmentos =
        segmentoDao.listarSegmentos();

      ArrayList<Solicitud> acciones = new ArrayList<>();

      int pendientesEvaluacion = 0;
      int aprobadas = 0;
      int pendientesCapacidad = 0;

      for (Solicitud solicitud : solicitudes) {
        String estado = solicitud.getEstado();

        if ("Registrada".equals(estado)
          || "En evaluacion".equals(estado)) {
          pendientesEvaluacion++;
        }

        if ("Aprobada".equals(estado)) {
          aprobadas++;
        }

        if ("Pendiente por capacidad".equals(estado)) {
          pendientesCapacidad++;
        }

        if ("Registrada".equals(estado)
          || "En evaluacion".equals(estado)
          || "Aprobada".equals(estado)
          || "Pendiente por capacidad".equals(estado)) {
          acciones.add(solicitud);
        }
      }

      int estables = 0;
      int limitados = 0;
      int criticos = 0;

      // Clasificar según capacidad ocupada + reservada
      for (Segmento segmento : segmentos) {
        long total = segmento.getCapacidadTotal();

        if (total <= 0) {
          criticos++;
          continue;
        }

        double porcentaje =
          (segmento.getCapacidadOcupada()
            + segmento.getCapacidadReservada()) * 100.0 / total;

        if (porcentaje < 80) {
          estables++;
        } else if (porcentaje <= 95) {
          limitados++;
        } else {
          criticos++;
        }
      }

      request.setAttribute("totalSolicitudes", solicitudes.size());
      request.setAttribute("pendientesEvaluacion", pendientesEvaluacion);
      request.setAttribute("solicitudesAprobadas", aprobadas);
      request.setAttribute("pendientesCapacidad", pendientesCapacidad);

      request.setAttribute("serviciosActivos",
        servicioDao.listarServicios("Activo").size());

      request.setAttribute("segmentosEstables", estables);
      request.setAttribute("segmentosLimitados", limitados);
      request.setAttribute("segmentosCriticos", criticos);
      request.setAttribute("accionesPendientes", acciones);

      request.getRequestDispatcher(
        "/capacity_planner/capacity_planner.jsp"
      ).forward(request, response);

    } catch (SQLException e) {
      throw new ServletException(
        "No se pudieron cargar los datos del dashboard.", e);
    }
  }
}
