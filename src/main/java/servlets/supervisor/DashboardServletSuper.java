package servlets.supervisor;

import beans.maintenance.Mantenimiento;
import beans.networkoperator.Incidencia;
import beans.networkoperator.Segmento;
import beans.networkoperator.Servicio;
import daos.BaseDao;
import daos.manteinance.MantenimientoDao;
import daos.networkoperator.IncidenciaDao;
import daos.networkoperator.SegmentoDao;
import daos.networkoperator.ServicioDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

@WebServlet(name = "DashboardServletSuper", value = "/DashboardServletSuper")
public class DashboardServletSuper extends HttpServlet {

  private static class ConsultaPlataformaDao extends BaseDao {

    ArrayList<String[]> listarTopClientesCapacidad() {
      ArrayList<String[]> lista = new ArrayList<>();
      String sql = "SELECT c.razon_social, COALESCE(SUM(sol.capacidad_solicitada), 0) AS total_gbps " +
        "FROM clientes c " +
        "INNER JOIN solicitudes sol ON sol.id_cliente = c.id_cliente " +
        "INNER JOIN servicios srv ON srv.id_solicitud = sol.id_solicitud " +
        "WHERE srv.estado = 'Activo' " +
        "GROUP BY c.id_cliente, c.razon_social " +
        "ORDER BY total_gbps DESC, c.razon_social ASC " +
        "LIMIT 5";
      try (Connection conn = getConnection();
           PreparedStatement pstmt = conn.prepareStatement(sql);
           ResultSet rs = pstmt.executeQuery()) {
        while (rs.next()) {
          String cliente = rs.getString("razon_social");
          String gbps = String.valueOf(rs.getLong("total_gbps"));
          lista.add(new String[]{cliente, gbps, "0"});
        }
      } catch (SQLException e) {
        e.printStackTrace();
      }
      return lista;
    }

    int contarRegistros(String sql) {
      try (Connection conn = getConnection();
           PreparedStatement pstmt = conn.prepareStatement(sql);
           ResultSet rs = pstmt.executeQuery()) {
        if (rs.next()) {
          return rs.getInt(1);
        }
      } catch (SQLException e) {
        e.printStackTrace();
      }
      return 0;
    }
  }

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

    IncidenciaDao incidenciaDao = new IncidenciaDao();
    SegmentoDao segmentoDao = new SegmentoDao();
    ServicioDao servicioDao = new ServicioDao();
    ConsultaPlataformaDao plataformaDao = new ConsultaPlataformaDao();

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
    long capacidadOcupada = 0;
    int operativos = 0;
    int degradados = 0;
    int fueraServicio = 0;
    int mantenimiento = 0;

    Map<Integer, String> mapaCodigosSegmento = new HashMap<>();
    ArrayList<String[]> rankingSegmentos = new ArrayList<>();

    for (Segmento segmento : segmentos) {
      mapaCodigosSegmento.put(segmento.getIdSegmento(), segmento.getCodigo());

      long capTot = segmento.getCapacidadTotal();
      long capOcu = segmento.getCapacidadOcupada();
      long capRes = segmento.getCapacidadReservada();
      long capUsada = capOcu + capRes;

      capacidadTotal += capTot;
      capacidadOcupada += capOcu;

      String estado = segmento.getEstado();
      if ("Operativo".equals(estado)) operativos++;
      else if ("Degradado".equals(estado)) degradados++;
      else if ("Fuera de servicio".equals(estado)) fueraServicio++;
      else if ("En mantenimiento".equals(estado)) mantenimiento++;

      double pct = capTot > 0 ? (capUsada * 100.0 / capTot) : 0.0;
      double pctBarra = Math.min(100.0, Math.max(0.0, pct));
      String claseBarra = pct > 95.0 ? "progreso-critica" : (pct >= 80.0 ? "progreso-alta" : "progreso-normal");

      // [0]=codigo, [1]=detalleCapacidad, [2]=anchoBarra, [3]=claseBarra, [4]=porcentaje, [5]=pctNum
      rankingSegmentos.add(new String[]{
        segmento.getCodigo(),
        capUsada + " / " + capTot + " Gbps",
        String.format(Locale.US, "%.1f", pctBarra),
        claseBarra,
        String.format(Locale.US, "%.0f", pct),
        String.valueOf(pct)
      });
    }

    rankingSegmentos.sort((a, b) -> Double.compare(
      Double.parseDouble(b[5]),
      Double.parseDouble(a[5])
    ));
    if (rankingSegmentos.size() > 5) {
      rankingSegmentos = new ArrayList<>(rankingSegmentos.subList(0, 5));
    }

    double disponibilidad = segmentos.isEmpty() ? 0 : operativos * 100.0 / segmentos.size();
    double utilizacion = capacidadTotal == 0 ? 0 : capacidadOcupada * 100.0 / capacidadTotal;
    String estadoRed;
    if (segmentos.isEmpty()) estadoRed = "SIN DATOS";
    else if (fueraServicio > 0) estadoRed = "INTERRUMPIDA";
    else if (degradados > 0 || mantenimiento > 0) estadoRed = "DEGRADADA";
    else estadoRed = "OPERATIVA";

    Integer proximosMantenimientos = null;
    ArrayList<Mantenimiento> listaProximosMantenimientos = new ArrayList<>();
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

    // [0]=cliente, [1]=gbps, [2]=anchoBarra
    ArrayList<String[]> topClientes = plataformaDao.listarTopClientesCapacidad();
    long maxGbpsCliente = 0;
    for (String[] c : topClientes) {
      long val = Long.parseLong(c[1]);
      if (val > maxGbpsCliente) maxGbpsCliente = val;
    }
    for (String[] c : topClientes) {
      long val = Long.parseLong(c[1]);
      double ancho = maxGbpsCliente > 0 ? (val * 100.0 / maxGbpsCliente) : 0.0;
      c[2] = String.format(Locale.US, "%.1f", ancho);
    }

    int totalLandingStations = plataformaDao.contarRegistros("SELECT COUNT(*) FROM landingstation");
    int totalUsuariosActivos = plataformaDao.contarRegistros("SELECT COUNT(*) FROM usuarios WHERE activo = 1");

    ArrayList<Incidencia> incidenciasRecientes = incidencias.size() > 5
      ? new ArrayList<>(incidencias.subList(0, 5))
      : incidencias;

    request.setAttribute("estadoRed", estadoRed);
    request.setAttribute("disponibilidad", String.format(Locale.US, "%.1f", disponibilidad));
    request.setAttribute("totalIncidencias", incidencias.size());
    request.setAttribute("incidenciasCriticas", criticas);
    request.setAttribute("incidenciasMedias", medias);
    request.setAttribute("clientesAfectados", idsClientes.size());
    request.setAttribute("serviciosAfectados", idsServicios.size());
    request.setAttribute("mantenimientosProgramados", proximosMantenimientos);
    request.setAttribute("utilizacion", String.format(Locale.US, "%.1f", utilizacion));

    request.setAttribute("topSegmentos", rankingSegmentos);
    request.setAttribute("topClientes", topClientes);
    request.setAttribute("totalLandingStations", totalLandingStations);
    request.setAttribute("totalSegmentos", segmentos.size());
    request.setAttribute("segmentosOperativos", operativos);
    request.setAttribute("totalUsuariosActivos", totalUsuariosActivos);

    request.setAttribute("incidenciasRecientes", incidenciasRecientes);
    request.setAttribute("proximosMantenimientosLista", listaProximosMantenimientos);
    request.setAttribute("mapaCodigosSegmento", mapaCodigosSegmento);

    request.getRequestDispatcher("/supervisor/supervisor.jsp").forward(request, response);
  }
}

