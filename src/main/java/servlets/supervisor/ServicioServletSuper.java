package servlets.supervisor;

import beans.capacityplanner.Servicio;
import daos.capacityplanner.RutaDao;
import daos.capacityplanner.ServicioDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;

@WebServlet(name = "ServicioServletSuper", value = "/ServicioServletSuper")
public class ServicioServletSuper extends HttpServlet {

  private static final int TAMANO_PAGINA = 10;

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

  @Override
  protected void doPost(HttpServletRequest request,
                        HttpServletResponse response)
    throws ServletException, IOException {
    response.sendRedirect(request.getContextPath() + "/ServicioServletSuper");
  }

  private void mostrarServicios(HttpServletRequest request,
                                HttpServletResponse response)
    throws SQLException, ServletException, IOException {

    ServicioDao servicioDao = new ServicioDao();
    RutaDao rutaDao = new RutaDao();

    String estado = filtroEstado(request);
    ArrayList<Servicio> todos = servicioDao.listarServicios(estado);
    if (todos == null) {
      todos = new ArrayList<>();
    }

    request.setAttribute("listaServicios", aplicarPaginacion(request, todos));
    request.setAttribute("filtroEstado", estado);
    request.setAttribute("listaRutas", rutaDao.listarRutas());

    int idServicio = parseId(request.getParameter("servicio"));
    if (idServicio <= 0) {
      idServicio = parseId(request.getParameter("id_servicio"));
    }

    if (idServicio > 0) {
      Servicio servicio = servicioDao.obtenerServicio(idServicio);
      request.setAttribute("servicioSeleccionado", servicio);

      if (servicio != null) {
        request.setAttribute("segmentosServicio",
          rutaDao.listarSegmentosRuta(servicio.getIdRuta()));
      }
    }

    request.getRequestDispatcher("/supervisor/servicios.jsp")
      .forward(request, response);
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

  private String filtroEstado(HttpServletRequest request) {
    String estado = request.getParameter("estado");

    if (!"Pendiente".equals(estado)
      && !"Activo".equals(estado)
      && !"Suspendido".equals(estado)
      && !"Cancelado".equals(estado)) {

      return "";
    }

    return estado;
  }

  private int parseId(String valor) {
    try {
      return Integer.parseInt(valor);
    } catch (NumberFormatException e) {
      return -1;
    }
  }
}
