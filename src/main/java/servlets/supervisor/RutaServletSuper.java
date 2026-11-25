package servlets.supervisor;

import beans.capacityplanner.Ruta;
import daos.capacityplanner.RutaDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "RutaServletSuper", value = "/RutaServletSuper")
public class RutaServletSuper extends HttpServlet {

  private static final int REGISTROS_POR_PAGINA = 10;

  @Override
  protected void doGet(HttpServletRequest request,
                       HttpServletResponse response)
    throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");

    String filtro = texto(request.getParameter("filtro"));
    if (!"activa".equals(filtro) && !"inactiva".equals(filtro)) {
      filtro = "Todas";
    }

    int idDetalle = parseId(request.getParameter("detalle"));

    RutaDao rutaDao = new RutaDao();

    try {
      ArrayList<Ruta> todas = rutaDao.listarRutas();
      ArrayList<Ruta> filtradas = new ArrayList<>();
      Ruta rutaDetalle = null;

      for (Ruta r : todas) {
        if (r.getIdRuta() == idDetalle) {
          rutaDetalle = r;
        }
        if (!"Todas".equals(filtro) && !filtro.equals(r.getEstado())) {
          continue;
        }
        filtradas.add(r);
      }

      int totalRegistros = filtradas.size();
      int totalPaginas = (int) Math.ceil((double) totalRegistros / REGISTROS_POR_PAGINA);
      if (totalPaginas == 0) {
        totalPaginas = 1;
      }

      int paginaActual = parsePagina(request.getParameter("pagina"), totalPaginas);
      int inicio = (paginaActual - 1) * REGISTROS_POR_PAGINA;
      int fin = Math.min(inicio + REGISTROS_POR_PAGINA, totalRegistros);

      List<Ruta> listaPaginada = new ArrayList<>();
      if (inicio < totalRegistros) {
        listaPaginada = filtradas.subList(inicio, fin);
      }

      int registroInicio = totalRegistros == 0 ? 0 : inicio + 1;
      int registroFin = fin;

      request.setAttribute("listaRutas", listaPaginada);
      request.setAttribute("filtroEstado", filtro);
      request.setAttribute("rutaDetalle", rutaDetalle);

      request.setAttribute("paginaActual", paginaActual);
      request.setAttribute("totalPaginas", totalPaginas);
      request.setAttribute("totalRegistros", totalRegistros);
      request.setAttribute("registroInicio", registroInicio);
      request.setAttribute("registroFin", registroFin);

      request.getRequestDispatcher("/supervisor/rutas.jsp")
        .forward(request, response);

    } catch (SQLException e) {
      throw new ServletException("No se pudieron cargar las rutas.", e);
    }
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

  private int parsePagina(String valor, int maxPaginas) {
    try {
      int p = Integer.parseInt(valor);
      if (p < 1) return 1;
      if (p > maxPaginas) return maxPaginas;
      return p;
    } catch (NumberFormatException e) {
      return 1;
    }
  }
}
