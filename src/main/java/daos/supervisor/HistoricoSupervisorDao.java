package daos.supervisor;

import beans.supervisor.HistoricoGeneral;
import daos.BaseDao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;

public class HistoricoSupervisorDao extends BaseDao {

  private static final DateTimeFormatter FORMATO_FECHA =
    DateTimeFormatter.ofPattern("dd MMM yyyy", Locale.forLanguageTag("es-PE"));

  public List<String> listarCodigosSegmentos() {
    List<String> codigos = new ArrayList<>();
    String sql = "SELECT codigo FROM segmentos ORDER BY codigo";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql);
         ResultSet rs = pstmt.executeQuery()) {

      while (rs.next()) {
        codigos.add(rs.getString("codigo"));
      }
    } catch (SQLException e) {
      e.printStackTrace();
    }
    return codigos;
  }

  public List<HistoricoGeneral> listarHistoricoConsolidado(String desde, String hasta, String origen, String segmento) {
    List<HistoricoGeneral> lista = new ArrayList<>();

    boolean incluirIncidencias = origen == null || origen.isBlank() || "Incidencia".equalsIgnoreCase(origen);
    boolean incluirMantenimientos = origen == null || origen.isBlank() || "Mantenimiento".equalsIgnoreCase(origen);

    if (incluirIncidencias) {
      lista.addAll(consultarIncidenciasCerradas(desde, hasta, segmento));
    }
    if (incluirMantenimientos) {
      lista.addAll(consultarMantenimientosHistoricos(desde, hasta, segmento));
    }

    // Ordenar cronológicamente del más reciente al más antiguo
    lista.sort(Comparator.comparing(
      HistoricoGeneral::getFechaOrden,
      Comparator.nullsLast(Comparator.reverseOrder())
    ));

    return lista;
  }

  private List<HistoricoGeneral> consultarIncidenciasCerradas(String desde, String hasta, String segmento) {
    List<HistoricoGeneral> lista = new ArrayList<>();

    boolean filtrarDesde = desde != null && !desde.isBlank();
    boolean filtrarHasta = hasta != null && !hasta.isBlank();
    boolean filtrarSegmento = segmento != null && !segmento.isBlank();

    StringBuilder sql = new StringBuilder(
      "SELECT i.id_incidencia, i.codigo, i.titulo, i.severidad, "
        + "       COALESCE(i.fecha_cierre, i.fecha_restauracion, i.fecha_registro) AS fecha_efectiva, "
        + "       COALESCE(GROUP_CONCAT(DISTINCT s.codigo ORDER BY s.codigo SEPARATOR ', '), 'Sin segmento') AS segs "
        + "FROM incidencias i "
        + "LEFT JOIN segmentos_has_incidencias si ON i.id_incidencia = si.id_incidencia "
        + "LEFT JOIN segmentos s ON si.id_segmento = s.id_segmento "
        + "WHERE i.estado = 'Cerrada' "
    );

    if (filtrarDesde) {
      sql.append("AND DATE(COALESCE(i.fecha_cierre, i.fecha_restauracion, i.fecha_registro)) >= ? ");
    }
    if (filtrarHasta) {
      sql.append("AND DATE(COALESCE(i.fecha_cierre, i.fecha_restauracion, i.fecha_registro)) <= ? ");
    }
    if (filtrarSegmento) {
      sql.append("AND EXISTS (SELECT 1 FROM segmentos_has_incidencias si2 "
        + "            JOIN segmentos s2 ON si2.id_segmento = s2.id_segmento "
        + "            WHERE si2.id_incidencia = i.id_incidencia AND s2.codigo = ?) ");
    }
    sql.append("GROUP BY i.id_incidencia");

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {

      int idx = 1;
      if (filtrarDesde) pstmt.setString(idx++, desde);
      if (filtrarHasta) pstmt.setString(idx++, hasta);
      if (filtrarSegmento) pstmt.setString(idx++, segmento);

      try (ResultSet rs = pstmt.executeQuery()) {
        while (rs.next()) {
          HistoricoGeneral h = new HistoricoGeneral();
          h.setIdNumerico(rs.getInt("id_incidencia"));
          h.setCodigoMostrar(rs.getString("codigo"));
          h.setTipoRegistro("Incidencia");
          h.setSegmento(rs.getString("segs"));
          h.setDetalleTipo(rs.getString("titulo"));

          Timestamp ts = rs.getTimestamp("fecha_efectiva");
          if (ts != null) {
            LocalDateTime ldt = ts.toLocalDateTime();
            h.setFechaOrden(ldt);
            h.setFechaFormateada(ldt.format(FORMATO_FECHA).toLowerCase());
          } else {
            h.setFechaFormateada("-");
          }

          String sev = rs.getString("severidad");
          h.setEstadoSeveridad(sev);
          h.setClaseBadge(obtenerClaseSeveridad(sev));
          lista.add(h);
        }
      }
    } catch (SQLException e) {
      e.printStackTrace();
    }
    return lista;
  }

  private List<HistoricoGeneral> consultarMantenimientosHistoricos(String desde, String hasta, String segmento) {
    List<HistoricoGeneral> lista = new ArrayList<>();

    boolean filtrarDesde = desde != null && !desde.isBlank();
    boolean filtrarHasta = hasta != null && !hasta.isBlank();
    boolean filtrarSegmento = segmento != null && !segmento.isBlank();

    StringBuilder sql = new StringBuilder(
      "SELECT m.id_mantenimiento, s.codigo AS seg, m.tipo, "
        + "       CASE WHEN m.estado = 'Cancelado' THEN 'Cancelado' ELSE 'Finalizado' END AS estado_real, "
        + "       COALESCE(m.fecha_fin, m.fecha_inicio) AS fecha_efectiva "
        + "FROM mantenimientos m "
        + "JOIN segmentos s ON m.id_segmento = s.id_segmento "
        + "WHERE (m.estado IN ('Finalizado', 'Cancelado') "
        + "       OR (m.fecha_fin IS NOT NULL AND m.fecha_fin < NOW())) "
    );

    if (filtrarDesde) {
      sql.append("AND DATE(COALESCE(m.fecha_fin, m.fecha_inicio)) >= ? ");
    }
    if (filtrarHasta) {
      sql.append("AND DATE(COALESCE(m.fecha_fin, m.fecha_inicio)) <= ? ");
    }
    if (filtrarSegmento) {
      sql.append("AND s.codigo = ? ");
    }

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {

      int idx = 1;
      if (filtrarDesde) pstmt.setString(idx++, desde);
      if (filtrarHasta) pstmt.setString(idx++, hasta);
      if (filtrarSegmento) pstmt.setString(idx++, segmento);

      try (ResultSet rs = pstmt.executeQuery()) {
        while (rs.next()) {
          int idMnt = rs.getInt("id_mantenimiento");
          String estadoReal = rs.getString("estado_real");

          HistoricoGeneral h = new HistoricoGeneral();
          h.setIdNumerico(idMnt);
          h.setCodigoMostrar(String.format("MNT-%03d", idMnt));
          h.setTipoRegistro("Mantenimiento");
          h.setSegmento(rs.getString("seg"));
          h.setDetalleTipo(rs.getString("tipo"));

          Timestamp ts = rs.getTimestamp("fecha_efectiva");
          if (ts != null) {
            LocalDateTime ldt = ts.toLocalDateTime();
            h.setFechaOrden(ldt);
            h.setFechaFormateada(ldt.format(FORMATO_FECHA).toLowerCase());
          } else {
            h.setFechaFormateada("-");
          }

          h.setEstadoSeveridad(estadoReal);
          h.setClaseBadge("Cancelado".equals(estadoReal) ? "badge-cancelado" : "badge-finalizado");
          lista.add(h);
        }
      }
    } catch (SQLException e) {
      e.printStackTrace();
    }
    return lista;
  }

  private String obtenerClaseSeveridad(String severidad) {
    if (severidad == null) return "severidad-leve";
    switch (severidad) {
      case "Critica": return "severidad-critica";
      case "Alta":    return "severidad-alta";
      case "Media":   return "severidad-media";
      default:        return "severidad-leve";
    }
  }
}
