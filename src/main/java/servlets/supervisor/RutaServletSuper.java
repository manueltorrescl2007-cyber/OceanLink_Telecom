package servlets.supervisor;

import beans.capacityplanner.Ruta;
import beans.capacityplanner.Segmento;
import daos.capacityplanner.LandingStationDao;
import daos.capacityplanner.RutaDao;
import daos.capacityplanner.SegmentoDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;

@WebServlet(name = "RutaServletSuper", value = "/RutaServletSuper")
public class RutaServletSuper extends HttpServlet {

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

    request.getRequestDispatcher("/supervisor/rutas.jsp")
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
