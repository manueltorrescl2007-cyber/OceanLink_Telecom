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

  public record Pagina(List<Evento> eventos, int total, int numero,
                       int totalPaginas, int desde) {}

  private static final int EVENTOS_POR_PAGINA = 10;

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
    try (Connection conn = getConnection()) {
      return consultarEventos(conn, idSegmento, null);
    }
  }

  public Pagina listarPagina(int idSegmento, int paginaSolicitada) throws SQLException {
    String contar = "SELECT COUNT(*) FROM historial_segmento WHERE id_segmento = ?";
    try (Connection conn = getConnection()) {
      int total;
      try (PreparedStatement stmt = conn.prepareStatement(contar)) {
        stmt.setInt(1, idSegmento);
        try (ResultSet rs = stmt.executeQuery()) {
          rs.next();
          total = rs.getInt(1);
        }
      }

      int paginas = Math.max(1, Math.ceilDiv(total, EVENTOS_POR_PAGINA));
      int pagina = Math.min(paginas, Math.max(1, paginaSolicitada));
      int desde = (pagina - 1) * EVENTOS_POR_PAGINA;
      List<Evento> eventos = consultarEventos(conn, idSegmento, desde);
      return new Pagina(eventos, total, pagina, paginas, desde);
    }
  }

  private static final String EVENTOS_SQL = """
    SELECT fecha, evento, referencia, cambio_ocupada, cambio_reservada,
           capacidad_total, capacidad_ocupada, capacidad_reservada
    FROM historial_segmento
    WHERE id_segmento = ?
    ORDER BY fecha DESC, id_historial DESC
    """;

  private List<Evento> consultarEventos(Connection conn, int idSegmento,
                                        Integer desde) throws SQLException {
    String sql = desde == null ? EVENTOS_SQL : EVENTOS_SQL + "LIMIT ? OFFSET ?";
    List<Evento> eventos = new ArrayList<>();
    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
      stmt.setInt(1, idSegmento);
      if (desde != null) {
        stmt.setInt(2, EVENTOS_POR_PAGINA);
        stmt.setInt(3, desde);
      }
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
