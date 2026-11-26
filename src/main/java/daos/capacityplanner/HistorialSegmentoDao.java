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

  // ===================== EVENTOS QUE SE ANOTAN EN EL HISTORIAL =====================
  // Cada vez que un DAO cambia el estado de un servicio o de un mantenimiento,
  // llama a uno de estos métodos con la MISMA conexión (misma transacción).
  // Se guarda una fila por cada segmento afectado, con la foto de su capacidad en ese momento.

  // Servicio: una fila por cada segmento de su ruta.
  // cambioOcupada / cambioReservada: cuánto subió (+) o bajó (-) la capacidad en ese evento.
  public static void registrarEventoServicio(Connection conn, int idServicio, String evento,
                                             long cambioOcupada, long cambioReservada)
    throws SQLException {
    String sql = """
      INSERT INTO historial_segmento
        (id_segmento, evento, referencia, cambio_ocupada, cambio_reservada,
         capacidad_total, capacidad_ocupada, capacidad_reservada)
      SELECT s.id_segmento, ?, ?, ?, ?,
             s.capacidad_total, s.capacidad_ocupada, s.capacidad_reservada
      FROM servicios sv
      JOIN ruta_segmentos rs ON rs.id_ruta = sv.id_ruta
      JOIN segmentos s ON s.id_segmento = rs.id_segmento
      WHERE sv.id_servicio = ?
      """;
    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
      stmt.setString(1, evento);
      stmt.setString(2, "SER-" + idServicio);
      stmt.setLong(3, cambioOcupada);
      stmt.setLong(4, cambioReservada);
      stmt.setInt(5, idServicio);
      stmt.executeUpdate();
    }
  }

  // Mantenimiento: una fila para su segmento. El texto depende del estado nuevo.
  public static void registrarEventoMantenimiento(Connection conn, int idMantenimiento, String estadoNuevo)
    throws SQLException {
    String evento;
    switch (estadoNuevo) {
      case "En ejecucion": evento = "Mantenimiento iniciado";   break;
      case "Finalizado":   evento = "Mantenimiento finalizado"; break;
      case "Cancelado":    evento = "Mantenimiento cancelado";  break;
      default:             evento = "Mantenimiento programado"; break;
    }

    String sql = """
      INSERT INTO historial_segmento
        (id_segmento, evento, referencia,
         capacidad_total, capacidad_ocupada, capacidad_reservada)
      SELECT s.id_segmento, ?, ?,
             s.capacidad_total, s.capacidad_ocupada, s.capacidad_reservada
      FROM mantenimientos m
      JOIN segmentos s ON s.id_segmento = m.id_segmento
      WHERE m.id_mantenimiento = ?
      """;
    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
      stmt.setString(1, evento);
      stmt.setString(2, "MAN-" + idMantenimiento);
      stmt.setInt(3, idMantenimiento);
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
