package servlets.supervisor;

import beans.capacityplanner.Cliente;
import beans.capacityplanner.Servicio;
import beans.capacityplanner.Solicitud;
import daos.capacityplanner.ClienteDao;
import daos.capacityplanner.ServicioDao;
import daos.capacityplanner.SolicitudDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;

@WebServlet(name = "ClienteServletSuper", value = "/ClienteServletSuper")
public class ClienteServletSuper extends HttpServlet {

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

  @Override
  protected void doPost(HttpServletRequest request,
                        HttpServletResponse response)
    throws ServletException, IOException {
    response.sendRedirect(request.getContextPath() + "/ClienteServletSuper");
  }

  private void mostrarClientes(HttpServletRequest request,
                               HttpServletResponse response)
    throws SQLException, ServletException, IOException {

    ClienteDao clienteDao = new ClienteDao();
    SolicitudDao solicitudDao = new SolicitudDao();
    ServicioDao servicioDao = new ServicioDao();

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

    if (cliente == null && !clientes.isEmpty()) {
      cliente = clientes.get(0);
    }

    request.setAttribute("clienteSeleccionado", cliente);

    ArrayList<Solicitud> solicitudes = new ArrayList<>();
    ArrayList<Servicio> servicios = new ArrayList<>();

    if (cliente != null) {
      solicitudes = solicitudDao.listarSolicitudesPorCliente(
        cliente.getIdCliente());

      servicios = servicioDao.listarServiciosPorCliente(
        cliente.getIdCliente());
    }

    request.setAttribute("solicitudesCliente", solicitudes);
    request.setAttribute("listaServiciosCliente", servicios);

    request.getRequestDispatcher("/supervisor/clientes.jsp")
      .forward(request, response);
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
}
