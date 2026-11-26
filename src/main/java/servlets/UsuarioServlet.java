package servlets;

import beans.Rol;
import beans.Usuario;
import daos.RolDao;
import daos.UsuarioDao;
import services.NotificacionAdminService;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;

@WebServlet(name = "UsuarioServlet", value = "/UsuarioServlet")
public class UsuarioServlet extends HttpServlet {

  private static final int TAMANO_PAGINA = 10;
  private final NotificacionAdminService notificacionAdminService = new NotificacionAdminService();

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
        int filtroIdRol = parseId(request.getParameter("idRol"));
        String filtroEstado = request.getParameter("estado");
        if (!"activo".equals(filtroEstado) && !"inactivo".equals(filtroEstado)) {
          filtroEstado = null;
        }

        ArrayList<Usuario> todos = usuarioDao.listarUsuarios(filtroIdRol, filtroEstado);
        if (todos == null) {
          todos = new ArrayList<>();
        }

        int totalRegistros = todos.size();
        int totalPaginas = (int) Math.ceil((double) totalRegistros / TAMANO_PAGINA);
        if (totalPaginas == 0) {
          totalPaginas = 1;
        }

        int paginaActual = parsePagina(request.getParameter("pagina"), totalPaginas);
        int inicio = (paginaActual - 1) * TAMANO_PAGINA;
        int fin = Math.min(inicio + TAMANO_PAGINA, totalRegistros);

        ArrayList<Usuario> paginaUsuarios = new ArrayList<>();
        if (inicio < totalRegistros) {
          paginaUsuarios.addAll(todos.subList(inicio, fin));
        }

        int registroInicio = totalRegistros == 0 ? 0 : inicio + 1;
        int registroFin = totalRegistros == 0 ? 0 : fin;

        request.setAttribute("listaUsuarios", paginaUsuarios);
        request.setAttribute("listaRoles", rolDao.listarRoles());
        request.setAttribute("filtroIdRol", filtroIdRol);
        request.setAttribute("filtroEstado", filtroEstado == null ? "" : filtroEstado);
        request.setAttribute("paginaActual", paginaActual);
        request.setAttribute("totalPaginas", totalPaginas);
        request.setAttribute("totalRegistros", totalRegistros);
        request.setAttribute("registroInicio", registroInicio);
        request.setAttribute("registroFin", registroFin);

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
        int idDesactivar = parseId(request.getParameter("id"));
        Usuario adminActual = obtenerUsuarioSesion(request);
        // Un administrador no puede desactivarse a sí mismo (se quedaría sin acceso)
        if (adminActual == null || adminActual.getIdUsuario() != idDesactivar) {
          usuarioDao.cambiarEstado(idDesactivar, "inactivo");
        }
        response.sendRedirect(construirUrlLista(request));
        break;

      case "activar":
        usuarioDao.cambiarEstado(parseId(request.getParameter("id")), "activo");
        response.sendRedirect(construirUrlLista(request));
        break;

      default:
        response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
    }
  }

  /* ===================== POST: guardar el formulario (crear o actualizar) ===================== */
  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");

    String action = request.getParameter("action") == null ? "guardar" : request.getParameter("action");
    UsuarioDao usuarioDao = new UsuarioDao();

    switch (action) {

      case "guardar":
        String idUsuario  = request.getParameter("idUsuario");
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

        boolean esNuevo = (idUsuario == null || idUsuario.isEmpty());
        int idActual = esNuevo ? 0 : parseId(idUsuario);

        // El correo debe ser único: si ya lo usa otro usuario, se vuelve al formulario con el aviso
        if (correo == null || correo.isBlank() || usuarioDao.existeCorreo(correo, idActual)) {
          usuario.setIdUsuario(idActual);
          request.setAttribute("usuario", usuario);
          request.setAttribute("listaRoles", new RolDao().listarRoles());
          request.setAttribute("error", "El correo ya está registrado por otro usuario.");
          request.getRequestDispatcher("/admin/usuario_form.jsp").forward(request, response);
          return;
        }

        if (esNuevo) {
          // CREATE
          usuario.setContrasena(contrasena);
          usuarioDao.crearUsuario(usuario);

          Usuario adminEjecutor = obtenerUsuarioSesion(request);
          notificacionAdminService.notificarCreacionUsuario(usuario, contrasena, adminEjecutor);
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

  private Usuario obtenerUsuarioSesion(HttpServletRequest request) {
    HttpSession sesion = request.getSession(false);
    if (sesion != null && sesion.getAttribute("usuarioLogueado") instanceof Usuario u) {
      return u;
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

  private int parsePagina(String valor, int maxPaginas) {
    try {
      int p = Integer.parseInt(valor);
      if (p < 1) return 1;
      if (p > maxPaginas) return maxPaginas;
      return p;
    } catch (NumberFormatException e) {
      return 1;
    }
  }

  private String construirUrlLista(HttpServletRequest request) {
    String idRol = request.getParameter("idRol") == null ? "" : request.getParameter("idRol").trim();
    String estado = request.getParameter("estado") == null ? "" : request.getParameter("estado").trim();
    String pagina = request.getParameter("pagina") == null ? "1" : request.getParameter("pagina").trim();

    return request.getContextPath() + "/UsuarioServlet?idRol="
      + URLEncoder.encode(idRol, StandardCharsets.UTF_8)
      + "&estado=" + URLEncoder.encode(estado, StandardCharsets.UTF_8)
      + "&pagina=" + URLEncoder.encode(pagina, StandardCharsets.UTF_8);
  }
}
