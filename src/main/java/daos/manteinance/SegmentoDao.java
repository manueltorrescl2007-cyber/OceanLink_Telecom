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
}
