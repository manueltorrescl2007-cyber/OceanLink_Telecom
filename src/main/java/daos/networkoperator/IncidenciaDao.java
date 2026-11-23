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

    // Al registrar una incidencia: sus segmentos pasan a Degradado (o Fuera de servicio si es Crítica)
    public void marcarSegmentosAfectados(int idIncidencia, String severidad) {
        try (Connection conn = getConnection()) {
            actualizarSegmentosPorSeveridad(conn, idIncidencia, severidad);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public boolean cambiarSeveridad(int idIncidencia, String severidadNueva, int idUsuario) {
        String sqlActual = "SELECT severidad, estado FROM incidencias "
                         + "WHERE id_incidencia = ? AND estado <> 'Cerrada' FOR UPDATE";
        String sqlUpdate = "UPDATE incidencias SET severidad = ? WHERE id_incidencia = ?";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try {
                String severidadActual = null;
                String estadoIncidencia = null;
                try (PreparedStatement pstmt = conn.prepareStatement(sqlActual)) {
                    pstmt.setInt(1, idIncidencia);
                    try (ResultSet rs = pstmt.executeQuery()) {
                        if (rs.next()) {
                            severidadActual = rs.getString("severidad");
                            estadoIncidencia = rs.getString("estado");
                        }
                    }
                }

                if (severidadActual == null || severidadActual.equals(severidadNueva)) {
                    conn.rollback();
                    return false;
                }

                try (PreparedStatement pstmt = conn.prepareStatement(sqlUpdate)) {
                    pstmt.setString(1, severidadNueva);
                    pstmt.setInt(2, idIncidencia);
                    pstmt.executeUpdate();
                }

                registrarCambio(conn, idIncidencia, idUsuario, "Cambio de severidad: "
                        + textoSeveridad(severidadActual) + " → " + textoSeveridad(severidadNueva));

                // Si sube a Crítica y la falla sigue activa, sus segmentos pasan a Fuera de servicio
                if ("Critica".equals(severidadNueva) && !"Servicio restaurado".equals(estadoIncidencia)) {
                    actualizarSegmentosPorSeveridad(conn, idIncidencia, severidadNueva);
                }

                conn.commit();
                return true;

            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean cambiarEstado(int idIncidencia, String estadoActual, String estadoNuevo, int idUsuario) {
        String sql = "UPDATE incidencias SET estado = ?";
        if ("Servicio restaurado".equals(estadoNuevo)) {
            sql += ", fecha_restauracion = NOW()";
        } else if ("Cerrada".equals(estadoNuevo)) {
            sql += ", fecha_cierre = NOW()";
        }
        sql += " WHERE id_incidencia = ? AND estado = ?";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try {
                int filas;
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setString(1, estadoNuevo);
                    pstmt.setInt(2, idIncidencia);
                    pstmt.setString(3, estadoActual);
                    filas = pstmt.executeUpdate();
                }

                if (filas == 0) {
                    conn.rollback();
                    return false;
                }

                registrarCambio(conn, idIncidencia, idUsuario, "Cambio de estado: "
                        + textoEstado(estadoActual) + " → " + textoEstado(estadoNuevo));

                // Servicio restaurado: los segmentos vuelven a Operativo (en la misma transacción)
                if ("Servicio restaurado".equals(estadoNuevo)) {
                    restaurarSegmentos(conn, idIncidencia);
                }

                conn.commit();
                return true;

            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Crítica -> Fuera de servicio; Leve/Media/Alta -> Degradado.
    // Solo cambia segmentos Operativo o Degradado: no toca los que están En mantenimiento ni Fuera de servicio.
    private void actualizarSegmentosPorSeveridad(Connection conn, int idIncidencia, String severidad) throws SQLException {
        String sql = "UPDATE segmentos s "
                   + "JOIN segmentos_has_incidencias si ON si.id_segmento = s.id_segmento "
                   + "SET s.estado = CASE WHEN ? = 'Critica' THEN 'Fuera de servicio' ELSE 'Degradado' END "
                   + "WHERE si.id_incidencia = ? "
                   + "AND s.estado IN ('Operativo', 'Degradado')";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, severidad);
            pstmt.setInt(2, idIncidencia);
            pstmt.executeUpdate();
        }
    }

    // Vuelve a Operativo los segmentos de la incidencia que no tengan otra incidencia abierta.
    // Los que están En mantenimiento no se tocan.
    private void restaurarSegmentos(Connection conn, int idIncidencia) throws SQLException {
        String sql = "UPDATE segmentos s "
                   + "JOIN segmentos_has_incidencias si ON si.id_segmento = s.id_segmento "
                   + "SET s.estado = 'Operativo' "
                   + "WHERE si.id_incidencia = ? "
                   + "AND s.estado IN ('Degradado', 'Fuera de servicio') "
                   + "AND NOT EXISTS ("
                   + "    SELECT 1 FROM segmentos_has_incidencias si2 "
                   + "    JOIN incidencias i2 ON i2.id_incidencia = si2.id_incidencia "
                   + "    WHERE si2.id_segmento = s.id_segmento "
                   + "    AND i2.id_incidencia <> ? "
                   + "    AND i2.estado NOT IN ('Servicio restaurado', 'Cerrada'))";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, idIncidencia);
            pstmt.setInt(2, idIncidencia);
            pstmt.executeUpdate();
        }
    }

    private void registrarCambio(Connection conn, int idIncidencia, int idUsuario, String mensaje) throws SQLException {
        String sql = "INSERT INTO observaciones_incidencias (id_incidencia, id_usuario, mensaje) "
                   + "VALUES (?, ?, ?)";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, idIncidencia);
            pstmt.setInt(2, idUsuario);
            pstmt.setString(3, mensaje);
            pstmt.executeUpdate();
        }
    }

    private String textoEstado(String estado) {
        switch (estado) {
            case "En analisis":           return "En análisis";
            case "Reparacion programada": return "Reparación programada";
            case "En reparacion":         return "En reparación";
            default:                      return estado;
        }
    }

    private String textoSeveridad(String severidad) {
        return "Critica".equals(severidad) ? "Crítica" : severidad;
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
