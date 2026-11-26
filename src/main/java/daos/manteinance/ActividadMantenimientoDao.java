package daos.manteinance;

import beans.maintenance.ActividadMantenimiento;
import daos.BaseDao;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ActividadMantenimientoDao extends BaseDao {

  // Tipo de actividad con el que se guarda el resultado final de un mantenimiento
  // (regla de negocio 5: un mantenimiento finalizado debe tener su resultado registrado).
  public static final String TIPO_RESULTADO = "Resultado";
  // Listamos las actividades de un mantenimiento (bitacora)

  public List<ActividadMantenimiento> listaPorMantenimiento(int idMantenimiento) {

    List<ActividadMantenimiento> actividades = new ArrayList<>();

    String sql = """
      SELECT
      a.id_actividad,
      a.id_mantenimiento,
      a.id_usuario,
      a.fecha_hora,
      a.descripcion_bitacora,
      a.tipo_actividad,
      COALESCE (u.nombre, 'Sistema') AS nombre_usuario
      FROM actividades_mantenimiento a
      LEFT JOIN usuarios u ON a.id_usuario = u.id_usuario
      WHERE a.id_mantenimiento = ?
      ORDER BY a.fecha_hora DESC, a.id_actividad DESC
      """;

    // Observación: COALESCE devuelve sistema en caso el usuario sea null

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setInt(1, idMantenimiento);

      try (ResultSet rs = pstmt.executeQuery()) {
        while (rs.next()) {
          ActividadMantenimiento actividad = new ActividadMantenimiento();
          actividad.setIdActividad(rs.getInt("id_actividad"));
          actividad.setIdMantenimiento(rs.getInt("id_mantenimiento"));

          int idUsuario = rs.getInt("id_usuario");
          // Verificamos si id_usuario no es nulo antes de asignarlo
          actividad.setIdUsuario(rs.wasNull() ? null : idUsuario); // Si era nulo devolvemos null, si no, devolvemos el usuario
          // idUsuario es integer, por lo que puede almacenar valores null

          Timestamp fechaHora = rs.getTimestamp("fecha_hora");

          // validamos que la fecha no sea nula
          if (fechaHora != null ) {
            actividad.setFechaHora(fechaHora.toLocalDateTime()); // lo cambiamos a formato de hora local
          }

          actividad.setDescripcionBitacora(rs.getString("descripcion_bitacora"));
          actividad.setTipoActividad(rs.getString("tipo_actividad"));

          actividad.setNombreUsuario(rs.getString("nombre_usuario"));

          actividades.add(actividad);

        }
      } catch (SQLException e) {
        e.printStackTrace();
      }

    } catch (SQLException e) {
      e.printStackTrace();
    }
    return actividades;
  }

  // REGISTRAR UNA NUEVA ACTIVIDAD

  public boolean crearActividad(ActividadMantenimiento actividad) {

    if (actividad == null) {
      throw new IllegalArgumentException("La actividad no puede ser nula");
    }

    if (actividad.getIdMantenimiento() <= 0) {
      throw new IllegalArgumentException("El mantenimiento indicado no es valido");

    }

    if (actividad.getDescripcionBitacora() == null || actividad.getDescripcionBitacora().isBlank()) {
      throw new IllegalArgumentException("La descripción de la actividad no puede estar vacia");
    }

    String sql = """
      INSERT INTO actividades_mantenimiento
      (id_mantenimiento, id_usuario, descripcion_bitacora, tipo_actividad)
      VALUES (?, ?, ?, ?)
      """;

    try (Connection conn = getConnection();
        PreparedStatement pstmt = conn.prepareStatement(sql)) {

          pstmt.setInt(1, actividad.getIdMantenimiento());

          if (actividad.getIdUsuario() != null) {
            pstmt.setInt(2, actividad.getIdUsuario());
          } else {
            pstmt.setNull(2, Types.INTEGER);
          }

          pstmt.setString(3, actividad.getDescripcionBitacora());
          pstmt.setString(4, actividad.getTipoActividad());

          return pstmt.executeUpdate() == 1; //Devuelve 1 si la actualización fue exitosa

    } catch (SQLException e) {
      throw new IllegalArgumentException("Error al registrar la nueva actividad del mantenimiento");
    }

  }

  // RESULTADO DE UN MANTENIMIENTO
  // Devuelve el texto del resultado, o null si todavía no se registró.

  public String obtenerResultado(int idMantenimiento) {

    String sql = """
      SELECT descripcion_bitacora
      FROM actividades_mantenimiento
      WHERE id_mantenimiento = ? AND tipo_actividad = ?
      LIMIT 1
      """;

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setInt(1, idMantenimiento);
      pstmt.setString(2, TIPO_RESULTADO);

      try (ResultSet rs = pstmt.executeQuery()) {
        return rs.next() ? rs.getString("descripcion_bitacora") : null;
      }

    } catch (SQLException e) {
      throw new IllegalStateException("Error al obtener el resultado del mantenimiento", e);
    }
  }

  // Resultados de todos los mantenimientos (para el historial): id_mantenimiento -> resultado

  public Map<Integer, String> listarResultados() {

    Map<Integer, String> resultados = new HashMap<>();

    String sql = """
      SELECT id_mantenimiento, descripcion_bitacora
      FROM actividades_mantenimiento
      WHERE tipo_actividad = ?
      """;

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setString(1, TIPO_RESULTADO);

      try (ResultSet rs = pstmt.executeQuery()) {
        while (rs.next()) {
          resultados.put(rs.getInt("id_mantenimiento"), rs.getString("descripcion_bitacora"));
        }
      }

    } catch (SQLException e) {
      throw new IllegalStateException("Error al listar los resultados de los mantenimientos", e);
    }

    return resultados;
  }

}
