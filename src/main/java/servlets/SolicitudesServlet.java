package servlets;

import beans.Solicitud;
import daos.ClienteDao;
import daos.SolicitudDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "SolicitudesServlet", value = "/SolicitudesServlet")
public class SolicitudesServlet extends HttpServlet {

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
            "/capacity_planner/solicitudes.jsp"
          ).forward(request, response);
          break;

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

          solicitud.setIdUsuario(ID_USUARIO_PRUEBA);

          solicitud.setIdLandingOrigen(
            parseId(request.getParameter("id_landing_origen"))
          );

          solicitud.setIdLandingDestino(
            parseId(request.getParameter("id_landing_destino"))
          );

          solicitud.setCapacidadSolicitada(
            parseCapacidad(
              request.getParameter("capacidad_solicitada")
            )
          );

          solicitud.setJustificacion(
            texto(request.getParameter("justificacion"))
          );

          request.setAttribute("solicitud", solicitud);

          String error = validarSolicitud(solicitud);

          if (error != null) {
            request.setAttribute("error", error);
            mostrarFormulario(request, response);
            return;
          }

          boolean guardado;

          if (esNuevo) {
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

          response.sendRedirect(servlet + "?mensaje=guardado");
          break;

        case "cambiarEstado":
          int idEstado =
            parseId(request.getParameter("id_solicitud"));

          String nuevoEstado = request.getParameter("estado");

          boolean actualizado =
            solicitudDao.cambiarEstado(idEstado, nuevoEstado);

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

  private String validarSolicitud(Solicitud solicitud) {

    if (solicitud.getIdCliente() <= 0) {
      return "Selecciona un cliente.";
    }

    if (solicitud.getIdLandingOrigen() <= 0
      || solicitud.getIdLandingDestino() <= 0) {
      return "Selecciona las estaciones de origen y destino.";
    }

    if (solicitud.getIdLandingOrigen()
      == solicitud.getIdLandingDestino()) {
      return "El origen y el destino deben ser diferentes.";
    }

    if (solicitud.getCapacidadSolicitada() <= 0
      || solicitud.getCapacidadSolicitada() > 4294967295L) {
      return "Ingresa una capacidad entre 1 y 4294967295 Gbps.";
    }

    if (solicitud.getJustificacion().isEmpty()) {
      return "Ingresa una justificación.";
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
