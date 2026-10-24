
package beans.maintenance;

import java.time.LocalDateTime;

public class Mantenimiento {

  private int idMantenimiento;
  private int idUsuario;
  private int idSegmento;

  private String tipo;
  private String prioridad;
  private String estado;

  private LocalDateTime fechaInicio;
  private LocalDateTime fechaFin;

  private String descripcionGeneral;

  // Getters y Setters

  public int getIdMantenimiento() {
    return idMantenimiento;
  }

  public void setIdMantenimiento(int idMantenimiento) {
    this.idMantenimiento = idMantenimiento;
  }

  public int getIdUsuario() {
    return idUsuario;
  }

  public void setIdUsuario(int idUsuario) {
    this.idUsuario = idUsuario;
  }

  public int getIdSegmento() {
    return idSegmento;
  }

  public void setIdSegmento(int idSegmento) {
    this.idSegmento = idSegmento;
  }

  public String getTipo() {
    return tipo;
  }

  public void setTipo(String tipo) {
    this.tipo = tipo;
  }

  public String getPrioridad() {
    return prioridad;
  }

  public void setPrioridad(String prioridad) {
    this.prioridad = prioridad;
  }

  public String getEstado() {
    return estado;
  }

  public void setEstado(String estado) {
    this.estado = estado;
  }

  public LocalDateTime getFechaInicio() {
    return fechaInicio;
  }

  public void setFechaInicio(LocalDateTime fechaInicio) {
    this.fechaInicio = fechaInicio;
  }

  public LocalDateTime getFechaFin() {
    return fechaFin;
  }

  public void setFechaFin(LocalDateTime fechaFin) {
    this.fechaFin = fechaFin;
  }

  public String getDescripcionGeneral() {
    return descripcionGeneral;
  }

  public void setDescripcionGeneral(String descripcionGeneral) {
    this.descripcionGeneral = descripcionGeneral;
  }
}
