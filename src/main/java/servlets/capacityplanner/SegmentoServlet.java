package servlets.capacityplanner;

import beans.capacityplanner.LandingStation;
import beans.capacityplanner.Segmento;
import daos.capacityplanner.LandingStationDao;
import daos.capacityplanner.SegmentoDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@WebServlet(name = "SegmentoServlet", value = "/SegmentoServlet")
public class SegmentoServlet extends HttpServlet {
  private static final int POR_PAGINA = 10;
  private static final Set<String> ESTADOS =
    Set.of("Operativo", "Degradado", "En mantenimiento", "Fuera de servicio");
  private static final Pattern CODIGO_ESTACIONES =
    Pattern.compile("([A-Z0-9]{2,7})-([A-Z0-9]{2,7})-[0-9]+");

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
    if ("previsualizarCodigo".equals(request.getParameter("accion"))) {
      previsualizarCodigo(request, response);
      return;
    }
    boolean nuevo = "nuevo".equals(request.getParameter("accion"))
      || "nuevo".equals(request.getParameter("ventana"));
    mostrarVista(request, response, nuevo);
  }

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
    request.setCharacterEncoding("UTF-8");
    String accion = request.getParameter("accion");
    if ("eliminar".equals(accion)) {
      eliminarSegmento(request, response);
      return;
    }
    if (!"guardar".equals(accion)) {
      response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Acción no válida.");
      return;
    }

    String idTexto = texto(request.getParameter("id"));
    boolean nuevo = idTexto.isEmpty();
    int id = nuevo ? 0 : parseId(idTexto);
    if (!nuevo && id <= 0) {
      response.sendError(HttpServletResponse.SC_BAD_REQUEST, "El ID del segmento no es válido.");
      return;
    }

    Segmento segmento = new Segmento();
    segmento.setIdSegmento(id);

    segmento.setCapacidadTotal(parseCapacidad(request.getParameter("total")));
    segmento.setEstado(texto(request.getParameter("estadoSegmento")));
    request.setAttribute("segmentoFormulario", segmento);

    try {
      List<LandingStation> estaciones = new LandingStationDao().listarEstaciones();
      segmento.setIdLandingInicial(idEstacion(estaciones, request.getParameter("nombreInicial")));
      segmento.setIdLandingFinal(idEstacion(estaciones, request.getParameter("nombreFinal")));

      String error = validarSegmento(segmento);
      if (error != null) {
        mostrarError(request, response, nuevo, error);
        return;
      }

      SegmentoDao dao = new SegmentoDao();
      boolean guardado = guardarConCodigo(dao, segmento, nuevo);
      if (!guardado) {
        mostrarError(request, response, nuevo, nuevo
          ? "No se pudo guardar el segmento."
          : "El segmento no existe o la capacidad total es menor que la ocupada más la reservada.");
        return;
      }

      String destino = request.getContextPath() + "/SegmentoServlet?guardado=1&detalle="
        + segmento.getIdSegmento();
      if (!nuevo) {
        destino += "&estado=" + URLEncoder.encode(filtroEstado(request), StandardCharsets.UTF_8)
          + "&pagina=" + Math.max(1, parseId(request.getParameter("pagina")));
      }
      response.sendRedirect(destino + "#detalle");
    } catch (SQLException e) {
      getServletContext().log("Error al guardar el segmento", e);
      String mensaje = switch (e.getErrorCode()) {
        case 1062 -> "Otro registro ocupó el código del segmento. Vuelve a guardar.";
        case 1452 -> "Una de las estaciones seleccionadas no existe.";
        default -> "No se pudo guardar el segmento.";
      };
      mostrarError(request, response, nuevo, mensaje);
    }
  }

  private void eliminarSegmento(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
    HttpSession sesion = request.getSession(false);
    Object token = sesion == null ? null : sesion.getAttribute("tokenEliminarSegmento");
    if (token == null || !token.equals(request.getParameter("tokenEliminar"))) {
      response.sendError(HttpServletResponse.SC_FORBIDDEN, "Recarga la página de Segmentos e inténtalo de nuevo.");
      return;
    }

    int id = parseId(request.getParameter("id"));
    if (id <= 0) {
      response.sendError(HttpServletResponse.SC_BAD_REQUEST, "El ID del segmento no es válido.");
      return;
    }

    String resultado;
    try {
      resultado = new SegmentoDao().eliminarSegmento(id) ? "ok" : "noDisponible";
    } catch (SQLException e) {
      if (e.getErrorCode() == 1451) {
        resultado = "asociado";
      } else {
        getServletContext().log("Error al eliminar el segmento", e);
        resultado = "error";
      }
    }

    response.sendRedirect(request.getContextPath() + "/SegmentoServlet?estado="
      + URLEncoder.encode(filtroEstado(request), StandardCharsets.UTF_8)
      + "&pagina=" + Math.max(1, parseId(request.getParameter("pagina")))
      + "&eliminacion=" + resultado);
  }

  private void previsualizarCodigo(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
    try {
      List<LandingStation> estaciones = new LandingStationDao().listarEstaciones();
      int inicial = idEstacion(estaciones, request.getParameter("nombreInicial"));
      int fin = idEstacion(estaciones, request.getParameter("nombreFinal"));
      if (inicial <= 0 || fin <= 0 || inicial == fin) {
        response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        return;
      }

      response.setHeader("Cache-Control", "no-store");
      response.setContentType("text/plain;charset=UTF-8");
      response.getWriter().write(codigoPara(new SegmentoDao().listarSegmentos(),
        parseId(request.getParameter("id")), inicial, fin));
    } catch (SQLException e) {
      throw new ServletException("No se pudo calcular el código del segmento.", e);
    }
  }

  private boolean guardarConCodigo(SegmentoDao dao, Segmento segmento, boolean nuevo)
    throws SQLException {
    for (int intento = 0; intento < 3; intento++) {
      segmento.setCodigo(codigoPara(dao.listarSegmentos(), segmento.getIdSegmento(),
        segmento.getIdLandingInicial(), segmento.getIdLandingFinal()));
      try {
        return nuevo ? dao.crearSegmento(segmento) : dao.actualizarSegmento(segmento);
      } catch (SQLException e) {
        if (e.getErrorCode() != 1062 || intento == 2) {
          throw e;
        }
      }
    }
    return false;
  }

  private String codigoPara(List<Segmento> existentes, int id, int inicial, int fin)
    throws SQLException {
    Set<String> usados = new HashSet<>();
    for (Segmento existente : existentes) {
      if (id > 0 && existente.getIdSegmento() == id) {
        if (existente.getIdLandingInicial() == inicial && existente.getIdLandingFinal() == fin) {
          return existente.getCodigo();
        }
      } else {
        usados.add(existente.getCodigo().toUpperCase(Locale.ROOT));
      }
    }

    String prefijo = prefijoEstacion(existentes, inicial) + "-" + prefijoEstacion(existentes, fin) + "-";
    int numero = 1;
    String codigo = prefijo + "01";
    while (usados.contains(codigo)) {
      numero++;
      codigo = prefijo + (numero < 10 ? "0" : "") + numero;
    }
    if (codigo.length() > 20) {
      throw new SQLException("Se agotaron los códigos para las estaciones seleccionadas.");
    }
    return codigo;
  }

  private String prefijoEstacion(List<Segmento> segmentos, int id) {
    for (Segmento segmento : segmentos) {
      if (segmento.getIdLandingInicial() != id && segmento.getIdLandingFinal() != id) {
        continue;
      }
      Matcher codigo = CODIGO_ESTACIONES.matcher(segmento.getCodigo().toUpperCase(Locale.ROOT));
      if (codigo.matches()) {
        return codigo.group(segmento.getIdLandingInicial() == id ? 1 : 2);
      }
    }
    return "E" + Integer.toString(id, 36).toUpperCase(Locale.ROOT);
  }

  private int idEstacion(List<LandingStation> estaciones, String nombre) {
    for (LandingStation estacion : estaciones) {
      if (estacion.getNombre().equals(texto(nombre))) {
        return estacion.getIdLanding();
      }
    }
    return -1;
  }

  private void mostrarVista(HttpServletRequest request, HttpServletResponse response, boolean nuevo)
    throws ServletException, IOException {
    try {
      String filtro = filtroEstado(request);
      int pagina = Math.max(1, parseId(request.getParameter("pagina")));
      request.setAttribute("listaEstaciones", new LandingStationDao().listarEstaciones());
      request.setAttribute("filtroEstado", filtro);
      if (nuevo) {
        request.setAttribute("paginaActual", pagina);
        request.getRequestDispatcher("/capacity_planner/segmento_form.jsp").forward(request, response);
        return;
      }

      SegmentoDao dao = new SegmentoDao();
      int detalle = parseId(request.getParameter("detalle"));
      int editar = parseId(request.getParameter("editar"));
      List<Segmento> filtrados = new ArrayList<>();
      for (Segmento segmento : dao.listarSegmentos()) {
        if (filtro.isEmpty() || filtro.equals(segmento.getEstado())) {
          filtrados.add(segmento);
        }
        if (segmento.getIdSegmento() == detalle) {
          request.setAttribute("segmentoDetalle", segmento);
        }
        if (request.getAttribute("segmentoFormulario") instanceof Segmento formulario
          && segmento.getIdSegmento() == formulario.getIdSegmento()) {
          request.setAttribute("codigoActual", segmento.getCodigo());
        }
        if (segmento.getIdSegmento() == editar && request.getAttribute("segmentoFormulario") == null) {
          request.setAttribute("segmentoFormulario", segmento);
        }
      }
      int total = filtrados.size();
      int totalPaginas = Math.max(1, (total + POR_PAGINA - 1) / POR_PAGINA);
      pagina = Math.min(pagina, totalPaginas);
      int desde = (pagina - 1) * POR_PAGINA;
      int hasta = Math.min(desde + POR_PAGINA, total);

      HttpSession sesion = request.getSession();
      if (sesion.getAttribute("tokenEliminarSegmento") == null) {
        sesion.setAttribute("tokenEliminarSegmento", UUID.randomUUID().toString());
      }
      request.setAttribute("listaSegmentos", new ArrayList<>(filtrados.subList(desde, hasta)));
      request.setAttribute("totalSegmentos", total);
      request.setAttribute("totalPaginas", totalPaginas);
      request.setAttribute("paginaActual", pagina);
      request.getRequestDispatcher("/capacity_planner/segmentos.jsp").forward(request, response);
    } catch (SQLException e) {
      throw new ServletException("No se pudieron cargar los datos de Segmentos.", e);
    }
  }

  private void mostrarError(HttpServletRequest request, HttpServletResponse response,
                            boolean nuevo, String mensaje) throws ServletException, IOException {
    request.setAttribute("error", mensaje);
    mostrarVista(request, response, nuevo);
  }

  private String filtroEstado(HttpServletRequest request) {
    String estado = texto(request.getParameter("estado"));
    return ESTADOS.contains(estado) ? estado : "";
  }

  private String validarSegmento(Segmento segmento) {
    if (segmento.getIdLandingInicial() <= 0 || segmento.getIdLandingFinal() <= 0) {
      return "Elige las estaciones inicial y final de la lista de coincidencias.";
    }
    if (segmento.getIdLandingInicial() == segmento.getIdLandingFinal()) {
      return "Las estaciones inicial y final deben ser diferentes.";
    }
    if (segmento.getCapacidadTotal() <= 0 || segmento.getCapacidadTotal() > 4294967295L) {
      return "Ingresa una capacidad total entre 1 y 4294967295 Gbps.";
    }
    if (!ESTADOS.contains(segmento.getEstado())) {
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
