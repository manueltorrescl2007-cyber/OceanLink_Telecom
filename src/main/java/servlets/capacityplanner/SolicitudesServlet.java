package servlets.capacityplanner;

import beans.Usuario;
import beans.capacityplanner.Solicitud;
import daos.capacityplanner.ClienteDao;
import daos.capacityplanner.SolicitudDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import services.NotificacionCapacityPlannerService;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "SolicitudesServlet", value = "/SolicitudesServlet")
public class SolicitudesServlet extends HttpServlet {

  private final NotificacionCapacityPlannerService notificaciones =
    new NotificacionCapacityPlannerService();

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

        case "lista": {
          String estado = request.getParameter("estado");
          var solicitudes = solicitudDao.listarSolicitudes(estado);

          final int porPagina = 10;
          int total = solicitudes.size();
          int totalPaginas = Math.max(1, (total + porPagina - 1) / porPagina);
          int pagina = parseId(request.getParameter("pagina"));
          pagina = Math.max(1, Math.min(pagina, totalPaginas));

          int desde = (pagina - 1) * porPagina;
          int hasta = Math.min(desde + porPagina, total);

          request.setAttribute("listaSolicitudes",
            new java.util.ArrayList<>(solicitudes.subList(desde, hasta)));
          request.setAttribute("paginaActual", pagina);
          request.setAttribute("totalPaginas", totalPaginas);
          request.setAttribute("totalSolicitudes", total);
          request.setAttribute("filtroEstado", estado == null ? "" : estado);

          int id = parseId(request.getParameter("id"));
          if (id > 0) {
            request.setAttribute("solicitudSeleccionada",
              solicitudDao.obtenerSolicitud(id));
          }

          request.getRequestDispatcher("/capacity_planner/solicitudes.jsp")
            .forward(request, response);
          break;
        }

        case "formCrear":
          mostrarFormulario(request, response);
          break;

        case "editar":
          int idSolicitud = parseId(request.getParameter("id"));
          Solicitud solicitud =
            solicitudDao.obtenerSolicitud(idSolicitud);

          if (solicitud == null) {
            response.sendError(
              HttpServletResponse.SC_NOT_FOUND,
              "La solicitud no existe."
            );
            return;
          }

          request.setAttribute("solicitud", solicitud);
          mostrarFormulario(request, response);
          break;

        default:
          response.sendRedirect(
            request.getContextPath() + "/SolicitudesServlet"
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

    request.setCharacterEncoding("UTF-8");

    String action = request.getParameter("action");
    if (action == null) {
      action = "guardar";
    }

    SolicitudDao solicitudDao = new SolicitudDao();
    String servlet =
      request.getContextPath() + "/SolicitudesServlet";

    try {
      switch (action) {

        case "guardar":
          String idTexto =
            texto(request.getParameter("id_solicitud"));

          boolean esNuevo = idTexto.isEmpty();
          int idSolicitud = esNuevo ? 0 : parseId(idTexto);

          if (!esNuevo && idSolicitud <= 0) {
            response.sendError(
              HttpServletResponse.SC_BAD_REQUEST,
              "El ID de la solicitud no es válido."
            );
            return;
          }

          Solicitud solicitud = new Solicitud();

          solicitud.setIdSolicitud(idSolicitud);

          solicitud.setIdCliente(
            parseId(request.getParameter("id_cliente"))
          );

          solicitud.setIdLandingOrigen(
            parseId(request.getParameter("id_landing_origen"))
          );

          solicitud.setIdLandingDestino(
            parseId(request.getParameter("id_landing_destino"))
          );

          String capacidadTexto = texto(request.getParameter("capacidad_solicitada"));
          solicitud.setCapacidadSolicitada(parseCapacidad(capacidadTexto));

          solicitud.setJustificacion(
            texto(request.getParameter("justificacion"))
          );

          request.setAttribute("solicitud", solicitud);

          String error = validarSolicitud(solicitud, capacidadTexto);

          if (error != null) {
            request.setAttribute("error", error);
            mostrarFormulario(request, response);
            return;
          }

          boolean guardado;

          if (esNuevo) {
            HttpSession sesion = request.getSession(false);
            Object usuarioSesion = sesion == null ? null : sesion.getAttribute("usuarioLogueado");

            if (!(usuarioSesion instanceof Usuario usuario) || usuario.getIdUsuario() <= 0) {
              response.sendRedirect(request.getContextPath() + "/LoginServlet");
              return;
            }

            solicitud.setIdUsuario(usuario.getIdUsuario());
            guardado = solicitudDao.crearSolicitud(solicitud);
          } else {
            guardado = solicitudDao.actualizarSolicitud(solicitud);
          }

          if (!guardado) {
            request.setAttribute("error",
              "No se pudo guardar. Revisa el estado de la solicitud.");
            mostrarFormulario(request, response);
            return;
          }

          if (esNuevo) {
            notificaciones.notificarSolicitud(solicitud.getIdSolicitud(), "Registrada");
          }

          response.sendRedirect(servlet + "?mensaje=guardado");
          break;

        case "cambiarEstado":
          int idEstado =
            parseId(request.getParameter("id_solicitud"));

          String nuevoEstado = request.getParameter("estado");

          boolean actualizado =
            solicitudDao.cambiarEstado(idEstado, nuevoEstado);

          if (actualizado) {
            String estadoNotificado = "En evaluacion".equals(nuevoEstado)
              ? "En evaluación" : nuevoEstado;
            notificaciones.notificarSolicitud(idEstado, estadoNotificado);
          }

          String mensajeEstado = actualizado
            ? "estadoActualizado"
            : "cambioNoPermitido";

          response.sendRedirect(
            servlet + "?id=" + idEstado
              + "&mensaje=" + mensajeEstado
          );
          break;

        case "eliminar":
          int idEliminar =
            parseId(request.getParameter("id_solicitud"));

          boolean eliminado =
            solicitudDao.eliminarSolicitud(idEliminar);

          String mensajeEliminar = eliminado
            ? "eliminado"
            : "eliminacionNoPermitida";

          response.sendRedirect(
            servlet + "?mensaje=" + mensajeEliminar
          );
          break;

        default:
          response.sendRedirect(servlet);
      }

    } catch (SQLException e) {
      throw new ServletException(
        "Error al guardar los cambios de la solicitud.", e
      );
    }
  }

  // Carga los clientes y estaciones para crear o editar.
  private void mostrarFormulario(HttpServletRequest request,
                                 HttpServletResponse response)
    throws SQLException, ServletException, IOException {

    ClienteDao clienteDao = new ClienteDao();
    SolicitudDao solicitudDao = new SolicitudDao();

    request.setAttribute("listaClientes",
      clienteDao.listarClientes(null, "activo"));

    request.setAttribute("listaEstaciones",
      solicitudDao.listarEstacionesActivas());

    request.getRequestDispatcher(
      "/capacity_planner/solicitud_form.jsp"
    ).forward(request, response);
  }

  private String validarSolicitud(Solicitud solicitud, String capacidadTexto) {

    if (solicitud.getIdCliente() <= 0
      || solicitud.getIdLandingOrigen() <= 0
      || solicitud.getIdLandingDestino() <= 0
      || capacidadTexto.isEmpty()
      || solicitud.getJustificacion().isEmpty()) {
      return "Completa todos los campos para continuar.";
    }

    if (solicitud.getIdLandingOrigen()
      == solicitud.getIdLandingDestino()) {
      return "El origen y el destino deben ser diferentes.";
    }

    if (solicitud.getCapacidadSolicitada() <= 0
      || solicitud.getCapacidadSolicitada() > 4294967295L) {
      return "Ingresa una capacidad entre 1 y 4294967295 Gbps.";
    }

    return null;
  }

  private int parseId(String valor) {
    try {
      return Integer.parseInt(valor);
    } catch (NumberFormatException e) {
      return -1;
    }
  }

  private long parseCapacidad(String valor) {
    try {
      return Long.parseLong(valor);
    } catch (NumberFormatException e) {
      return -1;
    }
  }

  private String texto(String valor) {
    return valor == null ? "" : valor.trim();
  }
}
