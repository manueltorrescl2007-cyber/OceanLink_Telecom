package daos.admin;

import beans.capacityplanner.LandingStation;
import daos.BaseDao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class LandingStationAdminDao extends BaseDao {

  public ArrayList<LandingStation> listarEstaciones(String filtroEstado) throws SQLException {
    ArrayList<LandingStation> lista = new ArrayList<>();
    boolean tieneFiltro = filtroEstado != null && !filtroEstado.isEmpty();

    String sql = "SELECT id_landing, nombre, pais, ciudad, estado "
      + "FROM landingstation "
      + (tieneFiltro ? "WHERE estado = ? " : "")
      + "ORDER BY id_landing";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      if (tieneFiltro) {
        pstmt.setString(1, filtroEstado);
      }

      try (ResultSet rs = pstmt.executeQuery()) {
        while (rs.next()) {
          lista.add(mapearEstacion(rs));
        }
      }
    }
    return lista;
  }

  public LandingStation obtenerEstacion(int idLanding) throws SQLException {
    String sql = "SELECT id_landing, nombre, pais, ciudad, estado "
      + "FROM landingstation WHERE id_landing = ?";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setInt(1, idLanding);
      try (ResultSet rs = pstmt.executeQuery()) {
        if (rs.next()) {
          return mapearEstacion(rs);
        }
      }
    }
    return null;
  }

  public boolean crearEstacion(LandingStation estacion) throws SQLException {
    String sql = "INSERT INTO landingstation (nombre, pais, ciudad, estado) VALUES (?, ?, ?, ?)";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setString(1, estacion.getNombre());
      pstmt.setString(2, estacion.getPais());
      pstmt.setString(3, estacion.getCiudad());
      pstmt.setString(4, estacion.getEstado());

      return pstmt.executeUpdate() == 1;
    }
  }

  public boolean actualizarEstacion(LandingStation estacion) throws SQLException {
    String sql = "UPDATE landingstation SET nombre = ?, pais = ?, ciudad = ?, estado = ? WHERE id_landing = ?";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setString(1, estacion.getNombre());
      pstmt.setString(2, estacion.getPais());
      pstmt.setString(3, estacion.getCiudad());
      pstmt.setString(4, estacion.getEstado());
      pstmt.setInt(5, estacion.getIdLanding());

      return pstmt.executeUpdate() == 1;
    }
  }

  public boolean cambiarEstado(int idLanding, String nuevoEstado) throws SQLException {
    String sql = "UPDATE landingstation SET estado = ? WHERE id_landing = ?";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setString(1, nuevoEstado);
      pstmt.setInt(2, idLanding);

      return pstmt.executeUpdate() == 1;
    }
  }

  public boolean eliminarEstacion(int idLanding) throws SQLException {
    String sql = "DELETE FROM landingstation WHERE id_landing = ?";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setInt(1, idLanding);
      return pstmt.executeUpdate() == 1;
    }
  }

  private LandingStation mapearEstacion(ResultSet rs) throws SQLException {
    LandingStation estacion = new LandingStation();
    estacion.setIdLanding(rs.getInt("id_landing"));
    estacion.setNombre(rs.getString("nombre"));
    estacion.setPais(rs.getString("pais"));
    estacion.setCiudad(rs.getString("ciudad"));
    estacion.setEstado(rs.getString("estado"));
    return estacion;
  }
}
