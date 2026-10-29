package servlets;

import beans.Servicio;
import daos.RutaDao;
import daos.ServicioDao;
import daos.SolicitudDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "ServicioServlet", value = "/ServicioServlet")
public class ServicioServlet extends HttpServlet {

  // Mostrar la lista y el detalle de un servicio
  @Override
  protected void doGet(HttpServletRequest request,
                       HttpServletResponse response)
    throws ServletException, IOException {

    try {
      mostrarServicios(request, response);
    } catch (SQLException e) {
      throw new ServletException(
        "No se pudieron cargar los servicios.", e);
    }
  }

  // Crear, activar o cancelar un servicio

  @Override
  protected void doPost(HttpServletRequest request,
                        HttpServletResponse response)
    throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");

    String accion = request.getParameter("accion");
    String servlet = request.getContextPath() + "/ServicioServlet";

    if (accion == null) {
      accion = "";
    }

    ServicioDao servicioDao = new ServicioDao();

    try {
      switch (accion) {

        case "guardar": {
          Servicio servicio = new Servicio();

          servicio.setIdSolicitud(parseId(
            request.getParameter("id_solicitud")));

          servicio.setIdRuta(parseId(
            request.getParameter("id_ruta")));

          request.setAttribute("servicioFormulario", servicio);
          request.setAttribute("mostrarFormulario", true);

          if (servicio.getIdSolicitud() <= 0
            || servicio.getIdRuta() <= 0) {

            mostrarError(request, response,
              "Selecciona una solicitud y una ruta.");
            return;
          }

          boolean creado = servicioDao.crearServicio(servicio);

          if (!creado) {
            mostrarError(request, response,
              "No se pudo crear el servicio. "
                + "La solicitud debe estar aprobada y sin "
                + "otro servicio vigente. La ruta debe estar "
                + "activa, conectar el origen con el destino "
                + "y tener capacidad suficiente.");
            return;
          }

          response.sendRedirect(servlet
            + "?guardado=1&servicio="
            + servicio.getIdServicio());
          break;
        }

        case "activar": {
          int idServicio = parseId(
            request.getParameter("id_servicio"));

          if (idServicio <= 0) {
            mostrarError(request, response,
              "El identificador del servicio no es válido.");
            return;
          }

          boolean activado =
            servicioDao.activarServicio(idServicio);

          if (!activado) {
            mostrarError(request, response,
              "No se pudo activar el servicio. "
                + "Debe estar Pendiente y su solicitud "
                + "Provisionada. Revisa también el estado "
                + "de la ruta y la reserva de sus segmentos.");
            return;
          }

          response.sendRedirect(servlet
            + "?activado=1&servicio=" + idServicio);
          break;
        }

        case "suspender": {
          int idServicio = parseId(
            request.getParameter("id_servicio"));

          if (idServicio <= 0) {
            mostrarError(request, response,
              "El identificador del servicio no es válido.");
            return;
          }

          boolean suspendido =
            servicioDao.suspenderServicio(idServicio);

          if (!suspendido) {
            mostrarError(request, response,
              "Solo se puede suspender un servicio Activo.");
            return;
          }

          response.sendRedirect(servlet
            + "?suspendido=1&servicio=" + idServicio);
          break;
        }

        case "cancelar": {
          int idServicio = parseId(
            request.getParameter("id_servicio"));

          if (idServicio <= 0) {
            mostrarError(request, response,
              "El identificador del servicio no es válido.");
            return;
          }

          boolean cancelado =
            servicioDao.cancelarServicio(idServicio);

          if (!cancelado) {
            mostrarError(request, response,
              "No se pudo cancelar el servicio. "
                + "Debe estar Pendiente, Activo o Suspendido, "
                + "y su capacidad debe estar registrada "
                + "correctamente en los segmentos.");
            return;
          }

          response.sendRedirect(servlet
            + "?cancelado=1&servicio=" + idServicio);
          break;
        }

        case "reactivar": {
          int idServicio = parseId(
            request.getParameter("id_servicio"));

          if (idServicio <= 0) {
            mostrarError(request, response,
              "El identificador del servicio no es válido.");
            return;
          }

          boolean reactivado =
            servicioDao.reactivarServicio(idServicio);

          if (!reactivado) {
            mostrarError(request, response,
              "No se pudo reactivar el servicio. "
                + "Debe estar Suspendido, con su solicitud Activa. "
                + "Revisa también la ruta, sus segmentos "
                + "y la capacidad asignada.");
            return;
          }

          response.sendRedirect(servlet
            + "?reactivado=1&servicio=" + idServicio);
          break;
        }

        default:
          response.sendError(
            HttpServletResponse.SC_BAD_REQUEST,
            "Acción no válida.");
      }

    } catch (SQLException e) {
      getServletContext().log(
        "Error al modificar un servicio", e);

      mostrarError(request, response,
        "No se pudo completar la operación. "
          + "Inténtalo nuevamente.");
    }
  }

  // Cargar los datos que necesita servicios.jsp
  private void mostrarServicios(HttpServletRequest request,
                                HttpServletResponse response)
    throws SQLException, ServletException, IOException {

    ServicioDao servicioDao = new ServicioDao();
    SolicitudDao solicitudDao = new SolicitudDao();
    RutaDao rutaDao = new RutaDao();

    String estado = request.getParameter("estado");

    if (!"Pendiente".equals(estado)
      && !"Activo".equals(estado)
      && !"Suspendido".equals(estado)
      && !"Cancelado".equals(estado)) {

      estado = "";
    }

    request.setAttribute("listaServicios",
      servicioDao.listarServicios(estado));

    request.setAttribute("filtroEstado", estado);

    // Solicitudes disponibles para crear un servicio
    request.setAttribute("listaSolicitudes",
      solicitudDao.listarSolicitudes("Aprobada"));

    // Cada ruta incluye sus segmentos y capacidad disponible
    request.setAttribute("listaRutas",
      rutaDao.listarRutas());

    int idServicio = parseId(
      request.getParameter("servicio"));

    // Conservar el detalle al mostrar un error de activar o cancelar
    if (idServicio <= 0) {
      idServicio = parseId(
        request.getParameter("id_servicio"));
    }

    if (idServicio > 0) {
      Servicio servicio =
        servicioDao.obtenerServicio(idServicio);

      request.setAttribute("servicioSeleccionado", servicio);

      if (servicio != null) {
        request.setAttribute("segmentosServicio",
          rutaDao.listarSegmentosRuta(servicio.getIdRuta()));
      }
    }

    request.getRequestDispatcher("/capacity_planner/servicios.jsp")
      .forward(request, response);
  }

  // Mostrar un error junto con la página de servicios
  private void mostrarError(HttpServletRequest request,
                            HttpServletResponse response,
                            String mensaje)
    throws ServletException, IOException {

    request.setAttribute("error", mensaje);

    try {
      mostrarServicios(request, response);
    } catch (SQLException e) {
      throw new ServletException(
        "No se pudieron cargar los servicios.", e);
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
