package servlets.supervisor;

import beans.supervisor.HistoricoGeneral;
import daos.supervisor.HistoricoSupervisorDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "HistoricoServletSuper", value = "/HistoricoServletSuper")
public class HistoricoServletSuper extends HttpServlet {

  private static final int REGISTROS_POR_PAGINA = 10;

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");

    String desde = texto(request.getParameter("desde"));
    String hasta = texto(request.getParameter("hasta"));
    String origen = texto(request.getParameter("origen"));
    String segmento = texto(request.getParameter("segmento"));

    HistoricoSupervisorDao dao = new HistoricoSupervisorDao();
    List<String> listaSegmentos = dao.listarCodigosSegmentos();
    List<HistoricoGeneral> todos = dao.listarHistoricoConsolidado(desde, hasta, origen, segmento);

    int totalRegistros = todos.size();
    int totalPaginas = (int) Math.ceil((double) totalRegistros / REGISTROS_POR_PAGINA);
    if (totalPaginas == 0) {
      totalPaginas = 1;
    }

    int paginaActual = parsePagina(request.getParameter("pagina"), totalPaginas);
    int inicio = (paginaActual - 1) * REGISTROS_POR_PAGINA;
    int fin = Math.min(inicio + REGISTROS_POR_PAGINA, totalRegistros);

    List<HistoricoGeneral> listaPaginada = new ArrayList<>();
    if (inicio < totalRegistros) {
      listaPaginada = todos.subList(inicio, fin);
    }

    request.setAttribute("listaHistorico", listaPaginada);
    request.setAttribute("listaSegmentos", listaSegmentos);

    request.setAttribute("desdeSeleccionado", desde);
    request.setAttribute("hastaSeleccionado", hasta);
    request.setAttribute("origenSeleccionado", origen);
    request.setAttribute("segmentoSeleccionado", segmento);

    request.setAttribute("paginaActual", paginaActual);
    request.setAttribute("totalPaginas", totalPaginas);
    request.setAttribute("totalRegistros", totalRegistros);

    request.getRequestDispatcher("/supervisor/historicos.jsp").forward(request, response);
  }

  private int parsePagina(String param, int maxPaginas) {
    try {
      int p = Integer.parseInt(param);
      if (p < 1) return 1;
      if (p > maxPaginas) return maxPaginas;
      return p;
    } catch (NumberFormatException e) {
      return 1;
    }
  }

  private String texto(String valor) {
    return valor == null ? "" : valor.trim();
  }
}
