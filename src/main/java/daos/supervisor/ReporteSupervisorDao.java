package daos.supervisor;

import beans.supervisor.ReporteSupervisor;
import daos.BaseDao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ReporteSupervisorDao extends BaseDao {

  public List<String> listarCodigosSegmentos() {
    List<String> codigos = new ArrayList<>();
    String sql = "SELECT codigo FROM segmentos ORDER BY codigo";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql);
         ResultSet rs = pstmt.executeQuery()) {

      while (rs.next()) {
        codigos.add(rs.getString("codigo"));
      }
    } catch (SQLException e) {
      e.printStackTrace();
    }
    return codigos;
  }

  public List<String> listarNombresClientes() {
    List<String> clientes = new ArrayList<>();
    String sql = "SELECT nombre FROM clientes ORDER BY nombre";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql);
         ResultSet rs = pstmt.executeQuery()) {

      while (rs.next()) {
        clientes.add(rs.getString("nombre"));
      }
    } catch (SQLException e) {
      e.printStackTrace();
    }
    return clientes;
  }

  public String[] obtenerEncabezados(String tipo) {
    if (tipo == null) tipo = "capacidad";
    switch (tipo) {
      case "incidencias":
        return new String[]{"Código", "Título", "Segmento(s)", "Severidad", "Estado", "Fecha Registro"};
      case "mantenimientos":
        return new String[]{"ID", "Segmento", "Tipo", "Prioridad", "Estado", "Inicio / Fin"};
      case "clientes_servicios":
        return new String[]{"Cliente (RUC)", "Origen -> Destino", "Ruta", "Capacidad", "Estado", "Fecha"};
      case "consolidado":
        return new String[]{"Módulo", "Indicador Clave", "Valor Actual", "Estado / Alerta", "Detalle", "Impacto / Alcance"};
      case "capacidad":
      default:
        return new String[]{"Código", "Origen -> Destino", "Cap. Total", "Ocupada / Reservada", "Disponible (% Uso)", "Estado"};
    }
  }

  public List<ReporteSupervisor> generarReporte(String tipo, String desde, String hasta,
                                                String segmento, String cliente,
                                                String severidad, String estado) {
    if (tipo == null || tipo.isBlank()) {
      tipo = "capacidad";
    }
    switch (tipo) {
      case "incidencias":
        return consultarIncidencias(desde, hasta, segmento, severidad, estado);
      case "mantenimientos":
        return consultarMantenimientos(desde, hasta, segmento, severidad, estado);
      case "clientes_servicios":
        return consultarClientesServicios(desde, hasta, cliente, estado);
      case "consolidado":
        return consultarConsolidado();
      case "capacidad":
      default:
        return consultarCapacidadSegmentos(segmento, estado);
    }
  }

  private List<ReporteSupervisor> consultarCapacidadSegmentos(String segmento, String estado) {
    List<ReporteSupervisor> lista = new ArrayList<>();
    boolean filtrarSegmento = segmento != null && !segmento.isBlank() && !"Todos".equalsIgnoreCase(segmento);
    boolean filtrarEstado = estado != null && !estado.isBlank() && !"Todos".equalsIgnoreCase(estado);

    String sql = "SELECT s.codigo, l1.nombre AS origen, l2.nombre AS destino, "
      + "       s.capacidad_total, s.capacidad_ocupada, s.capacidad_reservada, s.estado "
      + "FROM segmentos s "
      + "JOIN landingstation l1 ON s.id_landing_inicial = l1.id_landing "
      + "JOIN landingstation l2 ON s.id_landing_final = l2.id_landing "
      + "WHERE 1 = 1 ";
    if (filtrarSegmento) sql += "AND s.codigo = ? ";
    if (filtrarEstado) sql += "AND s.estado = ? ";
    sql += "ORDER BY s.codigo";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      int idx = 1;
      if (filtrarSegmento) pstmt.setString(idx++, segmento);
      if (filtrarEstado) pstmt.setString(idx++, estado);

      try (ResultSet rs = pstmt.executeQuery()) {
        while (rs.next()) {
          long total = rs.getLong("capacidad_total");
          long ocupada = rs.getLong("capacidad_ocupada");
          long reservada = rs.getLong("capacidad_reservada");
          long disponible = total - ocupada - reservada;
          double pct = total > 0 ? ((ocupada + reservada) * 100.0 / total) : 0.0;

          ReporteSupervisor r = new ReporteSupervisor();
          r.setCol1(rs.getString("codigo"));
          r.setCol2(rs.getString("origen") + " -> " + rs.getString("destino"));
          r.setCol3(total + " Gbps");
          r.setCol4(ocupada + " / " + reservada + " Gbps");
          r.setCol5(disponible + " Gbps (" + String.format("%.1f", pct) + "%)");
          r.setCol6(rs.getString("estado"));
          lista.add(r);
        }
      }
    } catch (SQLException e) {
      e.printStackTrace();
    }
    return lista;
  }

  private List<ReporteSupervisor> consultarIncidencias(String desde, String hasta, String segmento,
                                                       String severidad, String estado) {
    List<ReporteSupervisor> lista = new ArrayList<>();
    boolean filtrarDesde = desde != null && !desde.isBlank();
    boolean filtrarHasta = hasta != null && !hasta.isBlank();
    boolean filtrarSegmento = segmento != null && !segmento.isBlank() && !"Todos".equalsIgnoreCase(segmento);
    boolean filtrarSeveridad = severidad != null && !severidad.isBlank() && !"Todas".equalsIgnoreCase(severidad);
    boolean filtrarEstado = estado != null && !estado.isBlank() && !"Todos".equalsIgnoreCase(estado);

    String sql = "SELECT i.codigo, i.titulo, i.severidad, i.estado, "
      + "       DATE_FORMAT(i.fecha_registro, '%d/%m/%Y %H:%i') AS f_reg, "
      + "       COALESCE(GROUP_CONCAT(DISTINCT s.codigo SEPARATOR ', '), 'Sin segmento') AS segs "
      + "FROM incidencias i "
      + "LEFT JOIN segmentos_has_incidencias si ON i.id_incidencia = si.id_incidencia "
      + "LEFT JOIN segmentos s ON si.id_segmento = s.id_segmento "
      + "WHERE 1 = 1 ";

    if (filtrarDesde) sql += "AND DATE(i.fecha_registro) >= ? ";
    if (filtrarHasta) sql += "AND DATE(i.fecha_registro) <= ? ";
    if (filtrarSeveridad) sql += "AND i.severidad = ? ";
    if (filtrarEstado) sql += "AND i.estado = ? ";
    if (filtrarSegmento) {
      sql += "AND EXISTS (SELECT 1 FROM segmentos_has_incidencias si2 "
        + "            JOIN segmentos s2 ON si2.id_segmento = s2.id_segmento "
        + "            WHERE si2.id_incidencia = i.id_incidencia AND s2.codigo = ?) ";
    }
    sql += "GROUP BY i.id_incidencia ORDER BY i.fecha_registro DESC";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      int idx = 1;
      if (filtrarDesde) pstmt.setString(idx++, desde);
      if (filtrarHasta) pstmt.setString(idx++, hasta);
      if (filtrarSeveridad) pstmt.setString(idx++, severidad);
      if (filtrarEstado) pstmt.setString(idx++, estado);
      if (filtrarSegmento) pstmt.setString(idx++, segmento);

      try (ResultSet rs = pstmt.executeQuery()) {
        while (rs.next()) {
          ReporteSupervisor r = new ReporteSupervisor();
          r.setCol1(rs.getString("codigo"));
          r.setCol2(rs.getString("titulo"));
          r.setCol3(rs.getString("segs"));
          r.setCol4(rs.getString("severidad"));
          r.setCol5(rs.getString("estado"));
          r.setCol6(rs.getString("f_reg"));
          lista.add(r);
        }
      }
    } catch (SQLException e) {
      e.printStackTrace();
    }
    return lista;
  }

  private List<ReporteSupervisor> consultarMantenimientos(String desde, String hasta, String segmento,
                                                          String severidad, String estado) {
    List<ReporteSupervisor> lista = new ArrayList<>();
    boolean filtrarDesde = desde != null && !desde.isBlank();
    boolean filtrarHasta = hasta != null && !hasta.isBlank();
    boolean filtrarSegmento = segmento != null && !segmento.isBlank() && !"Todos".equalsIgnoreCase(segmento);
    boolean filtrarPrioridad = severidad != null && !severidad.isBlank() && !"Todas".equalsIgnoreCase(severidad);
    boolean filtrarEstado = estado != null && !estado.isBlank() && !"Todos".equalsIgnoreCase(estado);

    String sql = "SELECT m.id_mantenimiento, s.codigo AS seg, m.tipo, m.prioridad, m.estado, "
      + "       DATE_FORMAT(m.fecha_inicio, '%d/%m/%Y') AS f_ini, "
      + "       DATE_FORMAT(m.fecha_fin, '%d/%m/%Y') AS f_fin "
      + "FROM mantenimientos m "
      + "JOIN segmentos s ON m.id_segmento = s.id_segmento "
      + "WHERE 1 = 1 ";

    if (filtrarDesde) sql += "AND DATE(m.fecha_inicio) >= ? ";
    if (filtrarHasta) sql += "AND DATE(m.fecha_inicio) <= ? ";
    if (filtrarSegmento) sql += "AND s.codigo = ? ";
    if (filtrarPrioridad) sql += "AND m.prioridad = ? ";
    if (filtrarEstado) sql += "AND m.estado = ? ";
    sql += "ORDER BY m.fecha_inicio DESC";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      int idx = 1;
      if (filtrarDesde) pstmt.setString(idx++, desde);
      if (filtrarHasta) pstmt.setString(idx++, hasta);
      if (filtrarSegmento) pstmt.setString(idx++, segmento);
      if (filtrarPrioridad) pstmt.setString(idx++, severidad);
      if (filtrarEstado) pstmt.setString(idx++, estado);

      try (ResultSet rs = pstmt.executeQuery()) {
        while (rs.next()) {
          ReporteSupervisor r = new ReporteSupervisor();
          r.setCol1("MNT-" + rs.getInt("id_mantenimiento"));
          r.setCol2(rs.getString("seg"));
          r.setCol3(rs.getString("tipo"));
          r.setCol4(rs.getString("prioridad"));
          r.setCol5(rs.getString("estado"));
          r.setCol6(rs.getString("f_ini") + " al " + rs.getString("f_fin"));
          lista.add(r);
        }
      }
    } catch (SQLException e) {
      e.printStackTrace();
    }
    return lista;
  }
  private List<ReporteSupervisor> consultarClientesServicios(String desde, String hasta,
                                                             String cliente, String estado) {
    List<ReporteSupervisor> lista = new ArrayList<>();
    boolean filtrarDesde = desde != null && !desde.isBlank();
    boolean filtrarHasta = hasta != null && !hasta.isBlank();
    boolean filtrarCliente = cliente != null && !cliente.isBlank() && !"Todos".equalsIgnoreCase(cliente);
    boolean filtrarEstado = estado != null && !estado.isBlank() && !"Todos".equalsIgnoreCase(estado);

    String sql = "SELECT c.nombre AS cliente, c.ruc, l1.nombre AS origen, l2.nombre AS destino, "
      + "       COALESCE(ru.nombre, 'Por asignar') AS ruta, "
      + "       sol.capacidad_solicitada, sol.estado, "
      + "       DATE_FORMAT(sol.fecha_registro, '%d/%m/%Y') AS f_reg "
      + "FROM solicitudes sol "
      + "JOIN clientes c ON sol.id_cliente = c.id_cliente "
      + "JOIN landingstation l1 ON sol.id_landing_origen = l1.id_landing "
      + "JOIN landingstation l2 ON sol.id_landing_destino = l2.id_landing "
      + "LEFT JOIN servicios srv ON sol.id_solicitud = srv.id_solicitud "
      + "LEFT JOIN rutas ru ON srv.id_ruta = ru.id_ruta "
      + "WHERE 1 = 1 ";

    if (filtrarDesde) sql += "AND DATE(sol.fecha_registro) >= ? ";
    if (filtrarHasta) sql += "AND DATE(sol.fecha_registro) <= ? ";
    if (filtrarCliente) sql += "AND c.nombre = ? ";
    if (filtrarEstado) sql += "AND sol.estado = ? ";
    sql += "ORDER BY sol.fecha_registro DESC";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      int idx = 1;
      if (filtrarDesde) pstmt.setString(idx++, desde);
      if (filtrarHasta) pstmt.setString(idx++, hasta);
      if (filtrarCliente) pstmt.setString(idx++, cliente);
      if (filtrarEstado) pstmt.setString(idx++, estado);

      try (ResultSet rs = pstmt.executeQuery()) {
        while (rs.next()) {
          ReporteSupervisor r = new ReporteSupervisor();
          r.setCol1(rs.getString("cliente") + " (" + rs.getString("ruc") + ")");
          r.setCol2(rs.getString("origen") + " -> " + rs.getString("destino"));
          r.setCol3(rs.getString("ruta"));
          r.setCol4(rs.getLong("capacidad_solicitada") + " Gbps");
          r.setCol5(rs.getString("estado"));
          r.setCol6(rs.getString("f_reg"));
          lista.add(r);
        }
      }
    } catch (SQLException e) {
      e.printStackTrace();
    }
    return lista;
  }

  private List<ReporteSupervisor> consultarConsolidado() {
    List<ReporteSupervisor> lista = new ArrayList<>();
    String sql = "SELECT "
      + "(SELECT COUNT(*) FROM segmentos) AS total_seg, "
      + "(SELECT COUNT(*) FROM segmentos WHERE estado = 'Operativo') AS seg_op, "
      + "(SELECT COUNT(*) FROM landingstation WHERE estado = 'Operativa') AS ls_op, "
      + "(SELECT COALESCE(SUM(capacidad_total), 0) FROM segmentos) AS cap_tot, "
      + "(SELECT COALESCE(SUM(capacidad_ocupada + capacidad_reservada), 0) FROM segmentos) AS cap_uso, "
      + "(SELECT COUNT(*) FROM segmentos WHERE capacidad_total > 0 "
      + "   AND ((capacidad_ocupada + capacidad_reservada) * 100.0 / capacidad_total) >= 80) AS seg_alerta, "
      + "(SELECT COUNT(*) FROM incidencias WHERE estado <> 'Cerrada') AS inc_activas, "
      + "(SELECT COUNT(DISTINCT si.id_segmento) FROM segmentos_has_incidencias si "
      + "   JOIN incidencias i ON si.id_incidencia = i.id_incidencia "
      + "   WHERE i.estado <> 'Cerrada') AS seg_afectados, "
      + "(SELECT COUNT(*) FROM mantenimientos WHERE estado IN ('Programado', 'En ejecucion')) AS mnt_pend, "
      + "(SELECT COUNT(DISTINCT id_segmento) FROM mantenimientos "
      + "   WHERE estado IN ('Programado', 'En ejecucion')) AS seg_mnt, "
      + "(SELECT COUNT(*) FROM servicios WHERE estado = 'Activo') AS srv_activos, "
      + "(SELECT COALESCE(SUM(capacidad_asignada), 0) FROM servicios WHERE estado = 'Activo') AS cap_srv";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql);
         ResultSet rs = pstmt.executeQuery()) {

      if (rs.next()) {
        long capTot = rs.getLong("cap_tot");
        long capUso = rs.getLong("cap_uso");
        double pct = capTot > 0 ? (capUso * 100.0 / capTot) : 0.0;
        int incActivas = rs.getInt("inc_activas");
        int mntPend = rs.getInt("mnt_pend");
        int srvActivos = rs.getInt("srv_activos");

        ReporteSupervisor r1 = new ReporteSupervisor();
        r1.setCol1("Infraestructura");
        r1.setCol2("Segmentos Operativos");
        r1.setCol3(rs.getInt("seg_op") + " de " + rs.getInt("total_seg"));
        r1.setCol4(rs.getInt("seg_op") == rs.getInt("total_seg") ? "Óptimo" : "Con degradación");
        r1.setCol5("Red submarina");
        r1.setCol6(rs.getInt("ls_op") + " Landing Stations activas");
        lista.add(r1);

        ReporteSupervisor r2 = new ReporteSupervisor();
        r2.setCol1("Capacidad");
        r2.setCol2("Utilización Global de Red");
        r2.setCol3(capUso + " / " + capTot + " Gbps (" + String.format("%.1f", pct) + "%)");
        r2.setCol4(pct > 95 ? "Crítica" : (pct >= 80 ? "Alta" : "Normal"));
        r2.setCol5("Disponible: " + (capTot - capUso) + " Gbps");
        r2.setCol6(rs.getInt("seg_alerta") + " segmento(s) >= 80% uso");
        lista.add(r2);

        ReporteSupervisor r3 = new ReporteSupervisor();
        r3.setCol1("Incidencias");
        r3.setCol2("Incidencias Activas");
        r3.setCol3(String.valueOf(incActivas));
        r3.setCol4(incActivas > 0 ? "En seguimiento" : "Sin alertas");
        r3.setCol5("No cerradas");
        r3.setCol6(rs.getInt("seg_afectados") + " segmento(s) afectado(s)");
        lista.add(r3);

        ReporteSupervisor r4 = new ReporteSupervisor();
        r4.setCol1("Mantenimiento");
        r4.setCol2("Mantenimientos Programados / En curso");
        r4.setCol3(String.valueOf(mntPend));
        r4.setCol4(mntPend > 0 ? "Planificado" : "Sin pendientes");
        r4.setCol5("Preventivos y correctivos");
        r4.setCol6(rs.getInt("seg_mnt") + " segmento(s) intervenido(s)");
        lista.add(r4);

        ReporteSupervisor r5 = new ReporteSupervisor();
        r5.setCol1("Comercial");
        r5.setCol2("Servicios Empresariales Activos");
        r5.setCol3(String.valueOf(srvActivos));
        r5.setCol4(srvActivos > 0 ? "Operando" : "Sin servicios");
        r5.setCol5("Clientes conectados");
        r5.setCol6(rs.getLong("cap_srv") + " Gbps contratados");
        lista.add(r5);
      }
    } catch (SQLException e) {
      e.printStackTrace();
    }
    return lista;
  }
}
