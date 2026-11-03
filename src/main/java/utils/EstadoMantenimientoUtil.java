
package utils;

import beans.maintenance.Mantenimiento;

import java.time.LocalDateTime;

public class EstadoMantenimientoUtil {

  public static String calcularEstado(Mantenimiento m) {

    if ("Cancelado".equals(m.getEstado())) {
      return "Cancelado";
    }

    LocalDateTime ahora = LocalDateTime.now();

    if (m.getFechaInicio() == null ||
      m.getFechaFin() == null) {
      return m.getEstado();
    }

    if (ahora.isBefore(m.getFechaInicio())) {
      return "Programado";
    }

    if (ahora.isBefore(m.getFechaFin())) {
      return "En ejecucion";
    }

    return "Finalizado";
  }

  public static String mostrarEstado(String estado) {

    if ("En ejecucion".equals(estado)) {
      return "En ejecución";
    }

    return estado;
  }
}
