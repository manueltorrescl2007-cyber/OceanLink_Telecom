package servlets.supervisor;

import beans.supervisor.ReporteSupervisor;
import daos.supervisor.ReporteSupervisorDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "ReporteServletSuper", value = "/ReporteServletSuper")
public class ReporteServletSuper extends HttpServlet {

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");

    String tipo = texto(request.getParameter("tipo"));
    if (tipo.isEmpty()) tipo = "capacidad";

    String desde = texto(request.getParameter("desde"));
    String hasta = texto(request.getParameter("hasta"));

    String segmento = texto(request.getParameter("segmento"));
    if (segmento.isEmpty()) segmento = "Todos";

    String cliente = texto(request.getParameter("cliente"));
    if (cliente.isEmpty()) cliente = "Todos";

    String severidad = texto(request.getParameter("severidad"));
    if (severidad.isEmpty()) severidad = "Todas";

    String estado = texto(request.getParameter("estado"));
    if (estado.isEmpty()) estado = "Todos";

    ReporteSupervisorDao dao = new ReporteSupervisorDao();

    List<String> listaSegmentos = dao.listarCodigosSegmentos();
    List<String> listaClientes = dao.listarNombresClientes();
    String[] encabezados = dao.obtenerEncabezados(tipo);
    List<ReporteSupervisor> listaReporte = dao.generarReporte(tipo, desde, hasta, segmento, cliente, severidad, estado);

    request.setAttribute("listaSegmentos", listaSegmentos);
    request.setAttribute("listaClientes", listaClientes);
    request.setAttribute("encabezados", encabezados);
    request.setAttribute("listaReporte", listaReporte);

    request.setAttribute("tipoSeleccionado", tipo);
    request.setAttribute("desdeSeleccionado", desde);
    request.setAttribute("hastaSeleccionado", hasta);
    request.setAttribute("segmentoSeleccionado", segmento);
    request.setAttribute("clienteSeleccionado", cliente);
    request.setAttribute("severidadSeleccionada", severidad);
    request.setAttribute("estadoSeleccionado", estado);

    request.getRequestDispatcher("/supervisor/reportes.jsp").forward(request, response);
  }

  private String texto(String valor) {
    return valor == null ? "" : valor.trim();
  }
}
