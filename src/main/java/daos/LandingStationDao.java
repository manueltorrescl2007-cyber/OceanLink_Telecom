package daos;

import beans.LandingStation;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class LandingStationDao extends BaseDao {

  public ArrayList<LandingStation> listarEstaciones()
    throws SQLException {

    ArrayList<LandingStation> lista = new ArrayList<>();

    String sql = "SELECT id_landing, nombre, pais, ciudad, estado "
      + "FROM landingstation ORDER BY id_landing";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql);
         ResultSet rs = pstmt.executeQuery()) {

      while (rs.next()) {
        LandingStation estacion = new LandingStation();

        estacion.setIdLanding(rs.getInt("id_landing"));
        estacion.setNombre(rs.getString("nombre"));
        estacion.setPais(rs.getString("pais"));
        estacion.setCiudad(rs.getString("ciudad"));
        estacion.setEstado(rs.getString("estado"));

        lista.add(estacion);
      }
    }

    return lista;
  }
  // Crear una estación
  public boolean crearEstacion(LandingStation estacion)
    throws SQLException {

    String sql = "INSERT INTO landingstation "
      + "(nombre, pais, ciudad, estado) VALUES (?, ?, ?, ?)";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setString(1, estacion.getNombre());
      pstmt.setString(2, estacion.getPais());
      pstmt.setString(3, estacion.getCiudad());
      pstmt.setString(4, estacion.getEstado());

      return pstmt.executeUpdate() == 1;
    }
  }

  // Editar una estación
  public boolean actualizarEstacion(LandingStation estacion)
    throws SQLException {

    String sql = "UPDATE landingstation "
      + "SET nombre = ?, pais = ?, ciudad = ?, estado = ? "
      + "WHERE id_landing = ?";

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
}
