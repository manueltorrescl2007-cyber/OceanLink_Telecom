package servlets.supervisor;

import beans.networkoperator.Incidencia;
import beans.networkoperator.Servicio;
import beans.networkoperator.Segmento;
import beans.maintenance.Mantenimiento;
import daos.networkoperator.IncidenciaDao;
import daos.networkoperator.ServicioDao;
import daos.networkoperator.SegmentoDao;
import daos.manteinance.MantenimientoDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;

@WebServlet(name = "DashboardServletSuper", value = "/DashboardServletSuper")
public class DashboardServletSuper extends HttpServlet {

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

    IncidenciaDao incidenciaDao = new IncidenciaDao();
    SegmentoDao segmentoDao = new SegmentoDao();
    ServicioDao servicioDao = new ServicioDao();

    ArrayList<Incidencia> incidencias = incidenciaDao.listarIncidencias(false, null, -1);
    ArrayList<Segmento> segmentos = segmentoDao.listarSegmentos(null);

    int criticas = 0;
    int medias = 0;
    Set<Integer> idsServicios = new HashSet<>();
    Set<Integer> idsClientes = new HashSet<>();

    for (Incidencia incidencia : incidencias) {
      if ("Critica".equals(incidencia.getSeveridad())) criticas++;
      if ("Media".equals(incidencia.getSeveridad())) medias++;

      incidencia.setSegmentos(segmentoDao.listarSegmentosDeIncidencia(incidencia.getIdIncidencia()));

      // Un mismo servicio/cliente puede estar afectado por varias incidencias.
      for (Servicio servicio : servicioDao.listarServiciosAfectados(incidencia.getIdIncidencia())) {
        idsServicios.add(servicio.getIdServicio());
        if (servicio.getSolicitud() != null && servicio.getSolicitud().getCliente() != null) {
          idsClientes.add(servicio.getSolicitud().getCliente().getIdCliente());
        }
      }
    }

    long capacidadTotal = 0;
    long capacidadOcupada = 0;
    int operativos = 0;
    int degradados = 0;
    int fueraServicio = 0;
    int mantenimiento = 0;

    for (Segmento segmento : segmentos) {
      capacidadTotal += segmento.getCapacidadTotal();
      capacidadOcupada += segmento.getCapacidadOcupada();
      String estado = segmento.getEstado();
      if ("Operativo".equals(estado)) operativos++;
      else if ("Degradado".equals(estado)) degradados++;
      else if ("Fuera de servicio".equals(estado)) fueraServicio++;
      else if ("En mantenimiento".equals(estado)) mantenimiento++;
    }

    double disponibilidad = segmentos.isEmpty() ? 0 : operativos * 100.0 / segmentos.size();
    double utilizacion = capacidadTotal == 0 ? 0 : capacidadOcupada * 100.0 / capacidadTotal;
    String estadoRed;
    if (segmentos.isEmpty()) estadoRed = "SIN DATOS";
    else if (fueraServicio > 0) estadoRed = "INTERRUMPIDA";
    else if (degradados > 0 || mantenimiento > 0) estadoRed = "DEGRADADA";
    else estadoRed = "OPERATIVA";

    // Esta consulta no actualiza registros; evita modificar la BD al abrir el dashboard.
    // Si MantenimientoDao continúa fallando, informamos 'No disponible' y registramos el error.
    Integer proximosMantenimientos = null;
    try {
      LocalDateTime ahora = LocalDateTime.now();
      LocalDateTime limite = ahora.plusDays(7);
      int cantidad = 0;
      for (Mantenimiento m : new MantenimientoDao().listarMantenimientos()) {
        if ("Programado".equals(m.getEstado()) && m.getFechaInicio() != null
          && !m.getFechaInicio().isBefore(ahora)
          && m.getFechaInicio().isBefore(limite)) {
          cantidad++;
        }
      }
      proximosMantenimientos = cantidad;
    } catch (IllegalStateException e) {
      getServletContext().log("No se pudieron consultar los mantenimientos del dashboard", e);
    }

    String severidadFiltro = request.getParameter("severidad");
    if (!"Critica".equals(severidadFiltro) && !"Alta".equals(severidadFiltro)
      && !"Media".equals(severidadFiltro) && !"Leve".equals(severidadFiltro)) {
      severidadFiltro = "";
    }
    int idSegmentoFiltro = -1;
    try { idSegmentoFiltro = Integer.parseInt(request.getParameter("idSegmento")); }
    catch (NumberFormatException ignored) { }

    ArrayList<Incidencia> incidenciasFiltradas = new ArrayList<>();
    for (Incidencia incidencia : incidencias) {
      if (!severidadFiltro.isEmpty() && !severidadFiltro.equals(incidencia.getSeveridad())) continue;
      if (idSegmentoFiltro > 0) {
        boolean encontrada = false;
        for (Segmento segmento : incidencia.getSegmentos()) {
          if (segmento.getIdSegmento() == idSegmentoFiltro) { encontrada = true; break; }
        }
        if (!encontrada) continue;
      }
      incidenciasFiltradas.add(incidencia);
    }

    request.setAttribute("estadoRed", estadoRed);
    request.setAttribute("disponibilidad", String.format(java.util.Locale.US, "%.1f", disponibilidad));
    request.setAttribute("totalIncidencias", incidencias.size());
    request.setAttribute("incidenciasCriticas", criticas);
    request.setAttribute("incidenciasMedias", medias);
    request.setAttribute("clientesAfectados", idsClientes.size());
    request.setAttribute("serviciosAfectados", idsServicios.size());
    request.setAttribute("mantenimientosProgramados", proximosMantenimientos);
    request.setAttribute("utilizacion", String.format(java.util.Locale.US, "%.1f", utilizacion));
    request.setAttribute("listaIncidencias", incidenciasFiltradas);
    request.setAttribute("listaSegmentos", segmentos);
    request.setAttribute("filtroSeveridad", severidadFiltro);
    request.setAttribute("filtroIdSegmento", idSegmentoFiltro);

    request.getRequestDispatcher("/supervisor/supervisor.jsp").forward(request, response);
  }
}

