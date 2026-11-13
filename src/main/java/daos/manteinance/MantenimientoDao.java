
package daos.manteinance;

import beans.maintenance.Mantenimiento;
import utils.EstadoMantenimientoUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;

public class MantenimientoDao extends daos.BaseDao {

  // ===== READ: LISTAR MANTENIMIENTOS NO CANCELADOS =====

  public ArrayList<Mantenimiento> listarMantenimientos() {

    ArrayList<Mantenimiento> lista = new ArrayList<>();

    String sql = """
                SELECT *
                FROM mantenimientos
                WHERE estado NOT IN ('Cancelado', 'Finalizado')
                ORDER BY fecha_inicio DESC
                """;

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql);
         ResultSet rs = pstmt.executeQuery()) {

      while (rs.next()) {
        lista.add(mapearMantenimiento(rs));
      }

    } catch (SQLException e) {
      throw new IllegalStateException(
        "Error al listar mantenimientos", e);
    }

    return lista;
  }

  // ===== READ: LISTAR HISTORIAL COMPLETO =====


  public ArrayList<Mantenimiento> listarHistorial() {

    ArrayList<Mantenimiento> lista = new ArrayList<>();

    String sql = """
        SELECT *
        FROM mantenimientos
        ORDER BY fecha_inicio DESC
        """;

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql);
         ResultSet rs = pstmt.executeQuery()) {

      while (rs.next()) {

        Mantenimiento m = mapearMantenimiento(rs);

        String estadoReal =
          EstadoMantenimientoUtil.calcularEstado(m);

        if ("Finalizado".equals(estadoReal) ||
          "Cancelado".equals(estadoReal)) {

          m.setEstado(estadoReal);
          lista.add(m);
        }
      }

    } catch (SQLException e) {
      throw new IllegalStateException(
        "Error al listar historial", e);
    }

    return lista;
  }


  // ===== READ: OBTENER POR ID =====

  public Mantenimiento obtenerMantenimiento(int idMantenimiento) {

    String sql = """
                SELECT *
                FROM mantenimientos
                WHERE id_mantenimiento = ?
                """;

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setInt(1, idMantenimiento);

      try (ResultSet rs = pstmt.executeQuery()) {

        if (rs.next()) {

          Mantenimiento m = mapearMantenimiento(rs);

          m.setEstado(
            EstadoMantenimientoUtil.calcularEstado(m)
          );

          return m;
        }
      }

    } catch (SQLException e) {
      throw new IllegalStateException(
        "Error al obtener mantenimiento", e);
    }

    return null;
  }

  // ACTUALIZAR ESTADOS DE MANERA AUTOMÁTICA SEGÚN LA FECHA

  public void actualizarEstadosAutomaticamente() {

    String sql = """
            UPDATE mantenimientos
            SET estado = CASE
            WHEN fecha_fin IS NOT NULL
                 AND fecha_fin < NOW()
                THEN 'Finalizado'

            WHEN fecha_inicio IS NOT NULL
                 AND fecha_inicio <= NOW()
                 AND (fecha_fin IS NULL OR fecha_fin >= NOW())
                THEN 'En ejecucion'

            ELSE 'Programado'
            END
            WHERE estado IN ('Programado', 'En ejecucion')
            """;

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.executeUpdate();

    } catch (SQLException e) {
      throw new IllegalStateException(
        "Error al actualizar los estados automáticamente", e
      );
    }
  }

  // CREACIÓN DE NUEVOS MANTENIMIENTOS


  public int crearMantenimiento(Mantenimiento m) {

    String sql = """
        INSERT INTO mantenimientos
        (id_usuario, id_segmento, tipo, prioridad,
         fecha_inicio, fecha_fin, descripcion_general)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """;

    // Ahora usamos RETURN_GENERATED_KEYS para recuperar las claves generadas por MySQL
    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(
           sql,
           java.sql.Statement.RETURN_GENERATED_KEYS
         )) {

      pstmt.setInt(1, m.getIdUsuario());
      pstmt.setInt(2, m.getIdSegmento());
      pstmt.setString(3, m.getTipo());
      pstmt.setString(4, m.getPrioridad());

      pstmt.setTimestamp(5,
        Timestamp.valueOf(m.getFechaInicio()));

      pstmt.setTimestamp(6,
        Timestamp.valueOf(m.getFechaFin()));

      pstmt.setString(7, m.getDescripcionGeneral());

      int filasAfectadas = pstmt.executeUpdate();

      if (filasAfectadas != 1) {
        throw new IllegalStateException(
          "No se pudo registrar el mantenimiento."
        );
      }

      try (ResultSet rs = pstmt.getGeneratedKeys()) {

        if (rs.next()) {
          return rs.getInt(1); // devolvemos el ID del mantenimiento recien insertado
        }

        throw new IllegalStateException(
          "Se creó el mantenimiento, pero no se pudo recuperar su ID."
        );
      }

    } catch (SQLException e) {
      throw new IllegalStateException(
        "Error al crear mantenimiento", e
      );
    }
  }


  // ACTUALIZACIÓN DE LOS MANTENIMIENTOS

  public boolean actualizarMantenimiento(Mantenimiento m) {

        String sql = """
                    UPDATE mantenimientos
                    SET id_segmento = ?,
                        tipo = ?,
                        prioridad = ?,
                        fecha_inicio = ?,
                        fecha_fin = ?,
                        descripcion_general = ?
                    WHERE id_mantenimiento = ?
                      AND estado <> 'Cancelado'
                      AND fecha_inicio > NOW()
                    """;

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setInt(1, m.getIdSegmento());
      pstmt.setString(2, m.getTipo());
      pstmt.setString(3, m.getPrioridad());

      pstmt.setTimestamp(4,
        Timestamp.valueOf(m.getFechaInicio()));

      pstmt.setTimestamp(5,
        Timestamp.valueOf(m.getFechaFin()));

      pstmt.setString(6, m.getDescripcionGeneral());
      pstmt.setInt(7, m.getIdMantenimiento());

      return pstmt.executeUpdate() == 1;

    } catch (SQLException e) {
      throw new IllegalStateException(
        "Error al actualizar mantenimiento", e);
    }
  }

  // CANCELACIÓN DE MANTENIMIENTOS (BORRADO LÓGICO)


  public boolean cancelarMantenimiento(int idMantenimiento) {

    String sql = """
        UPDATE mantenimientos
        SET estado = 'Cancelado'
        WHERE id_mantenimiento = ?
          AND estado <> 'Cancelado'
          AND fecha_fin > NOW()
        """;

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setInt(1, idMantenimiento);

      return pstmt.executeUpdate() == 1;

    } catch (SQLException e) {
      throw new IllegalStateException(
        "Error al cancelar mantenimiento", e);
    }
  }


  // MAPEO DE UN SQL A UN BEAN DE MANTENIMIENTO

  private Mantenimiento mapearMantenimiento(ResultSet rs)
    throws SQLException {

    Mantenimiento m = new Mantenimiento();

    m.setIdMantenimiento(rs.getInt("id_mantenimiento"));
    m.setIdUsuario(rs.getInt("id_usuario"));
    m.setIdSegmento(rs.getInt("id_segmento"));

    m.setTipo(rs.getString("tipo"));
    m.setPrioridad(rs.getString("prioridad"));
    m.setEstado(rs.getString("estado"));

    Timestamp inicio = rs.getTimestamp("fecha_inicio");
    if (inicio != null) {
      m.setFechaInicio(inicio.toLocalDateTime());
    }

    Timestamp fin = rs.getTimestamp("fecha_fin");
    if (fin != null) {
      m.setFechaFin(fin.toLocalDateTime());
    }

    m.setDescripcionGeneral(
      rs.getString("descripcion_general"));

    return m;
  }
}
