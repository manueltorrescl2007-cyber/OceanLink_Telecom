package daos;

import beans.Servicio;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

public class ServicioDao extends BaseDao {

  private static final String SELECT_SERVICIO =
    "SELECT sv.*, c.nombre AS nombre_cliente, "
      + "r.nombre AS nombre_ruta, "
      + "so.estado AS estado_solicitud "
      + "FROM servicios sv "
      + "INNER JOIN solicitudes so "
      + "ON sv.id_solicitud = so.id_solicitud "
      + "INNER JOIN clientes c "
      + "ON so.id_cliente = c.id_cliente "
      + "INNER JOIN rutas r ON sv.id_ruta = r.id_ruta ";

  // Listar todos los servicios
  public ArrayList<Servicio> listarServicios() throws SQLException {
    return listarServicios(null);
  }

  // Listar servicios con filtro opcional por estado
  public ArrayList<Servicio> listarServicios(String estado)
    throws SQLException {

    ArrayList<Servicio> lista = new ArrayList<>();
    boolean filtrarEstado = estado != null && !estado.isEmpty();

    String sql = SELECT_SERVICIO;

    if (filtrarEstado) {
      sql += "WHERE sv.estado = ? ";
    }

    sql += "ORDER BY sv.id_servicio DESC";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      if (filtrarEstado) {
        pstmt.setString(1, estado);
      }

      try (ResultSet rs = pstmt.executeQuery()) {
        while (rs.next()) {
          lista.add(fetchServicio(rs));
        }
      }
    }

    return lista;
  }

  // Obtener un servicio por su ID
  public Servicio obtenerServicio(int idServicio) throws SQLException {

    String sql = SELECT_SERVICIO + "WHERE sv.id_servicio = ?";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setInt(1, idServicio);

      try (ResultSet rs = pstmt.executeQuery()) {
        if (rs.next()) {
          return fetchServicio(rs);
        }
      }
    }

    return null;
  }

  // Listar los servicios de un cliente
  public ArrayList<Servicio> listarServiciosPorCliente(int idCliente)
    throws SQLException {

    ArrayList<Servicio> lista = new ArrayList<>();

    String sql = SELECT_SERVICIO
      + "WHERE so.id_cliente = ? "
      + "ORDER BY sv.id_servicio DESC";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setInt(1, idCliente);

      try (ResultSet rs = pstmt.executeQuery()) {
        while (rs.next()) {
          lista.add(fetchServicio(rs));
        }
      }
    }

    return lista;
  }

  // Crear un servicio pendiente y reservar capacidad
  public boolean crearServicio(Servicio servicio) throws SQLException {

    try (Connection conn = getConnection()) {
      conn.setAutoCommit(false);

      try {
        long capacidad;
        int origen;
        int destino;

        // Consultar y bloquear la solicitud
        String sqlSolicitud =
          "SELECT capacidad_solicitada, id_landing_origen, "
            + "id_landing_destino, estado FROM solicitudes "
            + "WHERE id_solicitud = ? FOR UPDATE";

        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlSolicitud)) {

          pstmt.setInt(1, servicio.getIdSolicitud());

          try (ResultSet rs = pstmt.executeQuery()) {
            if (!rs.next()
              || !"Aprobada".equals(rs.getString("estado"))) {
              conn.rollback();
              return false;
            }

            capacidad = rs.getLong("capacidad_solicitada");
            origen = rs.getInt("id_landing_origen");
            destino = rs.getInt("id_landing_destino");
          }
        }

        if (capacidad <= 0) {
          conn.rollback();
          return false;
        }

        // La ruta debe estar activa y coincidir con la solicitud
        String sqlRuta =
          "SELECT estado, id_landing_origen, id_landing_destino "
            + "FROM rutas WHERE id_ruta = ? FOR UPDATE";

        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlRuta)) {

          pstmt.setInt(1, servicio.getIdRuta());

          try (ResultSet rs = pstmt.executeQuery()) {
            if (!rs.next()
              || !"activa".equals(rs.getString("estado"))
              || rs.getInt("id_landing_origen") != origen
              || rs.getInt("id_landing_destino") != destino) {

              conn.rollback();
              return false;
            }
          }
        }

        // Evitar otro servicio vigente para la misma solicitud
        String sqlExistente =
          "SELECT id_servicio FROM servicios "
            + "WHERE id_solicitud = ? "
            + "AND estado <> 'Cancelado' FOR UPDATE";

        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlExistente)) {

          pstmt.setInt(1, servicio.getIdSolicitud());

          try (ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
              conn.rollback();
              return false;
            }
          }
        }

        // Revisar el recorrido y la capacidad de los segmentos
        ArrayList<Integer> idsSegmentos = new ArrayList<>();

        String sqlSegmentos =
          "SELECT s.* FROM ruta_segmentos rs "
            + "INNER JOIN segmentos s "
            + "ON rs.id_segmento = s.id_segmento "
            + "WHERE rs.id_ruta = ? "
            + "ORDER BY rs.orden FOR UPDATE";

        int estacionActual = origen;

        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlSegmentos)) {

          pstmt.setInt(1, servicio.getIdRuta());

          try (ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
              long disponible = rs.getLong("capacidad_total")
                - rs.getLong("capacidad_ocupada")
                - rs.getLong("capacidad_reservada");

              if (disponible < capacidad
                || "Fuera de servicio".equals(
                rs.getString("estado"))
                || rs.getInt("id_landing_inicial")
                != estacionActual) {

                conn.rollback();
                return false;
              }

              idsSegmentos.add(rs.getInt("id_segmento"));
              estacionActual = rs.getInt("id_landing_final");
            }
          }
        }

        if (idsSegmentos.isEmpty() || estacionActual != destino) {
          conn.rollback();
          return false;
        }

        // Registrar el servicio
        String sqlCrear =
          "INSERT INTO servicios "
            + "(id_solicitud, id_ruta, capacidad_asignada, estado) "
            + "VALUES (?, ?, ?, 'Pendiente')";

        int idServicio;

        try (PreparedStatement pstmt = conn.prepareStatement(
          sqlCrear, Statement.RETURN_GENERATED_KEYS)) {

          pstmt.setInt(1, servicio.getIdSolicitud());
          pstmt.setInt(2, servicio.getIdRuta());
          pstmt.setLong(3, capacidad);

          if (pstmt.executeUpdate() != 1) {
            throw new SQLException(
              "No se pudo crear el servicio.");
          }

          try (ResultSet rs = pstmt.getGeneratedKeys()) {
            if (!rs.next()) {
              throw new SQLException(
                "No se pudo obtener el ID del servicio.");
            }

            idServicio = rs.getInt(1);
          }
        }

        // Reservar capacidad en cada segmento
        String sqlReservar =
          "UPDATE segmentos "
            + "SET capacidad_reservada = capacidad_reservada + ? "
            + "WHERE id_segmento = ?";

        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlReservar)) {

          for (int idSegmento : idsSegmentos) {
            pstmt.setLong(1, capacidad);
            pstmt.setInt(2, idSegmento);

            if (pstmt.executeUpdate() != 1) {
              throw new SQLException(
                "No se pudo reservar capacidad.");
            }
          }
        }

        // La solicitud ya tiene ruta y capacidad reservada
        String sqlProvisionar =
          "UPDATE solicitudes SET estado = 'Provisionada' "
            + "WHERE id_solicitud = ? AND estado = 'Aprobada'";

        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlProvisionar)) {

          pstmt.setInt(1, servicio.getIdSolicitud());

          if (pstmt.executeUpdate() != 1) {
            throw new SQLException(
              "No se pudo actualizar la solicitud.");
          }
        }

        conn.commit();

        servicio.setIdServicio(idServicio);
        servicio.setCapacidadAsignada(capacidad);
        servicio.setEstado("Pendiente");
        servicio.setEstadoSolicitud("Provisionada");

        return true;

      } catch (SQLException e) {
        conn.rollback();
        throw e;
      }
    }
  }

  // Activar y pasar la capacidad reservada a ocupada
  public boolean activarServicio(int idServicio) throws SQLException {

    try (Connection conn = getConnection()) {
      conn.setAutoCommit(false);

      try {
        int idSolicitud;
        int idRuta;
        long capacidad;

        String sqlServicio =
          "SELECT sv.id_solicitud, sv.id_ruta, "
            + "sv.capacidad_asignada, sv.estado, "
            + "so.estado AS estado_solicitud "
            + "FROM servicios sv "
            + "INNER JOIN solicitudes so "
            + "ON sv.id_solicitud = so.id_solicitud "
            + "WHERE sv.id_servicio = ? FOR UPDATE";

        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlServicio)) {

          pstmt.setInt(1, idServicio);

          try (ResultSet rs = pstmt.executeQuery()) {
            if (!rs.next()
              || !"Pendiente".equals(rs.getString("estado"))
              || !"Provisionada".equals(
              rs.getString("estado_solicitud"))) {

              conn.rollback();
              return false;
            }

            idSolicitud = rs.getInt("id_solicitud");
            idRuta = rs.getInt("id_ruta");
            capacidad = rs.getLong("capacidad_asignada");
          }
        }

        if (capacidad <= 0) {
          conn.rollback();
          return false;
        }

        // Verificar que la ruta siga activa
        String sqlRuta =
          "SELECT estado FROM rutas "
            + "WHERE id_ruta = ? FOR UPDATE";

        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlRuta)) {

          pstmt.setInt(1, idRuta);

          try (ResultSet rs = pstmt.executeQuery()) {
            if (!rs.next()
              || !"activa".equals(rs.getString("estado"))) {
              conn.rollback();
              return false;
            }
          }
        }

        // Revisar los segmentos antes de activar
        ArrayList<Integer> idsSegmentos = new ArrayList<>();

        String sqlSegmentos =
          "SELECT s.* FROM ruta_segmentos rs "
            + "INNER JOIN segmentos s "
            + "ON rs.id_segmento = s.id_segmento "
            + "WHERE rs.id_ruta = ? "
            + "ORDER BY rs.orden FOR UPDATE";

        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlSegmentos)) {

          pstmt.setInt(1, idRuta);

          try (ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
              long reservada = rs.getLong("capacidad_reservada");
              long ocupada = rs.getLong("capacidad_ocupada");
              long total = rs.getLong("capacidad_total");

              if ("Fuera de servicio".equals(rs.getString("estado"))
                || reservada < capacidad
                || ocupada + reservada > total) {

                conn.rollback();
                return false;
              }

              idsSegmentos.add(rs.getInt("id_segmento"));
            }
          }
        }

        if (idsSegmentos.isEmpty()) {
          conn.rollback();
          return false;
        }

        // Mover capacidad de reservada a ocupada
        String sqlCapacidad =
          "UPDATE segmentos "
            + "SET capacidad_reservada = capacidad_reservada - ?, "
            + "capacidad_ocupada = capacidad_ocupada + ? "
            + "WHERE id_segmento = ?";

        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlCapacidad)) {

          for (int idSegmento : idsSegmentos) {
            pstmt.setLong(1, capacidad);
            pstmt.setLong(2, capacidad);
            pstmt.setInt(3, idSegmento);

            if (pstmt.executeUpdate() != 1) {
              throw new SQLException(
                "No se pudo actualizar la capacidad.");
            }
          }
        }

        // Activar el servicio y registrar la fecha
        String sqlActivar =
          "UPDATE servicios "
            + "SET estado = 'Activo', fecha_activacion = NOW() "
            + "WHERE id_servicio = ? AND estado = 'Pendiente'";

        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlActivar)) {

          pstmt.setInt(1, idServicio);

          if (pstmt.executeUpdate() != 1) {
            throw new SQLException(
              "No se pudo activar el servicio.");
          }
        }

        // Actualizar la solicitud
        String sqlSolicitud =
          "UPDATE solicitudes SET estado = 'Activa' "
            + "WHERE id_solicitud = ? AND estado = 'Provisionada'";

        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlSolicitud)) {

          pstmt.setInt(1, idSolicitud);

          if (pstmt.executeUpdate() != 1) {
            throw new SQLException(
              "No se pudo actualizar la solicitud.");
          }
        }

        conn.commit();
        return true;

      } catch (SQLException e) {
        conn.rollback();
        throw e;
      }
    }
  }

  // Suspender sin liberar la capacidad ocupada
  public boolean suspenderServicio(int idServicio) throws SQLException {

    String sql =
      "UPDATE servicios SET estado = 'Suspendido' "
        + "WHERE id_servicio = ? AND estado = 'Activo'";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setInt(1, idServicio);
      return pstmt.executeUpdate() == 1;
    }
  }

  // Cancelar y liberar la capacidad del servicio
  public boolean cancelarServicio(int idServicio) throws SQLException {

    try (Connection conn = getConnection()) {
      conn.setAutoCommit(false);

      try {
        int idRuta;
        long capacidad;
        String estadoAnterior;

        String sqlServicio =
          "SELECT id_ruta, capacidad_asignada, estado "
            + "FROM servicios WHERE id_servicio = ? FOR UPDATE";

        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlServicio)) {

          pstmt.setInt(1, idServicio);

          try (ResultSet rs = pstmt.executeQuery()) {
            if (!rs.next()) {
              conn.rollback();
              return false;
            }

            idRuta = rs.getInt("id_ruta");
            capacidad = rs.getLong("capacidad_asignada");
            estadoAnterior = rs.getString("estado");
          }
        }

        if (capacidad <= 0
          || (!"Pendiente".equals(estadoAnterior)
          && !"Activo".equals(estadoAnterior)
          && !"Suspendido".equals(estadoAnterior))) {

          conn.rollback();
          return false;
        }

        // Bloquear la ruta durante la operación
        String sqlRuta =
          "SELECT id_ruta FROM rutas "
            + "WHERE id_ruta = ? FOR UPDATE";

        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlRuta)) {

          pstmt.setInt(1, idRuta);

          try (ResultSet rs = pstmt.executeQuery()) {
            if (!rs.next()) {
              conn.rollback();
              return false;
            }
          }
        }

        // Pendiente libera reserva.
        // Activo y Suspendido liberan capacidad ocupada.
        String columna = "Pendiente".equals(estadoAnterior)
          ? "capacidad_reservada" : "capacidad_ocupada";

        ArrayList<Integer> idsSegmentos = new ArrayList<>();

        String sqlSegmentos =
          "SELECT s.id_segmento, s.capacidad_reservada, "
            + "s.capacidad_ocupada "
            + "FROM ruta_segmentos rs "
            + "INNER JOIN segmentos s "
            + "ON rs.id_segmento = s.id_segmento "
            + "WHERE rs.id_ruta = ? "
            + "ORDER BY rs.orden FOR UPDATE";

        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlSegmentos)) {

          pstmt.setInt(1, idRuta);

          try (ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
              if (rs.getLong(columna) < capacidad) {
                conn.rollback();
                return false;
              }

              idsSegmentos.add(rs.getInt("id_segmento"));
            }
          }
        }

        if (idsSegmentos.isEmpty()) {
          conn.rollback();
          return false;
        }

        // Liberar capacidad en cada segmento
        String sqlLiberar =
          "UPDATE segmentos SET " + columna + " = "
            + columna + " - ? WHERE id_segmento = ?";

        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlLiberar)) {

          for (int idSegmento : idsSegmentos) {
            pstmt.setLong(1, capacidad);
            pstmt.setInt(2, idSegmento);

            if (pstmt.executeUpdate() != 1) {
              throw new SQLException(
                "No se pudo liberar la capacidad.");
            }
          }
        }

        // Conservar el servicio como Cancelado
        String sqlCancelar =
          "UPDATE servicios SET estado = 'Cancelado' "
            + "WHERE id_servicio = ? AND estado = ?";

        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlCancelar)) {

          pstmt.setInt(1, idServicio);
          pstmt.setString(2, estadoAnterior);

          if (pstmt.executeUpdate() != 1) {
            throw new SQLException(
              "No se pudo cancelar el servicio.");
          }
        }

        conn.commit();
        return true;

      } catch (SQLException e) {
        conn.rollback();
        throw e;
      }
    }
  }

  // Reactivar sin volver a sumar la capacidad ocupada
  public boolean reactivarServicio(int idServicio) throws SQLException {

    try (Connection conn = getConnection()) {
      conn.setAutoCommit(false);

      try {
        int idRuta;
        long capacidad;

        String sqlServicio =
          "SELECT sv.id_ruta, sv.capacidad_asignada, sv.estado, "
            + "so.estado AS estado_solicitud "
            + "FROM servicios sv "
            + "INNER JOIN solicitudes so "
            + "ON sv.id_solicitud = so.id_solicitud "
            + "WHERE sv.id_servicio = ? FOR UPDATE";

        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlServicio)) {

          pstmt.setInt(1, idServicio);

          try (ResultSet rs = pstmt.executeQuery()) {
            if (!rs.next()
              || !"Suspendido".equals(rs.getString("estado"))
              || !"Activa".equals(
              rs.getString("estado_solicitud"))) {

              conn.rollback();
              return false;
            }

            idRuta = rs.getInt("id_ruta");
            capacidad = rs.getLong("capacidad_asignada");
          }
        }

        if (capacidad <= 0) {
          conn.rollback();
          return false;
        }

        // Verificar que la ruta siga activa
        int origen;
        int destino;

        String sqlRuta =
          "SELECT estado, id_landing_origen, id_landing_destino "
            + "FROM rutas WHERE id_ruta = ? FOR UPDATE";

        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlRuta)) {

          pstmt.setInt(1, idRuta);

          try (ResultSet rs = pstmt.executeQuery()) {
            if (!rs.next()
              || !"activa".equals(rs.getString("estado"))) {

              conn.rollback();
              return false;
            }

            origen = rs.getInt("id_landing_origen");
            destino = rs.getInt("id_landing_destino");
          }
        }

        // Comprobar el recorrido y la capacidad ya asignada
        String sqlSegmentos =
          "SELECT s.* FROM ruta_segmentos rs "
            + "INNER JOIN segmentos s "
            + "ON rs.id_segmento = s.id_segmento "
            + "WHERE rs.id_ruta = ? "
            + "ORDER BY rs.orden FOR UPDATE";

        int cantidadSegmentos = 0;
        int estacionActual = origen;

        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlSegmentos)) {

          pstmt.setInt(1, idRuta);

          try (ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
              long ocupada = rs.getLong("capacidad_ocupada");
              long reservada = rs.getLong("capacidad_reservada");
              long total = rs.getLong("capacidad_total");

              if ("Fuera de servicio".equals(rs.getString("estado"))
                || ocupada < capacidad
                || ocupada + reservada > total
                || rs.getInt("id_landing_inicial")
                != estacionActual) {

                conn.rollback();
                return false;
              }

              estacionActual = rs.getInt("id_landing_final");
              cantidadSegmentos++;
            }
          }
        }

        if (cantidadSegmentos == 0 || estacionActual != destino) {
          conn.rollback();
          return false;
        }

        // Solo cambiar el estado; conservar capacidad y fecha original
        String sqlReactivar =
          "UPDATE servicios SET estado = 'Activo' "
            + "WHERE id_servicio = ? AND estado = 'Suspendido'";

        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlReactivar)) {

          pstmt.setInt(1, idServicio);

          if (pstmt.executeUpdate() != 1) {
            conn.rollback();
            return false;
          }
        }

        conn.commit();
        return true;

      } catch (SQLException e) {
        conn.rollback();
        throw e;
      }
    }
  }

  // Convertir una fila del resultado en un objeto Servicio
  private Servicio fetchServicio(ResultSet rs) throws SQLException {

    Servicio servicio = new Servicio();

    servicio.setIdServicio(rs.getInt("id_servicio"));
    servicio.setIdSolicitud(rs.getInt("id_solicitud"));
    servicio.setIdRuta(rs.getInt("id_ruta"));
    servicio.setCapacidadAsignada(rs.getLong("capacidad_asignada"));
    servicio.setFechaActivacion(rs.getTimestamp("fecha_activacion"));
    servicio.setEstado(rs.getString("estado"));
    servicio.setNombreCliente(rs.getString("nombre_cliente"));
    servicio.setNombreRuta(rs.getString("nombre_ruta"));
    servicio.setEstadoSolicitud(rs.getString("estado_solicitud"));

    return servicio;
  }
}
