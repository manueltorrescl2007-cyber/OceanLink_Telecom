package servlets.capacityplanner;

import beans.capacityplanner.Segmento;
import daos.capacityplanner.SegmentoDao;
import daos.capacityplanner.HistorialSegmentoDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

@WebServlet(name = "SegmentoServlet", value = "/SegmentoServlet")
public class SegmentoServlet extends HttpServlet {
  private static final Set<String> ESTADOS =
    Set.of("Normal", "Alta", "Crítica");
  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
    mostrarVista(request, response);
  }

  private void mostrarVista(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
    try {
      String filtro = filtroEstado(request);
      request.setAttribute("filtroEstado", filtro);
      SegmentoDao dao = new SegmentoDao();
      int detalle = parseId(request.getParameter("detalle"));
      List<Segmento> filtrados = new ArrayList<>();
      for (Segmento segmento : dao.listarSegmentos()) {
        if (filtro.isEmpty() || filtro.equals(nivelUtilizacion(segmento))) {
          filtrados.add(segmento);
        }
        if (segmento.getIdSegmento() == detalle) {
          request.setAttribute("segmentoDetalle", segmento);
        }
      }
      request.setAttribute("listaSegmentos", Paginacion.aplicar(request, filtrados));
      if ("historial".equals(request.getParameter("accion"))) {
        if (request.getAttribute("segmentoDetalle") == null) {
          response.sendError(HttpServletResponse.SC_NOT_FOUND, "Segmento no encontrado.");
          return;
        }
        request.setAttribute("historialSegmento", new HistorialSegmentoDao().listarPagina(
          detalle, Paginacion.numeroPagina(request.getParameter("paginaHistorial"))));
      }
      request.getRequestDispatcher("/capacity_planner/segmentos.jsp").forward(request, response);
    } catch (SQLException e) {
      throw new ServletException("No se pudieron cargar los datos de Segmentos.", e);
    }
  }

  public static String nivelUtilizacion(Segmento segmento) {
    long total = segmento.getCapacidadTotal();
    long ocupada = segmento.getCapacidadOcupada();
    if (total <= 0) return "Sin capacidad";
    if (ocupada * 100 > total * 95) return "Crítica";
    if (ocupada * 100 >= total * 80) return "Alta";
    return "Normal";
  }

  private String filtroEstado(HttpServletRequest request) {
    String estado = texto(request.getParameter("estado"));
    return ESTADOS.contains(estado) ? estado : "";
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
