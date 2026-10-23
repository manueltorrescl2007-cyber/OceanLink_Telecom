package daos;

import beans.Solicitud;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class SolicitudDao extends BaseDao {

  private static final String SELECT_SOLICITUD =
    "SELECT so.*, c.nombre AS nombre_cliente, "
      + "lo.nombre AS nombre_origen, ld.nombre AS nombre_destino "
      + "FROM solicitudes so "
      + "INNER JOIN clientes c ON so.id_cliente = c.id_cliente "
      + "INNER JOIN landingstation lo "
      + "ON so.id_landing_origen = lo.id_landing "
      + "INNER JOIN landingstation ld "
      + "ON so.id_landing_destino = ld.id_landing ";

  // Listar todas las solicitudes
  public ArrayList<Solicitud> listarSolicitudes() throws SQLException {
    return listarSolicitudes(null);
  }

  // Listar con filtro opcional por estado
  public ArrayList<Solicitud> listarSolicitudes(String estado)
    throws SQLException {

    ArrayList<Solicitud> lista = new ArrayList<>();

    boolean filtrarEstado = estado != null && !estado.isEmpty();

    String sql = SELECT_SOLICITUD;

    if (filtrarEstado) {
      sql += "WHERE so.estado = ? ";
    }

    sql += "ORDER BY so.fecha_registro DESC, so.id_solicitud DESC";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      if (filtrarEstado) {
        pstmt.setString(1, estado);
      }

      try (ResultSet rs = pstmt.executeQuery()) {
        while (rs.next()) {
          lista.add(fetchSolicitud(rs));
        }
      }
    }

    return lista;
  }

  // Obtener una solicitud por su ID
  public Solicitud obtenerSolicitud(int idSolicitud)
    throws SQLException {

    String sql = SELECT_SOLICITUD + "WHERE so.id_solicitud = ?";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setInt(1, idSolicitud);

      try (ResultSet rs = pstmt.executeQuery()) {
        if (rs.next()) {
          return fetchSolicitud(rs);
        }
      }
    }

    return null;
  }

  // Crear una solicitud en estado Registrada
  public boolean crearSolicitud(Solicitud solicitud)
    throws SQLException {

    String sql =
      "INSERT INTO solicitudes "
        + "(id_cliente, id_usuario, id_landing_origen, "
        + "id_landing_destino, capacidad_solicitada, "
        + "estado, justificacion) "
        + "VALUES (?, ?, ?, ?, ?, 'Registrada', ?)";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setInt(1, solicitud.getIdCliente());
      pstmt.setInt(2, solicitud.getIdUsuario());
      pstmt.setInt(3, solicitud.getIdLandingOrigen());
      pstmt.setInt(4, solicitud.getIdLandingDestino());
      pstmt.setLong(5, solicitud.getCapacidadSolicitada());
      pstmt.setString(6, solicitud.getJustificacion());

      return pstmt.executeUpdate() == 1;
    }
  }

  // Editar solicitudes no aprobadas y sin servicios asociados
  public boolean actualizarSolicitud(Solicitud solicitud)
    throws SQLException {

    String sql =
      "UPDATE solicitudes "
        + "SET id_cliente = ?, id_landing_origen = ?, "
        + "id_landing_destino = ?, capacidad_solicitada = ?, "
        + "justificacion = ? "
        + "WHERE id_solicitud = ? "
        + "AND estado IN "
        + "('Registrada', 'En evaluacion', 'Pendiente por capacidad') "
        + "AND NOT EXISTS ("
        + "SELECT 1 FROM servicios sv "
        + "WHERE sv.id_solicitud = solicitudes.id_solicitud)";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setInt(1, solicitud.getIdCliente());
      pstmt.setInt(2, solicitud.getIdLandingOrigen());
      pstmt.setInt(3, solicitud.getIdLandingDestino());
      pstmt.setLong(4, solicitud.getCapacidadSolicitada());
      pstmt.setString(5, solicitud.getJustificacion());
      pstmt.setInt(6, solicitud.getIdSolicitud());

      return pstmt.executeUpdate() == 1;
    }
  }

  // Cambiar de estado siguiendo el flujo de las solicitudes
  public boolean cambiarEstado(int idSolicitud, String nuevoEstado)
    throws SQLException {

    if (nuevoEstado == null) {
      return false;
    }

    String condicion;

    switch (nuevoEstado) {

      case "En evaluacion":
        condicion =
          "estado IN ('Registrada', 'Pendiente por capacidad')";
        break;

      case "Aprobada":
      case "Rechazada":
      case "Pendiente por capacidad":
        condicion = "estado = 'En evaluacion'";
        break;

      default:
        return false;
    }

    String sql =
      "UPDATE solicitudes SET estado = ? "
        + "WHERE id_solicitud = ? AND " + condicion;

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setString(1, nuevoEstado);
      pstmt.setInt(2, idSolicitud);

      return pstmt.executeUpdate() == 1;
    }
  }

  // Eliminar solicitudes no aprobadas y sin servicios asociados
  public boolean eliminarSolicitud(int idSolicitud)
    throws SQLException {

    String sql =
      "DELETE FROM solicitudes "
        + "WHERE id_solicitud = ? "
        + "AND estado IN "
        + "('Registrada', 'En evaluacion', "
        + "'Pendiente por capacidad', 'Rechazada') "
        + "AND NOT EXISTS ("
        + "SELECT 1 FROM servicios sv "
        + "WHERE sv.id_solicitud = solicitudes.id_solicitud)";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setInt(1, idSolicitud);

      return pstmt.executeUpdate() == 1;
    }
  }

  // Estaciones activas para seleccionar origen y destino
  public ArrayList<String[]> listarEstacionesActivas()
    throws SQLException {

    ArrayList<String[]> lista = new ArrayList<>();

    String sql =
      "SELECT id_landing, nombre FROM landingstation "
        + "WHERE estado = 'Activa' ORDER BY nombre";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql);
         ResultSet rs = pstmt.executeQuery()) {

      while (rs.next()) {
        lista.add(new String[]{
          rs.getString("id_landing"),
          rs.getString("nombre")
        });
      }
    }

    return lista;
  }

  // Listar las solicitudes de un cliente
  public ArrayList<Solicitud> listarSolicitudesPorCliente(int idCliente)
    throws SQLException {

    ArrayList<Solicitud> lista = new ArrayList<>();

    String sql = SELECT_SOLICITUD
      + "WHERE so.id_cliente = ? "
      + "ORDER BY so.fecha_registro DESC, so.id_solicitud DESC";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setInt(1, idCliente);

      try (ResultSet rs = pstmt.executeQuery()) {
        while (rs.next()) {
          lista.add(fetchSolicitud(rs));
        }
      }
    }

    return lista;
  }

  // Convertir una fila del resultado en un objeto Solicitud
  private Solicitud fetchSolicitud(ResultSet rs) throws SQLException {

    Solicitud solicitud = new Solicitud();

    solicitud.setIdSolicitud(rs.getInt("id_solicitud"));
    solicitud.setIdCliente(rs.getInt("id_cliente"));
    solicitud.setIdUsuario(rs.getInt("id_usuario"));
    solicitud.setIdLandingOrigen(rs.getInt("id_landing_origen"));
    solicitud.setIdLandingDestino(rs.getInt("id_landing_destino"));
    solicitud.setCapacidadSolicitada(rs.getLong("capacidad_solicitada"));
    solicitud.setEstado(rs.getString("estado"));
    solicitud.setJustificacion(rs.getString("justificacion"));
    solicitud.setFechaRegistro(rs.getTimestamp("fecha_registro"));

    solicitud.setNombreCliente(rs.getString("nombre_cliente"));
    solicitud.setNombreOrigen(rs.getString("nombre_origen"));
    solicitud.setNombreDestino(rs.getString("nombre_destino"));

    return solicitud;
  }
}
