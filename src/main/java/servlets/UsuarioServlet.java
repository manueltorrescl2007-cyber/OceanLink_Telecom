package servlets;

import beans.Rol;
import beans.Usuario;
import daos.RolDao;
import daos.UsuarioDao;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(name = "UsuarioServlet", value = "/UsuarioServlet")
public class UsuarioServlet extends HttpServlet {

    /* ===================== GET: mostrar páginas y acciones por enlace ===================== */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action") == null ? "lista" : request.getParameter("action");

        UsuarioDao usuarioDao = new UsuarioDao();
        RolDao rolDao = new RolDao();
        RequestDispatcher view;

        switch (action) {

            case "lista":
                request.setAttribute("listaUsuarios", usuarioDao.listarUsuarios());
                view = request.getRequestDispatcher("/admin/usuarios.jsp");
                view.forward(request, response);
                break;

            case "formCrear":
                request.setAttribute("listaRoles", rolDao.listarRoles());
                view = request.getRequestDispatcher("/admin/usuario_form.jsp");
                view.forward(request, response);
                break;

            case "editar":
                Usuario usuario = usuarioDao.obtenerUsuario(parseId(request.getParameter("id")));
                if (usuario == null) {
                    response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
                } else {
                    request.setAttribute("usuario", usuario);
                    request.setAttribute("listaRoles", rolDao.listarRoles());
                    view = request.getRequestDispatcher("/admin/usuario_form.jsp");
                    view.forward(request, response);
                }
                break;

            case "desactivar":
                usuarioDao.cambiarEstado(parseId(request.getParameter("id")), "inactivo");
                response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
                break;

            case "activar":
                usuarioDao.cambiarEstado(parseId(request.getParameter("id")), "activo");
                response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
        }
    }

    /* ===================== POST: guardar el formulario (crear o actualizar) ===================== */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");   // tildes y ñ (clase 7.3, diap. 16)

        String action = request.getParameter("action") == null ? "guardar" : request.getParameter("action");
        UsuarioDao usuarioDao = new UsuarioDao();

        switch (action) {

            case "guardar":
                String idUsuario  = request.getParameter("idUsuario");   // vacío si es nuevo
                String nombre     = request.getParameter("nombre");
                String correo     = request.getParameter("correo");
                String contrasena = request.getParameter("contrasena");
                int idRol         = parseId(request.getParameter("idRol"));

                Rol rol = new Rol();
                rol.setIdRol(idRol);

                Usuario usuario = new Usuario();
                usuario.setNombre(nombre);
                usuario.setCorreo(correo);
                usuario.setRol(rol);

                if (idUsuario == null || idUsuario.isEmpty()) {
                    // CREATE
                    usuario.setContrasena(contrasena);
                    usuarioDao.crearUsuario(usuario);
                } else {
                    // UPDATE
                    usuario.setIdUsuario(parseId(idUsuario));
                    usuarioDao.actualizarUsuario(usuario);
                }
                response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
        }
    }

    /* Convierte un parámetro a int; devuelve -1 si viene vacío o no es número */
    private int parseId(String valor) {
        try {
            return Integer.parseInt(valor);
        } catch (NumberFormatException e) {
            return -1;
        }
    }
}
