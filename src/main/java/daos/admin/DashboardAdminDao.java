package daos.admin;

import beans.admin.DashboardItem;
import daos.BaseDao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class DashboardAdminDao extends BaseDao {

  public Map<String, Object> obtenerResumenPlataforma() {
    Map<String, Object> resumen = new HashMap<>();

    resumen.put("totalUsuarios", 0);
    resumen.put("usuariosActivos", 0);
    resumen.put("usuariosInactivos", 0);
    resumen.put("totalRoles", 0);

    resumen.put("totalLandings", 0);
    resumen.put("landingsActivas", 0);
    resumen.put("landingsInactivas", 0);

    resumen.put("totalSegmentos", 0);
    resumen.put("segmentosOperativos", 0);
    resumen.put("segmentosNoOperativos", 0);
    resumen.put("porcentajeOperativo", 100.0);

    resumen.put("capacidadTotal", 0L);
    resumen.put("capacidadOcupada", 0L);
    resumen.put("capacidadReservada", 0L);
    resumen.put("capacidadDisponible", 0L);
    resumen.put("porcentajeUso", 0.0);

    String sqlUsuarios = "SELECT " +
      "COUNT(*) AS total, " +
      "COALESCE(SUM(CASE WHEN estado = 'activo' THEN 1 ELSE 0 END), 0) AS activos, " +
      "COALESCE(SUM(CASE WHEN estado = 'inactivo' THEN 1 ELSE 0 END), 0) AS inactivos " +
      "FROM usuarios";

    String sqlRoles = "SELECT COUNT(*) AS total FROM roles_usuario";

    String sqlLandings = "SELECT " +
      "COUNT(*) AS total, " +
      "COALESCE(SUM(CASE WHEN estado = 'Activa' THEN 1 ELSE 0 END), 0) AS activas, " +
      "COALESCE(SUM(CASE WHEN estado = 'Inactiva' THEN 1 ELSE 0 END), 0) AS inactivas " +
      "FROM landingstation";

    String sqlSegmentos = "SELECT " +
      "COUNT(*) AS total, " +
      "COALESCE(SUM(CASE WHEN estado = 'Operativo' THEN 1 ELSE 0 END), 0) AS operativos, " +
      "COALESCE(SUM(CASE WHEN estado <> 'Operativo' THEN 1 ELSE 0 END), 0) AS no_operativos, " +
      "COALESCE(SUM(capacidad_total), 0) AS cap_total, " +
      "COALESCE(SUM(capacidad_ocupada), 0) AS cap_ocupada, " +
      "COALESCE(SUM(capacidad_reservada), 0) AS cap_reservada " +
      "FROM segmentos";

    try (Connection conn = getConnection()) {

      try (PreparedStatement ps = conn.prepareStatement(sqlUsuarios);
           ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          resumen.put("totalUsuarios", rs.getInt("total"));
          resumen.put("usuariosActivos", rs.getInt("activos"));
          resumen.put("usuariosInactivos", rs.getInt("inactivos"));
        }
      }

      try (PreparedStatement ps = conn.prepareStatement(sqlRoles);
           ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          resumen.put("totalRoles", rs.getInt("total"));
        }
      }

      try (PreparedStatement ps = conn.prepareStatement(sqlLandings);
           ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          resumen.put("totalLandings", rs.getInt("total"));
          resumen.put("landingsActivas", rs.getInt("activas"));
          resumen.put("landingsInactivas", rs.getInt("inactivas"));
        }
      }

      try (PreparedStatement ps = conn.prepareStatement(sqlSegmentos);
           ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          int totalSeg = rs.getInt("total");
          int segOp = rs.getInt("operativos");
          int segNoOp = rs.getInt("no_operativos");
          long capTotal = rs.getLong("cap_total");
          long capOcupada = rs.getLong("cap_ocupada");
          long capReservada = rs.getLong("cap_reservada");
          long capDisponible = Math.max(0L, capTotal - capOcupada - capReservada);
          double porcentajeUso = capTotal > 0 ? ((capOcupada + capReservada) * 100.0) / capTotal : 0.0;
          double porcentajeOperativo = totalSeg > 0 ? (segOp * 100.0) / totalSeg : 100.0;

          resumen.put("totalSegmentos", totalSeg);
          resumen.put("segmentosOperativos", segOp);
          resumen.put("segmentosNoOperativos", segNoOp);
          resumen.put("porcentajeOperativo", porcentajeOperativo);
          resumen.put("capacidadTotal", capTotal);
          resumen.put("capacidadOcupada", capOcupada);
          resumen.put("capacidadReservada", capReservada);
          resumen.put("capacidadDisponible", capDisponible);
          resumen.put("porcentajeUso", porcentajeUso);
        }
      }

    } catch (SQLException e) {
      e.printStackTrace();
    }

    return resumen;
  }

  public ArrayList<DashboardItem> listarTopSegmentos(int limite) {
    ArrayList<DashboardItem> lista = new ArrayList<>();
    String sql = "SELECT s.codigo, s.capacidad_total, s.capacidad_ocupada, s.capacidad_reservada, s.estado, " +
      "l1.ciudad AS origen, l2.ciudad AS destino " +
      "FROM segmentos s " +
      "JOIN landingstation l1 ON s.id_landing_inicial = l1.id_landing " +
      "JOIN landingstation l2 ON s.id_landing_final = l2.id_landing " +
      "ORDER BY (s.capacidad_ocupada + s.capacidad_reservada) DESC, s.capacidad_total DESC, s.id_segmento ASC " +
      "LIMIT ?";

    try (Connection conn = getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
      ps.setInt(1, limite);
      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          DashboardItem item = new DashboardItem();
          item.setCodigo(rs.getString("codigo"));
          item.setCapacidadTotal(rs.getLong("capacidad_total"));
          item.setCapacidadOcupada(rs.getLong("capacidad_ocupada"));
          item.setCapacidadReservada(rs.getLong("capacidad_reservada"));
          item.setEstado(rs.getString("estado"));
          item.setTramo(rs.getString("origen") + " -> " + rs.getString("destino"));
          lista.add(item);
        }
      }
    } catch (SQLException e) {
      e.printStackTrace();
    }
    return lista;
  }

  public ArrayList<DashboardItem> listarUltimosUsuarios(int limite) {
    ArrayList<DashboardItem> lista = new ArrayList<>();
    String sql = "SELECT u.id_usuario, u.nombre, u.correo, u.estado, r.nombre AS rol " +
      "FROM usuarios u " +
      "JOIN roles_usuario r ON u.id_rol = r.id_rol " +
      "ORDER BY u.id_usuario DESC " +
      "LIMIT ?";

    try (Connection conn = getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
      ps.setInt(1, limite);
      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          DashboardItem item = new DashboardItem();
          item.setIdUsuario(rs.getInt("id_usuario"));
          item.setNombre(rs.getString("nombre"));
          item.setCorreo(rs.getString("correo"));
          item.setRol(rs.getString("rol"));
          item.setEstado(rs.getString("estado"));
          lista.add(item);
        }
      }
    } catch (SQLException e) {
      e.printStackTrace();
    }
    return lista;
  }

  public ArrayList<DashboardItem> listarUltimaInfraestructura() {
    ArrayList<DashboardItem> lista = new ArrayList<>();

    String sqlSeg = "SELECT s.codigo, s.capacidad_total, s.estado, l1.ciudad AS orig, l2.ciudad AS dest " +
      "FROM segmentos s " +
      "JOIN landingstation l1 ON s.id_landing_inicial = l1.id_landing " +
      "JOIN landingstation l2 ON s.id_landing_final = l2.id_landing " +
      "ORDER BY s.id_segmento DESC LIMIT 2";

    String sqlLs = "SELECT nombre, pais, ciudad, estado " +
      "FROM landingstation " +
      "ORDER BY id_landing DESC LIMIT 2";

    try (Connection conn = getConnection()) {
      try (PreparedStatement ps = conn.prepareStatement(sqlSeg);
           ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          DashboardItem item = new DashboardItem();
          item.setEstructura("Segmento " + rs.getString("codigo"));
          item.setTipo("Fibra submarina");
          item.setDetalle(rs.getString("orig") + " -> " + rs.getString("dest") + " (" + rs.getInt("capacidad_total") + " Gbps)");
          item.setEstado(rs.getString("estado"));
          lista.add(item);
        }
      }

      try (PreparedStatement ps = conn.prepareStatement(sqlLs);
           ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          DashboardItem item = new DashboardItem();
          item.setEstructura(rs.getString("nombre"));
          item.setTipo("Landing Station");
          item.setDetalle(rs.getString("pais") + " (" + rs.getString("ciudad") + ")");
          item.setEstado(rs.getString("estado"));
          lista.add(item);
        }
      }
    } catch (SQLException e) {
      e.printStackTrace();
    }

    return lista;
  }
}
