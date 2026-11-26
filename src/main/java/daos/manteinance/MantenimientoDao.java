package daos.manteinance;

import beans.maintenance.Mantenimiento;
import daos.capacityplanner.HistorialSegmentoDao;
import utils.EstadoMantenimientoUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;

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

    // Mantenimientos activos con el estado que les corresponde según la fecha
    String sql = """
            SELECT id_mantenimiento, estado,
                   CASE
                   WHEN fecha_fin IS NOT NULL
                        AND fecha_fin < NOW()
                       THEN 'Finalizado'

                   WHEN fecha_inicio IS NOT NULL
                        AND fecha_inicio <= NOW()
                        AND (fecha_fin IS NULL OR fecha_fin >= NOW())
                       THEN 'En ejecucion'

                   ELSE 'Programado'
                   END AS estado_nuevo
            FROM mantenimientos
            WHERE estado IN ('Programado', 'En ejecucion')
            """;

    String sqlCambiarEstado = """
            UPDATE mantenimientos
            SET estado = ?
            WHERE id_mantenimiento = ? AND estado = ?
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
        // 1. Estado de los mantenimientos según la fecha.
        //    Se revisa cada mantenimiento: si su estado debe cambiar, se cambia
        //    y se anota en el historial del segmento.
        ArrayList<Integer> ids = new ArrayList<>();
        ArrayList<String> estadosActuales = new ArrayList<>();
        ArrayList<String> estadosNuevos = new ArrayList<>();

        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
          while (rs.next()) {
            if (!rs.getString("estado").equals(rs.getString("estado_nuevo"))) {
              ids.add(rs.getInt("id_mantenimiento"));
              estadosActuales.add(rs.getString("estado"));
              estadosNuevos.add(rs.getString("estado_nuevo"));
            }
          }
        }

        for (int i = 0; i < ids.size(); i++) {
          try (PreparedStatement pstmt = conn.prepareStatement(sqlCambiarEstado)) {
            pstmt.setString(1, estadosNuevos.get(i));
            pstmt.setInt(2, ids.get(i));
            pstmt.setString(3, estadosActuales.get(i));

            if (pstmt.executeUpdate() == 1) {
              HistorialSegmentoDao.registrarEventoMantenimiento(conn, ids.get(i), estadosNuevos.get(i));
            }
          }
        }

        // 2. Estado de las incidencias según los mantenimientos correctivos de sus segmentos
        recalcularIncidencias(conn);

        // 3. Estado de los segmentos según sus mantenimientos
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

  // SINCRONIZACIÓN DE INCIDENCIAS CON LOS MANTENIMIENTOS
  //
  // Una incidencia que está "En analisis", "Reparacion programada" o "En reparacion"
  // toma su estado según los mantenimientos CORRECTIVOS de sus segmentos:
  //   - Todos sus segmentos tienen un correctivo Finalizado -> Servicio restaurado
  //   - Alguno En ejecucion (o alguno ya Finalizado)         -> En reparacion
  //   - Alguno tiene un correctivo Programado                -> Reparacion programada
  //   - Sus correctivos se cancelaron                        -> En analisis
  // Solo cuentan los correctivos que empiezan desde el minuto en que se registró la incidencia
  // (así un mantenimiento anterior, aunque sea del mismo día, no la marca como restaurada).
  // Las incidencias sin ningún correctivo no se tocan.

  private static final String[] ESTADOS_SINCRONIZADOS =
    {"En analisis", "Reparacion programada", "En reparacion"};

  private void recalcularIncidencias(Connection conn) throws SQLException {

    // 1. Incidencias que están en la parte del flujo que maneja el mantenimiento
    String sqlIncidencias = """
            SELECT id_incidencia, estado
            FROM incidencias
            WHERE estado IN (?, ?, ?)
            """;

    ArrayList<Integer> ids = new ArrayList<>();
    ArrayList<String> estadosActuales = new ArrayList<>();

    try (PreparedStatement pstmt = conn.prepareStatement(sqlIncidencias)) {
      pstmt.setString(1, ESTADOS_SINCRONIZADOS[0]);
      pstmt.setString(2, ESTADOS_SINCRONIZADOS[1]);
      pstmt.setString(3, ESTADOS_SINCRONIZADOS[2]);
      try (ResultSet rs = pstmt.executeQuery()) {
        while (rs.next()) {
          ids.add(rs.getInt("id_incidencia"));
          estadosActuales.add(rs.getString("estado"));
        }
      }
    }

    // 2. Para cada incidencia revisamos los correctivos de sus segmentos
    for (int i = 0; i < ids.size(); i++) {
      int idIncidencia = ids.get(i);
      String estadoActual = estadosActuales.get(i);

      String[] resultado = calcularEstadoIncidencia(conn, idIncidencia);
      if (resultado == null) {
        continue; // no tiene correctivos: no se toca
      }

      String estadoNuevo = resultado[0];
      int idUsuarioMantenimiento = Integer.parseInt(resultado[1]);

      if (!estadoNuevo.equals(estadoActual)) {
        cambiarEstadoIncidencia(conn, idIncidencia, estadoActual, estadoNuevo, idUsuarioMantenimiento);
      }
    }
  }

  // Devuelve {estadoNuevo, idUsuarioDelMantenimiento}, o null si la incidencia no tiene correctivos.
  private String[] calcularEstadoIncidencia(Connection conn, int idIncidencia) throws SQLException {

    // Una fila por cada segmento de la incidencia, con sus correctivos (si tiene)
    String sql = """
            SELECT si.id_segmento, m.estado AS estado_mantenimiento, m.id_usuario
            FROM segmentos_has_incidencias si
            JOIN incidencias i ON i.id_incidencia = si.id_incidencia
            LEFT JOIN mantenimientos m
                   ON m.id_segmento = si.id_segmento
                  AND m.tipo = 'Correctivo'
                  AND m.fecha_inicio >= DATE_FORMAT(i.fecha_registro, '%Y-%m-%d %H:%i:00')
            WHERE si.id_incidencia = ?
            """;

    Set<Integer> segmentos = new HashSet<>();
    Set<Integer> segmentosFinalizados = new HashSet<>();
    boolean hayEnEjecucion = false;
    boolean hayProgramado = false;
    int idUsuarioMantenimiento = 0;

    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
      pstmt.setInt(1, idIncidencia);
      try (ResultSet rs = pstmt.executeQuery()) {
        while (rs.next()) {
          int idSegmento = rs.getInt("id_segmento");
          String estadoMantenimiento = rs.getString("estado_mantenimiento"); // null si no tiene correctivo
          segmentos.add(idSegmento);

          if (estadoMantenimiento == null) {
            continue;
          }
          idUsuarioMantenimiento = rs.getInt("id_usuario");

          switch (estadoMantenimiento) {
            case "Finalizado"   -> segmentosFinalizados.add(idSegmento);
            case "En ejecucion" -> hayEnEjecucion = true;
            case "Programado"   -> hayProgramado = true;
            default             -> { } // Cancelado: no cuenta
          }
        }
      }
    }

    if (idUsuarioMantenimiento == 0) {
      return null; // ningún correctivo en sus segmentos
    }

    String estadoNuevo;
    if (!segmentos.isEmpty() && segmentosFinalizados.size() == segmentos.size()
        && !hayEnEjecucion && !hayProgramado) {
      // Todos sus segmentos terminaron y no queda ningún otro correctivo pendiente
      estadoNuevo = "Servicio restaurado";
    } else if (hayEnEjecucion || !segmentosFinalizados.isEmpty()) {
      // Ya se está reparando, o ya terminó un segmento y falta otro: nunca retrocede a "programada"
      estadoNuevo = "En reparacion";
    } else if (hayProgramado) {
      estadoNuevo = "Reparacion programada";
    } else {
      estadoNuevo = "En analisis";   // todos sus correctivos se cancelaron
    }

    return new String[]{estadoNuevo, String.valueOf(idUsuarioMantenimiento)};
  }

  private void cambiarEstadoIncidencia(Connection conn, int idIncidencia, String estadoActual,
                                       String estadoNuevo, int idUsuario) throws SQLException {

    String sql = "UPDATE incidencias SET estado = ?";
    if ("Servicio restaurado".equals(estadoNuevo)) {
      sql += ", fecha_restauracion = NOW()";
    }
    sql += " WHERE id_incidencia = ? AND estado = ?";

    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
      pstmt.setString(1, estadoNuevo);
      pstmt.setInt(2, idIncidencia);
      pstmt.setString(3, estadoActual);
      if (pstmt.executeUpdate() == 0) {
        return; // otra petición ya hizo este cambio: no se repite en la bitácora
      }
    }

    // Queda en la bitácora de la incidencia, a nombre de quien programó el mantenimiento
    String sqlBitacora = """
            INSERT INTO observaciones_incidencias (id_incidencia, id_usuario, mensaje)
            VALUES (?, ?, ?)
            """;

    try (PreparedStatement pstmt = conn.prepareStatement(sqlBitacora)) {
      pstmt.setInt(1, idIncidencia);
      pstmt.setInt(2, idUsuario);
      pstmt.setString(3, "Estado actualizado por mantenimiento: "
        + textoEstado(estadoActual) + " → " + textoEstado(estadoNuevo));
      pstmt.executeUpdate();
    }

    // Si quedó restaurada, sus segmentos Degradado / Fuera de servicio vuelven a Operativo
    // (si no tienen otra incidencia abierta). Los que están En mantenimiento se liberan en el paso 3.
    if ("Servicio restaurado".equals(estadoNuevo)) {
      String sqlSegmentos = """
              UPDATE segmentos s
              JOIN segmentos_has_incidencias si ON si.id_segmento = s.id_segmento
              SET s.estado = 'Operativo'
              WHERE si.id_incidencia = ?
                AND s.estado IN ('Degradado', 'Fuera de servicio')
                AND NOT EXISTS (
                    SELECT 1 FROM segmentos_has_incidencias si2
                    JOIN incidencias i2 ON i2.id_incidencia = si2.id_incidencia
                    WHERE si2.id_segmento = s.id_segmento
                      AND i2.estado NOT IN ('Servicio restaurado', 'Cerrada'))
              """;

      try (PreparedStatement pstmt = conn.prepareStatement(sqlSegmentos)) {
        pstmt.setInt(1, idIncidencia);
        pstmt.executeUpdate();
      }
    }
  }

  private String textoEstado(String estado) {
    switch (estado) {
      case "En analisis":           return "En análisis";
      case "Reparacion programada": return "Reparación programada";
      case "En reparacion":         return "En reparación";
      default:                      return estado;
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

    try (Connection conn = getConnection()) {
      conn.setAutoCommit(false);

      try (PreparedStatement pstmt = conn.prepareStatement(sql)) {

        pstmt.setInt(1, idMantenimiento);

        if (pstmt.executeUpdate() != 1) {
          conn.rollback();
          return false;
        }

        // Se anota en el historial del segmento
        HistorialSegmentoDao.registrarEventoMantenimiento(conn, idMantenimiento, "Cancelado");

        conn.commit();
        return true;

      } catch (SQLException e) {
        conn.rollback();
        throw e;
      }

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
