package daos.supervisor;

import beans.supervisor.MetricaBarra;
import beans.supervisor.ResumenOperativo;
import daos.BaseDao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class DashboardSupervisorDao extends BaseDao {

  public List<MetricaBarra> listarTopClientesCapacidad() {
    List<MetricaBarra> lista = new ArrayList<>();
    List<Long> capacidades = new ArrayList<>();

    String sql = "SELECT c.razon_social, COALESCE(SUM(sol.capacidad_solicitada), 0) AS total_gbps " +
      "FROM clientes c " +
      "INNER JOIN solicitudes sol ON sol.id_cliente = c.id_cliente " +
      "INNER JOIN servicios srv ON srv.id_solicitud = sol.id_solicitud " +
      "WHERE srv.estado = 'Activo' " +
      "GROUP BY c.id_cliente, c.razon_social " +
      "ORDER BY total_gbps DESC, c.razon_social ASC " +
      "LIMIT 5";

    long maxGbps = 0;

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql);
         ResultSet rs = pstmt.executeQuery()) {

      while (rs.next()) {
        String cliente = rs.getString("razon_social");
        long gbps = rs.getLong("total_gbps");
        if (gbps > maxGbps) {
          maxGbps = gbps;
        }
        capacidades.add(gbps);

        MetricaBarra item = new MetricaBarra();
        item.setTitulo(cliente);
        item.setDetalle(gbps + " Gbps");
        item.setClaseBarra("progreso-cliente");
        lista.add(item);
      }
    } catch (SQLException e) {
      e.printStackTrace();
    }

    for (int i = 0; i < lista.size(); i++) {
      long gbps = capacidades.get(i);
      double pct = maxGbps > 0 ? (gbps * 100.0 / maxGbps) : 0.0;
      lista.get(i).setPorcentaje(String.format(Locale.US, "%.0f", pct));
      lista.get(i).setAnchoBarra(String.format(Locale.US, "%.1f", pct));
    }

    return lista;
  }

  public ResumenOperativo obtenerResumenOperativo() {
    ResumenOperativo resumen = new ResumenOperativo();

    resumen.setClientesActivos(contar("SELECT COUNT(DISTINCT sol.id_cliente) " +
      "FROM solicitudes sol " +
      "INNER JOIN servicios srv ON srv.id_solicitud = sol.id_solicitud " +
      "WHERE srv.estado = 'Activo'"));

    resumen.setServiciosActivos(contar("SELECT COUNT(*) FROM servicios WHERE estado = 'Activo'"));

    resumen.setSolicitudesPendientes(contar("SELECT COUNT(*) FROM solicitudes " +
      "WHERE estado IN ('Registrada', 'En evaluacion', 'Aprobada', 'Pendiente por capacidad')"));

    resumen.setTotalLandingStations(contar("SELECT COUNT(*) FROM landingstation"));

    return resumen;
  }

  private int contar(String sql) {
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
