package daos.manteinance;

import beans.maintenance.ActividadMantenimiento;
import daos.BaseDao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ActividadMantenimientoDao extends BaseDao {
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

}
