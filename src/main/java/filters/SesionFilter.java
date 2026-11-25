package filters;

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
import java.util.HashMap;
import java.util.Map;

/**
 * Filtro único de sesión y rol para toda la aplicación.
 *
 * Se ejecuta ANTES de cada petición ("/*") y hace 3 cosas:
 *  1. Deja pasar sin revisar las páginas públicas (login, logout, css, imágenes...).
 *  2. Si no hay usuario en sesión, manda al login.
 *  3. Si hay usuario pero la página es de otro rol, lo manda a su propio dashboard.
 *  4. Si pidió un JSP directo (escribiendo la URL), lo manda al servlet que carga sus datos.
 *
 * Además le dice al navegador que no guarde en caché las páginas protegidas,
 * para que al cerrar sesión y apretar "Atrás" no se vea la página anterior.
 *
 * Roles (los mismos que usa LoginServlet):
 *  1 = Admin, 2 = Supervisor, 3 = Capacity Planner,
 *  4 = Network Operator, 5 = Maintenance Coordinator.
 */
@WebFilter("/*")
public class SesionFilter implements Filter {

  // Rol 0 = cualquier usuario logueado puede entrar (ej. Perfil).
  private static final int CUALQUIER_ROL = 0;

  // Carpeta de JSP -> rol dueño de esa carpeta.
  private static final Map<String, Integer> CARPETAS = new HashMap<>();

  // Servlet -> rol dueño de ese servlet.
  private static final Map<String, Integer> SERVLETS = new HashMap<>();

  // JSP -> servlet que carga sus datos.
  // Si alguien escribe la URL del JSP directo, lo mandamos al servlet para que vea la página CON datos.
  // (Los forward que hacen los servlets hacia el JSP no pasan por el filtro, así que no se afectan.)
  // Formularios y detalles necesitan un id, por eso van al listado de su servlet.
  private static final Map<String, String> VISTAS = new HashMap<>();

  static {
    // ---------- Carpetas de JSP ----------
    CARPETAS.put("/admin/", 1);
    CARPETAS.put("/supervisor/", 2);
    CARPETAS.put("/capacity_planner/", 3);
    CARPETAS.put("/network_operator/", 4);
    CARPETAS.put("/Maintenance_coordinator/", 5);

    // ---------- 1. Admin ----------
    SERVLETS.put("/DashboardServletAdmin", 1);
    SERVLETS.put("/UsuarioServlet", 1);
    SERVLETS.put("/SegmentoAdminServlet", 1);
    SERVLETS.put("/LandingStationAdminServlet", 1);
    SERVLETS.put("/usuarios.jsp", 1); // JSP antiguo que quedó en la raíz

    // ---------- 2. Supervisor ----------
    SERVLETS.put("/DashboardServletSuper", 2);
    SERVLETS.put("/TarjetasServletSuper", 2);
    SERVLETS.put("/EstadoRedServletSuper", 2);
    SERVLETS.put("/IncidenciaServletSuper", 2);
    SERVLETS.put("/MantenimientoServletSuper", 2);
    SERVLETS.put("/SegmentoServletSuper", 2);
    SERVLETS.put("/RutaServletSuper", 2);
    SERVLETS.put("/LandingStationServletSuper", 2);
    SERVLETS.put("/ServicioServletSuper", 2);
    SERVLETS.put("/ClienteServletSuper", 2);
    SERVLETS.put("/SolicitudesServletSuper", 2);
    SERVLETS.put("/HistoricoServletSuper", 2);
    SERVLETS.put("/ReporteServletSuper", 2);
    SERVLETS.put("/PdfReporteServletSuper", 2);

    // ---------- 3. Capacity Planner ----------
    SERVLETS.put("/CapacityPlannerServlet", 3);
    SERVLETS.put("/ClienteServlet", 3);
    SERVLETS.put("/SolicitudesServlet", 3);
    SERVLETS.put("/RutaServlet", 3);
    SERVLETS.put("/SegmentoServlet", 3);
    SERVLETS.put("/LandingStationServlet", 3);
    SERVLETS.put("/ServicioServlet", 3);

    // ---------- 4. Network Operator ----------
    SERVLETS.put("/EstadoRedServlet", 4);
    SERVLETS.put("/IncidenciaServlet", 4);

    // ---------- 5. Maintenance Coordinator ----------
    SERVLETS.put("/MantenimientoServlet", 5);
    SERVLETS.put("/ServiciosAfectadosServlet", 5);

    // ---------- Compartidos (todos los roles logueados) ----------
    SERVLETS.put("/PerfilServlet", CUALQUIER_ROL);
    SERVLETS.put("/perfil.jsp", CUALQUIER_ROL);

    // =============== JSP -> servlet ===============
    VISTAS.put("/perfil.jsp", "/PerfilServlet");

    // ---------- 1. Admin ----------
    VISTAS.put("/usuarios.jsp", "/UsuarioServlet");
    VISTAS.put("/admin/dashboard.jsp", "/DashboardServletAdmin");
    VISTAS.put("/admin/usuarios.jsp", "/UsuarioServlet");
    VISTAS.put("/admin/usuario_form.jsp", "/UsuarioServlet");
    VISTAS.put("/admin/segmentos.jsp", "/SegmentoAdminServlet");
    VISTAS.put("/admin/segmento_form.jsp", "/SegmentoAdminServlet");
    VISTAS.put("/admin/landing_stations.jsp", "/LandingStationAdminServlet");
    VISTAS.put("/admin/landing_station_form.jsp", "/LandingStationAdminServlet");

    // ---------- 2. Supervisor ----------
    VISTAS.put("/supervisor/supervisor.jsp", "/DashboardServletSuper");
    VISTAS.put("/supervisor/capacidad.jsp", "/TarjetasServletSuper");
    VISTAS.put("/supervisor/visualizar.jsp", "/IncidenciaServletSuper");
    VISTAS.put("/supervisor/historial_incidencias.jsp", "/IncidenciaServletSuper?action=historial");
    VISTAS.put("/supervisor/incidencias-detalle.jsp", "/IncidenciaServletSuper");
    VISTAS.put("/supervisor/programacion.jsp", "/MantenimientoServletSuper");
    VISTAS.put("/supervisor/historial_programados.jsp", "/MantenimientoServletSuper?accion=historial");
    VISTAS.put("/supervisor/estado_mantenimiento.jsp", "/MantenimientoServletSuper");
    VISTAS.put("/supervisor/segmentos.jsp", "/SegmentoServletSuper");
    VISTAS.put("/supervisor/rutas.jsp", "/RutaServletSuper");
    VISTAS.put("/supervisor/landing_stations.jsp", "/LandingStationServletSuper");
    VISTAS.put("/supervisor/servicios.jsp", "/ServicioServletSuper");
    VISTAS.put("/supervisor/clientes.jsp", "/ClienteServletSuper");
    VISTAS.put("/supervisor/solicitudes.jsp", "/SolicitudesServletSuper");
    VISTAS.put("/supervisor/historicos.jsp", "/HistoricoServletSuper");
    VISTAS.put("/supervisor/reportes.jsp", "/ReporteServletSuper");

    // ---------- 3. Capacity Planner ----------
    VISTAS.put("/capacity_planner/capacity_planner.jsp", "/CapacityPlannerServlet");
    VISTAS.put("/capacity_planner/clientes.jsp", "/ClienteServlet");
    VISTAS.put("/capacity_planner/cliente_form.jsp", "/ClienteServlet");
    VISTAS.put("/capacity_planner/solicitudes.jsp", "/SolicitudesServlet");
    VISTAS.put("/capacity_planner/solicitud_form.jsp", "/SolicitudesServlet");
    VISTAS.put("/capacity_planner/rutas.jsp", "/RutaServlet");
    VISTAS.put("/capacity_planner/ruta_form.jsp", "/RutaServlet");
    VISTAS.put("/capacity_planner/segmentos.jsp", "/SegmentoServlet");
    VISTAS.put("/capacity_planner/segmento_form.jsp", "/SegmentoServlet");
    VISTAS.put("/capacity_planner/landing_stations.jsp", "/LandingStationServlet");
    VISTAS.put("/capacity_planner/landing_station_form.jsp", "/LandingStationServlet");
    VISTAS.put("/capacity_planner/servicios.jsp", "/ServicioServlet");

    // ---------- 4. Network Operator ----------
    VISTAS.put("/network_operator/estado_red.jsp", "/EstadoRedServlet");
    VISTAS.put("/network_operator/segmento-detalle.jsp", "/EstadoRedServlet");
    VISTAS.put("/network_operator/incidencias-visualizar.jsp", "/IncidenciaServlet");
    VISTAS.put("/network_operator/incidencias-detalle.jsp", "/IncidenciaServlet");
    VISTAS.put("/network_operator/historial.jsp", "/IncidenciaServlet?action=historial");
    VISTAS.put("/network_operator/registrar_incidencia.jsp", "/IncidenciaServlet?action=formCrear");

    // ---------- 5. Maintenance Coordinator ----------
    VISTAS.put("/Maintenance_coordinator/fechas_duracion.jsp", "/MantenimientoServlet?accion=listar");
    VISTAS.put("/Maintenance_coordinator/historial.jsp", "/MantenimientoServlet?accion=historial");
    VISTAS.put("/Maintenance_coordinator/nuevo_mantenimiento.jsp", "/MantenimientoServlet?accion=nuevo");
    VISTAS.put("/Maintenance_coordinator/editar_mantenimiento.jsp", "/MantenimientoServlet?accion=listar");
    VISTAS.put("/Maintenance_coordinator/estado.jsp", "/MantenimientoServlet?accion=listar");
    VISTAS.put("/Maintenance_coordinator/serviciosAfectados.jsp", "/ServiciosAfectadosServlet");
  }

  @Override
  public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
    throws IOException, ServletException {

    HttpServletRequest request = (HttpServletRequest) req;
    HttpServletResponse response = (HttpServletResponse) res;

    // Ruta pedida sin el nombre del proyecto. Ej: "/EstadoRedServlet" o "/network_operator/estado_red.jsp"
    String ruta = request.getServletPath();

    // getSession(false): NO crea una sesión nueva, solo trae la que ya existe (o null)
    HttpSession sesion = request.getSession(false);
    Usuario usuario = null;
    if (sesion != null && sesion.getAttribute("usuarioLogueado") instanceof Usuario u) {
      usuario = u;
    }

    // 1. Si ya inició sesión y vuelve al login, lo mandamos a su dashboard
    //    (LoginServlet.doGet ya sabe redirigir según el rol).
    if (usuario != null && ruta.equals("/login.jsp")) {
      response.sendRedirect(request.getContextPath() + "/LoginServlet");
      return;
    }

    // 2. Las páginas públicas pasan sin revisar nada.
    if (esPublica(ruta)) {
      chain.doFilter(request, response);
      return;
    }

    // Desde aquí todo es protegido: que el navegador no lo guarde en caché.
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // 3. No hay sesión (ej. ventana de incógnito o sesión cerrada) -> al login.
    if (usuario == null || !(sesion.getAttribute("idRol") instanceof Integer)) {
      response.sendRedirect(request.getContextPath() + "/LoginServlet");
      return;
    }

    // 4. Hay sesión: revisamos que la página sea de su rol.
    int idRol = (Integer) sesion.getAttribute("idRol");
    int rolRequerido = rolDeLaRuta(ruta);

    if (rolRequerido != CUALQUIER_ROL && rolRequerido != idRol) {
      // Ej: en otra pestaña se inició sesión con otra cuenta y esta pestaña
      // intenta seguir en las vistas del rol anterior -> a su propio dashboard.
      response.sendRedirect(request.getContextPath() + "/LoginServlet");
      return;
    }

    // 5. Es de su rol pero pidió el JSP directo (sin pasar por el servlet, el JSP no tendría datos).
    //    Lo mandamos al servlet que carga esa vista; si no está en la lista (ej. header.jsp), a su dashboard.
    if (ruta.endsWith(".jsp")) {
      String destino = VISTAS.getOrDefault(ruta, "/LoginServlet");
      response.sendRedirect(request.getContextPath() + destino);
      return;
    }

    // Todo correcto: sigue hacia el servlet pedido.
    chain.doFilter(request, response);
  }

  /** Páginas que se pueden ver sin iniciar sesión. */
  private boolean esPublica(String ruta) {
    return ruta.equals("/")
      || ruta.equals("/login.jsp")
      || ruta.equals("/LoginServlet")
      || ruta.equals("/LogoutServlet")
      || ruta.startsWith("/css/")
      || ruta.startsWith("/img/")
      || ruta.endsWith(".css")
      || ruta.endsWith(".js")
      || ruta.endsWith(".png")
      || ruta.endsWith(".jpg")
      || ruta.endsWith(".jpeg")
      || ruta.endsWith(".svg")
      || ruta.endsWith(".ico")
      || ruta.endsWith(".webmanifest")
      || ruta.endsWith(".html")
      || ruta.endsWith(".txt");
  }

  /** Devuelve el rol dueño de la ruta, o CUALQUIER_ROL si no está en las listas. */
  private int rolDeLaRuta(String ruta) {
    // Primero buscamos el servlet o JSP exacto
    if (SERVLETS.containsKey(ruta)) {
      return SERVLETS.get(ruta);
    }

    // Luego buscamos por carpeta de JSP
    for (Map.Entry<String, Integer> carpeta : CARPETAS.entrySet()) {
      if (ruta.startsWith(carpeta.getKey())) {
        return carpeta.getValue();
      }
    }

    // Cualquier otra ruta: basta con estar logueado
    return CUALQUIER_ROL;
  }
}
