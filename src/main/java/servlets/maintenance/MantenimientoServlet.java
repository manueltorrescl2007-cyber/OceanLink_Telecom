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
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.Set;
import java.util.List;

@WebServlet(name = "MantenimientoServlet", value = "/MantenimientoServlet")
public class MantenimientoServlet extends HttpServlet {

  private final MantenimientoDao mantenimientoDao =
    new MantenimientoDao();

  private final SegmentoDao segmentoDao =
    new SegmentoDao(); // CREACIÓN DEL OBJETO SEGMENTO

  private final ActividadMantenimientoDao actividadMantenimientoDao =
    new ActividadMantenimientoDao(); // declaramos nuestro DAO para las actividades (bitacora) del mantenimiento

  // Declaramos nuestro DAO de notifiacionService
  private final NotificacionService notificacionService =
    new NotificacionService();

  // Rutas de las vistas que ya existen o crearemos después.
  private static final String VISTA_LISTADO =
    "/Maintenance_coordinator/fechas_duracion.jsp";

  private static final String VISTA_HISTORIAL =
    "/Maintenance_coordinator/historial.jsp";

  private static final String VISTA_EDICION =
    "/Maintenance_coordinator/editar_mantenimiento.jsp";

  private static final String VISTA_ESTADO =
    "/Maintenance_coordinator/estado.jsp";

  // GET para consultar información y mostrar vistas

  @Override
  protected void doGet(
    HttpServletRequest request,
    HttpServletResponse response
  ) throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");
    System.out.println("Hora Java: " + LocalDateTime.now());
    System.out.println("Zona horaria Java: " + java.time.ZoneId.systemDefault());

    String accion = request.getParameter("accion");

    // Si no se indica una acción, mostramos el listado normal.
    if (accion == null || accion.isBlank()) {
      accion = "listar";
    }

    try {
      switch (accion) {

        case "listar":

          // Actualizamos los estados según las fechas de MySQL.
          mantenimientoDao.actualizarEstadosAutomaticamente();

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

          // Actualizamos los estados según las fechas de MySQL.
          mantenimientoDao.actualizarEstadosAutomaticamente();

          // Recuperamos únicamente los mantenimientos finalizados y cancelados.
          request.setAttribute(
            "historialMantenimientos",
            mantenimientoDao.listarHistorial()
          );

          // Recuperamos los códigos de los segmentos.
          request.setAttribute(
            "segmentos",
            segmentoDao.listarSegmentos()
          );

          request.getRequestDispatcher(VISTA_HISTORIAL)
            .forward(request, response);

          break;


        case "editar":

          // Garantizamos que el estado esté actualizado antes de editar.
          mantenimientoDao.actualizarEstadosAutomaticamente();

          mostrarEdicion(request, response);

          break;


        case "estado":

          mostrarEstado(request, response);

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



  // POST: registrar, actualizar o cancelar

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


  // GET: preparar la edición de un mantenimiento

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


// Mostrar el estado de un mantenimiento específico


  private void mostrarEstado(
    HttpServletRequest request,
    HttpServletResponse response
  ) throws ServletException, IOException {

    // Obtener el ID enviado desde la URL.
    int id = obtenerIdPositivo(
      request.getParameter("idMantenimiento"),
      "El ID del mantenimiento no es válido."
    );

    // Actualizar los estados automáticamente.
    mantenimientoDao.actualizarEstadosAutomaticamente();

    // Buscar el mantenimiento correspondiente en MySQL.
    Mantenimiento mantenimiento =
      mantenimientoDao.obtenerMantenimiento(id);

    // Verificar que el mantenimiento exista.
    if (mantenimiento == null) {
      response.sendError(
        HttpServletResponse.SC_NOT_FOUND,
        "No se encontró el mantenimiento solicitado."
      );
      return;
    }

    // Recuperamos las actividades asociadas al mantenimiento
    List<ActividadMantenimiento> actividades = actividadMantenimientoDao.listaPorMantenimiento(id);

    // Enviar el objeto mantenimiento y sus actividades (bitacora) a estado.jsp.

    request.setAttribute("mantenimiento", mantenimiento);
    request.setAttribute("actividades", actividades);

    // Mostrar la vista.
    request.getRequestDispatcher(VISTA_ESTADO)
      .forward(request, response);
  }

  // POST: crear un mantenimiento

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


    // Registramos el mantenimiento en MySQL
    int idMantenimiento =
      mantenimientoDao.crearMantenimiento(mantenimiento);

    // Guardamos el ID generado en el Bean
    mantenimiento.setIdMantenimiento(idMantenimiento);

    // Solicitamos la notificación
    notificacionService.notificarCreacion(mantenimiento);

    // Redirigimos al listado
    redirigirListado(request, response, "creado");
  }



  // POST: actualizar un mantenimiento


  private void actualizarMantenimiento(
    HttpServletRequest request,
    HttpServletResponse response
  ) throws IOException {

    int id = obtenerIdPositivo(
      request.getParameter("idMantenimiento"),
      "El ID del mantenimiento no es válido."
    );

    // Recuperar los datos anteriores desde MySQL
    Mantenimiento anterior =
      mantenimientoDao.obtenerMantenimiento(id);

    // Leer los datos nuevos del formulario
    Mantenimiento mantenimiento = leerFormulario(request);
    mantenimiento.setIdMantenimiento(id);

    // Actualizar en MySQL
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

    // Comprobar si realmente cambiaron las fechas
    boolean fechasModificadas =
      !anterior.getFechaInicio().equals(
        mantenimiento.getFechaInicio()) ||
        !anterior.getFechaFin().equals(mantenimiento.getFechaFin()
        );

    // Notificar únicamente si hubo reprogramación
    if (fechasModificadas) {

      notificacionService.notificarReprogramacion(
        anterior,
        mantenimiento
      );
    }

    // Redirigir al listado
    redirigirListado(request, response, "actualizado");
  }



  // POST: cancelar un mantenimiento


  private void cancelarMantenimiento(
    HttpServletRequest request,
    HttpServletResponse response
  ) throws IOException {

    int id = obtenerIdPositivo(
      request.getParameter("idMantenimiento"),
      "El ID del mantenimiento no es válido."
    );

    // Recuperamos los datos antes de cancelar
    Mantenimiento anterior =
      mantenimientoDao.obtenerMantenimiento(id);

    // Intentamos cancelar el mantenimiento en MySQL
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

    // Notificar después de confirmar la cancelación
    if (anterior != null) {
      notificacionService.notificarCancelacion(anterior);
    }

    // Redirigimos al listado
    redirigirListado(request, response, "cancelado");
  }

  // POST: Agregar un comentario a la bitacora

  private void agregarComentario(HttpServletRequest request, HttpServletResponse response)
    throws IOException {

    // Primero obtenemos el id del mantenimiento en el que vamos a comentar
    int id = obtenerIdPositivo(request.getParameter("idMantenimiento"), "El ID del mantenimiento no es valido");

    // Obtenemos el usuario autenticado en ese momento
    Integer idUsuario = obtenerIdUsuarioSesion(request);

    if (idUsuario == null) {
      response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Debe iniciar sesión para registrar el comentario");

      return;
    }

    // Comprobamos que el mantenimiento exista

    Mantenimiento mantenimiento = mantenimientoDao.obtenerMantenimiento(id);

    if (mantenimiento == null) {
      response.sendError(HttpServletResponse.SC_NOT_FOUND, "No se encontró el mantenimiento");
      return;
    }

    // Recuperamos comentarios pasados
    String comentario = obtenerParametro(request, "comentario");

    // Construimos el bean de la actividad
    ActividadMantenimiento actividad = new ActividadMantenimiento();
    actividad.setIdMantenimiento(id);
    actividad.setIdUsuario(idUsuario);
    actividad.setDescripcionBitacora(comentario);
    actividad.setTipoActividad("Comentario");

    // Registramos la actividad
    boolean registrado = actividadMantenimientoDao.crearActividad(actividad);

    // Verificamos que se haya registrado correctamente el comentario
    if (!registrado) {
      throw new IllegalStateException("No se pudo registrar el comentario");
    }

    // Redirigimos al seguimiento para evitar que el usuario envie otra vez el comentario

    response.sendRedirect(request.getContextPath() + "/MantenimientoServlet?accion=estado&idMantenimiento=" + id);


  }




  // Convertir los campos del formulario en un Bean

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



  // Funciones auxiliares


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
