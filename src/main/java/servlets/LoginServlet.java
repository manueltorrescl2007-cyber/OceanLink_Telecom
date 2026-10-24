package servlets;

import beans.Usuario;
import daos.UsuarioDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "LoginServlet", value = "/LoginServlet")
public class LoginServlet extends HttpServlet {

  private final UsuarioDao usuarioDao = new UsuarioDao();

  @Override
  protected void doGet(
    HttpServletRequest request,
    HttpServletResponse response
  ) throws ServletException, IOException {

    HttpSession sesion = request.getSession(false);

    if (sesion != null) {
      Object objetoUsuario =
        sesion.getAttribute("usuarioLogueado");

      if (objetoUsuario instanceof Usuario usuario
        && usuario.getRol() != null) {

        redirigirSegunRol(
          usuario.getRol().getIdRol(),
          request,
          response
        );

        return;
      }
    }

    request.getRequestDispatcher("/login.jsp")
      .forward(request, response);
  }

  @Override
  protected void doPost(
    HttpServletRequest request,
    HttpServletResponse response
  ) throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");

    String correo = request.getParameter("correo");
    String contrasena = request.getParameter("password");

    // Compatibilidad si todavía existiera algún formulario
    // que envíe el parámetro anterior "username".
    if (correo == null) {
      correo = request.getParameter("username");
    }

    if (correo == null || correo.isBlank()
      || contrasena == null || contrasena.isEmpty()) {

      mostrarError(
        request,
        response,
        "Ingresa tu correo y contraseña."
      );

      return;
    }

    Usuario usuario;

    try {
      usuario = usuarioDao.autenticarUsuario(
        correo.trim(),
        contrasena
      );

    } catch (IllegalStateException e) {

      getServletContext().log(
        "Error al autenticar al usuario.",
        e
      );

      mostrarError(
        request,
        response,
        "No se pudo iniciar sesión en este momento."
      );

      return;
    }

    if (usuario == null) {
      mostrarError(
        request,
        response,
        "Correo o contraseña incorrectos, "
          + "o cuenta no disponible."
      );

      return;
    }

    if (usuario.getRol() == null) {
      mostrarError(
        request,
        response,
        "La cuenta no tiene un rol válido."
      );

      return;
    }

    int idRol = usuario.getRol().getIdRol();

    // Solo aceptamos los cinco roles definidos para OceanLink.
    if (idRol < 1 || idRol > 5) {
      mostrarError(
        request,
        response,
        "La cuenta no tiene un rol válido."
      );

      return;
    }

    // Invalidar cualquier sesión anterior para evitar
    // reutilizar su identificador después de iniciar sesión.
    HttpSession sesionAnterior = request.getSession(false);

    if (sesionAnterior != null) {
      sesionAnterior.invalidate();
    }

    HttpSession sesion = request.getSession(true);
    sesion.setMaxInactiveInterval(30 * 60);

    // Datos consultados desde MySQL.
    sesion.setAttribute("usuarioLogueado", usuario);

    // Compatibilidad con el código existente de mantenimiento.
    sesion.setAttribute("usuario", usuario);
    sesion.setAttribute("idUsuario", usuario.getIdUsuario());

    // Información para navegación y futuras comprobaciones.
    sesion.setAttribute("idRol", idRol);
    sesion.setAttribute("nombreUsuario", usuario.getNombre());
    sesion.setAttribute(
      "nombreRol",
      usuario.getRol().getNombre()
    );

    redirigirSegunRol(idRol, request, response);
  }

  private void redirigirSegunRol(
    int idRol,
    HttpServletRequest request,
    HttpServletResponse response
  ) throws IOException {

    String destino = switch (idRol) {

      case 1 -> "/UsuarioServlet";

      case 2 -> "/supervisor/supervisor.jsp";

      case 3 -> "/capacity_planner/capacity_planner.jsp";

      case 4 -> "/network_operator/estado_red.jsp";

      // Conservamos la vista de entrada que ya utilizaban
      // para el coordinador de mantenimiento.
      case 5 -> "/MantenimientoServlet?accion=nuevo";

      default -> null;
    };

    if (destino == null) {
      response.sendError(
        HttpServletResponse.SC_FORBIDDEN,
        "El rol de usuario no es válido."
      );

      return;
    }

    response.sendRedirect(
      request.getContextPath() + destino
    );
  }

  private void mostrarError(
    HttpServletRequest request,
    HttpServletResponse response,
    String mensaje
  ) throws ServletException, IOException {

    request.setAttribute("errorMsg", mensaje);

    request.getRequestDispatcher("/login.jsp")
      .forward(request, response);
  }
}
