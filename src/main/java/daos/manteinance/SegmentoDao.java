package daos.manteinance;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.util.LinkedHashMap;
import java.util.Map;

public class SegmentoDao extends daos.BaseDao {

  public Map<Integer, String> listarSegmentos() {

    Map<Integer, String> segmentos = new LinkedHashMap<>();

    String sql = """
                SELECT id_segmento, codigo
                FROM segmentos
                ORDER BY codigo ASC
                """;

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql);
         ResultSet rs = pstmt.executeQuery()) {

      while (rs.next()) {

        int id = rs.getInt("id_segmento");
        String codigo = rs.getString("codigo");

        segmentos.put(id, codigo);
      }

    } catch (SQLException e) {
      throw new IllegalStateException(
        "Error al obtener los segmentos", e
      );
    }

    return segmentos;
  }

  // Un segmento "tiene incidencia por reparar" si alguna de sus incidencias ya fue analizada
  // y todavía no se restaura: En analisis, Reparacion programada o En reparacion.
  // (Se incluyen las dos últimas porque una incidencia puede tener varios segmentos:
  //  si ya se programó uno, igual se debe poder programar el otro.)
  private static final String CONDICION_INCIDENCIA_POR_REPARAR = """
          EXISTS (
              SELECT 1 FROM segmentos_has_incidencias si
              JOIN incidencias i ON i.id_incidencia = si.id_incidencia
              WHERE si.id_segmento = s.id_segmento
                AND i.estado IN ('En analisis', 'Reparacion programada', 'En reparacion'))
          """;

  // Para los formularios de mantenimiento: igual que listarSegmentos(),
  // pero marca los segmentos que pueden recibir un mantenimiento correctivo.
  public Map<Integer, String> listarSegmentosParaFormulario() {

    Map<Integer, String> segmentos = new LinkedHashMap<>();

    String sql = "SELECT s.id_segmento, s.codigo, " + CONDICION_INCIDENCIA_POR_REPARAR + " AS por_reparar "
               + "FROM segmentos s ORDER BY s.codigo ASC";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql);
         ResultSet rs = pstmt.executeQuery()) {

      while (rs.next()) {
        String texto = rs.getString("codigo");
        if (rs.getBoolean("por_reparar")) {
          texto += " (incidencia por reparar)";
        }
        segmentos.put(rs.getInt("id_segmento"), texto);
      }

    } catch (SQLException e) {
      throw new IllegalStateException(
        "Error al obtener los segmentos", e
      );
    }

    return segmentos;
  }

  // Regla: un mantenimiento correctivo solo se programa en un segmento con incidencia por reparar.
  public boolean tieneIncidenciaPorReparar(int idSegmento) {

    String sql = "SELECT " + CONDICION_INCIDENCIA_POR_REPARAR + " AS por_reparar "
               + "FROM segmentos s WHERE s.id_segmento = ?";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setInt(1, idSegmento);
      try (ResultSet rs = pstmt.executeQuery()) {
        return rs.next() && rs.getBoolean("por_reparar");
      }

    } catch (SQLException e) {
      throw new IllegalStateException(
        "Error al validar el segmento", e
      );
    }
  }
}
