package daos.networkoperator;

import beans.networkoperator.UtilizacionDiaria;
import daos.BaseDao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class UtilizacionDao extends BaseDao {

    public void guardarFoto(String fecha, int total, int ocupada, int reservada) {
        String sql = "INSERT INTO utilizacion_diaria (fecha, capacidad_total, capacidad_ocupada, capacidad_reservada) "
                   + "VALUES (?, ?, ?, ?) "
                   + "ON DUPLICATE KEY UPDATE capacidad_total = ?, capacidad_ocupada = ?, capacidad_reservada = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, fecha);
            pstmt.setInt(2, total);
            pstmt.setInt(3, ocupada);
            pstmt.setInt(4, reservada);

            pstmt.setInt(5, total);
            pstmt.setInt(6, ocupada);
            pstmt.setInt(7, reservada);
            pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public ArrayList<UtilizacionDiaria> listarEntreFechas(String desde, String hasta) {
        ArrayList<UtilizacionDiaria> lista = new ArrayList<>();
        String sql = "SELECT fecha, capacidad_total, capacidad_ocupada, capacidad_reservada "
                   + "FROM utilizacion_diaria "
                   + "WHERE fecha BETWEEN ? AND ? "
                   + "ORDER BY fecha";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, desde);
            pstmt.setString(2, hasta);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    UtilizacionDiaria dia = new UtilizacionDiaria();
                    dia.setFecha(rs.getString("fecha"));
                    dia.setCapacidadTotal(rs.getInt("capacidad_total"));
                    dia.setCapacidadOcupada(rs.getInt("capacidad_ocupada"));
                    dia.setCapacidadReservada(rs.getInt("capacidad_reservada"));
                    lista.add(dia);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }
}
