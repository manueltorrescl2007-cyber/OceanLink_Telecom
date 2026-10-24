package daos.networkoperator;

import beans.networkoperator.LandingStation;
import beans.networkoperator.Segmento;
import daos.BaseDao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class SegmentoDao extends BaseDao {

    public ArrayList<Segmento> listarSegmentos(String estado) {
        ArrayList<Segmento> lista = new ArrayList<>();
        boolean filtrarEstado = estado != null && !estado.isEmpty();

        String sql = "SELECT s.id_segmento, s.codigo, "
                   + "       l1.id_landing AS id_inicial, l1.nombre AS punto_inicial, "
                   + "       l2.id_landing AS id_final,   l2.nombre AS punto_final, "
                   + "       s.capacidad_total, s.capacidad_ocupada, s.capacidad_reservada, s.estado "
                   + "FROM segmentos s "
                   + "JOIN landingstation l1 ON s.id_landing_inicial = l1.id_landing "
                   + "JOIN landingstation l2 ON s.id_landing_final   = l2.id_landing "
                   + "WHERE 1 = 1 ";
        if (filtrarEstado) {
            sql += "AND s.estado = ? ";
        }
        sql += "ORDER BY s.codigo";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            if (filtrarEstado) {
                pstmt.setString(1, estado);
            }

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    lista.add(fetchSegmento(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    public ArrayList<Segmento> listarSegmentosDeIncidencia(int idIncidencia) {
        ArrayList<Segmento> lista = new ArrayList<>();

        String sql = "SELECT s.id_segmento, s.codigo, "
                   + "       l1.id_landing AS id_inicial, l1.nombre AS punto_inicial, "
                   + "       l2.id_landing AS id_final,   l2.nombre AS punto_final, "
                   + "       s.capacidad_total, s.capacidad_ocupada, s.capacidad_reservada, s.estado "
                   + "FROM segmentos_has_incidencias si "
                   + "JOIN segmentos s        ON si.id_segmento = s.id_segmento "
                   + "JOIN landingstation l1  ON s.id_landing_inicial = l1.id_landing "
                   + "JOIN landingstation l2  ON s.id_landing_final   = l2.id_landing "
                   + "WHERE si.id_incidencia = ? "
                   + "ORDER BY s.codigo";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idIncidencia);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    lista.add(fetchSegmento(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    private Segmento fetchSegmento(ResultSet rs) throws SQLException {
        LandingStation inicial = new LandingStation();
        inicial.setIdLanding(rs.getInt("id_inicial"));
        inicial.setNombre(rs.getString("punto_inicial"));

        LandingStation fin = new LandingStation();
        fin.setIdLanding(rs.getInt("id_final"));
        fin.setNombre(rs.getString("punto_final"));

        Segmento segmento = new Segmento();
        segmento.setIdSegmento(rs.getInt("id_segmento"));
        segmento.setCodigo(rs.getString("codigo"));
        segmento.setLandingInicial(inicial);
        segmento.setLandingFinal(fin);
        segmento.setCapacidadTotal(rs.getInt("capacidad_total"));
        segmento.setCapacidadOcupada(rs.getInt("capacidad_ocupada"));
        segmento.setCapacidadReservada(rs.getInt("capacidad_reservada"));
        segmento.setEstado(rs.getString("estado"));
        return segmento;
    }
}
