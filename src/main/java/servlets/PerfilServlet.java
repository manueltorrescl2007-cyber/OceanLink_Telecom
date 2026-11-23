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

// Perfil del usuario que inició sesión (lo usan los 5 roles)
@WebServlet(name = "PerfilServlet", value = "/PerfilServlet")
public class PerfilServlet extends HttpServlet {

    private final UsuarioDao usuarioDao = new UsuarioDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int idUsuario = obtenerIdUsuarioSesion(request);
        if (idUsuario == -1) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        // Si venimos de cambiar la contraseña, mostramos el aviso
        String mensajeOk = null;
        if ("clave".equals(request.getParameter("ok"))) {
            mensajeOk = "Contraseña actualizada correctamente.";
        }

        mostrarPerfil(request, response, idUsuario, null, mensajeOk);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        int idUsuario = obtenerIdUsuarioSesion(request);
        if (idUsuario == -1) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        String actual = request.getParameter("contrasenaActual");
        String nueva = request.getParameter("contrasenaNueva");
        String repetir = request.getParameter("contrasenaRepetir");

        // Los tres campos son obligatorios
        if (actual == null || actual.isEmpty()
                || nueva == null || nueva.isEmpty()
                || repetir == null || repetir.isEmpty()) {
            mostrarPerfil(request, response, idUsuario, "Completa los tres campos.", null);
            return;
        }

        // La nueva contraseña debe escribirse igual las dos veces
        if (!nueva.equals(repetir)) {
            mostrarPerfil(request, response, idUsuario,
                    "La nueva contraseña y su confirmación no coinciden.", null);
            return;
        }

        try {
            // El DAO compara la actual con el hash guardado y, si coincide, guarda el hash de la nueva
            boolean cambiada = usuarioDao.cambiarContrasena(idUsuario, actual, nueva);

            if (!cambiada) {
                mostrarPerfil(request, response, idUsuario,
                        "La contraseña actual es incorrecta.", null);
                return;
            }
        } catch (IllegalStateException e) {
            getServletContext().log("Error al cambiar la contraseña.", e);
            mostrarPerfil(request, response, idUsuario,
                    "No se pudo cambiar la contraseña en este momento.", null);
            return;
        }

        // Redirect para que F5 no vuelva a enviar el formulario
        response.sendRedirect(request.getContextPath() + "/PerfilServlet?ok=clave");
    }

    // Carga el usuario desde la BD y muestra perfil.jsp
    private void mostrarPerfil(HttpServletRequest request, HttpServletResponse response,
                               int idUsuario, String errorMsg, String mensajeOk)
            throws ServletException, IOException {

        Usuario usuario = usuarioDao.obtenerUsuario(idUsuario);
        if (usuario == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        request.setAttribute("usuarioPerfil", usuario);
        request.setAttribute("errorMsg", errorMsg);
        request.setAttribute("mensajeOk", mensajeOk);
        request.getRequestDispatcher("/perfil.jsp").forward(request, response);
    }

    // Id del usuario guardado en la sesión al iniciar sesión (-1 si no hay sesión)
    private int obtenerIdUsuarioSesion(HttpServletRequest request) {
        HttpSession sesion = request.getSession(false);
        if (sesion == null) {
            return -1;
        }
        Object idUsuario = sesion.getAttribute("idUsuario");
        return idUsuario instanceof Integer ? (Integer) idUsuario : -1;
    }
}
