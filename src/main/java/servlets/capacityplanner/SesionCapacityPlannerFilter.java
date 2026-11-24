package servlets.capacityplanner;

import beans.Usuario;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebFilter(urlPatterns = {
  "/capacity_planner/*",
  "/CapacityPlannerServlet",
  "/ClienteServlet",
  "/SolicitudesServlet",
  "/RutaServlet",
  "/SegmentoServlet",
  "/LandingStationServlet",
  "/ServicioServlet"
})
public class SesionCapacityPlannerFilter implements Filter {
  @Override
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
    throws IOException, ServletException {
    HttpServletRequest http = (HttpServletRequest) request;
    HttpSession sesion = http.getSession(false);

    if (sesion == null || !(sesion.getAttribute("usuarioLogueado") instanceof Usuario)) {
      ((HttpServletResponse) response).sendRedirect(http.getContextPath() + "/LoginServlet");
      return;
    }

    chain.doFilter(request, response);
  }
}
