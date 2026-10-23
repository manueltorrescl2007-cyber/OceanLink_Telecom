package servlets;

import beans.Segmento;
import daos.SegmentoDao;
import daos.LandingStationDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "SegmentoServlet", value = "/SegmentoServlet")
public class SegmentoServlet extends HttpServlet {

  @Override
  protected void doGet(HttpServletRequest request,
                       HttpServletResponse response)
    throws ServletException, IOException {

    try {
      mostrarSegmentos(request, response);
    } catch (SQLException e) {
      throw new ServletException(
        "No se pudieron cargar los segmentos.", e);
    }
  }

  @Override
  protected void doPost(HttpServletRequest request,
                        HttpServletResponse response)
    throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");

    if (!"guardar".equals(request.getParameter("accion"))) {
      response.sendError(
        HttpServletResponse.SC_BAD_REQUEST,
        "Acción no válida.");
      return;
    }

    String idTexto = texto(request.getParameter("id"));
    boolean esNuevo = idTexto.isEmpty();
    int idSegmento = esNuevo ? 0 : parseId(idTexto);

    if (!esNuevo && idSegmento <= 0) {
      response.sendError(
        HttpServletResponse.SC_BAD_REQUEST,
        "El ID del segmento no es válido.");
      return;
    }

    Segmento segmento = new Segmento();

    segmento.setIdSegmento(idSegmento);
    segmento.setCodigo(texto(request.getParameter("codigo")));
    segmento.setIdLandingInicial(
      parseId(request.getParameter("inicial")));
    segmento.setIdLandingFinal(
      parseId(request.getParameter("final")));
    segmento.setCapacidadTotal(
      parseCapacidad(request.getParameter("total")));
    segmento.setEstado(
      texto(request.getParameter("estadoSegmento")));

    // Conservar los datos si ocurre un error.
    request.setAttribute("segmentoFormulario", segmento);

    String error = validarSegmento(segmento);

    if (error != null) {
      mostrarError(request, response, error);
      return;
    }

    SegmentoDao segmentoDao = new SegmentoDao();

    try {
      boolean guardado;

      if (esNuevo) {
        guardado = segmentoDao.crearSegmento(segmento);
      } else {
        guardado = segmentoDao.actualizarSegmento(segmento);
      }

      if (!guardado) {
        mostrarError(request, response,
          "El segmento no existe o la capacidad total "
            + "es menor que la ocupada más la reservada.");
        return;
      }

      response.sendRedirect(
        request.getContextPath()
          + "/SegmentoServlet?guardado=1&detalle="
          + segmento.getIdSegmento() + "#detalle");

    } catch (SQLException e) {
      getServletContext().log("Error al guardar el segmento", e);

      String mensaje;

      if (e.getErrorCode() == 1062) {
        mensaje = "Ya existe un segmento con ese código.";
      } else if (e.getErrorCode() == 1452) {
        mensaje = "Una de las estaciones seleccionadas no existe.";
      } else {
        mensaje = "No se pudo guardar el segmento.";
      }

      mostrarError(request, response, mensaje);
    }
  }

  private void mostrarSegmentos(HttpServletRequest request,
                                HttpServletResponse response)
    throws SQLException, ServletException, IOException {

    SegmentoDao segmentoDao = new SegmentoDao();
    LandingStationDao landingStationDao = new LandingStationDao();

    request.setAttribute("listaSegmentos",
      segmentoDao.listarSegmentos());

    request.setAttribute("listaEstaciones",
      landingStationDao.listarEstaciones());

    request.getRequestDispatcher(
      "/capacity_planner/segmentos.jsp"
    ).forward(request, response);
  }

  private void mostrarError(HttpServletRequest request,
                            HttpServletResponse response,
                            String mensaje)
    throws ServletException, IOException {

    request.setAttribute("error", mensaje);

    try {
      mostrarSegmentos(request, response);
    } catch (SQLException e) {
      throw new ServletException(
        "No se pudieron cargar los segmentos.", e);
    }
  }

  private String validarSegmento(Segmento segmento) {

    if (segmento.getCodigo().isEmpty()
      || segmento.getCodigo().length() > 20) {
      return "Escribe un código de hasta 20 caracteres.";
    }

    if (segmento.getIdLandingInicial() <= 0
      || segmento.getIdLandingFinal() <= 0) {
      return "Selecciona las estaciones inicial y final.";
    }

    if (segmento.getIdLandingInicial()
      == segmento.getIdLandingFinal()) {
      return "Las estaciones inicial y final deben ser diferentes.";
    }

    if (segmento.getCapacidadTotal() <= 0
      || segmento.getCapacidadTotal() > 4294967295L) {
      return "Ingresa una capacidad total entre 1 y 4294967295 Gbps.";
    }

    String estado = segmento.getEstado();

    if (!"Operativo".equals(estado)
      && !"Degradado".equals(estado)
      && !"En mantenimiento".equals(estado)
      && !"Fuera de servicio".equals(estado)) {
      return "Selecciona un estado válido.";
    }

    return null;
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

  private long parseCapacidad(String valor) {
    try {
      return Long.parseLong(valor);
    } catch (NumberFormatException e) {
      return -1;
    }
  }
}
