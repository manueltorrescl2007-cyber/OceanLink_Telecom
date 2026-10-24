package daos.networkoperator;

import beans.Usuario;
import beans.networkoperator.Incidencia;
import daos.BaseDao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

public class IncidenciaDao extends BaseDao {

    private static final String SELECT_INCIDENCIA =
            "SELECT i.id_incidencia, i.codigo, i.titulo, i.descripcion, i.severidad, i.estado, "
          + "       i.fecha_registro, i.fecha_restauracion, i.fecha_cierre, "
          + "       u.id_usuario, u.nombre AS registrado_por "
          + "FROM incidencias i "
          + "JOIN usuarios u ON i.id_usuario = u.id_usuario ";

    public ArrayList<Incidencia> listarIncidencias(boolean cerradas, String severidad, int idSegmento) {
        ArrayList<Incidencia> lista = new ArrayList<>();

        boolean filtrarSeveridad = severidad != null && !severidad.isEmpty();
        boolean filtrarSegmento = idSegmento > 0;

        String sql = SELECT_INCIDENCIA;
        sql += cerradas ? "WHERE i.estado = 'Cerrada' " : "WHERE i.estado <> 'Cerrada' ";
        if (filtrarSeveridad) {
            sql += "AND i.severidad = ? ";
        }
        if (filtrarSegmento) {

            sql += "AND i.id_incidencia IN (SELECT si.id_incidencia FROM segmentos_has_incidencias si "
                 + "                       WHERE si.id_segmento = ?) ";
        }
        sql += cerradas ? "ORDER BY i.fecha_cierre DESC" : "ORDER BY i.fecha_registro DESC, i.id_incidencia DESC";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            int indice = 1;
            if (filtrarSeveridad) {
                pstmt.setString(indice++, severidad);
            }
            if (filtrarSegmento) {
                pstmt.setInt(indice++, idSegmento);
            }

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    lista.add(fetchIncidencia(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    public Incidencia obtenerIncidencia(int idIncidencia) {
        Incidencia incidencia = null;
        String sql = SELECT_INCIDENCIA + "WHERE i.id_incidencia = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idIncidencia);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    incidencia = fetchIncidencia(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return incidencia;
    }

    public int crearIncidencia(Incidencia incidencia) {
        int idGenerado = -1;
        String sql = "INSERT INTO incidencias (codigo, titulo, descripcion, severidad, estado, id_usuario) "
                   + "VALUES (?, ?, ?, ?, 'Detectada', ?)";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setString(1, obtenerSiguienteCodigo());
            pstmt.setString(2, incidencia.getTitulo());
            pstmt.setString(3, incidencia.getDescripcion());
            pstmt.setString(4, incidencia.getSeveridad());
            pstmt.setInt(5, incidencia.getUsuario().getIdUsuario());
            pstmt.executeUpdate();

            try (ResultSet rs = pstmt.getGeneratedKeys()) {
                if (rs.next()) {
                    idGenerado = rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return idGenerado;
    }

    public void asociarSegmento(int idIncidencia, int idSegmento) {
        String sql = "INSERT INTO segmentos_has_incidencias (id_segmento, id_incidencia) VALUES (?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idSegmento);
            pstmt.setInt(2, idIncidencia);
            pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void actualizarSeveridad(int idIncidencia, String severidad) {
        String sql = "UPDATE incidencias SET severidad = ? "
                   + "WHERE id_incidencia = ? AND estado <> 'Cerrada'";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, severidad);
            pstmt.setInt(2, idIncidencia);
            pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public boolean actualizarEstado(int idIncidencia, String estadoActual, String estadoNuevo) {
        String sql = "UPDATE incidencias SET estado = ? "
                   + "WHERE id_incidencia = ? AND estado = ?";
        int filas = 0;

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, estadoNuevo);
            pstmt.setInt(2, idIncidencia);
            pstmt.setString(3, estadoActual);
            filas = pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return filas > 0;
    }

    public boolean registrarRestauracion(int idIncidencia) {
        String sql = "UPDATE incidencias SET estado = 'Servicio restaurado', fecha_restauracion = NOW() "
                   + "WHERE id_incidencia = ? AND estado = 'En reparacion'";
        int filas = 0;

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idIncidencia);
            filas = pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return filas > 0;
    }

    public boolean cerrarIncidencia(int idIncidencia) {
        String sql = "UPDATE incidencias SET estado = 'Cerrada', fecha_cierre = NOW() "
                   + "WHERE id_incidencia = ? AND estado = 'Servicio restaurado'";
        int filas = 0;

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idIncidencia);
            filas = pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return filas > 0;
    }

    public int obtenerIdNetworkOperator() {
        int idUsuario = -1;
        String sql = "SELECT id_usuario FROM usuarios "
                   + "WHERE id_rol = 4 AND estado = 'activo' ORDER BY id_usuario LIMIT 1";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            if (rs.next()) {
                idUsuario = rs.getInt("id_usuario");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return idUsuario;
    }

    private String obtenerSiguienteCodigo() {
        int siguiente = 1;
        String sql = "SELECT COALESCE(MAX(id_incidencia), 0) + 1 AS siguiente FROM incidencias";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            if (rs.next()) {
                siguiente = rs.getInt("siguiente");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return String.format("INC-%03d", siguiente);
    }

    private Incidencia fetchIncidencia(ResultSet rs) throws SQLException {
        Usuario usuario = new Usuario();
        usuario.setIdUsuario(rs.getInt("id_usuario"));
        usuario.setNombre(rs.getString("registrado_por"));

        Incidencia incidencia = new Incidencia();
        incidencia.setIdIncidencia(rs.getInt("id_incidencia"));
        incidencia.setCodigo(rs.getString("codigo"));
        incidencia.setTitulo(rs.getString("titulo"));
        incidencia.setDescripcion(rs.getString("descripcion"));
        incidencia.setSeveridad(rs.getString("severidad"));
        incidencia.setEstado(rs.getString("estado"));
        incidencia.setFechaRegistro(rs.getString("fecha_registro"));
        incidencia.setFechaRestauracion(rs.getString("fecha_restauracion"));
        incidencia.setFechaCierre(rs.getString("fecha_cierre"));
        incidencia.setUsuario(usuario);
        return incidencia;
    }
}
