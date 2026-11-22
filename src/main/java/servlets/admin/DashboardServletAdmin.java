package servlets.admin;

import daos.RolDao;
import daos.UsuarioDao;
import daos.admin.DashboardAdminDao;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Map;

@WebServlet(name = "DashboardServletAdmin", value = "/DashboardServletAdmin")
public class DashboardServletAdmin extends HttpServlet {

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

    DashboardAdminDao dashboardDao = new DashboardAdminDao();
    RolDao rolDao = new RolDao();
    UsuarioDao usuarioDao = new UsuarioDao();

    Map<String, Object> resumen = dashboardDao.obtenerResumenPlataforma();

    request.setAttribute("resumen", resumen);
    request.setAttribute("listaRoles", rolDao.listarRoles());
    request.setAttribute("listaUsuarios", usuarioDao.listarUsuarios(-1, null));
    request.setAttribute("topSegmentos", dashboardDao.listarTopSegmentos(5));
    request.setAttribute("ultimosUsuarios", dashboardDao.listarUltimosUsuarios(4));
    request.setAttribute("ultimaInfraestructura", dashboardDao.listarUltimaInfraestructura());

    RequestDispatcher view = request.getRequestDispatcher("/admin/dashboard.jsp");
    view.forward(request, response);
  }
}
