package servlets.capacityplanner;

import jakarta.servlet.http.HttpServletRequest;

import java.util.ArrayList;
import java.util.List;

final class Paginacion {

  private static final int POR_PAGINA = 10;

  private Paginacion() {
  }

  static <T> ArrayList<T> aplicar(HttpServletRequest request, List<T> registros) {
    int total = registros.size();
    int totalPaginas = Math.max(1, Math.ceilDiv(total, POR_PAGINA));
    int pagina = Math.min(totalPaginas, numeroPagina(request.getParameter("pagina")));
    int desde = (pagina - 1) * POR_PAGINA;
    int hasta = desde + Math.min(POR_PAGINA, total - desde);

    request.setAttribute("paginaActual", pagina);
    request.setAttribute("totalPaginas", totalPaginas);
    request.setAttribute("totalRegistros", total);
    request.setAttribute("registroInicio", total == 0 ? 0 : desde + 1);
    request.setAttribute("registroFin", hasta);
    return new ArrayList<>(registros.subList(desde, hasta));
  }

  static int numeroPagina(String valor) {
    try {
      return Math.max(1, Integer.parseInt(valor));
    } catch (NumberFormatException e) {
      return 1;
    }
  }
}
