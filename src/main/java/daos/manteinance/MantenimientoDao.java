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
    return listarMantenimientosFiltrados(null, null);
  }

  public ArrayList<Mantenimiento> listarMantenimientosFiltrados(Integer idSegmento, String prioridad) {

    ArrayList<Mantenimiento> lista = new ArrayList<>();

    boolean filtrarSegmento = idSegmento != null && idSegmento > 0;
    boolean filtrarPrioridad = prioridad != null && !prioridad.isBlank();

    StringBuilder sql = new StringBuilder("""
                SELECT *
                FROM mantenimientos
                WHERE estado NOT IN ('Cancelado', 'Finalizado')
                """);

    if (filtrarSegmento) {
      sql.append(" AND id_segmento = ? ");
    }
    if (filtrarPrioridad) {
      sql.append(" AND prioridad = ? ");
    }

    sql.append(" ORDER BY fecha_inicio DESC ");

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {

      int idx = 1;
      if (filtrarSegmento) {
        pstmt.setInt(idx++, idSegmento);
      }
      if (filtrarPrioridad) {
        pstmt.setString(idx++, prioridad);
      }

      try (ResultSet rs = pstmt.executeQuery()) {
        while (rs.next()) {
          lista.add(mapearMantenimiento(rs));
        }
      }

    } catch (SQLException e) {
      throw new IllegalStateException(
        "Error al listar mantenimientos", e);
    }

    return lista;
  }

  // ===== READ: LISTAR HISTORIAL COMPLETO =====

  public ArrayList<Mantenimiento> listarHistorial() {
    return listarHistorialFiltrado(null, null);
  }

  public ArrayList<Mantenimiento> listarHistorialFiltrado(Integer idSegmento, String estadoFiltro) {

    ArrayList<Mantenimiento> lista = new ArrayList<>();

    boolean filtrarSegmento = idSegmento != null && idSegmento > 0;
    boolean filtrarEstado = estadoFiltro != null && !estadoFiltro.isBlank();

    StringBuilder sql = new StringBuilder("""
        SELECT *
        FROM mantenimientos
        WHERE 1 = 1
        """);

    if (filtrarSegmento) {
      sql.append(" AND id_segmento = ? ");
    }

    sql.append(" ORDER BY fecha_inicio DESC ");

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {

      if (filtrarSegmento) {
        pstmt.setInt(1, idSegmento);
      }

      try (ResultSet rs = pstmt.executeQuery()) {
        while (rs.next()) {

          Mantenimiento m = mapearMantenimiento(rs);

          String estadoReal =
            EstadoMantenimientoUtil.calcularEstado(m);

          if ("Finalizado".equals(estadoReal) ||
            "Cancelado".equals(estadoReal)) {

            if (!filtrarEstado || estadoFiltro.equals(estadoReal)) {
              m.setEstado(estadoReal);
              lista.add(m);
            }
          }
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

    // Los segmentos con un mantenimiento en ejecución pasan a "En mantenimiento"
    String sqlSegmentosEnMantenimiento = """
            UPDATE segmentos s
            SET s.estado = 'En mantenimiento'
            WHERE s.estado <> 'En mantenimiento'
              AND EXISTS (
                  SELECT 1 FROM mantenimientos m
                  WHERE m.id_segmento = s.id_segmento
                    AND m.estado = 'En ejecucion')
            """;

    // Cuando ya no tienen mantenimiento en ejecución, vuelven a su estado según sus incidencias abiertas:
    // incidencia Crítica -> Fuera de servicio, otra incidencia -> Degradado, ninguna -> Operativo
    String sqlSegmentosLiberados = """
            UPDATE segmentos s
            SET s.estado = CASE
                WHEN EXISTS (
                    SELECT 1 FROM segmentos_has_incidencias si
                    JOIN incidencias i ON i.id_incidencia = si.id_incidencia
                    WHERE si.id_segmento = s.id_segmento
                      AND i.estado NOT IN ('Servicio restaurado', 'Cerrada')
                      AND i.severidad = 'Critica')
                    THEN 'Fuera de servicio'
                WHEN EXISTS (
                    SELECT 1 FROM segmentos_has_incidencias si
                    JOIN incidencias i ON i.id_incidencia = si.id_incidencia
                    WHERE si.id_segmento = s.id_segmento
                      AND i.estado NOT IN ('Servicio restaurado', 'Cerrada'))
                    THEN 'Degradado'
                ELSE 'Operativo'
            END
            WHERE s.estado = 'En mantenimiento'
              AND NOT EXISTS (
                  SELECT 1 FROM mantenimientos m
                  WHERE m.id_segmento = s.id_segmento
                    AND m.estado = 'En ejecucion')
            """;

    try (Connection conn = getConnection()) {
      conn.setAutoCommit(false);
      try {
        // 1. Estado de los mantenimientos según la fecha
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
          pstmt.executeUpdate();
        }

        // 2. Estado de los segmentos según sus mantenimientos
        try (PreparedStatement pstmt = conn.prepareStatement(sqlSegmentosEnMantenimiento)) {
          pstmt.executeUpdate();
        }
        try (PreparedStatement pstmt = conn.prepareStatement(sqlSegmentosLiberados)) {
          pstmt.executeUpdate();
        }

        conn.commit();

      } catch (SQLException e) {
        conn.rollback();
        throw e;
      }

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
          return rs.getInt(1);
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
