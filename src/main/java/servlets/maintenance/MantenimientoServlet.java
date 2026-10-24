package servlets.maintenance;

import beans.maintenance.Mantenimiento;
import beans.Usuario;
import daos.manteinance.MantenimientoDao;
import daos.manteinance.SegmentoDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.Set;

@WebServlet(name = "MantenimientoServlet", value = "/MantenimientoServlet")
public class MantenimientoServlet extends HttpServlet {

  private final MantenimientoDao mantenimientoDao =
    new MantenimientoDao();

  private final SegmentoDao segmentoDao =
    new SegmentoDao(); // CREACIÓN DEL OBJETO SEGMENTO

  // Rutas de las vistas que ya existen o crearemos después.
  private static final String VISTA_LISTADO =
    "/Maintenance_coordinator/fechas_duracion.jsp";

  private static final String VISTA_HISTORIAL =
    "/Maintenance_coordinator/historial.jsp";

  private static final String VISTA_EDICION =
    "/Maintenance_coordinator/editar_mantenimiento.jsp";

  // GET para consultar información y mostrar vistas

  @Override
  protected void doGet(
    HttpServletRequest request,
    HttpServletResponse response
  ) throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");

    String accion = request.getParameter("accion");

    // Si no se indica una acción, mostramos el listado normal.
    if (accion == null || accion.isBlank()) {
      accion = "listar";
    }

    try {
      switch (accion) {

        case "listar":

          request.setAttribute(
            "mantenimientos",
            mantenimientoDao.listarMantenimientos()
          );

          request.setAttribute(
            "segmentos",
            segmentoDao.listarSegmentos()
          );

          request.getRequestDispatcher(VISTA_LISTADO)
            .forward(request, response);

          break;


        case "historial":
          request.setAttribute(
            "historialMantenimientos",
            mantenimientoDao.listarHistorial()
          );

          request.getRequestDispatcher(VISTA_HISTORIAL)
            .forward(request, response);
          break;


        case "editar":
          mostrarEdicion(request, response);
          break;

        case "nuevo":
          request.setAttribute(
            "segmentos",
            segmentoDao.listarSegmentos()
          );

          request.getRequestDispatcher(
            "/Maintenance_coordinator/nuevo_mantenimiento.jsp"
          ).forward(request, response);
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


  // =========================================================
  // POST: registrar, actualizar o cancelar
  // =========================================================

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


  // =========================================================
  // GET: preparar la edición de un mantenimiento
  // =========================================================

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

    // Por ahora, solo permitimos editar mantenimientos programados.
    if (!"Programado".equals(mantenimiento.getEstado())) {
      response.sendError(
        HttpServletResponse.SC_CONFLICT,
        "Solo se pueden editar mantenimientos programados."
      );
      return;
    }

    // El JSP podrá utilizar este objeto para recuperar
    // los valores originales del mantenimiento.
    request.setAttribute(
      "mantenimiento",
      mantenimiento
    );

    request.setAttribute(
      "segmentos",
      segmentoDao.listarSegmentos()
    );

    request.getRequestDispatcher(VISTA_EDICION)
      .forward(request, response);
  }


  // =========================================================
  // POST: crear un mantenimiento
  // =========================================================

  private void crearMantenimiento(
    HttpServletRequest request,
    HttpServletResponse response
  ) throws IOException {

    Mantenimiento mantenimiento = leerFormulario(request);

    // El usuario responsable debe provenir de la sesión
    // autenticada, no de un ID libre enviado por el formulario.
    Integer idUsuario = obtenerIdUsuarioSesion(request);

    if (idUsuario == null) {
      response.sendError(
        HttpServletResponse.SC_UNAUTHORIZED,
        "Inicia sesión para registrar un mantenimiento."
      );
      return;
    }

    mantenimiento.setIdUsuario(idUsuario);

    boolean creado =
      mantenimientoDao.crearMantenimiento(mantenimiento);

    if (!creado) {
      throw new IllegalStateException(
        "No se pudo registrar el mantenimiento."
      );
    }

    redirigirListado(request, response, "creado");
  }


  // =========================================================
  // POST: actualizar un mantenimiento
  // =========================================================

  private void actualizarMantenimiento(
    HttpServletRequest request,
    HttpServletResponse response
  ) throws IOException {

    int id = obtenerIdPositivo(
      request.getParameter("idMantenimiento"),
      "El ID del mantenimiento no es válido."
    );

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

    redirigirListado(request, response, "actualizado");
  }


  // =========================================================
  // POST: cancelar un mantenimiento
  // =========================================================

  private void cancelarMantenimiento(
    HttpServletRequest request,
    HttpServletResponse response
  ) throws IOException {

    int id = obtenerIdPositivo(
      request.getParameter("idMantenimiento"),
      "El ID del mantenimiento no es válido."
    );

    boolean cancelado =
      mantenimientoDao.cancelarMantenimiento(id);

    if (!cancelado) {
      response.sendError(
        HttpServletResponse.SC_CONFLICT,
        "No se pudo cancelar el mantenimiento. "
          + "Verifica que exista y esté programado."
      );
      return;
    }

    redirigirListado(request, response, "cancelado");
  }


  // =========================================================
  // Convertir los campos del formulario en un Bean
  // =========================================================

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

    // Los input type="date" envían fechas como yyyy-MM-dd.
    LocalDate fechaInicio = LocalDate.parse(
      obtenerParametro(request, "fechaInicio")
    );

    LocalDate fechaFin = LocalDate.parse(
      obtenerParametro(request, "fechaFin")
    );

    if (fechaFin.isBefore(fechaInicio)) {
      throw new IllegalArgumentException(
        "La fecha de fin no puede ser anterior a la de inicio."
      );
    }

    mantenimiento.setIdSegmento(idSegmento);
    mantenimiento.setTipo(tipo);
    mantenimiento.setPrioridad(prioridad);

    // Como el formulario maneja días, no horas:
    // inicio a medianoche y fin al final del día seleccionado.
    LocalDateTime inicio = fechaInicio.atStartOfDay();
    LocalDateTime fin = fechaFin.atTime(23, 59, 59);

    mantenimiento.setFechaInicio(inicio);
    mantenimiento.setFechaFin(fin);

    // La descripción es opcional en la vista.
    String descripcion = request.getParameter("descripcionGeneral");

    mantenimiento.setDescripcionGeneral(
      descripcion == null ? "" : descripcion.trim()
    );

    return mantenimiento;
  }


  // =========================================================
  // Funciones auxiliares
  // =========================================================

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

    // Contemplamos dos nombres habituales para guardar
    // el Bean del usuario autenticado en la sesión.
    Object usuarioSesion = sesion.getAttribute("usuarioLogueado");

    if (!(usuarioSesion instanceof Usuario)) {
      usuarioSesion = sesion.getAttribute("usuario");
    }

    if (usuarioSesion instanceof Usuario usuario
      && usuario.getIdUsuario() > 0) {
      return usuario.getIdUsuario();
    }

    // Alternativa por si el login guarda solamente el ID.
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
