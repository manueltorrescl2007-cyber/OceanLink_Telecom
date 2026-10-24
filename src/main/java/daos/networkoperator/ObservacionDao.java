package daos.networkoperator;

import beans.Usuario;
import beans.networkoperator.Observacion;
import daos.BaseDao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class ObservacionDao extends BaseDao {

    public void crearObservacion(Observacion observacion) {
        String sql = "INSERT INTO observaciones_incidencias (id_incidencia, id_usuario, mensaje) "
                   + "VALUES (?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, observacion.getIncidencia().getIdIncidencia());
            pstmt.setInt(2, observacion.getUsuario().getIdUsuario());
            pstmt.setString(3, observacion.getMensaje());
            pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public ArrayList<Observacion> listarObservaciones(int idIncidencia) {
        ArrayList<Observacion> lista = new ArrayList<>();
        String sql = "SELECT o.id_observacion, o.fecha_hora, o.mensaje, "
                   + "       u.id_usuario, u.nombre AS operador "
                   + "FROM observaciones_incidencias o "
                   + "JOIN usuarios u ON o.id_usuario = u.id_usuario "
                   + "WHERE o.id_incidencia = ? "
                   + "ORDER BY o.fecha_hora ASC, o.id_observacion ASC";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idIncidencia);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Usuario usuario = new Usuario();
                    usuario.setIdUsuario(rs.getInt("id_usuario"));
                    usuario.setNombre(rs.getString("operador"));

                    Observacion observacion = new Observacion();
                    observacion.setIdObservacion(rs.getInt("id_observacion"));
                    observacion.setFechaHora(rs.getString("fecha_hora"));
                    observacion.setMensaje(rs.getString("mensaje"));
                    observacion.setUsuario(usuario);
                    lista.add(observacion);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }
}
