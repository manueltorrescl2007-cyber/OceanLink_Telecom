package daos.manteinance;

import beans.maintenance.ServicioAfectado;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.LinkedHashMap;
import java.util.Map;

public class ServiciosAfectadosDao extends daos.BaseDao {

  public List<ServicioAfectado> listarServiciosAfectados(
    Integer idCliente,
    Integer idSegmento
  ) {

    List<ServicioAfectado> servicios = new ArrayList<>();

    StringBuilder sql = new StringBuilder("""
            SELECT
                s.id_servicio,
                c.nombre AS cliente,
                r.nombre AS ruta,
                GROUP_CONCAT(
                    DISTINCT seg.codigo
                    ORDER BY seg.codigo
                    SEPARATOR ', '
                ) AS segmentos_en_mantenimiento,
                GROUP_CONCAT(
                    DISTINCT u.nombre
                    ORDER BY u.nombre
                    SEPARATOR ', '
                ) AS usuarios_encargados

            FROM servicios s
            INNER JOIN rutas r
                ON s.id_ruta = r.id_ruta
            INNER JOIN solicitudes sol
                ON s.id_solicitud = sol.id_solicitud
            INNER JOIN clientes c
                ON sol.id_cliente = c.id_cliente
            INNER JOIN ruta_segmentos rs
                ON r.id_ruta = rs.id_ruta
            INNER JOIN segmentos seg
                ON rs.id_segmento = seg.id_segmento
            INNER JOIN mantenimientos m
                ON seg.id_segmento = m.id_segmento
            INNER JOIN usuarios u
                ON m.id_usuario = u.id_usuario

            WHERE m.estado IN ('Programado', 'En ejecucion')
              AND s.estado = 'Activo'
            """);

    // Agregar filtros solamente si el usuario los seleccionó.
    if (idCliente != null) {
      sql.append(" AND c.id_cliente = ?");
    }

    if (idSegmento != null) {
      sql.append(" AND seg.id_segmento = ?");
    }

    // Separar las condiciones del WHERE del GROUP BY.
    sql.append(" ");

    sql.append("""
        GROUP BY
            s.id_servicio,
            c.nombre,
            r.nombre
        ORDER BY s.id_servicio
        """);

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {

      int indice = 1;

      if (idCliente != null) {
        pstmt.setInt(indice++, idCliente);
      }

      if (idSegmento != null) {
        pstmt.setInt(indice++, idSegmento);
      }

      try (ResultSet rs = pstmt.executeQuery()) {

        while (rs.next()) {
          ServicioAfectado servicio = new ServicioAfectado();

          servicio.setIdServicio(rs.getInt("id_servicio"));
          servicio.setCliente(rs.getString("cliente"));
          servicio.setRuta(rs.getString("ruta"));

          servicio.setSegmentosEnMantenimiento(
            rs.getString("segmentos_en_mantenimiento")
          );

          servicio.setUsuariosEncargados(
            rs.getString("usuarios_encargados")
          );

          servicios.add(servicio);
        }
      }

    } catch (SQLException e) {
      throw new IllegalStateException(
        "Error al listar los servicios afectados", e
      );
    }

    return servicios;
  }

  public Map<Integer, String> listarClientesConServiciosAfectados() {

    Map<Integer, String> clientes = new LinkedHashMap<>();

    String sql = """
            SELECT DISTINCT
                c.id_cliente,
                c.nombre
            FROM clientes c
            INNER JOIN solicitudes sol
                ON c.id_cliente = sol.id_cliente
            INNER JOIN servicios s
                ON sol.id_solicitud = s.id_solicitud
            INNER JOIN rutas r
                ON s.id_ruta = r.id_ruta
            INNER JOIN ruta_segmentos rs
                ON r.id_ruta = rs.id_ruta
            INNER JOIN segmentos seg
                ON rs.id_segmento = seg.id_segmento
            INNER JOIN mantenimientos m
                ON seg.id_segmento = m.id_segmento
            WHERE m.estado IN ('Programado', 'En ejecucion')
              AND s.estado = 'Activo'
            ORDER BY c.nombre ASC
            """;

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql);
         ResultSet rs = pstmt.executeQuery()) {

      while (rs.next()) {
        clientes.put(
          rs.getInt("id_cliente"),
          rs.getString("nombre")
        );
      }

    } catch (SQLException e) {
      throw new IllegalStateException(
        "Error al obtener los clientes con servicios afectados", e
      );
    }

    return clientes;
  }
}
