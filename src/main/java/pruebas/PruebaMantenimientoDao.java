
package pruebas;

import beans.maintenance.Mantenimiento;
import daos.BaseDao;
import daos.manteinance.MantenimientoDao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.UUID;

public class PruebaMantenimientoDao {

  public static void main(String[] args) {

    MantenimientoDao dao = new MantenimientoDao();
    BaseDao baseDao = new BaseDao();

    try {
      System.out.println("=== PRUEBA DEL CRUD DE MANTENIMIENTOS ===");

      // 1. Obtener IDs válidos para las claves foráneas
      int idUsuario = obtenerPrimerId(
        baseDao, "SELECT id_usuario FROM usuarios ORDER BY id_usuario LIMIT 1");

      int idSegmento = obtenerPrimerId(
        baseDao, "SELECT id_segmento FROM segmentos ORDER BY id_segmento LIMIT 1");

      System.out.println("Usuario de prueba: " + idUsuario);
      System.out.println("Segmento de prueba: " + idSegmento);

      // 2. CREATE: crear un mantenimiento de prueba
      String identificador = UUID.randomUUID().toString()
        .substring(0, 8);

      String descripcion = "PRUEBA DAO " + identificador;

      LocalDateTime inicio = LocalDateTime.now()
        .plusDays(7)
        .withSecond(0)
        .withNano(0);

      Mantenimiento nuevo = new Mantenimiento();
      nuevo.setIdUsuario(idUsuario);
      nuevo.setIdSegmento(idSegmento);
      nuevo.setTipo("Preventivo");
      nuevo.setPrioridad("Alta");
      nuevo.setFechaInicio(inicio);
      nuevo.setFechaFin(inicio.plusHours(3));
      nuevo.setDescripcionGeneral(descripcion);

      boolean creado = dao.crearMantenimiento(nuevo);

      if (!creado) {
        throw new IllegalStateException(
          "No se pudo crear el mantenimiento.");
      }

      System.out.println("\n[OK] CREATE: mantenimiento creado.");

      // 3. READ: localizar el registro recién creado
      ArrayList<Mantenimiento> historial = dao.listarHistorial();

      Mantenimiento mantenimiento = null;

      for (Mantenimiento m : historial) {
        if (descripcion.equals(m.getDescripcionGeneral())) {
          mantenimiento = m;
          break;
        }
      }

      if (mantenimiento == null) {
        throw new IllegalStateException(
          "El registro creado no aparece en el historial.");
      }

      int id = mantenimiento.getIdMantenimiento();

      System.out.println("[OK] READ: mantenimiento recuperado.");
      System.out.println("ID generado por MySQL: " + id);
      imprimir(mantenimiento);

      // 4. UPDATE: modificar la prioridad y la descripción
      mantenimiento.setPrioridad("Crítica");
      mantenimiento.setDescripcionGeneral(
        descripcion + " - ACTUALIZADO");

      boolean actualizado =
        dao.actualizarMantenimiento(mantenimiento);

      if (!actualizado) {
        throw new IllegalStateException(
          "No se pudo actualizar el mantenimiento.");
      }

      Mantenimiento actualizadoDesdeBD =
        dao.obtenerMantenimiento(id);

      if (actualizadoDesdeBD == null
        || !"Crítica".equals(
        actualizadoDesdeBD.getPrioridad())
        || !(descripcion + " - ACTUALIZADO").equals(
        actualizadoDesdeBD.getDescripcionGeneral())) {

        throw new IllegalStateException(
          "La verificación del UPDATE falló.");
      }

      System.out.println("\n[OK] UPDATE: cambios guardados en MySQL.");
      imprimir(actualizadoDesdeBD);

      // 5. DELETE lógico: cancelar el mantenimiento
      boolean cancelado = dao.cancelarMantenimiento(id);

      if (!cancelado) {
        throw new IllegalStateException(
          "No se pudo cancelar el mantenimiento.");
      }

      System.out.println("\n[OK] DELETE LÓGICO: estado cambiado a Cancelado.");

      // 6. Verificar que ya no aparece en la lista normal
      boolean apareceEnListaNormal = false;

      for (Mantenimiento m : dao.listarMantenimientos()) {
        if (m.getIdMantenimiento() == id) {
          apareceEnListaNormal = true;
          break;
        }
      }

      if (apareceEnListaNormal) {
        throw new IllegalStateException(
          "El mantenimiento cancelado sigue en la lista normal.");
      }

      System.out.println("[OK] No aparece en la lista normal.");

      // 7. Verificar que permanece en el historial
      Mantenimiento registroHistorial =
        dao.obtenerMantenimiento(id);

      if (registroHistorial == null
        || !"Cancelado".equals(registroHistorial.getEstado())) {

        throw new IllegalStateException(
          "El mantenimiento cancelado no se conserva correctamente.");
      }

      System.out.println("[OK] El registro permanece en el historial.");
      imprimir(registroHistorial);

      System.out.println("\n=== TODAS LAS PRUEBAS FINALIZARON CORRECTAMENTE ===");

    } catch (Exception e) {
      System.out.println("\n[ERROR] La prueba no se completó.");
      e.printStackTrace();
    }
  }

  private static int obtenerPrimerId(BaseDao baseDao, String sql)
    throws SQLException {

    try (Connection conn = baseDao.getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql);
         ResultSet rs = pstmt.executeQuery()) {

      if (rs.next()) {
        return rs.getInt(1);
      }

      throw new IllegalStateException(
        "No hay registros disponibles para una clave foránea. "
          + "Revisa la tabla correspondiente.");
    }
  }

  private static void imprimir(Mantenimiento m) {
    System.out.println("  ID: " + m.getIdMantenimiento());
    System.out.println("  Tipo: " + m.getTipo());
    System.out.println("  Prioridad: " + m.getPrioridad());
    System.out.println("  Estado: " + m.getEstado());
    System.out.println("  Inicio: " + m.getFechaInicio());
    System.out.println("  Fin: " + m.getFechaFin());
    System.out.println("  Descripción: " + m.getDescripcionGeneral());
  }
}

