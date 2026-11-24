package servlets.admin;

import beans.Usuario;
import beans.capacityplanner.LandingStation;
import beans.capacityplanner.Segmento;
import daos.admin.LandingStationAdminDao;
import daos.admin.SegmentoAdminDao;
import services.NotificacionAdminService;

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
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@WebServlet(name = "SegmentoAdminServlet", value = "/SegmentoAdminServlet")
public class SegmentoAdminServlet extends HttpServlet {

  private static final int POR_PAGINA = 10;
  private static final Set<String> ESTADOS =
    Set.of("Operativo", "Degradado", "En mantenimiento", "Fuera de servicio");
  private static final Pattern CODIGO_ESTACIONES =
    Pattern.compile("([A-Z0-9]{2,7})-([A-Z0-9]{2,7})-[0-9]+");

  private final NotificacionAdminService notificacionAdminService = new NotificacionAdminService();

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

    String action = request.getParameter("action") == null ? "lista" : request.getParameter("action");
    SegmentoAdminDao segmentoDao = new SegmentoAdminDao();
    LandingStationAdminDao stationDao = new LandingStationAdminDao();

    try {
      switch (action) {
        case "formCrear":
          request.setAttribute("listaEstaciones", stationDao.listarEstaciones(""));
          request.setAttribute("filtroEstado", filtroEstado(request));
          request.setAttribute("paginaActual", Math.max(1, parseId(request.getParameter("pagina"))));
          request.getRequestDispatcher("/admin/segmento_form.jsp").forward(request, response);
          break;

        case "editar":
          int idEditar = parseId(request.getParameter("id"));
          Segmento segEditar = segmentoDao.obtenerSegmento(idEditar);
          if (segEditar == null) {
            response.sendRedirect(request.getContextPath() + "/SegmentoAdminServlet");
          } else {
            request.setAttribute("segmento", segEditar);
            request.setAttribute("listaEstaciones", stationDao.listarEstaciones(""));
            request.setAttribute("filtroEstado", filtroEstado(request));
            request.setAttribute("paginaActual", Math.max(1, parseId(request.getParameter("pagina"))));
            request.getRequestDispatcher("/admin/segmento_form.jsp").forward(request, response);
          }
          break;

        case "eliminar":
          int idEliminar = parseId(request.getParameter("id"));
          try {
            boolean eliminado = segmentoDao.eliminarSegmento(idEliminar);
            response.sendRedirect(urlListado(request, eliminado ? "eliminado" : "noDisponible"));
          } catch (SQLException e) {
            if (e.getErrorCode() == 1451) {
              response.sendRedirect(urlListado(request, "asociado"));
            } else {
              throw e;
            }
          }
          break;

        case "lista":
        default:
          mostrarLista(request, response, segmentoDao);
          break;
      }
    } catch (SQLException e) {
      throw new ServletException("Error en la gestión de Segmentos.", e);
    }
  }

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");
    String action = request.getParameter("action") == null ? "guardar" : request.getParameter("action");

    if (!"guardar".equals(action)) {
      response.sendRedirect(request.getContextPath() + "/SegmentoAdminServlet");
      return;
    }

    String idTexto = texto(request.getParameter("idSegmento"));
    boolean esNuevo = idTexto.isEmpty();
    int id = esNuevo ? 0 : parseId(idTexto);

    if (!esNuevo && id <= 0) {
      response.sendRedirect(request.getContextPath() + "/SegmentoAdminServlet");
      return;
    }

    Segmento segmento = new Segmento();
    segmento.setIdSegmento(id);
    segmento.setIdLandingInicial(parseId(request.getParameter("idLandingInicial")));
    segmento.setIdLandingFinal(parseId(request.getParameter("idLandingFinal")));
    segmento.setCapacidadTotal(parseCapacidad(request.getParameter("capacidadTotal")));
    segmento.setEstado(texto(request.getParameter("estadoSegmento")));

    SegmentoAdminDao segmentoDao = new SegmentoAdminDao();
    LandingStationAdminDao stationDao = new LandingStationAdminDao();

    try {
      String error = validarSegmento(segmento);
      if (error != null) {
        reenviarFormularioError(request, response, stationDao, segmentoDao, segmento, error);
        return;
      }

      Segmento anterior = esNuevo ? null : segmentoDao.obtenerSegmento(id);

      boolean guardado = guardarConCodigo(segmentoDao, segmento, esNuevo);
      if (!guardado) {
        String msg = esNuevo
          ? "No se pudo registrar el segmento."
          : "El segmento no existe o la capacidad total es menor que la capacidad ocupada + reservada.";
        reenviarFormularioError(request, response, stationDao, segmentoDao, segmento, msg);
        return;
      }

      Segmento completo = segmentoDao.obtenerSegmento(segmento.getIdSegmento());
      String tramo = (completo != null && completo.getNombreInicial() != null && completo.getNombreFinal() != null)
        ? completo.getNombreInicial() + " -> " + completo.getNombreFinal()
        : "Landing #" + segmento.getIdLandingInicial() + " -> Landing #" + segmento.getIdLandingFinal();

      boolean esAlertaCritica = !"Operativo".equalsIgnoreCase(segmento.getEstado());
      String accionTexto = esNuevo ? "Nuevo segmento registrado" : "Actualización de segmento";
      String detalle = "Tramo: " + tramo
        + " | Capacidad total: " + segmento.getCapacidadTotal() + " Gbps"
        + " | Estado: " + segmento.getEstado();
      if (anterior != null && !anterior.getEstado().equalsIgnoreCase(segmento.getEstado())) {
        detalle += " (estado anterior: " + anterior.getEstado() + ")";
      }

      notificacionAdminService.notificarCambioInfraestructura(
        "Segmento submarino",
        accionTexto,
        segmento.getCodigo(),
        detalle,
        esAlertaCritica,
        obtenerUsuarioSesion(request)
      );

      response.sendRedirect(urlListado(request, "guardado"));
    } catch (SQLException e) {
      String msg = switch (e.getErrorCode()) {
        case 1062 -> "El código generado ya existe. Intenta guardar nuevamente.";
        case 1452 -> "Una de las Landing Stations seleccionadas no existe.";
        default -> "Error al guardar el segmento en la base de datos.";
      };
      try {
        reenviarFormularioError(request, response, stationDao, segmentoDao, segmento, msg);
      } catch (SQLException ex) {
        throw new ServletException("Error al recargar el formulario de segmento.", ex);
      }
    }
  }

  private void mostrarLista(HttpServletRequest request, HttpServletResponse response, SegmentoAdminDao dao)
    throws SQLException, ServletException, IOException {

    String filtro = filtroEstado(request);
    int idDetalle = parseId(request.getParameter("detalle"));

    ArrayList<Segmento> filtrados = new ArrayList<>();
    for (Segmento s : dao.listarSegmentos()) {
      if (filtro.isEmpty() || filtro.equals(s.getEstado())) {
        filtrados.add(s);
      }
      if (s.getIdSegmento() == idDetalle) {
        request.setAttribute("segmentoDetalle", s);
      }
    }

    int totalRegistros = filtrados.size();
    int totalPaginas = Math.max(1, (totalRegistros + POR_PAGINA - 1) / POR_PAGINA);
    int paginaActual = Math.max(1, Math.min(parseId(request.getParameter("pagina")), totalPaginas));

    int desde = (paginaActual - 1) * POR_PAGINA;
    int hasta = Math.min(desde + POR_PAGINA, totalRegistros);
    ArrayList<Segmento> paginaLista = new ArrayList<>(filtrados.subList(desde, hasta));

    int registroInicio = totalRegistros == 0 ? 0 : desde + 1;
    int registroFin = totalRegistros == 0 ? 0 : hasta;

    request.setAttribute("listaSegmentos", paginaLista);
    request.setAttribute("filtroEstado", filtro);
    request.setAttribute("totalRegistros", totalRegistros);
    request.setAttribute("totalPaginas", totalPaginas);
    request.setAttribute("paginaActual", paginaActual);
    request.setAttribute("registroInicio", registroInicio);
    request.setAttribute("registroFin", registroFin);

    request.getRequestDispatcher("/admin/segmentos.jsp").forward(request, response);
  }

  private void reenviarFormularioError(HttpServletRequest request, HttpServletResponse response,
                                       LandingStationAdminDao stationDao, SegmentoAdminDao segmentoDao,
                                       Segmento segmento, String error)
    throws SQLException, ServletException, IOException {
    if (segmento.getIdSegmento() > 0) {
      Segmento actual = segmentoDao.obtenerSegmento(segmento.getIdSegmento());
      if (actual != null) {
        segmento.setCodigo(actual.getCodigo());
        segmento.setCapacidadOcupada(actual.getCapacidadOcupada());
        segmento.setCapacidadReservada(actual.getCapacidadReservada());
      }
    }
    request.setAttribute("error", error);
    request.setAttribute("segmento", segmento);
    request.setAttribute("listaEstaciones", stationDao.listarEstaciones(""));
    request.setAttribute("filtroEstado", filtroEstado(request));
    request.setAttribute("paginaActual", Math.max(1, parseId(request.getParameter("pagina"))));
    request.getRequestDispatcher("/admin/segmento_form.jsp").forward(request, response);
  }

  private boolean guardarConCodigo(SegmentoAdminDao dao, Segmento segmento, boolean esNuevo)
    throws SQLException {
    for (int intento = 0; intento < 3; intento++) {
      segmento.setCodigo(codigoPara(
        dao.listarSegmentos(),
        segmento.getIdSegmento(),
        segmento.getIdLandingInicial(),
        segmento.getIdLandingFinal()
      ));
      try {
        return esNuevo ? dao.crearSegmento(segmento) : dao.actualizarSegmento(segmento);
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

  private Usuario obtenerUsuarioSesion(HttpServletRequest request) {
    HttpSession sesion = request.getSession(false);
    if (sesion != null && sesion.getAttribute("usuarioLogueado") instanceof Usuario u) {
      return u;
    }
    return null;
  }

  private String urlListado(HttpServletRequest request, String msg) {
    String filtro = filtroEstado(request);
    int pagina = Math.max(1, parseId(request.getParameter("pagina")));
    StringBuilder sb = new StringBuilder(request.getContextPath())
      .append("/SegmentoAdminServlet?pagina=").append(pagina);
    if (!filtro.isEmpty()) {
      sb.append("&estado=").append(URLEncoder.encode(filtro, StandardCharsets.UTF_8));
    }
    if (msg != null && !msg.isEmpty()) {
      sb.append("&msg=").append(msg);
    }
    return sb.toString();
  }

  private String filtroEstado(HttpServletRequest request) {
    String estado = texto(request.getParameter("estado"));
    return ESTADOS.contains(estado) ? estado : "";
  }

  private String validarSegmento(Segmento segmento) {
    if (segmento.getIdLandingInicial() <= 0 || segmento.getIdLandingFinal() <= 0) {
      return "Selecciona una estación inicial y una estación final.";
    }
    if (segmento.getIdLandingInicial() == segmento.getIdLandingFinal()) {
      return "La estación inicial y final deben ser diferentes.";
    }
    if (segmento.getCapacidadTotal() <= 0 || segmento.getCapacidadTotal() > 4294967295L) {
      return "Ingresa una capacidad total válida entre 1 y 4294967295 Gbps.";
    }
    if (!ESTADOS.contains(segmento.getEstado())) {
      return "Selecciona un estado operativo válido.";
    }
    return null;
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

  private String texto(String valor) {
    return valor == null ? "" : valor.trim();
  }
}
