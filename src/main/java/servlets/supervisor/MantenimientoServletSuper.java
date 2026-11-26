package servlets.supervisor;

import beans.maintenance.ActividadMantenimiento;
import beans.maintenance.Mantenimiento;
import beans.maintenance.ServicioAfectado;

import daos.manteinance.ActividadMantenimientoDao;
import daos.manteinance.MantenimientoDao;
import daos.manteinance.SegmentoDao;
import daos.manteinance.ServiciosAfectadosDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

@WebServlet(name = "MantenimientoServletSuper", value = "/MantenimientoServletSuper")
public class MantenimientoServletSuper extends HttpServlet {

  private final MantenimientoDao mantenimientoDao =
    new MantenimientoDao();

  private final SegmentoDao segmentoDao =
    new SegmentoDao();

  private final ActividadMantenimientoDao actividadMantenimientoDao =
    new ActividadMantenimientoDao();

  private final ServiciosAfectadosDao serviciosAfectadosDao =
    new ServiciosAfectadosDao();

  private static final int TAMANO_PAGINA = 10;

  private static final String VISTA_LISTADO =
    "/supervisor/programacion.jsp";

  private static final String VISTA_HISTORIAL =
    "/supervisor/historial_programados.jsp";

  private static final String VISTA_ESTADO =
    "/supervisor/estado_mantenimiento.jsp";

  @Override
  protected void doGet(
    HttpServletRequest request,
    HttpServletResponse response
  ) throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");

    String accion = request.getParameter("accion");

    if (accion == null || accion.isBlank()) {
      accion = "listar";
    }

    try {
      switch (accion) {

        case "listar": {
          mantenimientoDao.actualizarEstadosAutomaticamente();

          Integer idSegmentoFiltro = parsearIdOpcional(request.getParameter("idSegmento"));
          String prioridadFiltro = limpiarTextoOpcional(request.getParameter("prioridad"));

          Set<String> prioridadesValidas = Set.of("Leve", "Media", "Alta", "Crítica");
          if (prioridadFiltro != null && !prioridadesValidas.contains(prioridadFiltro)) {
            prioridadFiltro = null;
          }

          ArrayList<Mantenimiento> listaCompleta =
            mantenimientoDao.listarMantenimientosFiltrados(idSegmentoFiltro, prioridadFiltro);

          ArrayList<Mantenimiento> paginaLista =
            aplicarPaginacion(request, listaCompleta);

          request.setAttribute("mantenimientos", paginaLista);
          request.setAttribute("segmentos", segmentoDao.listarSegmentos());
          request.setAttribute("segmentoSeleccionado", idSegmentoFiltro);
          request.setAttribute("prioridadSeleccionada", prioridadFiltro);

          request.getRequestDispatcher(VISTA_LISTADO)
            .forward(request, response);

          break;
        }

        case "historial": {
          mantenimientoDao.actualizarEstadosAutomaticamente();

          Integer idSegmentoFiltro = parsearIdOpcional(request.getParameter("idSegmento"));
          String estadoFiltro = limpiarTextoOpcional(request.getParameter("estado"));

          Set<String> estadosHistorialValidos = Set.of("Finalizado", "Cancelado");
          if (estadoFiltro != null && !estadosHistorialValidos.contains(estadoFiltro)) {
            estadoFiltro = null;
          }

          ArrayList<Mantenimiento> listaCompleta =
            mantenimientoDao.listarHistorialFiltrado(idSegmentoFiltro, estadoFiltro);

          ArrayList<Mantenimiento> paginaLista =
            aplicarPaginacion(request, listaCompleta);

          request.setAttribute("historialMantenimientos", paginaLista);
          request.setAttribute("resultados", actividadMantenimientoDao.listarResultados());
          request.setAttribute("segmentos", segmentoDao.listarSegmentos());
          request.setAttribute("segmentoSeleccionado", idSegmentoFiltro);
          request.setAttribute("estadoSeleccionado", estadoFiltro);

          request.getRequestDispatcher(VISTA_HISTORIAL)
            .forward(request, response);

          break;
        }

        case "estado":
          mostrarEstado(request, response);
          break;

        default:
          response.sendError(
            HttpServletResponse.SC_BAD_REQUEST,
            "La acción solicitada no es válida."
          );
      }

    } catch (IllegalArgumentException e) {
      response.sendError(
        HttpServletResponse.SC_BAD_REQUEST,
        e.getMessage()
      );

    } catch (IllegalStateException e) {
      getServletContext().log(
        "Error consultando mantenimientos", e
      );

      response.sendError(
        HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
        "Ocurrió un error al consultar los mantenimientos."
      );
    }
  }

  private ArrayList<Mantenimiento> aplicarPaginacion(
    HttpServletRequest request,
    ArrayList<Mantenimiento> listaCompleta
  ) {
    int totalRegistros = listaCompleta.size();
    int totalPaginas = Math.max(1, (int) Math.ceil((double) totalRegistros / TAMANO_PAGINA));

    Integer paginaParam = parsearIdOpcional(request.getParameter("pagina"));
    int paginaActual = (paginaParam == null) ? 1 : paginaParam;

    if (paginaActual > totalPaginas) {
      paginaActual = totalPaginas;
    }

    int indiceInicio = (paginaActual - 1) * TAMANO_PAGINA;
    int indiceFin = Math.min(indiceInicio + TAMANO_PAGINA, totalRegistros);

    ArrayList<Mantenimiento> sublista = new ArrayList<>();
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

  private void mostrarEstado(
    HttpServletRequest request,
    HttpServletResponse response
  ) throws ServletException, IOException {

    int id = obtenerIdPositivo(
      request.getParameter("idMantenimiento"),
      "El ID del mantenimiento no es válido."
    );

    mantenimientoDao.actualizarEstadosAutomaticamente();

    Mantenimiento mantenimiento =
      mantenimientoDao.obtenerMantenimiento(id);

    if (mantenimiento == null) {
      response.sendError(
        HttpServletResponse.SC_NOT_FOUND,
        "No se encontró el mantenimiento solicitado."
      );
      return;
    }

    List<ActividadMantenimiento> actividades =
      actividadMantenimientoDao.listaPorMantenimiento(id);

    request.setAttribute("mantenimiento", mantenimiento);
    request.setAttribute("actividades", actividades);
    request.setAttribute("segmentos", segmentoDao.listarSegmentos());
    request.setAttribute("resultado", actividadMantenimientoDao.obtenerResultado(id));

    // Servicios activos que pasan por el segmento de este mantenimiento (solo si está Programado o En ejecución).
    // Se reutiliza el mismo DAO de la vista "Servicios afectados" de Maintenance, filtrando por el segmento.
    List<ServicioAfectado> serviciosAfectados = new ArrayList<>();
    if ("Programado".equals(mantenimiento.getEstado()) || "En ejecucion".equals(mantenimiento.getEstado())) {
      serviciosAfectados = serviciosAfectadosDao.listarServiciosAfectados(null, mantenimiento.getIdSegmento());
    }
    request.setAttribute("serviciosAfectados", serviciosAfectados);

    request.getRequestDispatcher(VISTA_ESTADO)
      .forward(request, response);
  }

  // Funciones auxiliares

  private Integer parsearIdOpcional(String valor) {
    if (valor == null || valor.isBlank()) {
      return null;
    }
    try {
      int id = Integer.parseInt(valor.trim());
      return id > 0 ? id : null;
    } catch (NumberFormatException e) {
      return null;
    }
  }

  private String limpiarTextoOpcional(String valor) {
    if (valor == null || valor.isBlank()) {
      return null;
    }
    return valor.trim();
  }

  private int obtenerIdPositivo(
    String valor,
    String mensajeError
  ) {
    try {
      int id = Integer.parseInt(valor);

      if (id <= 0) {
        throw new NumberFormatException();
      }

      return id;

    } catch (NumberFormatException | NullPointerException e) {
      throw new IllegalArgumentException(mensajeError);
    }
  }
}
