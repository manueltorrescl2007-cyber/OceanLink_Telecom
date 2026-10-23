package servlets;

import beans.Cliente;
import daos.ClienteDao;
import beans.Solicitud;
import daos.SolicitudDao;
import java.util.ArrayList;


import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "ClienteServlet", value = "/ClienteServlet")
public class ClienteServlet extends HttpServlet {

  // GET: listar clientes y mostrar el cliente seleccionado
  @Override
  protected void doGet(HttpServletRequest request,
                       HttpServletResponse response)
    throws ServletException, IOException {

    try {
      mostrarClientes(request, response);
    } catch (SQLException e) {
      throw new ServletException("No se pudieron cargar los clientes", e);
    }
  }

  // POST: crear, editar, activar o desactivar
  @Override
  protected void doPost(HttpServletRequest request,
                        HttpServletResponse response)
    throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");

    String action = texto(request.getParameter("action"));
    ClienteDao clienteDao = new ClienteDao();

    try {
      boolean realizado;
      String mensaje;

      switch (action) {

        case "guardar": {
          String idTexto = texto(request.getParameter("id_cliente"));
          boolean nuevo = idTexto.isEmpty();

          int idCliente = nuevo ? 0 : parseId(idTexto);

          if (!nuevo && idCliente <= 0) {
            mostrarError(request, response,
              "El identificador del cliente no es válido.");
            return;
          }

          Cliente cliente = new Cliente();
          cliente.setIdCliente(idCliente);
          cliente.setNombre(texto(request.getParameter("nombre")));
          cliente.setRazonSocial(texto(
            request.getParameter("razon_social")));
          cliente.setRuc(texto(request.getParameter("RUC")));
          cliente.setCorreo(texto(request.getParameter("correo")));
          cliente.setTelefono(texto(request.getParameter("telefono")));
          cliente.setEstado(texto(request.getParameter("estado")));

          // Conservar los datos si ocurre un error
          request.setAttribute("clienteFormulario", cliente);

          String error = validarCliente(cliente);

          if (error != null) {
            mostrarError(request, response, error);
            return;
          }

          if (nuevo) {
            realizado = clienteDao.crearCliente(cliente);
            mensaje = "creado";
          } else {
            realizado = clienteDao.actualizarCliente(cliente);
            mensaje = "actualizado";
          }

          break;
        }

        case "activar":
        case "desactivar": {
          int idCliente = parseId(
            request.getParameter("id_cliente"));

          if (idCliente <= 0) {
            mostrarError(request, response,
              "El identificador del cliente no es válido.");
            return;
          }

          String estado = "activar".equals(action)
            ? "activo" : "inactivo";

          realizado = clienteDao.cambiarEstado(idCliente, estado);
          mensaje = "activar".equals(action)
            ? "activado" : "desactivado";

          break;
        }

        default:
          response.sendError(
            HttpServletResponse.SC_BAD_REQUEST,
            "Acción no válida");
          return;
      }

      if (!realizado) {
        mostrarError(request, response,
          "No se modificó ningún cliente. "
            + "Verifica que el registro todavía exista.");
        return;
      }

      // Redirigir evita repetir el formulario al actualizar la página
      response.sendRedirect(
        request.getContextPath()
          + "/ClienteServlet?mensaje=" + mensaje);

    } catch (SQLException e) {
      getServletContext().log("Error al guardar un cliente", e);

      String mensajeError = e.getErrorCode() == 1062
        ? "El RUC o el correo ya está registrado en otro cliente."
        : "No se pudo guardar el cambio. Inténtalo nuevamente.";

      mostrarError(request, response, mensajeError);
    }
  }

  // Consultar los datos que necesita la vista
  private void mostrarClientes(HttpServletRequest request,
                               HttpServletResponse response)
    throws SQLException, ServletException, IOException {

    ClienteDao clienteDao = new ClienteDao();
    SolicitudDao solicitudDao = new SolicitudDao();

    String buscar = texto(request.getParameter("buscar"));
    String estado = texto(request.getParameter("estadoFiltro"));

    if (!"activo".equals(estado) && !"inactivo".equals(estado)) {
      estado = "";
    }

    ArrayList<Cliente> clientes =
      clienteDao.listarClientes(buscar, estado);

    request.setAttribute("listaClientes", clientes);
    request.setAttribute("buscar", buscar);
    request.setAttribute("estadoFiltro", estado);

    int idCliente = parseId(request.getParameter("id"));

    if (idCliente <= 0) {
      idCliente = parseId(request.getParameter("id_cliente"));
    }

    Cliente cliente = null;

    if (idCliente > 0) {
      cliente = clienteDao.obtenerCliente(idCliente);
    }

    // Mostrar el primer cliente si no hay uno seleccionado.
    if (cliente == null && !clientes.isEmpty()) {
      cliente = clientes.get(0);
    }

    request.setAttribute("clienteSeleccionado", cliente);

    // Consultar las solicitudes del cliente seleccionado.
    ArrayList<Solicitud> solicitudes = new ArrayList<>();

    if (cliente != null) {
      solicitudes = solicitudDao.listarSolicitudesPorCliente(
        cliente.getIdCliente()
      );
    }

    request.setAttribute("solicitudesCliente", solicitudes);

    request.getRequestDispatcher("/capacity_planner/clientes.jsp")
      .forward(request, response);
  }

  // Mostrar un error junto con la lista de clientes
  private void mostrarError(HttpServletRequest request,
                            HttpServletResponse response,
                            String mensaje)
    throws ServletException, IOException {

    request.setAttribute("error", mensaje);

    try {
      mostrarClientes(request, response);
    } catch (SQLException e) {
      throw new ServletException(
        "No se pudieron cargar los clientes", e);
    }
  }

  // Validaciones del formulario en el servidor
  private String validarCliente(Cliente cliente) {

    if (cliente.getNombre().isEmpty()
      || cliente.getNombre().length() > 100) {
      return "El nombre es obligatorio y admite hasta 100 caracteres.";
    }

    if (cliente.getRazonSocial().isEmpty()
      || cliente.getRazonSocial().length() > 150) {
      return "La razón social es obligatoria "
        + "y admite hasta 150 caracteres.";
    }

    if (!cliente.getRuc().matches("[0-9]{11}")) {
      return "El RUC debe tener exactamente 11 dígitos.";
    }

    if (cliente.getCorreo().length() > 100
      || !cliente.getCorreo().matches(
      "^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
      return "Ingresa un correo válido de hasta 100 caracteres.";
    }

    if (cliente.getTelefono().length() > 15) {
      return "El teléfono admite hasta 15 caracteres.";
    }

    if (!"activo".equals(cliente.getEstado())
      && !"inactivo".equals(cliente.getEstado())) {
      return "Selecciona un estado válido.";
    }

    return null;
  }

  // Evitar valores null y quitar espacios al inicio y al final
  private String texto(String valor) {
    return valor == null ? "" : valor.trim();
  }

  // Convertir un identificador recibido desde el formulario
  private int parseId(String valor) {
    try {
      return Integer.parseInt(valor);
    } catch (NumberFormatException e) {
      return -1;
    }
  }
}
