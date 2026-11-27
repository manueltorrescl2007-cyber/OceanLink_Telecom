package servlets.capacityplanner;

import beans.capacityplanner.LandingStation;
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
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.regex.Pattern;

@WebServlet(name = "RutaServlet", value = "/RutaServlet")
public class RutaServlet extends HttpServlet {
  private static final Pattern NOMBRE_RUTA =
    Pattern.compile("([A-Z0-9]{2,12})-([A-Z0-9]{2,12})-R[0-9]+");
  private static final Pattern CODIGO_SEGMENTO =
    Pattern.compile("([A-Z0-9]{2,12})-([A-Z0-9]{2,12})-[0-9]+");

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
    RutaDao dao = new RutaDao();
    try {
      if (request.getParameter("editar") != null) {
        Ruta ruta = dao.obtenerRuta(id(request.getParameter("editar")));
        if (ruta == null) {
          response.sendError(HttpServletResponse.SC_NOT_FOUND, "La ruta no existe.");
          return;
        }
        request.setAttribute("rutaFormulario", ruta);
        mostrarFormulario(request, response);
      } else if ("nuevo".equals(request.getParameter("ventana"))) {
        mostrarFormulario(request, response);
      } else {
        mostrarRutas(request, response, dao);
      }
    } catch (SQLException e) {
      throw new ServletException("No se pudieron cargar las rutas.", e);
    }
  }

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
    request.setCharacterEncoding("UTF-8");
    String accion = texto(request.getParameter("accion"));
    if (accion.isEmpty() && (request.getParameter("elegir_origen") != null
      || request.getParameter("elegir_destino") != null)) {
      accion = "actualizar";
    }
    RutaDao dao = new RutaDao();
    try {
      if (Set.of("guardar", "actualizar", "agregar", "quitar", "buscarRecorrido").contains(accion)) {
        procesarFormulario(request, response, dao, accion);
      } else if ("eliminar".equals(accion)) {
        int idRuta = id(request.getParameter("id_ruta"));
        if (idRuta > 0 && dao.eliminarRuta(idRuta)) {
          response.sendRedirect(urlLista(request) + "&eliminado=1");
        } else {
          request.setAttribute("error", "No se pudo eliminar. La ruta puede no existir o tener servicios asociados.");
          mostrarRutas(request, response, dao);
        }
      } else {
        request.setAttribute("error", "Actualiza la página y vuelve a intentar la acción.");
        mostrarRutas(request, response, dao);
      }
    } catch (SQLException e) {
      getServletContext().log("Error al guardar cambios de una ruta", e);
      String mensaje = switch (e.getErrorCode()) {
        case 1062 -> "El nombre de la ruta ya está en uso. Intenta guardar nuevamente.";
        case 1451 -> "La ruta tiene registros asociados.";
        case 1452 -> "Una estación o un segmento seleccionado ya no existe.";
        default -> "No se pudo guardar el cambio. Intenta nuevamente.";
      };
      request.setAttribute("error", mensaje);
      try {
        if (Set.of("guardar", "actualizar", "agregar", "quitar", "buscarRecorrido").contains(accion)) {
          mostrarFormulario(request, response);
        } else {
          mostrarRutas(request, response, dao);
        }
      } catch (SQLException carga) {
        throw new ServletException("No se pudieron cargar las rutas.", carga);
      }
    }
  }

  private void procesarFormulario(HttpServletRequest request, HttpServletResponse response, RutaDao dao, String accion)
    throws SQLException, ServletException, IOException {
    String idTexto = texto(request.getParameter("id_ruta"));
    boolean nueva = idTexto.isEmpty();
    int idRuta = nueva ? 0 : id(idTexto);
    Ruta actual = nueva ? null : dao.obtenerRuta(idRuta);
    if (!nueva && actual == null) {
      response.sendError(HttpServletResponse.SC_NOT_FOUND, "La ruta no existe.");
      return;
    }

    Ruta ruta = new Ruta();
    ruta.setIdRuta(idRuta);
    ruta.setNombre(actual == null ? "" : actual.getNombre());
    List<LandingStation> estaciones = new LandingStationDao().listarEstaciones();
    List<Segmento> segmentos = new SegmentoDao().listarSegmentos();
    ruta.setIdLandingOrigen(idEstacionFormulario(request, estaciones, "origen"));
    ruta.setIdLandingDestino(idEstacionFormulario(request, estaciones, "destino"));
    ruta.setEstado(texto(request.getParameter("estado_ruta")));

    int origen = ruta.getIdLandingOrigen();
    int destino = ruta.getIdLandingDestino();
    String codigos = texto(request.getParameter("segmentos"));
    if ("buscarRecorrido".equals(accion)) {
      if (origen <= 0 || destino <= 0 || origen == destino) {
        request.setAttribute("error", "Selecciona estaciones de origen y destino diferentes.");
      } else {
        List<Segmento> sugeridos = buscarRecorrido(origen, destino, segmentos);
        if (sugeridos.isEmpty()) {
          request.setAttribute("error", "No hay un recorrido disponible entre las estaciones seleccionadas.");
        } else {
          codigos = sugeridos.stream().map(Segmento::getCodigo).collect(Collectors.joining(","));
        }
      }
    } else if ("quitar".equals(accion)) {
      codigos = codigos.contains(",") ? codigos.substring(0, codigos.lastIndexOf(',')) : "";
    } else if ("agregar".equals(accion)) {
      String siguiente = texto(request.getParameter("siguiente"));
      if (!siguiente.isEmpty() && segmentos.stream().anyMatch(s -> s.getCodigo().equals(siguiente))) {
        codigos = codigos.isEmpty() ? siguiente : codigos + "," + siguiente;
      }
    }

    request.setAttribute("rutaFormulario", ruta);
    request.setAttribute("segmentosFormulario", codigos);
    ruta.setNombre(origen > 0 && destino > 0 && origen != destino
      ? nombreRuta(dao.listarRutas(), segmentos, idRuta, origen, destino) : "");

    if (!"guardar".equals(accion)) {
      mostrarFormulario(request, response);
      return;
    }

    String error = validarRuta(ruta, codigos, estaciones, segmentos);
    if (error != null) {
      request.setAttribute("error", error);
      mostrarFormulario(request, response);
      return;
    }

    for (int intento = 0; intento < 3; intento++) {
      ruta.setNombre(nombreRuta(dao.listarRutas(), segmentos, idRuta,
        ruta.getIdLandingOrigen(), ruta.getIdLandingDestino()));
      try {
        boolean guardada = nueva ? dao.crearRuta(ruta) : dao.actualizarRuta(ruta);
        if (guardada) {
          response.sendRedirect(urlLista(request) + "&guardado=1&detalle=" + ruta.getIdRuta() + "#detalle-ruta");
        } else {
          request.setAttribute("error", "No se pudo guardar. La ruta puede no existir o tener servicios asociados.");
          mostrarFormulario(request, response);
        }
        return;
      } catch (SQLException e) {
        if (e.getErrorCode() != 1062 || intento == 2) {
          throw e;
        }
      }
    }
  }

  private int idEstacionFormulario(HttpServletRequest request, List<LandingStation> estaciones,
                                   String extremo) {
    String elegido = request.getParameter("elegir_" + extremo);
    if (elegido == null) {
      return idEstacion(estaciones, request.getParameter(extremo));
    }

    int idEstacion = id(elegido);
    for (LandingStation estacion : estaciones) {
      if (estacion.getIdLanding() == idEstacion) {
        request.setAttribute("estacion_" + extremo, estacion.getNombre());
        return idEstacion;
      }
    }
    return -1;
  }

  private int idEstacion(List<LandingStation> estaciones, String nombre) {
    return estaciones.stream()
      .filter(estacion -> estacion.getNombre().equalsIgnoreCase(texto(nombre)))
      .mapToInt(LandingStation::getIdLanding)
      .findFirst().orElse(-1);
  }

  private String nombreRuta(List<Ruta> rutas, List<Segmento> segmentos, int idRuta, int origen, int destino) {
    Set<String> nombres = new HashSet<>();
    for (Ruta ruta : rutas) {
      if (ruta.getIdRuta() == idRuta) {
        if (ruta.getIdLandingOrigen() == origen && ruta.getIdLandingDestino() == destino) {
          return ruta.getNombre();
        }
      } else {
        nombres.add(ruta.getNombre().toUpperCase(Locale.ROOT));
      }
    }

    String base = prefijo(rutas, segmentos, origen) + "-" + prefijo(rutas, segmentos, destino) + "-R";
    int numero = 1;
    String nombre;
    do {
      nombre = base + String.format(Locale.ROOT, "%02d", numero++);
    } while (nombres.contains(nombre));
    return nombre;
  }

  private String prefijo(List<Ruta> rutas, List<Segmento> segmentos, int estacion) {
    for (Ruta ruta : rutas) {
      boolean origen = ruta.getIdLandingOrigen() == estacion;
      if (origen || ruta.getIdLandingDestino() == estacion) {
        var nombre = NOMBRE_RUTA.matcher(ruta.getNombre().toUpperCase(Locale.ROOT));
        if (nombre.matches()) return nombre.group(origen ? 1 : 2);
      }
    }

    for (Segmento segmento : segmentos) {
      boolean inicial = segmento.getIdLandingInicial() == estacion;
      if (inicial || segmento.getIdLandingFinal() == estacion) {
        var codigo = CODIGO_SEGMENTO.matcher(segmento.getCodigo().toUpperCase(Locale.ROOT));
        if (codigo.matches()) return codigo.group(inicial ? 1 : 2);
      }
    }
    return "E" + Integer.toString(estacion, 36).toUpperCase(Locale.ROOT);
  }

  private String validarRuta(Ruta ruta, String codigos, List<LandingStation> estaciones, List<Segmento> disponibles) {
    int origen = ruta.getIdLandingOrigen();
    int destino = ruta.getIdLandingDestino();
    if (!estacionExiste(estaciones, origen) || !estacionExiste(estaciones, destino)) {
      return "Selecciona las estaciones de origen y destino.";
    }
    if (origen == destino) return "El origen y el destino deben ser diferentes.";
    if (!Set.of("activa", "inactiva").contains(ruta.getEstado())) return "Selecciona un estado válido.";
    if (codigos.isEmpty()) return "Añade al menos un segmento al recorrido.";

    ArrayList<Segmento> seleccionados = new ArrayList<>();
    Set<Integer> usados = new HashSet<>();
    int actual = origen;
    for (String codigo : codigos.split(",", -1)) {
      Segmento encontrado = null;
      for (Segmento segmento : disponibles) {
        if (segmento.getCodigo().equalsIgnoreCase(codigo.trim())) {
          encontrado = segmento;
          break;
        }
      }
      if (encontrado == null) return "Revisa el segmento seleccionado: " + codigo;
      if (!usados.add(encontrado.getIdSegmento())) return "No puedes repetir el segmento: " + codigo;
      if (encontrado.getIdLandingInicial() != actual) return "El segmento " + codigo + " no continúa el recorrido.";
      seleccionados.add(encontrado);
      actual = encontrado.getIdLandingFinal();
    }
    if (actual != destino) return "El último segmento debe terminar en la estación de destino.";
    ruta.setSegmentos(seleccionados);
    return null;
  }

  static List<Segmento> buscarRecorrido(int origen, int destino, List<Segmento> segmentos) {
    ArrayDeque<Integer> pendientes = new ArrayDeque<>();
    Map<Integer, Segmento> llegada = new HashMap<>();
    pendientes.add(origen);
    llegada.put(origen, null);

    // La búsqueda por niveles encuentra primero el recorrido de menos tramos.
    while (!pendientes.isEmpty() && !llegada.containsKey(destino)) {
      int actual = pendientes.remove();
      for (Segmento segmento : segmentos) {
        int siguiente = segmento.getIdLandingFinal();
        if (segmento.getIdLandingInicial() == actual
          && !"Fuera de servicio".equals(segmento.getEstado())
          && !llegada.containsKey(siguiente)) {
          llegada.put(siguiente, segmento);
          pendientes.add(siguiente);
        }
      }
    }

    if (!llegada.containsKey(destino)) return List.of();
    List<Segmento> recorrido = new ArrayList<>();
    for (int actual = destino; actual != origen; ) {
      Segmento tramo = llegada.get(actual);
      recorrido.add(tramo);
      actual = tramo.getIdLandingInicial();
    }
    Collections.reverse(recorrido);
    return recorrido;
  }

  public static Set<Integer> estacionesConCaminoAlDestino(
    int destino, Set<Integer> visitadas, List<Segmento> segmentos) {
    Set<Integer> alcanzables = new HashSet<>();
    if (visitadas.contains(destino)) return alcanzables;
    alcanzables.add(destino);

    // Recorre las conexiones hacia atrás desde el destino.
    boolean huboCambios;
    do {
      huboCambios = false;
      for (Segmento segmento : segmentos) {
        int inicial = segmento.getIdLandingInicial();
        if (!visitadas.contains(inicial)
          && alcanzables.contains(segmento.getIdLandingFinal())
          && alcanzables.add(inicial)) {
          huboCambios = true;
        }
      }
    } while (huboCambios);
    return alcanzables;
  }

  private boolean estacionExiste(List<LandingStation> estaciones, int idEstacion) {
    return estaciones.stream().anyMatch(estacion -> estacion.getIdLanding() == idEstacion);
  }

  private void mostrarFormulario(HttpServletRequest request, HttpServletResponse response)
    throws SQLException, ServletException, IOException {
    request.setAttribute("vistaFormulario", true);
    request.setAttribute("listaEstaciones", new LandingStationDao().listarEstaciones());
    request.setAttribute("listaSegmentos", new SegmentoDao().listarSegmentos());
    request.getRequestDispatcher("/capacity_planner/ruta_form.jsp").forward(request, response);
  }

  private void mostrarRutas(HttpServletRequest request, HttpServletResponse response, RutaDao dao)
    throws SQLException, ServletException, IOException {
    String filtro = filtro(request);
    List<Ruta> rutas = dao.listarRutas();
    List<Ruta> filtradas = rutas.stream().filter(ruta -> "Todas".equals(filtro) || filtro.equals(ruta.getEstado())).toList();
    int detalle = id(request.getParameter("detalle"));
    if (detalle <= 0 && "eliminar".equals(request.getParameter("accion"))) {
      detalle = id(request.getParameter("id_ruta"));
    }
    for (Ruta ruta : rutas) {
      if (ruta.getIdRuta() == detalle) {
        request.setAttribute("rutaDetalle", ruta);
        break;
      }
    }

    request.setAttribute("listaRutas", Paginacion.aplicar(request, filtradas));
    request.getRequestDispatcher("/capacity_planner/rutas.jsp").forward(request, response);
  }

  private String urlLista(HttpServletRequest request) {
    return request.getContextPath() + "/RutaServlet?filtro=" + filtro(request)
      + "&pagina=" + Math.max(1, id(request.getParameter("pagina")));
  }

  private String filtro(HttpServletRequest request) {
    String valor = texto(request.getParameter("filtro"));
    return Set.of("activa", "inactiva").contains(valor) ? valor : "Todas";
  }

  private String texto(String valor) {
    return valor == null ? "" : valor.trim();
  }

  private int id(String valor) {
    try {
      return Integer.parseInt(valor);
    } catch (NumberFormatException e) {
      return -1;
    }
  }
}

