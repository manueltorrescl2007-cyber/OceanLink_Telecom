package servlets;

import beans.Ruta;
import beans.Segmento;
import daos.LandingStationDao;
import daos.RutaDao;
import daos.SegmentoDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;

@WebServlet(name = "RutaServlet", value = "/RutaServlet")
public class RutaServlet extends HttpServlet {

  // Mostrar las rutas y los datos necesarios para el formulario
  @Override
  protected void doGet(HttpServletRequest request,
                       HttpServletResponse response)
    throws ServletException, IOException {

    try {
      mostrarRutas(request, response);
    } catch (SQLException e) {
      throw new ServletException(
        "No se pudieron cargar las rutas.", e);
    }
  }

  // Crear, editar o eliminar una ruta
  @Override
  protected void doPost(HttpServletRequest request,
                        HttpServletResponse response)
    throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");

    String accion = texto(request.getParameter("accion"));
    String servlet = request.getContextPath() + "/RutaServlet";
    RutaDao rutaDao = new RutaDao();

    try {
      switch (accion) {

        case "guardar": {
          String idTexto = texto(
            request.getParameter("id_ruta"));
          boolean nuevo = idTexto.isEmpty();

          Ruta ruta = new Ruta();
          ruta.setIdRuta(nuevo ? 0 : parseId(idTexto));
          ruta.setNombre(texto(request.getParameter("nombre")));
          ruta.setIdLandingOrigen(parseId(
            request.getParameter("id_landing_origen")));
          ruta.setIdLandingDestino(parseId(
            request.getParameter("id_landing_destino")));
          ruta.setEstado(texto(
            request.getParameter("estado_ruta")));

          String codigos = texto(
            request.getParameter("segmentos"));

          // Conservar lo escrito si hay un error
          request.setAttribute("rutaFormulario", ruta);
          request.setAttribute("segmentosFormulario", codigos);

          if (!nuevo && ruta.getIdRuta() <= 0) {
            mostrarError(request, response,
              "El identificador de la ruta no es válido.");
            return;
          }

          String error = validarRuta(ruta, codigos);

          if (error != null) {
            mostrarError(request, response, error);
            return;
          }

          boolean guardado;

          if (nuevo) {
            guardado = rutaDao.crearRuta(ruta);
          } else {
            guardado = rutaDao.actualizarRuta(ruta);
          }

          if (!guardado) {
            mostrarError(request, response,
              "No se pudo guardar. La ruta puede no existir "
                + "o tener servicios asociados.");
            return;
          }

          response.sendRedirect(servlet
            + "?guardado=1&detalle=" + ruta.getIdRuta());
          break;
        }

        case "eliminar": {
          int idRuta = parseId(
            request.getParameter("id_ruta"));

          if (idRuta <= 0) {
            mostrarError(request, response,
              "El identificador de la ruta no es válido.");
            return;
          }

          boolean eliminado = rutaDao.eliminarRuta(idRuta);

          if (!eliminado) {
            mostrarError(request, response,
              "No se pudo eliminar. La ruta puede no existir "
                + "o tener servicios asociados.");
            return;
          }

          response.sendRedirect(servlet + "?eliminado=1");
          break;
        }

        default:
          response.sendError(
            HttpServletResponse.SC_BAD_REQUEST,
            "Acción no válida.");
      }

    } catch (SQLException e) {
      getServletContext().log(
        "Error al guardar cambios de una ruta", e);

      String mensaje;

      if (e.getErrorCode() == 1062) {
        mensaje = "Ya existe una ruta con ese nombre "
          + "o se ha repetido un segmento.";
      } else if (e.getErrorCode() == 1451) {
        mensaje = "No se puede modificar o eliminar la ruta "
          + "porque tiene registros asociados.";
      } else if (e.getErrorCode() == 1452) {
        mensaje = "Una estación o un segmento seleccionado "
          + "ya no existe.";
      } else {
        mensaje = "No se pudo guardar el cambio. "
          + "Inténtalo nuevamente.";
      }

      mostrarError(request, response, mensaje);
    }
  }

  // Cargar la información que utilizará rutas.jsp
  private void mostrarRutas(HttpServletRequest request,
                            HttpServletResponse response)
    throws SQLException, ServletException, IOException {

    RutaDao rutaDao = new RutaDao();
    LandingStationDao estacionDao = new LandingStationDao();
    SegmentoDao segmentoDao = new SegmentoDao();

    request.setAttribute("listaRutas",
      rutaDao.listarRutas());

    request.setAttribute("listaEstaciones",
      estacionDao.listarEstaciones());

    request.setAttribute("listaSegmentos",
      segmentoDao.listarSegmentos());

    request.getRequestDispatcher("/capacity_planner/rutas.jsp")
      .forward(request, response);
  }

  // Mostrar el error conservando los datos del formulario
  private void mostrarError(HttpServletRequest request,
                            HttpServletResponse response,
                            String mensaje)
    throws ServletException, IOException {

    request.setAttribute("error", mensaje);

    try {
      mostrarRutas(request, response);
    } catch (SQLException e) {
      throw new ServletException(
        "No se pudieron cargar las rutas.", e);
    }
  }

  // Validar los datos y construir la lista ordenada de segmentos
  private String validarRuta(Ruta ruta, String codigos)
    throws SQLException {

    if (ruta.getNombre().isEmpty()
      || ruta.getNombre().length() > 100) {
      return "El nombre es obligatorio y admite hasta 100 caracteres.";
    }

    if (ruta.getIdLandingOrigen() <= 0
      || ruta.getIdLandingDestino() <= 0) {
      return "Selecciona las estaciones de origen y destino.";
    }

    if (ruta.getIdLandingOrigen() == ruta.getIdLandingDestino()) {
      return "El origen y el destino deben ser diferentes.";
    }

    if (!"activa".equals(ruta.getEstado())
      && !"inactiva".equals(ruta.getEstado())) {
      return "Selecciona un estado válido.";
    }

    if (codigos.isEmpty()) {
      return "Ingresa al menos un segmento.";
    }

    SegmentoDao segmentoDao = new SegmentoDao();
    ArrayList<Segmento> disponibles = segmentoDao.listarSegmentos();
    ArrayList<Segmento> seleccionados = new ArrayList<>();
    ArrayList<Integer> idsUsados = new ArrayList<>();

    int estacionActual = ruta.getIdLandingOrigen();

    // Los códigos llegan separados por comas
    for (String codigo : codigos.split(",", -1)) {
      codigo = codigo.trim();

      if (codigo.isEmpty()) {
        return "Revisa los códigos: hay un segmento vacío "
          + "entre comas o al final.";
      }

      Segmento encontrado = null;

      for (Segmento segmento : disponibles) {
        if (segmento.getCodigo().equalsIgnoreCase(codigo)) {
          encontrado = segmento;
          break;
        }
      }

      if (encontrado == null) {
        return "No existe el segmento: " + codigo;
      }

      if (idsUsados.contains(encontrado.getIdSegmento())) {
        return "No puedes repetir el segmento: " + codigo;
      }

      if (encontrado.getIdLandingInicial() != estacionActual) {
        return "El segmento " + codigo
          + " no continúa el recorrido. "
          + "Revisa el origen y el orden de los segmentos.";
      }

      seleccionados.add(encontrado);
      idsUsados.add(encontrado.getIdSegmento());
      estacionActual = encontrado.getIdLandingFinal();
    }

    if (estacionActual != ruta.getIdLandingDestino()) {
      return "El último segmento no termina "
        + "en la estación de destino seleccionada.";
    }

    ruta.setSegmentos(seleccionados);
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
}
