package servlets.supervisor;

import beans.Usuario;
import beans.maintenance.Mantenimiento;
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

@WebServlet(name = "MantenimientoServletSuper", value = "/MantenimientoServletSuper")
public class MantenimientoServletSuper extends HttpServlet {

  private final MantenimientoDao mantenimientoDao =
    new MantenimientoDao();

  private final SegmentoDao segmentoDao =
    new SegmentoDao(); // CREACIÓN DEL OBJETO SEGMENTO

  // Rutas de las vistas que ya existen o crearemos después.
  private static final String VISTA_LISTADO =
    "/supervisor/programacion.jsp";

  private static final String VISTA_HISTORIAL =
    "/supervisor/historial_programados.jsp";

  private static final String VISTA_ESTADO =
    "/supervisor/programacion.jsp";

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

        case "estado":

          mostrarEstado(request, response);

          break;
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

    // Enviar el objeto a estado.jsp.
    request.setAttribute(
      "mantenimiento",
      mantenimiento
    );

    // Mostrar la vista.
    request.getRequestDispatcher(VISTA_ESTADO)
      .forward(request, response);
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
        + "/MantenimientoServletSuper?accion=listar&resultado="
        + resultado
    );
  }
}
