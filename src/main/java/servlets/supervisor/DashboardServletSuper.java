package servlets.supervisor;

import beans.maintenance.Mantenimiento;
import beans.networkoperator.Incidencia;
import beans.networkoperator.Segmento;
import beans.networkoperator.Servicio;
import beans.supervisor.MetricaBarra;
import beans.supervisor.ResumenOperativo;
import daos.manteinance.MantenimientoDao;
import daos.networkoperator.IncidenciaDao;
import daos.networkoperator.SegmentoDao;
import daos.networkoperator.ServicioDao;
import daos.supervisor.DashboardSupervisorDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

@WebServlet(name = "DashboardServletSuper", value = "/DashboardServletSuper")
public class DashboardServletSuper extends HttpServlet {

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

    IncidenciaDao incidenciaDao = new IncidenciaDao();
    SegmentoDao segmentoDao = new SegmentoDao();
    ServicioDao servicioDao = new ServicioDao();
    DashboardSupervisorDao dashboardDao = new DashboardSupervisorDao();

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

      for (Servicio servicio : servicioDao.listarServiciosAfectados(incidencia.getIdIncidencia())) {
        idsServicios.add(servicio.getIdServicio());
        if (servicio.getSolicitud() != null && servicio.getSolicitud().getCliente() != null) {
          idsClientes.add(servicio.getSolicitud().getCliente().getIdCliente());
        }
      }
    }

    long capacidadTotal = 0;
    long capacidadUtilizada = 0;
    int operativos = 0;
    int degradados = 0;
    int fueraServicio = 0;
    int mantenimiento = 0;

    Map<Integer, String> mapaCodigosSegmento = new HashMap<>();
    List<MetricaBarra> rankingSegmentos = new ArrayList<>();
    List<Double> porcentajesSegmentos = new ArrayList<>();

    for (Segmento segmento : segmentos) {
      mapaCodigosSegmento.put(segmento.getIdSegmento(), segmento.getCodigo());

      long capTot = segmento.getCapacidadTotal();
      long capOcu = segmento.getCapacidadOcupada();
      long capRes = segmento.getCapacidadReservada();
      long capUsada = capOcu + capRes;

      capacidadTotal += capTot;
      capacidadUtilizada += capUsada;

      String estado = segmento.getEstado();
      if ("Operativo".equals(estado)) operativos++;
      else if ("Degradado".equals(estado)) degradados++;
      else if ("Fuera de servicio".equals(estado)) fueraServicio++;
      else if ("En mantenimiento".equals(estado)) mantenimiento++;

      double pct = capTot > 0 ? (capUsada * 100.0 / capTot) : 0.0;
      double pctBarra = Math.min(100.0, Math.max(0.0, pct));
      String claseBarra = pct > 95.0 ? "progreso-critica" : (pct >= 80.0 ? "progreso-alta" : "progreso-normal");

      MetricaBarra metrica = new MetricaBarra(
        segmento.getCodigo(),
        capUsada + " / " + capTot + " Gbps",
        String.format(Locale.US, "%.0f", pct),
        String.format(Locale.US, "%.1f", pctBarra),
        claseBarra
      );
      rankingSegmentos.add(metrica);
      porcentajesSegmentos.add(pct);
    }

    // Ordenar Top 5 segmentos de mayor a menor utilización
    for (int i = 0; i < rankingSegmentos.size() - 1; i++) {
      for (int j = i + 1; j < rankingSegmentos.size(); j++) {
        if (porcentajesSegmentos.get(j) > porcentajesSegmentos.get(i)) {
          double tmpPct = porcentajesSegmentos.get(i);
          porcentajesSegmentos.set(i, porcentajesSegmentos.get(j));
          porcentajesSegmentos.set(j, tmpPct);

          MetricaBarra tmpMetrica = rankingSegmentos.get(i);
          rankingSegmentos.set(i, rankingSegmentos.get(j));
          rankingSegmentos.set(j, tmpMetrica);
        }
      }
    }
    if (rankingSegmentos.size() > 5) {
      rankingSegmentos = new ArrayList<>(rankingSegmentos.subList(0, 5));
    }

    double disponibilidad = segmentos.isEmpty() ? 0 : operativos * 100.0 / segmentos.size();
    double utilizacion = capacidadTotal == 0 ? 0 : capacidadUtilizada * 100.0 / capacidadTotal;
    String claseUtilizacion = utilizacion > 95.0 ? "kpi-alerta-critica" : (utilizacion >= 80.0 ? "kpi-alerta-alta" : "kpi-alerta-normal");

    String estadoRed;
    if (segmentos.isEmpty()) estadoRed = "SIN DATOS";
    else if (fueraServicio > 0) estadoRed = "INTERRUMPIDA";
    else if (degradados > 0 || mantenimiento > 0) estadoRed = "DEGRADADA";
    else estadoRed = "OPERATIVA";

    String claseEstadoRed = "INTERRUMPIDA".equals(estadoRed) ? "kpi-alerta-critica"
      : ("DEGRADADA".equals(estadoRed) ? "kpi-alerta-alta" : "kpi-alerta-normal");

    Integer proximosMantenimientos = null;
    List<Mantenimiento> listaProximosMantenimientos = new ArrayList<>();
    try {
      LocalDateTime ahora = LocalDateTime.now();
      LocalDateTime limite = ahora.plusDays(7);
      int cantidad = 0;
      for (Mantenimiento m : new MantenimientoDao().listarMantenimientos()) {
        if ("Programado".equals(m.getEstado()) && m.getFechaInicio() != null
          && !m.getFechaInicio().isBefore(ahora)) {
          if (m.getFechaInicio().isBefore(limite)) {
            cantidad++;
          }
          listaProximosMantenimientos.add(m);
        }
      }
      listaProximosMantenimientos.sort(Comparator.comparing(Mantenimiento::getFechaInicio));
      if (listaProximosMantenimientos.size() > 5) {
        listaProximosMantenimientos = new ArrayList<>(listaProximosMantenimientos.subList(0, 5));
      }
      proximosMantenimientos = cantidad;
    } catch (IllegalStateException e) {
      getServletContext().log("No se pudieron consultar los mantenimientos del dashboard", e);
    }

    List<MetricaBarra> topClientes = dashboardDao.listarTopClientesCapacidad();
    ResumenOperativo resumenOperativo = dashboardDao.obtenerResumenOperativo();

    List<Incidencia> incidenciasRecientes = incidencias.size() > 5
      ? new ArrayList<>(incidencias.subList(0, 5))
      : incidencias;

    request.setAttribute("estadoRed", estadoRed);
    request.setAttribute("claseEstadoRed", claseEstadoRed);
    request.setAttribute("disponibilidad", String.format(Locale.US, "%.1f", disponibilidad));
    request.setAttribute("totalIncidencias", incidencias.size());
    request.setAttribute("incidenciasCriticas", criticas);
    request.setAttribute("incidenciasMedias", medias);
    request.setAttribute("clientesAfectados", idsClientes.size());
    request.setAttribute("serviciosAfectados", idsServicios.size());
    request.setAttribute("mantenimientosProgramados", proximosMantenimientos);
    request.setAttribute("utilizacion", String.format(Locale.US, "%.1f", utilizacion));
    request.setAttribute("claseUtilizacion", claseUtilizacion);

    request.setAttribute("topSegmentos", rankingSegmentos);
    request.setAttribute("topClientes", topClientes);
    request.setAttribute("resumenOperativo", resumenOperativo);

    request.setAttribute("incidenciasRecientes", incidenciasRecientes);
    request.setAttribute("proximosMantenimientosLista", listaProximosMantenimientos);
    request.setAttribute("mapaCodigosSegmento", mapaCodigosSegmento);

    request.getRequestDispatcher("/supervisor/supervisor.jsp").forward(request, response);
  }
}
