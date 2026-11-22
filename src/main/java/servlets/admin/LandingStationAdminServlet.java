package servlets.admin;

import beans.capacityplanner.LandingStation;
import daos.admin.LandingStationAdminDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.ArrayList;

@WebServlet(name = "LandingStationAdminServlet", value = "/LandingStationAdminServlet")
public class LandingStationAdminServlet extends HttpServlet {

  private static final int POR_PAGINA = 10;

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

    String action = request.getParameter("action") == null ? "lista" : request.getParameter("action");
    LandingStationAdminDao dao = new LandingStationAdminDao();

    try {
      switch (action) {
        case "formCrear":
          request.setAttribute("filtroEstado", filtroEstado(request));
          request.setAttribute("paginaActual", Math.max(1, parseId(request.getParameter("pagina"))));
          request.getRequestDispatcher("/admin/landing_station_form.jsp").forward(request, response);
          break;

        case "editar":
          int idEditar = parseId(request.getParameter("id"));
          LandingStation estacion = dao.obtenerEstacion(idEditar);
          if (estacion == null) {
            response.sendRedirect(request.getContextPath() + "/LandingStationAdminServlet");
          } else {
            request.setAttribute("estacion", estacion);
            request.setAttribute("filtroEstado", filtroEstado(request));
            request.setAttribute("paginaActual", Math.max(1, parseId(request.getParameter("pagina"))));
            request.getRequestDispatcher("/admin/landing_station_form.jsp").forward(request, response);
          }
          break;

        case "desactivar":
          dao.cambiarEstado(parseId(request.getParameter("id")), "Inactiva");
          response.sendRedirect(urlListado(request, "estadoOk"));
          break;

        case "activar":
          dao.cambiarEstado(parseId(request.getParameter("id")), "Activa");
          response.sendRedirect(urlListado(request, "estadoOk"));
          break;

        case "eliminar":
          try {
            boolean eliminado = dao.eliminarEstacion(parseId(request.getParameter("id")));
            response.sendRedirect(urlListado(request, eliminado ? "eliminado" : "noExiste"));
          } catch (SQLException e) {
            if (e.getErrorCode() == 1451) {
              response.sendRedirect(urlListado(request, "asociado"));
            } else {
              throw e;
            }
          }
          break;

        case "lista":
        default:
          mostrarLista(request, response, dao);
          break;
      }
    } catch (SQLException e) {
      throw new ServletException("Error en la gestión de Landing Stations.", e);
    }
  }

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");
    String action = request.getParameter("action") == null ? "guardar" : request.getParameter("action");

    if (!"guardar".equals(action)) {
      response.sendRedirect(request.getContextPath() + "/LandingStationAdminServlet");
      return;
    }

    String idTexto = texto(request.getParameter("idLanding"));
    boolean esNuevo = idTexto.isEmpty();

    LandingStation estacion = new LandingStation();
    if (!esNuevo) {
      int id = parseId(idTexto);
      if (id <= 0) {
        response.sendRedirect(request.getContextPath() + "/LandingStationAdminServlet");
        return;
      }
      estacion.setIdLanding(id);
    }

    estacion.setNombre(texto(request.getParameter("nombre")));
    estacion.setPais(texto(request.getParameter("pais")));
    estacion.setCiudad(texto(request.getParameter("ciudad")));
    estacion.setEstado(texto(request.getParameter("estadoEstacion")));

    String error = validarEstacion(estacion);
    if (error != null) {
      request.setAttribute("error", error);
      request.setAttribute("estacion", estacion);
      request.setAttribute("filtroEstado", filtroEstado(request));
      request.setAttribute("paginaActual", Math.max(1, parseId(request.getParameter("pagina"))));
      request.getRequestDispatcher("/admin/landing_station_form.jsp").forward(request, response);
      return;
    }

    LandingStationAdminDao dao = new LandingStationAdminDao();
    try {
      boolean ok = esNuevo ? dao.crearEstacion(estacion) : dao.actualizarEstacion(estacion);
      if (!ok) {
        request.setAttribute("error", "No se pudo guardar la estación.");
        request.setAttribute("estacion", estacion);
        request.setAttribute("filtroEstado", filtroEstado(request));
        request.setAttribute("paginaActual", Math.max(1, parseId(request.getParameter("pagina"))));
        request.getRequestDispatcher("/admin/landing_station_form.jsp").forward(request, response);
        return;
      }
      response.sendRedirect(urlListado(request, "guardado"));
    } catch (SQLException e) {
      String msg = (e.getErrorCode() == 1062)
        ? "Ya existe una Landing Station con ese nombre."
        : "Error al guardar la estación en la base de datos.";
      request.setAttribute("error", msg);
      request.setAttribute("estacion", estacion);
      request.setAttribute("filtroEstado", filtroEstado(request));
      request.setAttribute("paginaActual", Math.max(1, parseId(request.getParameter("pagina"))));
      request.getRequestDispatcher("/admin/landing_station_form.jsp").forward(request, response);
    }
  }

  private void mostrarLista(HttpServletRequest request, HttpServletResponse response, LandingStationAdminDao dao)
    throws SQLException, ServletException, IOException {

    String filtro = filtroEstado(request);
    ArrayList<LandingStation> todas = dao.listarEstaciones(filtro);

    int totalRegistros = todas.size();
    int totalPaginas = Math.max(1, (totalRegistros + POR_PAGINA - 1) / POR_PAGINA);
    int paginaActual = Math.max(1, Math.min(parseId(request.getParameter("pagina")), totalPaginas));

    int desde = (paginaActual - 1) * POR_PAGINA;
    int hasta = Math.min(desde + POR_PAGINA, totalRegistros);
    ArrayList<LandingStation> paginaLista = new ArrayList<>(todas.subList(desde, hasta));

    int registroInicio = totalRegistros == 0 ? 0 : desde + 1;
    int registroFin = totalRegistros == 0 ? 0 : hasta;
    int idDetalle = parseId(request.getParameter("detalle"));
    if (idDetalle > 0) {
      for (LandingStation est : todas) {
        if (est.getIdLanding() == idDetalle) {
          request.setAttribute("estacionDetalle", est);
          break;
        }
      }
    }

    request.setAttribute("listaEstaciones", paginaLista);
    request.setAttribute("filtroEstado", filtro);
    request.setAttribute("totalRegistros", totalRegistros);
    request.setAttribute("totalPaginas", totalPaginas);
    request.setAttribute("paginaActual", paginaActual);
    request.setAttribute("registroInicio", registroInicio);
    request.setAttribute("registroFin", registroFin);

    request.getRequestDispatcher("/admin/landing_stations.jsp").forward(request, response);
  }

  private String urlListado(HttpServletRequest request, String msg) {
    String filtro = filtroEstado(request);
    int pagina = Math.max(1, parseId(request.getParameter("pagina")));
    StringBuilder sb = new StringBuilder(request.getContextPath())
      .append("/LandingStationAdminServlet?pagina=").append(pagina);
    if (!filtro.isEmpty()) {
      sb.append("&estado=").append(URLEncoder.encode(filtro, StandardCharsets.UTF_8));
    }
    if (msg != null && !msg.isEmpty()) {
      sb.append("&msg=").append(msg);
    }
    return sb.toString();
  }

  private String filtroEstado(HttpServletRequest request) {
    String estado = texto(request.getParameter("estado"));
    return ("Activa".equals(estado) || "Inactiva".equals(estado)) ? estado : "";
  }

  private String validarEstacion(LandingStation estacion) {
    if (estacion.getNombre().isEmpty() || estacion.getNombre().length() > 100) {
      return "Ingresa un nombre válido (máximo 100 caracteres).";
    }
    if (estacion.getPais().isEmpty() || estacion.getPais().length() > 45) {
      return "Ingresa un país válido (máximo 45 caracteres).";
    }
    if (estacion.getCiudad().isEmpty() || estacion.getCiudad().length() > 45) {
      return "Ingresa una ciudad válida (máximo 45 caracteres).";
    }
    if (!"Activa".equals(estacion.getEstado()) && !"Inactiva".equals(estacion.getEstado())) {
      return "Selecciona un estado válido.";
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

  private String texto(String valor) {
    return valor == null ? "" : valor.trim();
  }
}
