package daos.networkoperator;

import beans.networkoperator.Cliente;
import beans.networkoperator.Ruta;
import beans.networkoperator.Servicio;
import beans.networkoperator.Solicitud;
import daos.BaseDao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class ServicioDao extends BaseDao {

    public ArrayList<Servicio> listarServiciosAfectados(int idIncidencia) {
        ArrayList<Servicio> lista = new ArrayList<>();
        String sql = "SELECT DISTINCT sv.id_servicio, sv.capacidad_asignada, sv.estado, "
                   + "       r.id_ruta, r.nombre AS ruta, "
                   + "       c.id_cliente, c.nombre AS cliente "
                   + "FROM segmentos_has_incidencias si "
                   + "JOIN ruta_segmentos rsg ON si.id_segmento  = rsg.id_segmento "
                   + "JOIN servicios sv       ON rsg.id_ruta     = sv.id_ruta "
                   + "JOIN rutas r            ON sv.id_ruta      = r.id_ruta "
                   + "JOIN solicitudes so     ON sv.id_solicitud = so.id_solicitud "
                   + "JOIN clientes c         ON so.id_cliente   = c.id_cliente "
                   + "WHERE si.id_incidencia = ? "
                   + "  AND sv.estado = 'Activo' "
                   + "ORDER BY sv.id_servicio";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idIncidencia);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    lista.add(fetchServicio(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    public ArrayList<Servicio> listarServiciosPorSegmentos(ArrayList<Integer> idsSegmentos) {
        ArrayList<Servicio> lista = new ArrayList<>();
        ArrayList<Integer> yaAgregados = new ArrayList<>();

        String sql = "SELECT sv.id_servicio, sv.capacidad_asignada, sv.estado, "
                   + "       r.id_ruta, r.nombre AS ruta, "
                   + "       c.id_cliente, c.nombre AS cliente "
                   + "FROM ruta_segmentos rsg "
                   + "JOIN servicios sv       ON rsg.id_ruta     = sv.id_ruta "
                   + "JOIN rutas r            ON sv.id_ruta      = r.id_ruta "
                   + "JOIN solicitudes so     ON sv.id_solicitud = so.id_solicitud "
                   + "JOIN clientes c         ON so.id_cliente   = c.id_cliente "
                   + "WHERE rsg.id_segmento = ? AND sv.estado = 'Activo' "
                   + "ORDER BY sv.id_servicio";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            for (int idSegmento : idsSegmentos) {
                pstmt.setInt(1, idSegmento);
                try (ResultSet rs = pstmt.executeQuery()) {
                    while (rs.next()) {
                        Servicio servicio = fetchServicio(rs);
                        if (!yaAgregados.contains(servicio.getIdServicio())) {
                            yaAgregados.add(servicio.getIdServicio());
                            lista.add(servicio);
                        }
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    private Servicio fetchServicio(ResultSet rs) throws SQLException {
        Cliente cliente = new Cliente();
        cliente.setIdCliente(rs.getInt("id_cliente"));
        cliente.setNombre(rs.getString("cliente"));

        Solicitud solicitud = new Solicitud();
        solicitud.setCliente(cliente);

        Ruta ruta = new Ruta();
        ruta.setIdRuta(rs.getInt("id_ruta"));
        ruta.setNombre(rs.getString("ruta"));

        Servicio servicio = new Servicio();
        servicio.setIdServicio(rs.getInt("id_servicio"));
        servicio.setCapacidadAsignada(rs.getInt("capacidad_asignada"));
        servicio.setEstado(rs.getString("estado"));
        servicio.setRuta(ruta);
        servicio.setSolicitud(solicitud);
        return servicio;
    }
}
