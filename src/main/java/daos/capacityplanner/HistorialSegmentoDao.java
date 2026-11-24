package daos.capacityplanner;

import daos.BaseDao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class HistorialSegmentoDao extends BaseDao {
  public record Evento(LocalDateTime fecha, String nombre, String referencia,
                       long cambioOcupada, long cambioReservada, long total,
                       long ocupada, long reservada) {}

  static void registrarReserva(Connection conn, int idRuta, int idServicio, long capacidad)
    throws SQLException {
    String sql = """
      INSERT INTO historial_segmento
        (id_segmento, evento, referencia, cambio_reservada,
         capacidad_total, capacidad_ocupada, capacidad_reservada)
      SELECT s.id_segmento, 'Capacidad reservada', ?, ?,
             s.capacidad_total, s.capacidad_ocupada, s.capacidad_reservada
      FROM ruta_segmentos rs
      JOIN segmentos s ON s.id_segmento = rs.id_segmento
      WHERE rs.id_ruta = ?
      """;
    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
      stmt.setString(1, "SER-" + idServicio);
      stmt.setLong(2, capacidad);
      stmt.setInt(3, idRuta);
      stmt.executeUpdate();
    }
  }

  public List<Evento> listar(int idSegmento) throws SQLException {
    String sql = """
      SELECT fecha, evento, referencia, cambio_ocupada, cambio_reservada,
             capacidad_total, capacidad_ocupada, capacidad_reservada
      FROM historial_segmento
      WHERE id_segmento = ?
      ORDER BY fecha DESC, id_historial DESC
      """;
    List<Evento> eventos = new ArrayList<>();
    try (Connection conn = getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
      stmt.setInt(1, idSegmento);
      try (ResultSet rs = stmt.executeQuery()) {
        while (rs.next()) {
          eventos.add(new Evento(rs.getObject("fecha", LocalDateTime.class),
            rs.getString("evento"), rs.getString("referencia"), rs.getLong("cambio_ocupada"),
            rs.getLong("cambio_reservada"), rs.getLong("capacidad_total"),
            rs.getLong("capacidad_ocupada"), rs.getLong("capacidad_reservada")));
        }
      }
    }
    return eventos;
  }
}
