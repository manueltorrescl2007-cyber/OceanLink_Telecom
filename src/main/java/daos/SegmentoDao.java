package daos;

import beans.Segmento;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.sql.Statement;

public class SegmentoDao extends BaseDao {

  private static final String SELECT_SEGMENTO =
    "SELECT s.*, "
      + "li.nombre AS nombre_inicial, "
      + "lf.nombre AS nombre_final "
      + "FROM segmentos s "
      + "INNER JOIN landingstation li "
      + "ON s.id_landing_inicial = li.id_landing "
      + "INNER JOIN landingstation lf "
      + "ON s.id_landing_final = lf.id_landing ";

  // Listar todos los segmentos
  public ArrayList<Segmento> listarSegmentos() throws SQLException {

    ArrayList<Segmento> lista = new ArrayList<>();

    String sql = SELECT_SEGMENTO + "ORDER BY s.id_segmento";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql);
         ResultSet rs = pstmt.executeQuery()) {

      while (rs.next()) {
        lista.add(fetchSegmento(rs));
      }
    }

    return lista;
  }

  // Obtener un segmento para mostrar su detalle
  public Segmento obtenerSegmento(int idSegmento)
    throws SQLException {

    String sql = SELECT_SEGMENTO + "WHERE s.id_segmento = ?";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setInt(1, idSegmento);

      try (ResultSet rs = pstmt.executeQuery()) {
        if (rs.next()) {
          return fetchSegmento(rs);
        }
      }
    }

    return null;
  }

  // Crear el segmento y relacionarlo con sus dos estaciones
  public boolean crearSegmento(Segmento segmento) throws SQLException {

    String sql = "INSERT INTO segmentos "
      + "(codigo, id_landing_inicial, id_landing_final, "
      + "capacidad_total, estado) "
      + "VALUES (?, ?, ?, ?, ?)";

    String sqlEstaciones = "INSERT INTO segmentos_has_landingstation "
      + "(id_segmento, id_landing) VALUES (?, ?), (?, ?)";

    try (Connection conn = getConnection()) {

      conn.setAutoCommit(false);

      try {
        int idSegmento;

        try (PreparedStatement pstmt = conn.prepareStatement(
          sql, Statement.RETURN_GENERATED_KEYS)) {

          pstmt.setString(1, segmento.getCodigo());
          pstmt.setInt(2, segmento.getIdLandingInicial());
          pstmt.setInt(3, segmento.getIdLandingFinal());
          pstmt.setLong(4, segmento.getCapacidadTotal());
          pstmt.setString(5, segmento.getEstado());

          if (pstmt.executeUpdate() != 1) {
            throw new SQLException("No se pudo crear el segmento.");
          }

          try (ResultSet rs = pstmt.getGeneratedKeys()) {
            if (!rs.next()) {
              throw new SQLException(
                "No se obtuvo el ID del segmento.");
            }

            idSegmento = rs.getInt(1);
          }
        }

        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlEstaciones)) {

          pstmt.setInt(1, idSegmento);
          pstmt.setInt(2, segmento.getIdLandingInicial());
          pstmt.setInt(3, idSegmento);
          pstmt.setInt(4, segmento.getIdLandingFinal());

          pstmt.executeUpdate();
        }

        conn.commit();
        segmento.setIdSegmento(idSegmento);
        return true;

      } catch (SQLException e) {
        conn.rollback();
        throw e;
      }
    }
  }

  // Editar el segmento y actualizar sus estaciones relacionadas
  public boolean actualizarSegmento(Segmento segmento)
    throws SQLException {

    String sql = "UPDATE segmentos "
      + "SET codigo = ?, id_landing_inicial = ?, "
      + "id_landing_final = ?, capacidad_total = ?, estado = ? "
      + "WHERE id_segmento = ? "
      + "AND capacidad_ocupada + capacidad_reservada <= ?";

    String sqlEliminar = "DELETE FROM segmentos_has_landingstation "
      + "WHERE id_segmento = ?";

    String sqlEstaciones = "INSERT INTO segmentos_has_landingstation "
      + "(id_segmento, id_landing) VALUES (?, ?), (?, ?)";

    try (Connection conn = getConnection()) {

      conn.setAutoCommit(false);

      try {
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {

          pstmt.setString(1, segmento.getCodigo());
          pstmt.setInt(2, segmento.getIdLandingInicial());
          pstmt.setInt(3, segmento.getIdLandingFinal());
          pstmt.setLong(4, segmento.getCapacidadTotal());
          pstmt.setString(5, segmento.getEstado());
          pstmt.setInt(6, segmento.getIdSegmento());
          pstmt.setLong(7, segmento.getCapacidadTotal());

          if (pstmt.executeUpdate() != 1) {
            conn.rollback();
            return false;
          }
        }

        // Reemplazar las relaciones anteriores con las estaciones.
        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlEliminar)) {

          pstmt.setInt(1, segmento.getIdSegmento());
          pstmt.executeUpdate();
        }

        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlEstaciones)) {

          pstmt.setInt(1, segmento.getIdSegmento());
          pstmt.setInt(2, segmento.getIdLandingInicial());
          pstmt.setInt(3, segmento.getIdSegmento());
          pstmt.setInt(4, segmento.getIdLandingFinal());

          pstmt.executeUpdate();
        }

        conn.commit();
        return true;

      } catch (SQLException e) {
        conn.rollback();
        throw e;
      }
    }
  }

  // Convertir una fila en un objeto Segmento
  private Segmento fetchSegmento(ResultSet rs) throws SQLException {

    Segmento segmento = new Segmento();

    segmento.setIdSegmento(rs.getInt("id_segmento"));
    segmento.setCodigo(rs.getString("codigo"));
    segmento.setIdLandingInicial(rs.getInt("id_landing_inicial"));
    segmento.setIdLandingFinal(rs.getInt("id_landing_final"));
    segmento.setCapacidadTotal(rs.getLong("capacidad_total"));
    segmento.setCapacidadOcupada(rs.getLong("capacidad_ocupada"));
    segmento.setCapacidadReservada(rs.getLong("capacidad_reservada"));
    segmento.setEstado(rs.getString("estado"));
    segmento.setNombreInicial(rs.getString("nombre_inicial"));
    segmento.setNombreFinal(rs.getString("nombre_final"));

    return segmento;
  }
}
