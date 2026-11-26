package servlets.maintenance;

import beans.maintenance.Mantenimiento;
import beans.Usuario;
import beans.maintenance.ActividadMantenimiento;

import daos.manteinance.MantenimientoDao;
import daos.manteinance.SegmentoDao;
import daos.manteinance.ActividadMantenimientoDao;

import services.NotificacionService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Set;
import java.util.List;

@WebServlet(name = "MantenimientoServlet", value = "/MantenimientoServlet")
public class MantenimientoServlet extends HttpServlet {

  private final MantenimientoDao mantenimientoDao =
    new MantenimientoDao();

  private final SegmentoDao segmentoDao =
    new SegmentoDao();

  private final ActividadMantenimientoDao actividadMantenimientoDao =
    new ActividadMantenimientoDao();

  private final NotificacionService notificacionService =
    new NotificacionService();

  private static final int TAMANO_PAGINA = 10;

  private static final String VISTA_LISTADO =
    "/Maintenance_coordinator/fechas_duracion.jsp";

  private static final String VISTA_HISTORIAL =
    "/Maintenance_coordinator/historial.jsp";

  private static final String VISTA_NUEVO =
    "/Maintenance_coordinator/nuevo_mantenimiento.jsp";

  private static final String VISTA_EDICION =
    "/Maintenance_coordinator/editar_mantenimiento.jsp";

  private static final String VISTA_ESTADO =
    "/Maintenance_coordinator/estado.jsp";

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

        case "editar":
          mantenimientoDao.actualizarEstadosAutomaticamente();
          mostrarEdicion(request, response);
          break;

        case "estado":
          mostrarEstado(request, response);
          break;

        case "nuevo":
          request.setAttribute(
            "segmentos",
            segmentoDao.listarSegmentosParaFormulario()
          );

          request.getRequestDispatcher(VISTA_NUEVO)
            .forward(request, response);
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

  @Override
  protected void doPost(
    HttpServletRequest request,
    HttpServletResponse response
  ) throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");

    String accion = request.getParameter("accion");

    if (accion == null || accion.isBlank()) {
      response.sendError(
        HttpServletResponse.SC_BAD_REQUEST,
        "No se indicó la acción solicitada."
      );
      return;
    }

    try {
      switch (accion) {

        case "crear":
          crearMantenimiento(request, response);
          break;

        case "actualizar":
          actualizarMantenimiento(request, response);
          break;

        case "cancelar":
          cancelarMantenimiento(request, response);
          break;

        case "comentar":
          agregarComentario(request, response);
          break;

        default:
          response.sendError(
            HttpServletResponse.SC_BAD_REQUEST,
            "La acción solicitada no es válida."
          );
      }

    } catch (DateTimeParseException e) {
      response.sendError(
        HttpServletResponse.SC_BAD_REQUEST,
        "Las fechas no tienen un formato válido."
      );

    } catch (IllegalArgumentException e) {
      response.sendError(
        HttpServletResponse.SC_BAD_REQUEST,
        e.getMessage()
      );

    } catch (IllegalStateException e) {
      getServletContext().log(
        "Error procesando un mantenimiento", e
      );

      response.sendError(
        HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
        "Ocurrió un error al procesar el mantenimiento."
      );
    }
  }

  private void mostrarEdicion(
    HttpServletRequest request,
    HttpServletResponse response
  ) throws ServletException, IOException {

    int id = obtenerIdPositivo(
      request.getParameter("idMantenimiento"),
      "El ID del mantenimiento no es válido."
    );

    Mantenimiento mantenimiento =
      mantenimientoDao.obtenerMantenimiento(id);

    if (mantenimiento == null) {
      response.sendError(
        HttpServletResponse.SC_NOT_FOUND,
        "No se encontró el mantenimiento solicitado."
      );
      return;
    }

    if (!"Programado".equals(mantenimiento.getEstado())) {
      response.sendError(
        HttpServletResponse.SC_CONFLICT,
        "Solo se pueden editar mantenimientos programados."
      );
      return;
    }

    request.setAttribute("mantenimiento", mantenimiento);
    request.setAttribute("segmentos", segmentoDao.listarSegmentosParaFormulario());

    request.getRequestDispatcher(VISTA_EDICION)
      .forward(request, response);
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

    List<ActividadMantenimiento> actividades = actividadMantenimientoDao.listaPorMantenimiento(id);

    request.setAttribute("mantenimiento", mantenimiento);
    request.setAttribute("actividades", actividades);
    request.setAttribute("resultado", actividadMantenimientoDao.obtenerResultado(id));

    request.getRequestDispatcher(VISTA_ESTADO)
      .forward(request, response);
  }

  private void crearMantenimiento(
    HttpServletRequest request,
    HttpServletResponse response
  ) throws ServletException, IOException {

    try {
      Mantenimiento mantenimiento = leerFormulario(request);

      Integer idUsuario = obtenerIdUsuarioSesion(request);

      if (idUsuario == null) {
        response.sendError(
          HttpServletResponse.SC_UNAUTHORIZED,
          "Inicia sesión para registrar un mantenimiento."
        );
        return;
      }

      mantenimiento.setIdUsuario(idUsuario);

      int idMantenimiento =
        mantenimientoDao.crearMantenimiento(mantenimiento);

      mantenimiento.setIdMantenimiento(idMantenimiento);

      notificacionService.notificarCreacion(mantenimiento);

      redirigirListado(request, response, "creado");

    } catch (DateTimeParseException e) {
      volverAFormularioConError(request, response, VISTA_NUEVO, null, "Las fechas ingresadas no tienen un formato válido.");

    } catch (IllegalArgumentException e) {
      volverAFormularioConError(request, response, VISTA_NUEVO, null, e.getMessage());
    }
  }

  private void actualizarMantenimiento(
    HttpServletRequest request,
    HttpServletResponse response
  ) throws ServletException, IOException {

    int id = obtenerIdPositivo(
      request.getParameter("idMantenimiento"),
      "El ID del mantenimiento no es válido."
    );

    try {
      Mantenimiento anterior =
        mantenimientoDao.obtenerMantenimiento(id);

      Mantenimiento mantenimiento = leerFormulario(request);
      mantenimiento.setIdMantenimiento(id);

      boolean actualizado =
        mantenimientoDao.actualizarMantenimiento(mantenimiento);

      if (!actualizado) {
        response.sendError(
          HttpServletResponse.SC_CONFLICT,
          "No se pudo actualizar. El registro puede no existir "
            + "o haber dejado de estar programado."
        );
        return;
      }

      boolean fechasModificadas =
        !anterior.getFechaInicio().equals(
          mantenimiento.getFechaInicio()) ||
          !anterior.getFechaFin().equals(mantenimiento.getFechaFin()
          );

      if (fechasModificadas) {
        notificacionService.notificarReprogramacion(
          anterior,
          mantenimiento
        );
      }

      redirigirListado(request, response, "actualizado");

    } catch (DateTimeParseException e) {
      volverAFormularioConError(request, response, VISTA_EDICION, id, "Las fechas ingresadas no tienen un formato válido.");

    } catch (IllegalArgumentException e) {
      volverAFormularioConError(request, response, VISTA_EDICION, id, e.getMessage());
    }
  }

  private void volverAFormularioConError(
    HttpServletRequest request,
    HttpServletResponse response,
    String vistaJsp,
    Integer idMantenimiento,
    String mensajeError
  ) throws ServletException, IOException {

    Mantenimiento borrador = reconstruirBorrador(request);
    if (idMantenimiento != null) {
      borrador.setIdMantenimiento(idMantenimiento);
    }

    request.setAttribute("error", mensajeError);
    request.setAttribute("mantenimiento", borrador);
    request.setAttribute("segmentos", segmentoDao.listarSegmentosParaFormulario());

    request.getRequestDispatcher(vistaJsp)
      .forward(request, response);
  }

  private Mantenimiento reconstruirBorrador(HttpServletRequest request) {
    Mantenimiento m = new Mantenimiento();

    Integer idSeg = parsearIdOpcional(request.getParameter("idSegmento"));
    if (idSeg != null) {
      m.setIdSegmento(idSeg);
    }

    m.setTipo(limpiarTextoOpcional(request.getParameter("tipo")));

    String prio = limpiarTextoOpcional(request.getParameter("prioridad"));
    if ("Critica".equalsIgnoreCase(prio)) {
      prio = "Crítica";
    }
    m.setPrioridad(prio);

    try {
      String fIni = limpiarTextoOpcional(request.getParameter("fechaInicio"));
      if (fIni != null) {
        m.setFechaInicio(LocalDateTime.parse(fIni));
      }
    } catch (DateTimeParseException ignored) {
    }

    try {
      String fFin = limpiarTextoOpcional(request.getParameter("fechaFin"));
      if (fFin != null) {
        m.setFechaFin(LocalDateTime.parse(fFin));
      }
    } catch (DateTimeParseException ignored) {
    }

    String desc = request.getParameter("descripcionGeneral");
    m.setDescripcionGeneral(desc == null ? "" : desc.trim());

    return m;
  }

  private void cancelarMantenimiento(
    HttpServletRequest request,
    HttpServletResponse response
  ) throws IOException {

    int id = obtenerIdPositivo(
      request.getParameter("idMantenimiento"),
      "El ID del mantenimiento no es válido."
    );

    Mantenimiento anterior =
      mantenimientoDao.obtenerMantenimiento(id);

    boolean cancelado =
      mantenimientoDao.cancelarMantenimiento(id);

    if (!cancelado) {
      response.sendError(
        HttpServletResponse.SC_CONFLICT,
        "No se pudo cancelar el mantenimiento. "
          + "Verifica que exista y no haya finalizado "
          + "ni sido cancelado."
      );
      return;
    }

    if (anterior != null) {
      notificacionService.notificarCancelacion(anterior);
    }

    redirigirListado(request, response, "cancelado");
  }

  private void agregarComentario(HttpServletRequest request, HttpServletResponse response)
    throws IOException {

    int id = obtenerIdPositivo(request.getParameter("idMantenimiento"), "El ID del mantenimiento no es valido");

    Integer idUsuario = obtenerIdUsuarioSesion(request);

    if (idUsuario == null) {
      response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Debe iniciar sesión para registrar el comentario");
      return;
    }

    Mantenimiento mantenimiento = mantenimientoDao.obtenerMantenimiento(id);

    if (mantenimiento == null) {
      response.sendError(HttpServletResponse.SC_NOT_FOUND, "No se encontró el mantenimiento");
      return;
    }

    String comentario = obtenerParametro(request, "comentario");

    // Si el mantenimiento ya está Finalizado, lo que se escribe es su RESULTADO (una sola vez).
    // Mientras está Programado o En ejecución, es un comentario normal de la bitácora.
    String tipoActividad = "Comentario";

    if ("Finalizado".equals(mantenimiento.getEstado())) {
      if (actividadMantenimientoDao.obtenerResultado(id) != null) {
        // Ya tiene resultado: no se puede registrar otro
        response.sendRedirect(request.getContextPath()
          + "/MantenimientoServlet?accion=estado&idMantenimiento=" + id);
        return;
      }
      tipoActividad = ActividadMantenimientoDao.TIPO_RESULTADO;
    }

    ActividadMantenimiento actividad = new ActividadMantenimiento();
    actividad.setIdMantenimiento(id);
    actividad.setIdUsuario(idUsuario);
    actividad.setDescripcionBitacora(comentario);
    actividad.setTipoActividad(tipoActividad);

    boolean registrado = actividadMantenimientoDao.crearActividad(actividad);

    if (!registrado) {
      throw new IllegalStateException("No se pudo registrar el comentario");
    }

    response.sendRedirect(request.getContextPath() + "/MantenimientoServlet?accion=estado&idMantenimiento=" + id);
  }

  private Mantenimiento leerFormulario(
    HttpServletRequest request
  ) {

    Mantenimiento mantenimiento = new Mantenimiento();

    int idSegmento = obtenerIdPositivo(
      request.getParameter("idSegmento"),
      "Debes seleccionar un segmento válido."
    );

    String tipo = obtenerParametro(request, "tipo");
    String prioridad = obtenerParametro(request, "prioridad");
    if ("Critica".equalsIgnoreCase(prioridad)) {
      prioridad = "Crítica";
    }

    Set<String> tiposValidos =
      Set.of("Preventivo", "Correctivo");

    Set<String> prioridadesValidas =
      Set.of("Leve", "Media", "Alta", "Crítica");

    if (!tiposValidos.contains(tipo)) {
      throw new IllegalArgumentException(
        "El tipo de mantenimiento no es válido."
      );
    }

    if (!prioridadesValidas.contains(prioridad)) {
      throw new IllegalArgumentException(
        "La prioridad seleccionada no es válida."
      );
    }

    // Regla: un correctivo solo se programa en un segmento con una incidencia por reparar
    // (En análisis, Reparación programada o En reparación). Los preventivos van en cualquier segmento.
    if ("Correctivo".equals(tipo) && !segmentoDao.tieneIncidenciaPorReparar(idSegmento)) {
      throw new IllegalArgumentException(
        "Un mantenimiento correctivo solo se puede programar en un segmento "
          + "con una incidencia en análisis (marcados como \"incidencia por reparar\")."
      );
    }

    // Fecha y hora (input datetime-local), ej. "2026-11-25T10:05"
    LocalDateTime inicio = LocalDateTime.parse(
      obtenerParametro(request, "fechaInicio")
    );

    LocalDateTime fin = LocalDateTime.parse(
      obtenerParametro(request, "fechaFin")
    );

    // Se compara por minutos: se puede programar desde el minuto actual
    LocalDateTime ahora = LocalDateTime.now().truncatedTo(ChronoUnit.MINUTES);

    if (inicio.isBefore(ahora)) {
      throw new IllegalArgumentException(
        "La fecha y hora de inicio no puede ser anterior a la actual."
      );
    }

    if (!fin.isAfter(inicio)) {
      throw new IllegalArgumentException(
        "La fecha y hora de fin debe ser posterior a la de inicio."
      );
    }

    mantenimiento.setIdSegmento(idSegmento);
    mantenimiento.setTipo(tipo);
    mantenimiento.setPrioridad(prioridad);

    mantenimiento.setFechaInicio(inicio);
    mantenimiento.setFechaFin(fin);

    String descripcion = request.getParameter("descripcionGeneral");

    mantenimiento.setDescripcionGeneral(
      descripcion == null ? "" : descripcion.trim()
    );

    return mantenimiento;
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

  private String obtenerParametro(
    HttpServletRequest request,
    String nombre
  ) {
    String valor = request.getParameter(nombre);

    if (valor == null || valor.isBlank()) {
      throw new IllegalArgumentException(
        "Falta completar el campo: " + nombre
      );
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

  private Integer obtenerIdUsuarioSesion(
    HttpServletRequest request
  ) {
    HttpSession sesion = request.getSession(false);

    if (sesion == null) {
      return null;
    }

    Object usuarioSesion = sesion.getAttribute("usuarioLogueado");

    if (!(usuarioSesion instanceof Usuario)) {
      usuarioSesion = sesion.getAttribute("usuario");
    }

    if (usuarioSesion instanceof Usuario usuario
      && usuario.getIdUsuario() > 0) {
      return usuario.getIdUsuario();
    }

    Object idSesion = sesion.getAttribute("idUsuario");

    if (idSesion instanceof Number numero
      && numero.intValue() > 0) {
      return numero.intValue();
    }

    return null;
  }

  private void redirigirListado(
    HttpServletRequest request,
    HttpServletResponse response,
    String resultado
  ) throws IOException {

    response.sendRedirect(
      request.getContextPath()
        + "/MantenimientoServlet?accion=listar&resultado="
        + resultado
    );
  }
}
