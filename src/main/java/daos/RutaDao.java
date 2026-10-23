package daos;

import beans.Ruta;
import beans.Segmento;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

public class RutaDao extends BaseDao {

  private static final String SELECT_RUTA =
    "SELECT r.*, lo.nombre AS nombre_origen, "
      + "ld.nombre AS nombre_destino "
      + "FROM rutas r "
      + "INNER JOIN landingstation lo "
      + "ON r.id_landing_origen = lo.id_landing "
      + "INNER JOIN landingstation ld "
      + "ON r.id_landing_destino = ld.id_landing ";

  // Listar todas las rutas con sus segmentos
  public ArrayList<Ruta> listarRutas() throws SQLException {

    ArrayList<Ruta> lista = new ArrayList<>();

    String sql = SELECT_RUTA + "ORDER BY r.id_ruta";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql);
         ResultSet rs = pstmt.executeQuery()) {

      while (rs.next()) {
        lista.add(fetchRuta(rs));
      }
    }

    for (Ruta ruta : lista) {
      ruta.setSegmentos(listarSegmentosRuta(ruta.getIdRuta()));
    }

    return lista;
  }

  // Obtener una ruta por su ID
  public Ruta obtenerRuta(int idRuta) throws SQLException {

    Ruta ruta = null;

    String sql = SELECT_RUTA + "WHERE r.id_ruta = ?";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setInt(1, idRuta);

      try (ResultSet rs = pstmt.executeQuery()) {
        if (rs.next()) {
          ruta = fetchRuta(rs);
        }
      }
    }

    if (ruta != null) {
      ruta.setSegmentos(listarSegmentosRuta(idRuta));
    }

    return ruta;
  }

  // Obtener los segmentos de una ruta en su orden
  public ArrayList<Segmento> listarSegmentosRuta(int idRuta)
    throws SQLException {

    ArrayList<Segmento> lista = new ArrayList<>();

    String sql =
      "SELECT s.*, li.nombre AS nombre_inicial, "
        + "lf.nombre AS nombre_final "
        + "FROM ruta_segmentos rs "
        + "INNER JOIN segmentos s "
        + "ON rs.id_segmento = s.id_segmento "
        + "INNER JOIN landingstation li "
        + "ON s.id_landing_inicial = li.id_landing "
        + "INNER JOIN landingstation lf "
        + "ON s.id_landing_final = lf.id_landing "
        + "WHERE rs.id_ruta = ? "
        + "ORDER BY rs.orden";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setInt(1, idRuta);

      try (ResultSet rs = pstmt.executeQuery()) {
        while (rs.next()) {
          Segmento segmento = new Segmento();

          segmento.setIdSegmento(rs.getInt("id_segmento"));
          segmento.setCodigo(rs.getString("codigo"));
          segmento.setIdLandingInicial(
            rs.getInt("id_landing_inicial"));
          segmento.setIdLandingFinal(
            rs.getInt("id_landing_final"));
          segmento.setCapacidadTotal(
            rs.getLong("capacidad_total"));
          segmento.setCapacidadOcupada(
            rs.getLong("capacidad_ocupada"));
          segmento.setCapacidadReservada(
            rs.getLong("capacidad_reservada"));
          segmento.setEstado(rs.getString("estado"));
          segmento.setNombreInicial(
            rs.getString("nombre_inicial"));
          segmento.setNombreFinal(
            rs.getString("nombre_final"));

          lista.add(segmento);
        }
      }
    }

    return lista;
  }

  // Crear una ruta y guardar sus segmentos en orden
  public boolean crearRuta(Ruta ruta) throws SQLException {

    String sqlRuta =
      "INSERT INTO rutas "
        + "(nombre, id_landing_origen, id_landing_destino, estado) "
        + "VALUES (?, ?, ?, ?)";

    String sqlSegmentos =
      "INSERT INTO ruta_segmentos "
        + "(id_ruta, id_segmento, orden) VALUES (?, ?, ?)";

    try (Connection conn = getConnection()) {
      conn.setAutoCommit(false);

      try {
        int idRuta;

        try (PreparedStatement pstmt = conn.prepareStatement(
          sqlRuta, Statement.RETURN_GENERATED_KEYS)) {

          pstmt.setString(1, ruta.getNombre());
          pstmt.setInt(2, ruta.getIdLandingOrigen());
          pstmt.setInt(3, ruta.getIdLandingDestino());
          pstmt.setString(4, ruta.getEstado());

          if (pstmt.executeUpdate() != 1) {
            conn.rollback();
            return false;
          }

          try (ResultSet rs = pstmt.getGeneratedKeys()) {
            if (!rs.next()) {
              throw new SQLException(
                "No se pudo obtener el ID de la ruta.");
            }

            idRuta = rs.getInt(1);
          }
        }

        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlSegmentos)) {

          int orden = 1;

          for (Segmento segmento : ruta.getSegmentos()) {
            pstmt.setInt(1, idRuta);
            pstmt.setInt(2, segmento.getIdSegmento());
            pstmt.setInt(3, orden);

            pstmt.executeUpdate();
            orden++;
          }
        }

        conn.commit();
        ruta.setIdRuta(idRuta);
        return true;

      } catch (SQLException e) {
        conn.rollback();
        throw e;
      }
    }
  }

  // Editar una ruta solo si no tiene servicios asociados
  public boolean actualizarRuta(Ruta ruta) throws SQLException {

    String sqlRuta =
      "UPDATE rutas SET nombre = ?, id_landing_origen = ?, "
        + "id_landing_destino = ?, estado = ? "
        + "WHERE id_ruta = ? "
        + "AND NOT EXISTS (SELECT 1 FROM servicios sv "
        + "WHERE sv.id_ruta = rutas.id_ruta)";

    String sqlEliminar =
      "DELETE FROM ruta_segmentos WHERE id_ruta = ?";

    String sqlSegmentos =
      "INSERT INTO ruta_segmentos "
        + "(id_ruta, id_segmento, orden) VALUES (?, ?, ?)";

    try (Connection conn = getConnection()) {
      conn.setAutoCommit(false);

      try {
        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlRuta)) {

          pstmt.setString(1, ruta.getNombre());
          pstmt.setInt(2, ruta.getIdLandingOrigen());
          pstmt.setInt(3, ruta.getIdLandingDestino());
          pstmt.setString(4, ruta.getEstado());
          pstmt.setInt(5, ruta.getIdRuta());

          if (pstmt.executeUpdate() != 1) {
            conn.rollback();
            return false;
          }
        }

        // Quitar las asociaciones anteriores
        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlEliminar)) {

          pstmt.setInt(1, ruta.getIdRuta());
          pstmt.executeUpdate();
        }

        // Guardar los segmentos en su nuevo orden
        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlSegmentos)) {

          int orden = 1;

          for (Segmento segmento : ruta.getSegmentos()) {
            pstmt.setInt(1, ruta.getIdRuta());
            pstmt.setInt(2, segmento.getIdSegmento());
            pstmt.setInt(3, orden);

            pstmt.executeUpdate();
            orden++;
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

  // Eliminar una ruta solo si no tiene servicios asociados
  public boolean eliminarRuta(int idRuta) throws SQLException {

    String sqlSegmentos =
      "DELETE FROM ruta_segmentos WHERE id_ruta = ?";

    String sqlRuta =
      "DELETE FROM rutas WHERE id_ruta = ? "
        + "AND NOT EXISTS (SELECT 1 FROM servicios sv "
        + "WHERE sv.id_ruta = rutas.id_ruta)";

    try (Connection conn = getConnection()) {
      conn.setAutoCommit(false);

      try {
        // Quitar las asociaciones con los segmentos
        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlSegmentos)) {

          pstmt.setInt(1, idRuta);
          pstmt.executeUpdate();
        }

        try (PreparedStatement pstmt =
               conn.prepareStatement(sqlRuta)) {

          pstmt.setInt(1, idRuta);

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

  // Convertir una fila del resultado en un objeto Ruta
  private Ruta fetchRuta(ResultSet rs) throws SQLException {

    Ruta ruta = new Ruta();

    ruta.setIdRuta(rs.getInt("id_ruta"));
    ruta.setNombre(rs.getString("nombre"));
    ruta.setIdLandingOrigen(rs.getInt("id_landing_origen"));
    ruta.setIdLandingDestino(rs.getInt("id_landing_destino"));
    ruta.setEstado(rs.getString("estado"));
    ruta.setNombreOrigen(rs.getString("nombre_origen"));
    ruta.setNombreDestino(rs.getString("nombre_destino"));

    return ruta;
  }
}
